#!/bin/bash
# Emit a Mach-O -alias_list mapping bare assembly symbol references to the
# underscore-mangled names the C compiler actually produces.
#
# Assembly emitted from inside .inc macros never passes through
# tools/mach_o_symbols.py -- macros expand at assembly time, after the filter
# has run -- so those references keep their bare GBA names. Prefixing them at
# the emission site does not work either, because several take parenthesized
# expressions such as `setbyte (gBattleScripting + 0x0E), 2`.
#
# Only bare undefined names whose `_`-prefixed counterpart is actually defined
# somewhere get an alias; aliasing anything else just moves the error.
# Regenerated on every link so it stays in step with the sources.
set -euo pipefail
out=$1; shift
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# nm prints defined symbols as "<addr> <type> <name>" but undefined ones as
# "U <name>" -- only two fields. Keying on the type column by position is
# therefore wrong for undefined lines, so split the cases explicitly.
# Definitions include tentative/common symbols (`u16 INTR_CHECK;`), type C.
for obj in "$@"; do
  nm "$obj" 2>/dev/null || true
# Uppercase type letters are global definitions; lowercase are file-local. Only
# globals can satisfy a cross-object reference, and several data objects define
# local absolutes for GBA hardware addresses (INTR_CHECK, REG_BASE, ...) that
# must not be mistaken for the C variables of the same name.
done | awk 'NF>=3 && $2!="U" && $2 ~ /^[A-Z]$/ {print $3}' | sort -u > "$tmp/defined"

for obj in "$@"; do
  nm "$obj" 2>/dev/null || true
done | awk '($1=="U" && NF==2) {print $2} (NF>=3 && $2=="U") {print $3}' \
     | sort -u > "$tmp/allundef"

grep -E '^[A-Za-z][A-Za-z0-9_]*$' "$tmp/allundef" | sort -u > "$tmp/undef"   || true
grep -E '^_[A-Za-z][A-Za-z0-9_]*$' "$tmp/allundef" | sort -u > "$tmp/undef_us" || true

{
  # bare reference -> underscore definition
  awk 'NR==FNR {def[$1]=1; next} ("_" $1) in def {print "_" $1 " " $1}' \
      "$tmp/defined" "$tmp/undef"
  # underscore reference -> bare definition
  awk 'NR==FNR {def[$1]=1; next} substr($1,2) in def {print substr($1,2) " " $1}' \
      "$tmp/defined" "$tmp/undef_us"
} | sort -u > "$tmp/pairs"

# Drop any alias whose name is already defined -- mach_o_symbols.py emits
# `_name = name` aliases inline for labels it can see, and re-aliasing those
# here would be a duplicate symbol.
awk 'NR==FNR {def[$1]=1; next} !($2 in def)' "$tmp/defined" "$tmp/pairs" > "$out"
echo "wrote $(wc -l < "$out" | tr -d ' ') aliases"
