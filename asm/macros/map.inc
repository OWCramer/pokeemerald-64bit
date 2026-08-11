/* Most of the macros in this file are for arranging map event data, and are output by mapjson using data from each map's JSON file.*/

	/* Takes a MAP constant and outputs the map group and map number as separate bytes*/
	.macro map map_id:req
	.ifdef \map_id
	.byte \map_id >> 8    @ map group
	.byte \map_id & 0xFF  @ map num
	.else
	.error "undefined map (check for typos)"
	.endif
	.endm

	/* Defines a map script. 'type' is any MAP_SCRIPT_* constant (see include/constants/map_scripts.h)*/
	/* mapScripts is a raw byte stream walked with a hardcoded stride of 5
	   (see MapHeaderGetScriptTable), so the pointer stays 4 bytes wide and
	   holds an anchor-relative offset instead. */
	.macro map_script type:req, script:req
	.byte \type
	.ifdef PORTABLE_ASM
	.ifc \script, NULL
	.long 0
	.else
	.long (\script - .)
	.endif
	.else
	.int \script
	.endif
	.endm

	/* Defines an entry in a map script table (for either ON_WARP_INTO_MAP_TABLE or ON_FRAME_TABLE)*/
	/* Also a raw stream: MapHeaderCheckScriptTable walks it with ptr += 2,
	   ptr += 2, ptr += 4. Keep 4 bytes; store an anchor-relative offset. */
	.macro map_script_2 var:req, compare:req, script:req
	.short \var
	.short \compare
	.ifdef PORTABLE_ASM
	.ifc \script, NULL
	.long 0
	.else
	.long (\script - .)
	.endif
	.else
	.int \script
	.endif
	.endm

	/* Defines an object event template for map data, to be used by a normal object. Mirrors the struct layout of ObjectEventTemplate in include/global.fieldmap.h*/
	.macro object_event index:req, gfx:req, x:req, y:req, elevation:req, movement_type:req, x_radius:req, y_radius:req, trainer_type:req, sight_radius_tree_etc:req, script:req, event_flag:req
	.byte \index
	.byte \gfx
	.byte OBJ_KIND_NORMAL
	.space 1  /* Padding*/
	.2byte \x, \y
	.byte \elevation
	.byte \movement_type
	.byte ((\y_radius << 4) | \x_radius)
	.space 1  /* Padding*/
	.short \trainer_type
	.short \sight_radius_tree_etc
	/* ObjectEventTemplate is a real C struct: 24 bytes on GBA, 32 on a 64-bit
	   host with script at offset 16 and flagId at 24. */
	.ifdef PORTABLE_ASM
	.quad \script
	.short \event_flag
	.space 6  /* Padding to sizeof == 32*/
	.else
	.int \script
	.short \event_flag
	.space 2  /* Padding*/
	.endif
	inc _num_npcs
	.endm

	/* Defines an object event template for map data, to be used by a clone object. Mirrors the struct layout of ObjectEventTemplate in include/global.fieldmap.h*/
	/* NOTE: The handling for this type of event does not exist in Emerald by default; it is exclusive to FRLG.*/
	.macro clone_event index:req, gfx:req, x:req, y:req, target_local_id:req, target_map_id:req
	.byte \index
	.byte \gfx
	.byte OBJ_KIND_CLONE
	.space 1  /* Padding*/
	.2byte \x, \y
	.byte \target_local_id
	.space 3  /* Padding*/
	.2byte \target_map_id & 0xFF  /* map num*/
	.2byte \target_map_id >> 8    /* map group*/
	/* Shares ObjectEventTemplate's layout: 24 bytes on GBA, 32 on a 64-bit host. */
	.ifdef PORTABLE_ASM
	.space 16 /* Padding*/
	.else
	.space 8  /* Padding*/
	.endif
	inc _num_npcs
	.endm

	/* Defines a warp event for map data. Mirrors the struct layout of WarpEvent in include/global.fieldmap.h*/
	.macro warp_def x:req, y:req, elevation:req, warpId:req, map_id:req
	.short \x, \y
	.byte \elevation
	.byte \warpId
	.byte \map_id & 0xFF  /* map num*/
	.byte \map_id >> 8    /* map group*/
	inc _num_warps
	.endm

	/* Defines a coord event for map data. Mirrors the struct layout of CoordEvent in include/global.fieldmap.h*/
	.macro coord_event x:req, y:req, elevation:req, var:req, varValue:req, script:req
	.2byte \x, \y
	.byte \elevation
	.space 1  /* Padding*/
	.2byte \var
	.2byte \varValue
	/* CoordEvent: 16 bytes on GBA, 24 on a 64-bit host with script at 16. */
	.ifdef PORTABLE_ASM
	.space 6  /* Padding*/
	.quad \script
	.else
	.space 2  /* Padding*/
	.4byte \script
	.endif
	inc _num_traps
	.endm

	/* Defines a weather coord event for map data. Any coord event is treated as a weather coord event if its script is NULL*/
	.macro coord_weather_event x:req, y:req, elevation:req, weather:req
	coord_event \x, \y, \elevation, \weather, 0, NULL
	.endm

	/* Defines a generic background event for map data. Mirrors the struct layout of BgEvent in include/global.fieldmap.h*/
	/* 'kind' is any BG_EVENT_* constant (see include/constants/event_bg.h).*/
	/* 'arg6' and 'arg7' are used differently depending on the bg event type. See macros below*/
	.macro bg_event x:req, y:req, elevation:req, kind:req, arg6:req, arg7
	.short \x, \y
	.byte \elevation
	.byte \kind
	.space 2  /* Padding*/
	/* BgEvent: 12 bytes on GBA, 16 on a 64-bit host with bgUnion at 8. */
	.if \kind != BG_EVENT_HIDDEN_ITEM
		.ifdef PORTABLE_ASM
		.quad \arg6
		.else
		.int \arg6
		.endif
	.else
		.short \arg6
		.short \arg7
		.ifdef PORTABLE_ASM
		.space 4  /* Padding to sizeof == 16*/
		.endif
	.endif
	inc _num_signs
	.endm

	/* Defines a background sign event for map data. 'facing_dir' is any of the BG_EVENT_PLAYER_FACING_* constants (see include/constants/event_bg.h)*/
	.macro bg_sign_event x:req, y:req, elevation:req, facing_dir:req, script:req
	bg_event \x, \y, \elevation, \facing_dir, \script
	.endm

	/* Defines a background hidden item event for map data*/
	.macro bg_hidden_item_event x:req, y:req, elevation:req, item:req, flag:req
	.if \flag < FLAG_HIDDEN_ITEMS_START
	.error "Hidden Item flag \flag is too small. Must be >= FLAG_HIDDEN_ITEMS_START."
	.endif
	bg_event \x, \y, \elevation, BG_EVENT_HIDDEN_ITEM, \item, ((\flag) - FLAG_HIDDEN_ITEMS_START)
	.endm

	/* Defines a background secret base event for map data*/
	.macro bg_secret_base_event x:req, y:req, elevation:req, secret_base_id:req
	bg_event \x, \y, \elevation, BG_EVENT_SECRET_BASE, \secret_base_id
	.endm

	/* Defines the table of event data for a map. Mirrors the struct layout of MapEvents in include/global.fieldmap.h*/
	.macro map_events npcs:req, warps:req, traps:req, signs:req
	.byte _num_npcs, _num_warps, _num_traps, _num_signs
	/* MapEvents: 20 bytes on GBA, 40 on a 64-bit host -- the four counts are
	   followed by padding to 8 before the first pointer. */
	.ifdef PORTABLE_ASM
	.space 4  /* Padding*/
	.quad \npcs
	.quad \warps
	.quad \traps
	.quad \signs
	.else
	.int \npcs, \warps, \traps, \signs
	.endif
	reset_map_events
	.endm

	/* Resets the event counters used to track how many events a map has. Run when the events table is created by map_events*/
	.macro reset_map_events
	.set _num_npcs, 0
	.set _num_warps, 0
	.set _num_traps, 0
	.set _num_signs, 0
	.endm

	/* Initialize the event counters for the first map*/
	reset_map_events


	/* Directions for connecting maps*/
	/* The map.json files will only have e.g. "down" as direction data, and this will be appended to "connection_" by the connection macro*/
	.equiv connection_down, CONNECTION_SOUTH
	.equiv connection_up, CONNECTION_NORTH
	.equiv connection_left, CONNECTION_WEST
	.equiv connection_right, CONNECTION_EAST
	.equiv connection_dive, CONNECTION_DIVE
	.equiv connection_emerge, CONNECTION_EMERGE

	/* Defines a map connection. Mirrors the struct layout of MapConnection in include/global.fieldmap.h*/
	.macro connection direction:req, offset:req, map:req
	.byte connection_\direction
	.space 3  /* Padding*/
	.int \offset
	map \map
	.space 2  /* Padding*/
	.endm

	/* Defines the flags for a map header. Mirrors the layout of the bitfield in struct MapHeader in include/global.fieldmap.h*/
	.macro map_header_flags allow_cycling:req, allow_escaping:req, allow_running:req, show_map_name:req
	.byte ((\show_map_name & 1) << 3) | ((\allow_running & 1) << 2) | ((\allow_escaping & 1) << 1) | \allow_cycling
	.endm
