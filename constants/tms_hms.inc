#ifndef GUARD_CONSTANTS_TMS_HMS_INC
#define GUARD_CONSTANTS_TMS_HMS_INC

#include "constants/tms_hms.h"

/* Expands to:
* enum_start ITEM_TM01
* enum ITEM_TM_FOCUS_PUNCH
* ...
* enum_start ITEM_HM01
* enum ITEM_HM_CUT
* ... */
#define EQUIV_TM(id) enum ITEM_TM_ ## id;
#define EQUIV_HM(id) enum ITEM_HM_ ## id;
/* On clang's arm64 assembler ';' is a comment, so this one-line expansion only
   ever defines the first entry of each list. The native build defines all of
   them from constants/tms_hms_flat.inc instead. */
	.ifndef PORTABLE_ASM
	enum_start ITEM_TM01
FOREACH_TM(EQUIV_TM)
	enum_start ITEM_HM01
FOREACH_HM(EQUIV_HM)
	.endif
#undef EQUIV_TM
#undef EQUIV_HM

#endif @ GUARD_CONSTANTS_TMS_HMS_INC
