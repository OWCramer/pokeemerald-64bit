build-linux/native-sdl3/src/pokenav_match_call_gfx.o: build-linux/assets/graphics/pokenav/match_call/call_window.pal.gbapal build-linux/assets/graphics/pokenav/match_call/list_window.pal.gbapal build-linux/assets/graphics/pokenav/match_call/options_cursor.png.4bpp.lz build-linux/assets/graphics/pokenav/match_call/options_cursor.png.gbapal build-linux/assets/graphics/pokenav/match_call/pokeball.pal.gbapal build-linux/assets/graphics/pokenav/match_call/pokeball.png.4bpp.lz build-linux/assets/graphics/pokenav/match_call/ui.bin.lz build-linux/assets/graphics/pokenav/match_call/ui.png.gbapal build-linux/assets/graphics/pokenav/match_call/ui.png_num_tiles_13__Wnum_tiles.4bpp.lz include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/region_map_sections.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/data.h include/decompress.h include/dma3.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/international_string_util.h include/list_menu.h include/main.h include/match_call.h include/menu.h include/overworld.h include/palette.h include/pokemon.h include/pokemon_storage_system.h include/pokenav.h include/region_map.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/window.h
build-linux/native-sdl3/src/pokenav_match_call_gfx.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/region_map_sections.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/data.h include/decompress.h include/dma3.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/international_string_util.h include/list_menu.h include/main.h include/match_call.h include/menu.h include/overworld.h include/palette.h include/pokemon.h include/pokemon_storage_system.h include/pokenav.h include/region_map.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/window.h
build-linux/assets/graphics/pokenav/match_call/call_window.pal.gbapal:
build-linux/assets/graphics/pokenav/match_call/list_window.pal.gbapal:
build-linux/assets/graphics/pokenav/match_call/options_cursor.png.4bpp.lz:
build-linux/assets/graphics/pokenav/match_call/options_cursor.png.gbapal:
build-linux/assets/graphics/pokenav/match_call/pokeball.pal.gbapal:
build-linux/assets/graphics/pokenav/match_call/pokeball.png.4bpp.lz:
build-linux/assets/graphics/pokenav/match_call/ui.bin.lz:
build-linux/assets/graphics/pokenav/match_call/ui.png.gbapal:
build-linux/assets/graphics/pokenav/match_call/ui.png_num_tiles_13__Wnum_tiles.4bpp.lz:
include/bg.h:
include/config.h:
include/constants/berry.h:
include/constants/characters.h:
include/constants/easy_chat.h:
include/constants/flags.h:
include/constants/game_stat.h:
include/constants/global.h:
include/constants/map_groups.h:
include/constants/maps.h:
include/constants/moves.h:
include/constants/opponents.h:
include/constants/pokedex.h:
include/constants/pokemon.h:
include/constants/region_map_sections.h:
include/constants/rematches.h:
include/constants/songs.h:
include/constants/sound.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
include/data.h:
include/decompress.h:
include/dma3.h:
include/gametypes.h:
include/gba/defines.h:
include/gba/gba.h:
include/gba/io_reg.h:
include/gba/isagbprint.h:
include/gba/macro.h:
include/gba/multiboot.h:
include/gba/syscall.h:
include/gba/types.h:
include/global.berry.h:
include/global.fieldmap.h:
include/global.h:
include/global.tv.h:
include/international_string_util.h:
include/list_menu.h:
include/main.h:
include/match_call.h:
include/menu.h:
include/overworld.h:
include/palette.h:
include/pokemon.h:
include/pokemon_storage_system.h:
include/pokenav.h:
include/region_map.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/trig.h:
include/window.h:
ifndef build-linux/assets/graphics/pokenav/match_call/call_window.pal.gbapal
build-linux/assets/graphics/pokenav/match_call/call_window.pal.gbapal := defined
build-linux/assets/graphics/pokenav/match_call/call_window.pal.gbapal: graphics/pokenav/match_call/call_window.pal
	@mkdir -p 'build-linux/assets/graphics/pokenav/match_call'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/match_call/list_window.pal.gbapal
build-linux/assets/graphics/pokenav/match_call/list_window.pal.gbapal := defined
build-linux/assets/graphics/pokenav/match_call/list_window.pal.gbapal: graphics/pokenav/match_call/list_window.pal
	@mkdir -p 'build-linux/assets/graphics/pokenav/match_call'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/match_call/options_cursor.png.4bpp
build-linux/assets/graphics/pokenav/match_call/options_cursor.png.4bpp := defined
build-linux/assets/graphics/pokenav/match_call/options_cursor.png.4bpp: graphics/pokenav/match_call/options_cursor.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/match_call'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/match_call/options_cursor.png.gbapal
build-linux/assets/graphics/pokenav/match_call/options_cursor.png.gbapal := defined
build-linux/assets/graphics/pokenav/match_call/options_cursor.png.gbapal: graphics/pokenav/match_call/options_cursor.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/match_call'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/match_call/pokeball.pal.gbapal
build-linux/assets/graphics/pokenav/match_call/pokeball.pal.gbapal := defined
build-linux/assets/graphics/pokenav/match_call/pokeball.pal.gbapal: graphics/pokenav/match_call/pokeball.pal
	@mkdir -p 'build-linux/assets/graphics/pokenav/match_call'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/match_call/pokeball.png.4bpp
build-linux/assets/graphics/pokenav/match_call/pokeball.png.4bpp := defined
build-linux/assets/graphics/pokenav/match_call/pokeball.png.4bpp: graphics/pokenav/match_call/pokeball.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/match_call'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/match_call/ui.bin.lz
build-linux/assets/graphics/pokenav/match_call/ui.bin.lz := defined
build-linux/assets/graphics/pokenav/match_call/ui.bin.lz: graphics/pokenav/match_call/ui.bin
	@mkdir -p 'build-linux/assets/graphics/pokenav/match_call'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/match_call/ui.png.gbapal
build-linux/assets/graphics/pokenav/match_call/ui.png.gbapal := defined
build-linux/assets/graphics/pokenav/match_call/ui.png.gbapal: graphics/pokenav/match_call/ui.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/match_call'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/match_call/ui.png_num_tiles_13__Wnum_tiles.4bpp
build-linux/assets/graphics/pokenav/match_call/ui.png_num_tiles_13__Wnum_tiles.4bpp := defined
build-linux/assets/graphics/pokenav/match_call/ui.png_num_tiles_13__Wnum_tiles.4bpp: graphics/pokenav/match_call/ui.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/match_call'
	$(GFX) $< $@ -num_tiles 13 -Wnum_tiles
endif
