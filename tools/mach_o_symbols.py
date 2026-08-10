#!/usr/bin/env python3
"""
mach_o_symbols.py - stdin/stdout filter making GBA data assembly link on Mach-O.

Mach-O mangles C symbols with a leading underscore (C `foo` -> asm `_foo`), and
treats any symbol starting with uppercase 'L' as a file-local label that cannot
be exported. The GBA/ELF sources assume neither. Two complementary strategies:

1. NON-'L' LABELS ARE ALIASED, NOT RENAMED.
   `foo:` keeps its bare name and gains `.globl _foo` + `_foo = foo`. Aliasing
   matters because intra-assembly references appear in macro *arguments*
   (`call MyScript`), which cannot be rewritten safely -- macro invocations also
   carry keyword arguments (`waitstate implicit=1`) that must not be touched.
   Keeping the bare name means those references keep resolving untouched.

2. 'L'-PREFIXED LABELS ARE RENAMED.
   Aliasing cannot rescue these: `.globl LilycoveCity_x` is rejected outright.
   They are renamed to `_LilycoveCity_x`, and references are rewritten -- but
   only for identifiers starting with uppercase 'L', which keeps the rewrite
   narrow enough to be safe inside macro arguments.

Pointer operands (.quad/.long/.int) additionally get external C references
prefixed, since those name C functions and data. A missed prefix surfaces as a
link-time undefined symbol, never as silent data corruption.

Also rewrites preproc's `foo: ; .global foo` output, because clang's arm64
assembler treats ';' as a comment and would silently drop the export.
"""

import re
import sys

# preproc turns `label::` into `label: ; .global label`
GLOBL_COMMENT = re.compile(
    r'^(\s*)([A-Za-z_][A-Za-z0-9_]*): ; \.global ([A-Za-z_][A-Za-z0-9_]*)\s*$')
LABEL_DEF = re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*):\s*(?:$|[^:])')
# `.equ name, value` also defines a name (song files alias voicegroups this way).
SET_DEF = re.compile(r'^\s*\.(?:set|equ|equiv)\s+([A-Za-z_][A-Za-z0-9_]*)')
GLOBL_DIR = re.compile(r'^\s*\.glob(?:a)?l\s+([A-Za-z_][A-Za-z0-9_]*)\s*$')
# Pointer-sized operands are where cross-language symbol references live.
PTR_OPERAND = re.compile(r'^(\s*\.(?:quad|long|int)\s+)(.+?)(\s*(?:/\*.*)?)$')
# Negative lookbehind for '\' leaves macro parameter references (\script) alone;
# for '.' leaves local labels (.Lfoo) and directives alone.
IDENT = re.compile(r'(?<![\\\w.])([A-Za-z_][A-Za-z0-9_]*)\b')
QUOTED = re.compile(r'"[^"]*"')


def is_constant_name(name):
    """Assembler constants are ALL_CAPS here; real symbols are mixed case."""
    return name.upper() == name


def is_local_prefixed(name):
    """Mach-O treats a leading uppercase 'L' as a file-local label."""
    return name.startswith('L') and not is_constant_name(name)


def outside_strings(text, sub):
    parts, strs = QUOTED.split(text), QUOTED.findall(text)
    fixed = [IDENT.sub(sub, p) for p in parts]
    out = []
    for i, p in enumerate(fixed):
        out.append(p)
        if i < len(strs):
            out.append(strs[i])
    return ''.join(out)


def split_statements(lines):
    """clang's arm64 assembler treats ';' as a comment, not a separator.

    GNU as accepts `enum A; enum B; enum C` on one line and runs all three;
    clang silently drops everything after the first. cpp-expanded constant
    tables arrive exactly like that, so split them onto separate lines. Text
    inside string literals is left alone.
    """
    # Deliberately narrow: only split when *every* segment is a bare
    # `macroname argument` invocation. Splitting more aggressively corrupts
    # macro bodies and makes the integrated assembler crash.
    SAFE = re.compile(r'^\s*[A-Za-z_]\w*\s+[A-Za-z_]\w*\s*$')
    out = []
    for line in lines:
        if ';' not in line or '"' in line:
            out.append(line)
            continue
        pieces = [p for p in line.rstrip('\n').split(';') if p.strip()]
        if len(pieces) > 1 and all(SAFE.match(p) for p in pieces):
            out.extend('\t' + p.strip() + '\n' for p in pieces)
        else:
            out.append(line)
    return out


