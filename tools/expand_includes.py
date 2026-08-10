#!/usr/bin/env python3
"""
expand_includes.py - recursively inline `.include "..."` before the Mach-O filters.

The assembler resolves `.include` itself, which means everything reached that way
-- the mapjson-generated header.inc / layouts.inc / connections.inc, the shared
constants, the specials table -- never passes through ASM_PSEUDO_OP_CONV or
mach_o_symbols.py. Those files still emit GBA-width `.4byte` pointers and 4-byte
`.align 2`, so they produced 32-bit relocations and misaligned 8-byte pointers
that no amount of patching the *visible* stream could fix.

Inlining them first puts the whole translation unit in front of the filters.
Macro definition files are left as `.include` directives: the filters must not
rewrite macro *bodies* (a `.4byte \\ptr` there is widened deliberately and
conditionally by the .ifdef PORTABLE_ASM edits), and expanding them would also
re-introduce the deep-nesting and `;`-separator problems.

Usage: expand_includes.py [-I dir]... < in > out
"""

import os
import re
import sys

INCLUDE = re.compile(r'^\s*\.include\s+"([^"]+)"\s*$')

# Keep these as .include: they define macros, whose bodies must stay untouched.
KEEP = ('asm/macros', 'asm/macros.inc')


def resolve(path, search):
    if os.path.isfile(path):
        return path
    for d in search:
        cand = os.path.join(d, path)
        if os.path.isfile(cand):
            return cand
    return None


def expand(lines, search, seen, depth=0):
    if depth > 64:
        return lines
    out = []
    for line in lines:
        m = INCLUDE.match(line)
        if not m:
            out.append(line)
            continue
        path = m.group(1)
        if any(path.startswith(k) for k in KEEP):
            out.append(line)
            continue
        real = resolve(path, search)
        if real is None:
            out.append(line)          # let the assembler report it
            continue
        key = os.path.realpath(real)
        if key in seen:
            # Assembler .include has no include guard; a repeat is intentional
            # only for macro files, which we already skipped.
            continue
        seen.add(key)
        with open(real, 'r', encoding='utf-8', errors='replace') as f:
            out.extend(expand(f.readlines(), search, seen, depth + 1))
    return out


def main():
    search = []
    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == '-I' and i + 1 < len(args):
            search.append(args[i + 1]); i += 2
        elif args[i].startswith('-I'):
            search.append(args[i][2:]); i += 1
        else:
            i += 1
    data = sys.stdin.buffer.read().decode('utf-8', errors='replace').splitlines(True)
    sys.stdout.write(''.join(expand(data, search, set())))


if __name__ == '__main__':
    main()
