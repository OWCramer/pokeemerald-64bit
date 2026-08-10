	.macro inc x:req
	.set \x, \x + 1
	.endm

	.macro enum_start x=0
	.set __enum__, \x
	.endm

	.macro enum constant:req
	.equiv \constant, __enum__
	inc __enum__
	.endm

	/* Emits a script bytecode pointer as a signed 32-bit offset from
	   gScriptBase (see SCRIPT_REBASE in include/global.h). A null script is
	   stored as offset 0 -- Mach-O cannot express `0 - symbol`, and offset 0
	   addresses the anchor itself, which is never a real script. */
	.macro scriptptr sym:req
	.ifc \sym, NULL
	.long 0
	.else
	.ifc \sym, 0x0
	.long 0
	.else
	.ifc \sym, 0
	.long 0
	.else
	.ifc \sym, NULL
	.long 0
	.else
	.long (\sym - _gScriptBase)
	.endif
	.endif
	.endif
	.endif
	.endm