def main():
    lines = sys.stdin.buffer.read().decode('utf-8', errors='replace').splitlines(True)
    # NOTE: split_statements() is correct but currently disabled. Enabling it
    # makes the cpp-expanded `enum A; enum B; ...` constant tables actually
    # execute (clang treats ';' as a comment, so today only the first runs).
    # That in turn crashes Apple clang 21's integrated assembler -- a compiler
    # bug, not malformed input -- on 5 of the 15 data files. The one symbol
    # still affected is ITEM_TM_DOUBLE_TEAM in map_events.s; see PORTING notes.
    # lines = split_statements(lines)

    # Labels defined in this stream resolve under their bare name; only
    # references that leave the file need the Mach-O underscore.
    defined = set()
    for line in lines:
        m = GLOBL_COMMENT.match(line)
        if m:
            defined.add(m.group(2)); continue
        m = LABEL_DEF.match(line)
        if m:
            defined.add(m.group(1)); continue
        m = SET_DEF.match(line)
        if m:
            defined.add(m.group(1))

    def ptr_sub(m):
        name = m.group(1)
        if name in defined or is_constant_name(name) or name.startswith('_'):
            return name
        return '_' + name

    def l_only_sub(m):
        name = m.group(1)
        if name.startswith('_') or not is_local_prefixed(name):
            return name
        return '_' + name

    out = []
    aliased = set()
    prev_was_byte = False

    def emit_alias(name):
        if name in aliased:
            return
        aliased.add(name)
        out.append('\t.globl _%s\n' % name)
        out.append('\t_%s = %s\n' % (name, name))

    for line in lines:
        stripped_line = line.strip()
        is_byte = stripped_line.startswith('.byte')
        m = GLOBL_COMMENT.match(line)
        if m and m.group(2) == m.group(3):
            indent, label = m.group(1), m.group(2)
            # 'L'-prefixed labels cannot be exported under their own name, but
            # the '_L...' alias can be -- and keeping the bare definition means
            # macro-constructed references like \name\()_Blockdata still
            # resolve, which no text filter could rewrite.
            if not is_local_prefixed(label):
                out.append('\t.globl %s\n' % label)
            out.append('%s%s:\n' % (indent, label))
            emit_alias(label)
            continue

        m = PTR_OPERAND.match(line.rstrip('\n'))
        if m:
            # An 8-byte pointer must sit on an 8-byte boundary. GBA structs put
            # them at 4-aligned offsets (struct MapConnections is `s32 count`
            # followed by a pointer), so pad first. This is a no-op wherever the
            # data is already aligned, which covers every correctly-laid-out
            # struct array, and only inserts padding where ld would reject it.
            # Every .quad here is a struct field: bytecode operands are emitted
            # as 4-byte gScriptBase-relative offsets instead, precisely because a
            # relocated 8-byte pointer would need 8-byte alignment that a packed
            # instruction stream cannot provide.
            if m.group(1).lstrip().startswith('.quad'):
                out.append('\t.balign 8\n')
            out.append(m.group(1) + outside_strings(m.group(2), ptr_sub) + m.group(3) + '\n')
            prev_was_byte = False
            continue

        m = LABEL_DEF.match(line)
        if m:
            out.append(line if line.endswith('\n') else line + '\n')
            emit_alias(m.group(1))
            continue

        if stripped_line:
            prev_was_byte = is_byte

        # Rewrite 'L'-prefixed references to the exported '_L' alias so they
        # resolve across object files. Safe within a file too, since the alias
        # points at the bare definition. Narrow enough not to disturb macro
        # keyword arguments.
        out.append(outside_strings(line if line.endswith('\n') else line + '\n',
                                   l_only_sub))

    sys.stdout.write(''.join(out))


if __name__ == '__main__':
    main()
