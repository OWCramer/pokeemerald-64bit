/* commands*/
	.macro attackcanceler
	.byte B_SCR_OP_ATTACKCANCELER
	.endm

	.macro accuracycheck failPtr:req, move:req
	.byte B_SCR_OP_ACCURACYCHECK
	.ifdef PORTABLE_ASM
	.ifc \failPtr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \failPtr
	.else
	.long (\failPtr - _gScriptBase)
	.endif
	.endif
	.else
	.int \failPtr
	.endif
	.short \move
	.endm

	.macro attackstring
	.byte B_SCR_OP_ATTACKSTRING
	.endm

	.macro ppreduce
	.byte B_SCR_OP_PPREDUCE
	.endm

	.macro critcalc
	.byte B_SCR_OP_CRITCALC
	.endm

	.macro damagecalc
	.byte B_SCR_OP_DAMAGECALC
	.endm

	.macro typecalc
	.byte B_SCR_OP_TYPECALC
	.endm

	.macro adjustnormaldamage
	.byte B_SCR_OP_ADJUSTNORMALDAMAGE
	.endm

	.macro adjustnormaldamage2
	.byte B_SCR_OP_ADJUSTNORMALDAMAGE2
	.endm

	.macro attackanimation
	.byte B_SCR_OP_ATTACKANIMATION
	.endm

	.macro waitanimation
	.byte B_SCR_OP_WAITANIMATION
	.endm

	.macro healthbarupdate battler:req
	.byte B_SCR_OP_HEALTHBARUPDATE
	.byte \battler
	.endm

	.macro datahpupdate battler:req
	.byte B_SCR_OP_DATAHPUPDATE
	.byte \battler
	.endm

	.macro critmessage
	.byte B_SCR_OP_CRITMESSAGE
	.endm

	.macro effectivenesssound
	.byte B_SCR_OP_EFFECTIVENESSSOUND
	.endm

	.macro resultmessage
	.byte B_SCR_OP_RESULTMESSAGE
	.endm

	.macro printstring id:req
	.byte B_SCR_OP_PRINTSTRING
	.short \id
	.endm

	.macro printselectionstring id:req
	.byte B_SCR_OP_PRINTSELECTIONSTRING
	.short \id
	.endm

	.macro waitmessage time:req
	.byte B_SCR_OP_WAITMESSAGE
	.short \time
	.endm

	.macro printfromtable ptr:req
	.byte B_SCR_OP_PRINTFROMTABLE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro printselectionstringfromtable ptr:req
	.byte B_SCR_OP_PRINTSELECTIONSTRINGFROMTABLE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro seteffectwithchance
	.byte B_SCR_OP_SETEFFECTWITHCHANCE
	.endm

	.macro seteffectprimary
	.byte B_SCR_OP_SETEFFECTPRIMARY
	.endm

	.macro seteffectsecondary
	.byte B_SCR_OP_SETEFFECTSECONDARY
	.endm

	.macro clearstatusfromeffect battler:req
	.byte B_SCR_OP_CLEARSTATUSFROMEFFECT
	.byte \battler
	.endm

	.macro tryfaintmon battler:req
	.byte B_SCR_OP_TRYFAINTMON
	.byte \battler
	.byte FALSE
	.int NULL
	.endm

	.macro tryfaintmon_spikes battler:req, ptr:req
	.byte B_SCR_OP_TRYFAINTMON
	.byte \battler
	.byte TRUE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro dofaintanimation battler:req
	.byte B_SCR_OP_DOFAINTANIMATION
	.byte \battler
	.endm

	.macro cleareffectsonfaint battler:req
	.byte B_SCR_OP_CLEAREFFECTSONFAINT
	.byte \battler
	.endm

	.macro jumpifstatus battler:req, status1:req, ptr:req
	.byte B_SCR_OP_JUMPIFSTATUS
	.byte \battler
	.int \status1
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifstatus2 battler:req, status2:req, ptr:req
	.byte B_SCR_OP_JUMPIFSTATUS2
	.byte \battler
	.int \status2
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifability battler:req, ability:req, ptr:req
	.byte B_SCR_OP_JUMPIFABILITY
	.byte \battler
	.byte \ability
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifsideaffecting battler:req, sidestatus:req, ptr:req
	.byte B_SCR_OP_JUMPIFSIDEAFFECTING
	.byte \battler
	.short \sidestatus
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifstat battler:req, ifflag:req, stat:req, value:req, ptr
	.byte B_SCR_OP_JUMPIFSTAT
	.byte \battler
	.byte \ifflag
	.byte \stat
	.byte \value
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifstatus3condition battler:req, status3:req, condition:req, ptr:req
	.byte B_SCR_OP_JUMPIFSTATUS3CONDITION
	.byte \battler
	.int \status3
	.byte \condition
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpiftype battler:req, type:req, ptr:req
	.byte B_SCR_OP_JUMPIFTYPE
	.byte \battler
	.byte \type
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro getexp battler:req
	.byte B_SCR_OP_GETEXP
	.byte \battler
	.endm

	.macro checkteamslost ptr:req
	.byte B_SCR_OP_CHECKTEAMSLOST
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro movevaluescleanup
	.byte B_SCR_OP_MOVEVALUESCLEANUP
	.endm

	.macro setmultihit value:req
	.byte B_SCR_OP_SETMULTIHIT
	.byte \value
	.endm

	/* Despite the generic parameter name, \value is a jump target. */
	.macro decrementmultihit value:req
	.byte B_SCR_OP_DECREMENTMULTIHIT
	.ifdef PORTABLE_ASM
	.ifc \value, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \value
	.else
	.long (\value - _gScriptBase)
	.endif
	.endif
	.else
	.int \value
	.endif
	.endm

	.macro goto ptr:req
	.byte B_SCR_OP_GOTO
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifbyte ifflag:req, val:req, byte:req, ptr:req
	.byte B_SCR_OP_JUMPIFBYTE
	.byte \ifflag
	.ifdef PORTABLE_ASM
	.ifc \val, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \val
	.else
	.long (\val - _gScriptBase)
	.endif
	.endif
	.else
	.int \val
	.endif
	.byte \byte
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifhalfword ifflag:req, val:req, hword:req, ptr:req
	.byte B_SCR_OP_JUMPIFHALFWORD
	.byte \ifflag
	.ifdef PORTABLE_ASM
	.ifc \val, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \val
	.else
	.long (\val - _gScriptBase)
	.endif
	.endif
	.else
	.int \val
	.endif
	.short \hword
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifword ifflag:req, val:req, word:req, ptr:req
	.byte B_SCR_OP_JUMPIFWORD
	.byte \ifflag
	.ifdef PORTABLE_ASM
	.ifc \val, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \val
	.else
	.long (\val - _gScriptBase)
	.endif
	.endif
	.else
	.int \val
	.endif
	.int \word
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifarrayequal val1:req, val2:req, size:req, ptr:req
	.byte B_SCR_OP_JUMPIFARRAYEQUAL
	.ifdef PORTABLE_ASM
	.ifc \val1, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \val1
	.else
	.long (\val1 - _gScriptBase)
	.endif
	.endif
	.else
	.int \val1
	.endif
	.ifdef PORTABLE_ASM
	.ifc \val2, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \val2
	.else
	.long (\val2 - _gScriptBase)
	.endif
	.endif
	.else
	.int \val2
	.endif
	.byte \size
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifarraynotequal val1:req, val2:req, size:req, ptr:req
	.byte B_SCR_OP_JUMPIFARRAYNOTEQUAL
	.ifdef PORTABLE_ASM
	.ifc \val1, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \val1
	.else
	.long (\val1 - _gScriptBase)
	.endif
	.endif
	.else
	.int \val1
	.endif
	.ifdef PORTABLE_ASM
	.ifc \val2, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \val2
	.else
	.long (\val2 - _gScriptBase)
	.endif
	.endif
	.else
	.int \val2
	.endif
	.byte \size
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro setbyte ptr:req, byte:req
	.byte B_SCR_OP_SETBYTE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.byte \byte
	.endm

	.macro addbyte ptr:req, byte:req
	.byte B_SCR_OP_ADDBYTE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.byte \byte
	.endm

	.macro subbyte ptr:req, byte:req
	.byte B_SCR_OP_SUBBYTE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.byte \byte
	.endm

	.macro copyarray dest:req, src:req, size:req
	.byte B_SCR_OP_COPYARRAY
	.ifdef PORTABLE_ASM
	.ifc \dest, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \dest
	.else
	.long (\dest - _gScriptBase)
	.endif
	.endif
	.else
	.int \dest
	.endif
	.ifdef PORTABLE_ASM
	.ifc \src, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \src
	.else
	.long (\src - _gScriptBase)
	.endif
	.endif
	.else
	.int \src
	.endif
	.byte \size
	.endm

	.macro copyarraywithindex dest:req, src:req, index:req, size:req
	.byte B_SCR_OP_COPYARRAYWITHINDEX
	.ifdef PORTABLE_ASM
	.ifc \dest, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \dest
	.else
	.long (\dest - _gScriptBase)
	.endif
	.endif
	.else
	.int \dest
	.endif
	.ifdef PORTABLE_ASM
	.ifc \src, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \src
	.else
	.long (\src - _gScriptBase)
	.endif
	.endif
	.else
	.int \src
	.endif
	.ifdef PORTABLE_ASM
	.ifc \index, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \index
	.else
	.long (\index - _gScriptBase)
	.endif
	.endif
	.else
	.int \index
	.endif
	.byte \size
	.endm

	.macro orbyte ptr:req, byte:req
	.byte B_SCR_OP_ORBYTE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.byte \byte
	.endm

	.macro orhalfword ptr:req, hword:req
	.byte B_SCR_OP_ORHALFWORD
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.short \hword
	.endm

	.macro orword ptr:req, word:req
	.byte B_SCR_OP_ORWORD
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.int \word
	.endm

	.macro bicbyte ptr:req, byte:req
	.byte B_SCR_OP_BICBYTE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.byte \byte
	.endm

	.macro bichalfword ptr:req, hword:req
	.byte B_SCR_OP_BICHALFWORD
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.short \hword
	.endm

	.macro bicword ptr:req, word:req
	.byte B_SCR_OP_BICWORD
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.int \word
	.endm

	.macro pause time:req
	.byte B_SCR_OP_PAUSE
	.short \time
	.endm

	.macro waitstate
	.byte B_SCR_OP_WAITSTATE
	.endm

	.macro healthbar_update battler:req
	.byte B_SCR_OP_HEALTHBAR_UPDATE
	.byte \battler
	.endm

	.macro return
	.byte B_SCR_OP_RETURN
	.endm

	.macro end
	.byte B_SCR_OP_END
	.endm

	.macro end2
	.byte B_SCR_OP_END2
	.endm

	.macro end3
	.byte B_SCR_OP_END3
	.endm

	.macro jumpifaffectedbyprotect ptr:req
	.byte B_SCR_OP_JUMPIFAFFECTEDBYPROTECT
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro call ptr:req
	.byte B_SCR_OP_CALL
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpiftype2 battler:req, type:req, ptr:req
	.byte B_SCR_OP_JUMPIFTYPE2
	.byte \battler
	.byte \type
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifabilitypresent ability:req, ptr:req
	.byte B_SCR_OP_JUMPIFABILITYPRESENT
	.byte \ability
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro endselectionscript
	.byte B_SCR_OP_ENDSELECTIONSCRIPT
	.endm

	.macro playanimation battler:req, animType:req, arg=NULL
	.byte B_SCR_OP_PLAYANIMATION
	.byte \battler
	.byte \animType
	.ifdef PORTABLE_ASM
	.ifc \arg, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \arg
	.else
	.long (\arg - _gScriptBase)
	.endif
	.endif
	.else
	.int \arg
	.endif
	.endm

	.macro playanimation_var battler:req, animType:req, arg=NULL
	.byte B_SCR_OP_PLAYANIMATION_VAR
	.byte \battler
	.ifdef PORTABLE_ASM
	.ifc \animType, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \animType
	.else
	.long (\animType - _gScriptBase)
	.endif
	.endif
	.else
	.int \animType
	.endif
	.ifdef PORTABLE_ASM
	.ifc \arg, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \arg
	.else
	.long (\arg - _gScriptBase)
	.endif
	.endif
	.else
	.int \arg
	.endif
	.endm

	.macro setgraphicalstatchangevalues
	.byte B_SCR_OP_SETGRAPHICALSTATCHANGEVALUES
	.endm

	.macro playstatchangeanimation battler:req, stats:req, statchange:req
	.byte B_SCR_OP_PLAYSTATCHANGEANIMATION
	.byte \battler
	.byte \stats
	.byte \statchange
	.endm

	.macro moveend endMode:req, endState:req
	.byte B_SCR_OP_MOVEEND
	.byte \endMode
	.byte \endState
	.endm

	/* Help macros for 5 uses of moveend command*/

	/* All cases*/
	.macro moveendall
	setbyte sMOVEEND_STATE, 0
	moveend 0, 0
	.endm

	/* Chosen case*/
	.macro moveendcase case:req
	setbyte sMOVEEND_STATE, \case
	moveend 1, 0
	.endm

	/* All cases from (inclusive)*/
	.macro moveendfrom from:req
	setbyte sMOVEEND_STATE, \from
	moveend 0, 0
	.endm

	/* All cases from 0 to (not inclusive)*/
	.macro moveendto to:req
	setbyte sMOVEEND_STATE, 0
	moveend 2, \to
	.endm

	/* Cases from (inclusive) to (not inclusive)*/
	.macro moveendfromto from:req, to:req
	setbyte sMOVEEND_STATE, \from
	moveend 2, \to
	.endm

	.macro typecalc2
	.byte B_SCR_OP_TYPECALC2
	.endm

	.macro returnatktoball
	.byte B_SCR_OP_RETURNATKTOBALL
	.endm

	.macro getswitchedmondata battler:req
	.byte B_SCR_OP_GETSWITCHEDMONDATA
	.byte \battler
	.endm

	.macro switchindataupdate battler:req
	.byte B_SCR_OP_SWITCHINDATAUPDATE
	.byte \battler
	.endm

	.macro switchinanim battler:req, dontclearsubstitutebit:req
	.byte B_SCR_OP_SWITCHINANIM
	.byte \battler
	.byte \dontclearsubstitutebit
	.endm

	.macro jumpifcantswitch battler:req, ptr:req
	.byte B_SCR_OP_JUMPIFCANTSWITCH
	.byte \battler
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro openpartyscreen battler:req, ptr:req
	.byte B_SCR_OP_OPENPARTYSCREEN
	.byte \battler
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro switchhandleorder battler:req, state:req
	.byte B_SCR_OP_SWITCHHANDLEORDER
	.byte \battler
	.byte \state
	.endm

	.macro switchineffects battler:req
	.byte B_SCR_OP_SWITCHINEFFECTS
	.byte \battler
	.endm

	.macro trainerslidein battler:req
	.byte B_SCR_OP_TRAINERSLIDEIN
	.byte \battler
	.endm

	.macro playse song:req
	.byte B_SCR_OP_PLAYSE
	.short \song
	.endm

	.macro fanfare song:req
	.byte B_SCR_OP_FANFARE
	.short \song
	.endm

	.macro playfaintcry battler:req
	.byte B_SCR_OP_PLAYFAINTCRY
	.byte \battler
	.endm

	.macro endlinkbattle
	.byte B_SCR_OP_ENDLINKBATTLE
	.endm

	.macro returntoball battler:req
	.byte B_SCR_OP_RETURNTOBALL
	.byte \battler
	.endm

	.macro handlelearnnewmove learnedMovePtr:req, nothingToLearnPtr:req, isFirstMove:req
	.byte B_SCR_OP_HANDLELEARNNEWMOVE
	.ifdef PORTABLE_ASM
	.ifc \learnedMovePtr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \learnedMovePtr
	.else
	.long (\learnedMovePtr - _gScriptBase)
	.endif
	.endif
	.else
	.int \learnedMovePtr
	.endif
	.ifdef PORTABLE_ASM
	.ifc \nothingToLearnPtr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \nothingToLearnPtr
	.else
	.long (\nothingToLearnPtr - _gScriptBase)
	.endif
	.endif
	.else
	.int \nothingToLearnPtr
	.endif
	.byte \isFirstMove
	.endm

	.macro yesnoboxlearnmove forgotMovePtr:req
	.byte B_SCR_OP_YESNOBOXLEARNMOVE
	.ifdef PORTABLE_ASM
	.ifc \forgotMovePtr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \forgotMovePtr
	.else
	.long (\forgotMovePtr - _gScriptBase)
	.endif
	.endif
	.else
	.int \forgotMovePtr
	.endif
	.endm

	.macro yesnoboxstoplearningmove noPtr:req
	.byte B_SCR_OP_YESNOBOXSTOPLEARNINGMOVE
	.ifdef PORTABLE_ASM
	.ifc \noPtr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \noPtr
	.else
	.long (\noPtr - _gScriptBase)
	.endif
	.endif
	.else
	.int \noPtr
	.endif
	.endm

	.macro hitanimation battler:req
	.byte B_SCR_OP_HITANIMATION
	.byte \battler
	.endm

	.macro getmoneyreward
	.byte B_SCR_OP_GETMONEYREWARD
	.endm

	.macro updatebattlermoves battler:req
	.byte B_SCR_OP_UPDATEBATTLERMOVES
	.byte \battler
	.endm

	.macro swapattackerwithtarget
	.byte B_SCR_OP_SWAPATTACKERWITHTARGET
	.endm

	.macro incrementgamestat stat:req
	.byte B_SCR_OP_INCREMENTGAMESTAT
	.byte \stat
	.endm

	.macro drawpartystatussummary battler:req
	.byte B_SCR_OP_DRAWPARTYSTATUSSUMMARY
	.byte \battler
	.endm

	.macro hidepartystatussummary battler:req
	.byte B_SCR_OP_HIDEPARTYSTATUSSUMMARY
	.byte \battler
	.endm

	.macro jumptocalledmove notChosenMove:req
	.byte B_SCR_OP_JUMPTOCALLEDMOVE
	.byte \notChosenMove
	.endm

	.macro statusanimation battler:req
	.byte B_SCR_OP_STATUSANIMATION
	.byte \battler
	.endm

	.macro status2animation battler:req, status2:req
	.byte B_SCR_OP_STATUS2ANIMATION
	.byte \battler
	.int \status2
	.endm

	.macro chosenstatusanimation battler:req, isStatus2:req, status:req
	.byte B_SCR_OP_CHOSENSTATUSANIMATION
	.byte \battler
	.byte \isStatus2
	.int \status
	.endm

	.macro yesnobox
	.byte B_SCR_OP_YESNOBOX
	.endm

	.macro cancelallactions
	.byte B_SCR_OP_CANCELALLACTIONS
	.endm

	.macro adjustsetdamage
	.byte B_SCR_OP_ADJUSTSETDAMAGE
	.endm

	.macro removeitem battler:req
	.byte B_SCR_OP_REMOVEITEM
	.byte \battler
	.endm

	.macro atknameinbuff1
	.byte B_SCR_OP_ATKNAMEINBUFF1
	.endm

	.macro drawlvlupbox
	.byte B_SCR_OP_DRAWLVLUPBOX
	.endm

	.macro resetsentmonsvalue
	.byte B_SCR_OP_RESETSENTMONSVALUE
	.endm

	.macro setatktoplayer0
	.byte B_SCR_OP_SETATKTOPLAYER0
	.endm

	.macro makevisible battler:req
	.byte B_SCR_OP_MAKEVISIBLE
	.byte \battler
	.endm

	.macro recordlastability battler:req
	.byte B_SCR_OP_RECORDLASTABILITY
	.byte \battler
	.endm

	.macro buffermovetolearn
	.byte B_SCR_OP_BUFFERMOVETOLEARN
	.endm

	.macro jumpifplayerran ptr:req
	.byte B_SCR_OP_JUMPIFPLAYERRAN
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro hpthresholds battler:req
	.byte B_SCR_OP_HPTHRESHOLDS
	.byte \battler
	.endm

	.macro hpthresholds2 battler:req
	.byte B_SCR_OP_HPTHRESHOLDS2
	.byte \battler
	.endm

	.macro useitemonopponent
	.byte B_SCR_OP_USEITEMONOPPONENT
	.endm

	.macro various battler:req, id:req
	.byte B_SCR_OP_VARIOUS
	.byte \battler
	.byte \id
	.endm

	.macro setprotectlike
	.byte B_SCR_OP_SETPROTECTLIKE
	.endm

	.macro tryexplosion
	.byte B_SCR_OP_TRYEXPLOSION
	.endm

	.macro setatkhptozero
	.byte B_SCR_OP_SETATKHPTOZERO
	.endm

	.macro jumpifnexttargetvalid ptr:req
	.byte B_SCR_OP_JUMPIFNEXTTARGETVALID
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro tryhealhalfhealth ptr:req, battler:req
	.byte B_SCR_OP_TRYHEALHALFHEALTH
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.byte \battler
	.endm

	.macro trymirrormove
	.byte B_SCR_OP_TRYMIRRORMOVE
	.endm

	.macro setrain
	.byte B_SCR_OP_SETRAIN
	.endm

	.macro setreflect
	.byte B_SCR_OP_SETREFLECT
	.endm

	.macro setseeded
	.byte B_SCR_OP_SETSEEDED
	.endm

	.macro manipulatedamage mode:req
	.byte B_SCR_OP_MANIPULATEDAMAGE
	.byte \mode
	.endm

	.macro trysetrest ptr:req
	.byte B_SCR_OP_TRYSETREST
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifnotfirstturn ptr:req
	.byte B_SCR_OP_JUMPIFNOTFIRSTTURN
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro nop
	.byte B_SCR_OP_NOP
	.endm

	.macro jumpifcantmakeasleep ptr:req
	.byte B_SCR_OP_JUMPIFCANTMAKEASLEEP
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro stockpile
	.byte B_SCR_OP_STOCKPILE
	.endm

	.macro stockpiletobasedamage ptr:req
	.byte B_SCR_OP_STOCKPILETOBASEDAMAGE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro stockpiletohpheal ptr:req
	.byte B_SCR_OP_STOCKPILETOHPHEAL
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro negativedamage
	.byte B_SCR_OP_NEGATIVEDAMAGE
	.endm

	.macro statbuffchange flags:req, jumpptr:req
	.byte B_SCR_OP_STATBUFFCHANGE
	.byte \flags
	.ifdef PORTABLE_ASM
	.ifc \jumpptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \jumpptr
	.else
	.long (\jumpptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \jumpptr
	.endif
	.endm

	.macro normalisebuffs
	.byte B_SCR_OP_NORMALISEBUFFS
	.endm

	.macro setbide
	.byte B_SCR_OP_SETBIDE
	.endm

	.macro confuseifrepeatingattackends
	.byte B_SCR_OP_CONFUSEIFREPEATINGATTACKENDS
	.endm

	.macro setmultihitcounter val:req
	.byte B_SCR_OP_SETMULTIHITCOUNTER
	.byte \val
	.endm

	.macro initmultihitstring
	.byte B_SCR_OP_INITMULTIHITSTRING
	.endm

	.macro forcerandomswitch ptr:req
	.byte B_SCR_OP_FORCERANDOMSWITCH
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro tryconversiontypechange ptr:req
	.byte B_SCR_OP_TRYCONVERSIONTYPECHANGE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro givepaydaymoney
	.byte B_SCR_OP_GIVEPAYDAYMONEY
	.endm

	.macro setlightscreen
	.byte B_SCR_OP_SETLIGHTSCREEN
	.endm

	.macro tryKO ptr:req
	.byte B_SCR_OP_TRYKO
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro damagetohalftargethp
	.byte B_SCR_OP_DAMAGETOHALFTARGETHP
	.endm

	.macro setsandstorm
	.byte B_SCR_OP_SETSANDSTORM
	.endm

	.macro weatherdamage
	.byte B_SCR_OP_WEATHERDAMAGE
	.endm

	.macro tryinfatuating ptr:req
	.byte B_SCR_OP_TRYINFATUATING
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro updatestatusicon battler:req
	.byte B_SCR_OP_UPDATESTATUSICON
	.byte \battler
	.endm

	.macro setmist
	.byte B_SCR_OP_SETMIST
	.endm

	.macro setfocusenergy
	.byte B_SCR_OP_SETFOCUSENERGY
	.endm

	.macro transformdataexecution
	.byte B_SCR_OP_TRANSFORMDATAEXECUTION
	.endm

	.macro setsubstitute
	.byte B_SCR_OP_SETSUBSTITUTE
	.endm

	.macro mimicattackcopy ptr:req
	.byte B_SCR_OP_MIMICATTACKCOPY
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro metronome
	.byte B_SCR_OP_METRONOME
	.endm

	.macro dmgtolevel
	.byte B_SCR_OP_DMGTOLEVEL
	.endm

	.macro psywavedamageeffect
	.byte B_SCR_OP_PSYWAVEDAMAGEEFFECT
	.endm

	.macro counterdamagecalculator ptr:req
	.byte B_SCR_OP_COUNTERDAMAGECALCULATOR
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro mirrorcoatdamagecalculator ptr:req
	.byte B_SCR_OP_MIRRORCOATDAMAGECALCULATOR
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro disablelastusedattack ptr:req
	.byte B_SCR_OP_DISABLELASTUSEDATTACK
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trysetencore ptr:req
	.byte B_SCR_OP_TRYSETENCORE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro painsplitdmgcalc ptr:req
	.byte B_SCR_OP_PAINSPLITDMGCALC
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro settypetorandomresistance ptr:req
	.byte B_SCR_OP_SETTYPETORANDOMRESISTANCE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro setalwayshitflag
	.byte B_SCR_OP_SETALWAYSHITFLAG
	.endm

	.macro copymovepermanently ptr:req
	.byte B_SCR_OP_COPYMOVEPERMANENTLY
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trychoosesleeptalkmove ptr:req
	.byte B_SCR_OP_TRYCHOOSESLEEPTALKMOVE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro setdestinybond
	.byte B_SCR_OP_SETDESTINYBOND
	.endm

	.macro trysetdestinybondtohappen
	.byte B_SCR_OP_TRYSETDESTINYBONDTOHAPPEN
	.endm

	.macro remaininghptopower
	.byte B_SCR_OP_REMAININGHPTOPOWER
	.endm

	.macro tryspiteppreduce ptr:req
	.byte B_SCR_OP_TRYSPITEPPREDUCE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro healpartystatus
	.byte B_SCR_OP_HEALPARTYSTATUS
	.endm

	.macro cursetarget ptr:req
	.byte B_SCR_OP_CURSETARGET
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trysetspikes ptr:req
	.byte B_SCR_OP_TRYSETSPIKES
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro setforesight
	.byte B_SCR_OP_SETFORESIGHT
	.endm

	.macro trysetperishsong ptr:req
	.byte B_SCR_OP_TRYSETPERISHSONG
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro rolloutdamagecalculation
	.byte B_SCR_OP_ROLLOUTDAMAGECALCULATION
	.endm

	.macro jumpifconfusedandstatmaxed stat:req, ptr:req
	.byte B_SCR_OP_JUMPIFCONFUSEDANDSTATMAXED
	.byte \stat
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro furycuttercalc
	.byte B_SCR_OP_FURYCUTTERCALC
	.endm

	.macro friendshiptodamagecalculation
	.byte B_SCR_OP_FRIENDSHIPTODAMAGECALCULATION
	.endm

	.macro presentdamagecalculation
	.byte B_SCR_OP_PRESENTDAMAGECALCULATION
	.endm

	.macro setsafeguard
	.byte B_SCR_OP_SETSAFEGUARD
	.endm

	.macro magnitudedamagecalculation
	.byte B_SCR_OP_MAGNITUDEDAMAGECALCULATION
	.endm

	.macro jumpifnopursuitswitchdmg ptr:req
	.byte B_SCR_OP_JUMPIFNOPURSUITSWITCHDMG
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro setsunny
	.byte B_SCR_OP_SETSUNNY
	.endm

	.macro maxattackhalvehp ptr:req
	.byte B_SCR_OP_MAXATTACKHALVEHP
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro copyfoestats ptr:req
	.byte B_SCR_OP_COPYFOESTATS
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro rapidspinfree
	.byte B_SCR_OP_RAPIDSPINFREE
	.endm

	.macro setdefensecurlbit
	.byte B_SCR_OP_SETDEFENSECURLBIT
	.endm

	.macro recoverbasedonsunlight ptr:req
	.byte B_SCR_OP_RECOVERBASEDONSUNLIGHT
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro hiddenpowercalc
	.byte B_SCR_OP_HIDDENPOWERCALC
	.endm

	.macro selectfirstvalidtarget
	.byte B_SCR_OP_SELECTFIRSTVALIDTARGET
	.endm

	.macro trysetfutureattack ptr:req
	.byte B_SCR_OP_TRYSETFUTUREATTACK
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trydobeatup endPtr:req, failPtr:req
	.byte B_SCR_OP_TRYDOBEATUP
	.ifdef PORTABLE_ASM
	.ifc \endPtr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \endPtr
	.else
	.long (\endPtr - _gScriptBase)
	.endif
	.endif
	.else
	.int \endPtr
	.endif
	.ifdef PORTABLE_ASM
	.ifc \failPtr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \failPtr
	.else
	.long (\failPtr - _gScriptBase)
	.endif
	.endif
	.else
	.int \failPtr
	.endif
	.endm

	.macro setsemiinvulnerablebit
	.byte B_SCR_OP_SETSEMIINVULNERABLEBIT
	.endm

	.macro clearsemiinvulnerablebit
	.byte B_SCR_OP_CLEARSEMIINVULNERABLEBIT
	.endm

	.macro setminimize
	.byte B_SCR_OP_SETMINIMIZE
	.endm

	.macro sethail
	.byte B_SCR_OP_SETHAIL
	.endm

	.macro trymemento ptr:req
	.byte B_SCR_OP_TRYMEMENTO
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro setforcedtarget
	.byte B_SCR_OP_SETFORCEDTARGET
	.endm

	.macro setcharge
	.byte B_SCR_OP_SETCHARGE
	.endm

	.macro callenvironmentattack
	.byte B_SCR_OP_CALLENVIRONMENTATTACK
	.endm

	.macro cureifburnedparalyzedorpoisoned ptr:req
	.byte B_SCR_OP_CUREIFBURNEDPARALYZEDORPOISONED
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro settorment ptr:req
	.byte B_SCR_OP_SETTORMENT
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro jumpifnodamage ptr:req
	.byte B_SCR_OP_JUMPIFNODAMAGE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro settaunt ptr:req
	.byte B_SCR_OP_SETTAUNT
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trysethelpinghand ptr:req
	.byte B_SCR_OP_TRYSETHELPINGHAND
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro tryswapitems ptr:req
	.byte B_SCR_OP_TRYSWAPITEMS
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trycopyability ptr:req
	.byte B_SCR_OP_TRYCOPYABILITY
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trywish turnNumber:req, ptr:req
	.byte B_SCR_OP_TRYWISH
	.byte \turnNumber
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trysetroots ptr:req
	.byte B_SCR_OP_TRYSETROOTS
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro doubledamagedealtifdamaged
	.byte B_SCR_OP_DOUBLEDAMAGEDEALTIFDAMAGED
	.endm

	.macro setyawn ptr:req
	.byte B_SCR_OP_SETYAWN
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro setdamagetohealthdifference ptr:req
	.byte B_SCR_OP_SETDAMAGETOHEALTHDIFFERENCE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro scaledamagebyhealthratio
	.byte B_SCR_OP_SCALEDAMAGEBYHEALTHRATIO
	.endm

	.macro tryswapabilities ptr:req
	.byte B_SCR_OP_TRYSWAPABILITIES
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro tryimprison ptr:req
	.byte B_SCR_OP_TRYIMPRISON
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trysetgrudge ptr:req
	.byte B_SCR_OP_TRYSETGRUDGE
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro weightdamagecalculation
	.byte B_SCR_OP_WEIGHTDAMAGECALCULATION
	.endm

	.macro assistattackselect ptr:req
	.byte B_SCR_OP_ASSISTATTACKSELECT
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trysetmagiccoat ptr:req
	.byte B_SCR_OP_TRYSETMAGICCOAT
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trysetsnatch ptr:req
	.byte B_SCR_OP_TRYSETSNATCH
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro trygetintimidatetarget ptr:req
	.byte B_SCR_OP_TRYGETINTIMIDATETARGET
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro switchoutabilities battler:req
	.byte B_SCR_OP_SWITCHOUTABILITIES
	.byte \battler
	.endm

	.macro jumpifhasnohp battler:req, ptr:req
	.byte B_SCR_OP_JUMPIFHASNOHP
	.byte \battler
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro getsecretpowereffect
	.byte B_SCR_OP_GETSECRETPOWEREFFECT
	.endm

	.macro pickup
	.byte B_SCR_OP_PICKUP
	.endm

	.macro docastformchangeanimation
	.byte B_SCR_OP_DOCASTFORMCHANGEANIMATION
	.endm

	.macro trycastformdatachange
	.byte B_SCR_OP_TRYCASTFORMDATACHANGE
	.endm

	.macro settypebasedhalvers ptr:req
	.byte B_SCR_OP_SETTYPEBASEDHALVERS
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro setweatherballtype
	.byte B_SCR_OP_SETWEATHERBALLTYPE
	.endm

	.macro tryrecycleitem ptr:req
	.byte B_SCR_OP_TRYRECYCLEITEM
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro settypetoenvironment ptr:req
	.byte B_SCR_OP_SETTYPETOENVIRONMENT
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro pursuitdoubles ptr:req
	.byte B_SCR_OP_PURSUITDOUBLES
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro snatchsetbattlers
	.byte B_SCR_OP_SNATCHSETBATTLERS
	.endm

	.macro removelightscreenreflect
	.byte B_SCR_OP_REMOVELIGHTSCREENREFLECT
	.endm

	.macro handleballthrow
	.byte B_SCR_OP_HANDLEBALLTHROW
	.endm

	.macro givecaughtmon
	.byte B_SCR_OP_GIVECAUGHTMON
	.endm

	.macro trysetcaughtmondexflags ptr:req
	.byte B_SCR_OP_TRYSETCAUGHTMONDEXFLAGS
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro displaydexinfo
	.byte B_SCR_OP_DISPLAYDEXINFO
	.endm

	.macro trygivecaughtmonnick ptr:req
	.byte B_SCR_OP_TRYGIVECAUGHTMONNICK
	.ifdef PORTABLE_ASM
	.ifc \ptr, NULL
	.long 0
	.else
	.if ELF_BUILD
	.long \ptr
	.else
	.long (\ptr - _gScriptBase)
	.endif
	.endif
	.else
	.int \ptr
	.endif
	.endm

	.macro subattackerhpbydmg
	.byte B_SCR_OP_SUBATTACKERHPBYDMG
	.endm

	.macro removeattackerstatus1
	.byte B_SCR_OP_REMOVEATTACKERSTATUS1
	.endm

	.macro finishaction
	.byte B_SCR_OP_FINISHACTION
	.endm

	.macro finishturn
	.byte B_SCR_OP_FINISHTURN
	.endm

	.macro trainerslideout position:req
	.byte B_SCR_OP_TRAINERSLIDEOUT
	.byte \position
	.endm

/* various command changed to more readable macros*/
	.macro cancelmultiturnmoves battler:req
	various \battler, VARIOUS_CANCEL_MULTI_TURN_MOVES
	.endm

	.macro setmagiccoattarget battler:req
	various \battler, VARIOUS_SET_MAGIC_COAT_TARGET
	.endm

	.macro getifcantrunfrombattle battler:req
	various \battler, VARIOUS_IS_RUNNING_IMPOSSIBLE
	.endm

	.macro getmovetarget battler:req
	various \battler, VARIOUS_GET_MOVE_TARGET
	.endm

	.macro getbattlerfainted battler:req
	various \battler, VARIOUS_GET_BATTLER_FAINTED
	.endm

	.macro resetintimidatetracebits battler:req
	various \battler, VARIOUS_RESET_INTIMIDATE_TRACE_BITS
	.endm

	.macro updatechoicemoveonlvlup battler:req
	various \battler, VARIOUS_UPDATE_CHOICE_MOVE_ON_LVL_UP
	.endm

	.macro resetplayerfainted
	various BS_ATTACKER, VARIOUS_RESET_PLAYER_FAINTED
	.endm

	.macro palaceflavortext battler:req
	various \battler, VARIOUS_PALACE_FLAVOR_TEXT
	.endm

	.macro arenajudgmentwindow
	various BS_ATTACKER, VARIOUS_ARENA_JUDGMENT_WINDOW
	.endm

	.macro arenaopponentmonlost
	various BS_ATTACKER, VARIOUS_ARENA_OPPONENT_MON_LOST
	.endm

	.macro arenaplayermonlost
	various BS_ATTACKER, VARIOUS_ARENA_PLAYER_MON_LOST
	.endm

	.macro arenabothmonlost
	various BS_ATTACKER, VARIOUS_ARENA_BOTH_MONS_LOST
	.endm

	.macro forfeityesnobox battler:req
	various \battler, VARIOUS_EMIT_YESNOBOX
	.endm

	.macro arenadrawreftextbox
	various BS_ATTACKER, VARIOUS_DRAW_ARENA_REF_TEXT_BOX
	.endm

	.macro arenaerasereftextbox
	various BS_ATTACKER, VARIOUS_ERASE_ARENA_REF_TEXT_BOX
	.endm

	.macro arenajudgmentstring id:req
	various \id, VARIOUS_ARENA_JUDGMENT_STRING
	.endm

	.macro arenawaitmessage id:req
	various \id, VARIOUS_ARENA_WAIT_STRING
	.endm

	.macro waitcry battler:req
	various \battler, VARIOUS_WAIT_CRY
	.endm

	.macro returnopponentmon1toball battler:req
	various \battler, VARIOUS_RETURN_OPPONENT_MON1
	.endm

	.macro returnopponentmon2toball battler:req
	various \battler, VARIOUS_RETURN_OPPONENT_MON2
	.endm

	.macro volumedown
	various BS_ATTACKER, VARIOUS_VOLUME_DOWN
	.endm

	.macro volumeup
	various BS_ATTACKER, VARIOUS_VOLUME_UP
	.endm

	.macro setalreadystatusedmoveattempt battler:req
	various \battler, VARIOUS_SET_ALREADY_STATUS_MOVE_ATTEMPT
	.endm

	.macro palacetryescapestatus battler:req
	various \battler, VARIOUS_PALACE_TRY_ESCAPE_STATUS
	.endm

	.macro setoutcomeonteleport battler:req
	various \battler, VARIOUS_SET_TELEPORT_OUTCOME
	.endm

	.macro playtrainerdefeatbgm battler:req
	various \battler, VARIOUS_PLAY_TRAINER_DEFEATED_MUSIC
	.endm

/* helpful macros*/
	.macro setstatchanger stat:req, stages:req, down:req
	setbyte sSTATCHANGER, \stat | \stages << 4 | \down << 7
	.endm

	.macro setmoveeffect effect:req
	setbyte cEFFECT_CHOOSER, \effect
	.endm

	.macro chosenstatus1animation battler:req, status:req
	chosenstatusanimation \battler, 0x0, \status
	.endm

	.macro chosenstatus2animation battler:req, status:req
	chosenstatusanimation \battler, 0x1, \status
	.endm

	.macro sethword dst:req, value:req
	setbyte \dst, (\value) & 0xFF
	setbyte \dst + 1, ((\value) >> 8) & 0xFF
	.endm

	.macro setword dst:req, value:req
	setbyte \dst, (\value) & 0xFF
	setbyte \dst + 1, ((\value) >> 8) & 0xFF
	setbyte \dst + 2, ((\value) >> 16) & 0xFF
	setbyte \dst + 3, ((\value) >> 24) & 0xFF
	.endm

	.macro copybyte dst:req, src:req
	copyarray \dst, \src, 0x1
	.endm

	.macro copyhword dst:req, src:req
	copyarray \dst, \src, 0x2
	.endm

	.macro copyword dst:req, src:req
	copyarray \dst, \src, 0x4
	.endm

	.macro jumpifbytenotequal byte1:req, byte2:req, jumpptr:req
	jumpifarraynotequal \byte1, \byte2, 0x1, \jumpptr
	.endm

	.macro jumpifbyteequal byte1:req, byte2:req, jumpptr:req
	jumpifarrayequal \byte1, \byte2, 0x1, \jumpptr
	.endm

	.macro jumpifmove move:req, jumpptr:req
	jumpifhalfword CMP_EQUAL, gCurrentMove, \move, \jumpptr
	.endm

	.macro jumpifnotmove move:req, jumpptr:req
	jumpifhalfword CMP_NOT_EQUAL, gCurrentMove, \move, \jumpptr
	.endm

	.macro jumpifstatus3 battler:req, status:req, jumpptr:req
	jumpifstatus3condition \battler, \status, FALSE, \jumpptr
	.endm

	.macro jumpifnostatus3 battler:req, status:req, jumpptr:req
	jumpifstatus3condition \battler, \status, TRUE, \jumpptr
	.endm

	.macro jumpifmovehadnoeffect jumpptr:req
	jumpifbyte CMP_COMMON_BITS, gMoveResultFlags, MOVE_RESULT_NO_EFFECT, \jumpptr
	.endm

	.macro jumpifbattletype flags:req, jumpptr:req
	jumpifword CMP_COMMON_BITS, gBattleTypeFlags, \flags, \jumpptr
	.endm

	.macro jumpifnotbattletype flags:req, jumpptr:req
	jumpifword CMP_NO_COMMON_BITS, gBattleTypeFlags, \flags, \jumpptr
	.endm
