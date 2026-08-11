@ The first .byte argument of each macro below is an index into gFieldEffectScriptFuncs

	.macro field_eff_loadtiles address:req
	.byte 0
	.ifdef PORTABLE_ASM
	.ifc \address, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \address
	.else
	.long (\address - _gScriptBase)
	.endif
	.endif
	.else
	.int \address
	.endif
	.endm

	.macro field_eff_loadfadedpal address:req
	.byte 1
	.ifdef PORTABLE_ASM
	.ifc \address, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \address
	.else
	.long (\address - _gScriptBase)
	.endif
	.endif
	.else
	.int \address
	.endif
	.endm

	.macro field_eff_loadpal address:req
	.byte 2
	.ifdef PORTABLE_ASM
	.ifc \address, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \address
	.else
	.long (\address - _gScriptBase)
	.endif
	.endif
	.else
	.int \address
	.endif
	.endm

	.macro field_eff_callnative address:req
	.byte 3
	.ifdef PORTABLE_ASM
	.ifc \address, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \address
	.else
	.long (\address - _gScriptBase)
	.endif
	.endif
	.else
	.int \address
	.endif
	.endm

	.macro field_eff_end
	.byte 4
	.endm

	.macro field_eff_loadgfx_callnative tiles_address:req, palette_address:req, function_address:req
	.byte 5
	.ifdef PORTABLE_ASM
	.ifc \tiles_address, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \tiles_address
	.else
	.long (\tiles_address - _gScriptBase)
	.endif
	.endif
	.else
	.int \tiles_address
	.endif
	.ifdef PORTABLE_ASM
	.ifc \palette_address, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \palette_address
	.else
	.long (\palette_address - _gScriptBase)
	.endif
	.endif
	.else
	.int \palette_address
	.endif
	.ifdef PORTABLE_ASM
	.ifc \function_address, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \function_address
	.else
	.long (\function_address - _gScriptBase)
	.endif
	.endif
	.else
	.int \function_address
	.endif
	.endm

	.macro field_eff_loadtiles_callnative tiles_address:req, function_address:req
	.byte 6
	.ifdef PORTABLE_ASM
	.ifc \tiles_address, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \tiles_address
	.else
	.long (\tiles_address - _gScriptBase)
	.endif
	.endif
	.else
	.int \tiles_address
	.endif
	.ifdef PORTABLE_ASM
	.ifc \function_address, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \function_address
	.else
	.long (\function_address - _gScriptBase)
	.endif
	.endif
	.else
	.int \function_address
	.endif
	.endm

	.macro field_eff_loadfadedpal_callnative palette_address:req, function_address:req
	.byte 7
	.ifdef PORTABLE_ASM
	.ifc \palette_address, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \palette_address
	.else
	.long (\palette_address - _gScriptBase)
	.endif
	.endif
	.else
	.int \palette_address
	.endif
	.ifdef PORTABLE_ASM
	.ifc \function_address, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \function_address
	.else
	.long (\function_address - _gScriptBase)
	.endif
	.endif
	.else
	.int \function_address
	.endif
	.endm
