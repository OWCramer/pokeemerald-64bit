	/* struct Song: 8 bytes on GBA, 16 on a 64-bit host (header at 0, ms at 8). */
	.macro song label:req, music_player:req, unknown:req
	.ifdef PORTABLE_ASM
	.quad \label
	.short \music_player
	.short \unknown
	.space 4
	.else
	.int \label
	.short \music_player
	.short \unknown
	.endif
	.endm

	/* struct MusicPlayer: 12 bytes on GBA, 24 on a 64-bit host
	   (info 0, track 8, numTracks 16, unk_A 18). */
	.macro music_player info_struct:req, track_struct:req, num_tracks:req, unknown:req
	.ifdef PORTABLE_ASM
	.quad \info_struct
	.quad \track_struct
	.byte \num_tracks
	.space 1  /* Padding*/
	.short \unknown
	.space 4  /* Padding*/
	.else
	.int \info_struct
	.int \track_struct
	.byte \num_tracks
	.space 1  /* Padding*/
	.short \unknown
	.endif
	.endm

	.macro voice_group label:req, starting_note
	/* Voicegroup entries are ToneData/MP2KInstrument structs, which are
	   8-byte aligned on a 64-bit host (they hold pointers). This .align sits
	   inside a macro body, so the build's .align rewrite never sees it. */
	.ifdef PORTABLE_ASM
	.balign 8
	.else
	.align 2
	.endif
	.ifb \starting_note
		.global voicegroup_\label 
		voicegroup_\label:
	.else
		/* 0xC is the GBA sizeof(ToneData). On a 64-bit host an instrument is
		   24 bytes (MP2KInstrument), so a voicegroup declared with a
		   starting_note would otherwise resolve to the wrong base and play
		   the wrong samples. */
		.ifdef PORTABLE_ASM
		.set voicegroup_\label, . - \starting_note * 24
		.else
		.set voicegroup_\label, . - \starting_note * 0xC
		.endif
	.endif
	.endm

	.macro keysplit label:req, starting_note
	.ifb \starting_note
		.global keysplit_\label
		keysplit_\label:
		.set _last_note, 0
	.else
		.set keysplit_\label, . - \starting_note
		.set _last_note, \starting_note
	.endif
	.set _last_split, 0
	.endm

	.macro split index:req, ending_note:req
	.if \ending_note < _last_note
		.if _last_split == 0
			.error "split's ending_note earlier than previous keysplit's starting_note"
		.else
			.error "split's ending_note earlier than previous split's ending_note"
		.endif
	.else
	.rept \ending_note - _last_note
	  .byte \index
	.endr
	.endif
	.set _last_note, \ending_note
	.set _last_split, 1
	.endm
