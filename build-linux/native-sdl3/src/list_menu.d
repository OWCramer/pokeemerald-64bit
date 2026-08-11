build-linux/native-sdl3/src/list_menu.o: build-linux/assets/graphics/interface/arrow_cursor.png.4bpp.lz build-linux/assets/graphics/interface/outline_cursor.png_num_tiles_8__Wnum_tiles.4bpp.lz build-linux/assets/graphics/interface/red.pal.gbapal build-linux/assets/graphics/interface/scroll_indicator.png.4bpp.lz include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/palette.h include/pokemon.h include/sound.h include/sprite.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/window.h
build-linux/native-sdl3/src/list_menu.d: include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/palette.h include/pokemon.h include/sound.h include/sprite.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/window.h
build-linux/assets/graphics/interface/arrow_cursor.png.4bpp.lz:
build-linux/assets/graphics/interface/outline_cursor.png_num_tiles_8__Wnum_tiles.4bpp.lz:
build-linux/assets/graphics/interface/red.pal.gbapal:
build-linux/assets/graphics/interface/scroll_indicator.png.4bpp.lz:
include/config.h:
include/constants/berry.h:
include/constants/characters.h:
include/constants/easy_chat.h:
include/constants/flags.h:
include/constants/game_stat.h:
include/constants/global.h:
include/constants/map_groups.h:
include/constants/maps.h:
include/constants/opponents.h:
include/constants/pokedex.h:
include/constants/pokemon.h:
include/constants/rematches.h:
include/constants/songs.h:
include/constants/sound.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
include/decompress.h:
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
include/list_menu.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/palette.h:
include/pokemon.h:
include/sound.h:
include/sprite.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/trig.h:
include/window.h:
ifndef build-linux/assets/graphics/interface/arrow_cursor.png.4bpp
build-linux/assets/graphics/interface/arrow_cursor.png.4bpp := defined
build-linux/assets/graphics/interface/arrow_cursor.png.4bpp: graphics/interface/arrow_cursor.png
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/interface/outline_cursor.png_num_tiles_8__Wnum_tiles.4bpp
build-linux/assets/graphics/interface/outline_cursor.png_num_tiles_8__Wnum_tiles.4bpp := defined
build-linux/assets/graphics/interface/outline_cursor.png_num_tiles_8__Wnum_tiles.4bpp: graphics/interface/outline_cursor.png
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ -num_tiles 8 -Wnum_tiles
endif
ifndef build-linux/assets/graphics/interface/red.pal.gbapal
build-linux/assets/graphics/interface/red.pal.gbapal := defined
build-linux/assets/graphics/interface/red.pal.gbapal: graphics/interface/red.pal
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/interface/scroll_indicator.png.4bpp
build-linux/assets/graphics/interface/scroll_indicator.png.4bpp := defined
build-linux/assets/graphics/interface/scroll_indicator.png.4bpp: graphics/interface/scroll_indicator.png
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
