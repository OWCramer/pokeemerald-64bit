#!/usr/bin/env python3
"""Post-link fixup for the Android (PIE ELF) build's 4-byte script pointers.

The 64-bit builds widen most stored pointers to 8-byte .quad, which the dynamic
linker relocates normally. The script-bytecode/sound pointers must stay 4 bytes,
and the game reads them through the anchor-offset macros in include/global.h:
SCRIPT_REBASE(v) == gScriptBase + (s32)v -- each 4-byte slot must hold a SIGNED
32-bit offset from gScriptBase.

macOS emits that offset with a Mach-O SUBTRACTOR relocation; ELF has no
equivalent, and a shared object cannot carry 4-byte absolute relocations at all.
So on Android the assembler's `sptr` macro instead:
  * stores a PC-relative offset in the slot (target - slot), which folds to a
    constant under -Bsymbolic and needs no dynamic relocation, and
  * records the slot's own address as an 8-byte entry in section .emerald_sptr.

This tool walks that table and rewrites each slot from (target - slot) to
(target - gScriptBase), so the read-time macros reconstruct the correct PIE
address regardless of load bias. It is exhaustive by construction: every script
pointer has a table entry, including same-section ones the assembler folded with
no relocation to scan for.

Usage: elf_script_rebase.py <libmain.so>
"""
import sys, struct
from elftools.elf.elffile import ELFFile
from elftools.elf.relocation import RelocationSection


def vaddr_to_fileoff(segs, vaddr):
    for off, va, filesz in segs:
        if va <= vaddr < va + filesz:
            return off + (vaddr - va)
    return None


def find_symbol(elf, name):
    for secname in ('.symtab', '.dynsym'):
        sec = elf.get_section_by_name(secname)
        if not sec:
            continue
        for sym in sec.iter_symbols():
            if sym.name == name:
                return sym['st_value']
    return None


def main():
    path = sys.argv[1]
    with open(path, 'rb') as f:
        blob = bytearray(f.read())
    elf = ELFFile(open(path, 'rb'))

    anchor = find_symbol(elf, 'gScriptBase')
    if anchor is None:
        sys.exit("elf_script_rebase: gScriptBase not found")

    tab = elf.get_section_by_name('.emerald_sptr')
    if tab is None:
        # No script pointers routed through sptr -- nothing to do (e.g. a build
        # with none). Not an error.
        print("elf_script_rebase: no .emerald_sptr section, nothing to patch")
        return
    tab_start = tab['sh_addr']
    tab_end = tab_start + tab['sh_size']

    segs = [(s['p_offset'], s['p_vaddr'], s['p_filesz'])
            for s in elf.iter_segments() if s['p_type'] == 'PT_LOAD']

    # Each 8-byte table entry holds a slot address, materialised as an
    # R_*_RELATIVE dynamic relocation (content 0, addend = slot vaddr) in a PIE.
    # Map entry-vaddr -> slot vaddr from those relocations; fall back to any
    # inline value for non-PIE edge cases.
    rel_addend = {}
    for sec in elf.iter_sections():
        if not isinstance(sec, RelocationSection):
            continue
        for r in sec.iter_relocations():
            off = r['r_offset']
            if tab_start <= off < tab_end:
                rel_addend[off] = r['r_addend'] if sec.is_RELA() else None

    slots = []
    entry_va = tab_start
    tab_fo = vaddr_to_fileoff(segs, tab_start)
    while entry_va < tab_end:
        if entry_va in rel_addend and rel_addend[entry_va] is not None:
            slot = rel_addend[entry_va]
        else:
            fo = vaddr_to_fileoff(segs, entry_va)
            slot = struct.unpack_from('<Q', blob, fo)[0]
        if slot:
            slots.append(slot)
        entry_va += 8

    patched = 0
    for slot in slots:
        fo = vaddr_to_fileoff(segs, slot)
        if fo is None:
            print(f"  WARN slot {slot:#x} not in a PT_LOAD", file=sys.stderr)
            continue
        pcrel = struct.unpack_from('<i', blob, fo)[0]   # target - slot
        target = slot + pcrel
        offset = target - anchor
        if not (-0x80000000 <= offset <= 0x7fffffff):
            sys.exit(f"elf_script_rebase: offset {offset:#x} at slot {slot:#x} "
                     f"does not fit in 32 bits")
        struct.pack_into('<i', blob, fo, offset)
        patched += 1

    with open(path, 'wb') as f:
        f.write(blob)
    print(f"elf_script_rebase: gScriptBase={anchor:#x} "
          f"table_entries={len(slots)} patched={patched}")


if __name__ == '__main__':
    main()
