build-linux/native-sdl3/src/pokenav_ribbons_list.o: build-linux/assets/graphics/pokenav/ribbons/list_bg.bin.lz build-linux/assets/graphics/pokenav/ribbons/list_bg.png.4bpp.lz build-linux/assets/graphics/pokenav/ribbons/list_bg.png.gbapal build-linux/assets/graphics/pokenav/ribbons/list_ui.pal.gbapal include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/international_string_util.h include/list_menu.h include/main.h include/menu.h include/palette.h include/pokemon.h include/pokemon_storage_system.h include/pokenav.h include/sound.h include/sprite.h include/string_util.h include/task.h include/text.h include/window.h
build-linux/native-sdl3/src/pokenav_ribbons_list.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/international_string_util.h include/list_menu.h include/main.h include/menu.h include/palette.h include/pokemon.h include/pokemon_storage_system.h include/pokenav.h include/sound.h include/sprite.h include/string_util.h include/task.h include/text.h include/window.h
build-linux/assets/graphics/pokenav/ribbons/list_bg.bin.lz:
build-linux/assets/graphics/pokenav/ribbons/list_bg.png.4bpp.lz:
build-linux/assets/graphics/pokenav/ribbons/list_bg.png.gbapal:
build-linux/assets/graphics/pokenav/ribbons/list_ui.pal.gbapal:
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
include/menu.h:
include/palette.h:
include/pokemon.h:
include/pokemon_storage_system.h:
include/pokenav.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/task.h:
include/text.h:
include/window.h:
ifndef build-linux/assets/graphics/pokenav/ribbons/list_bg.bin.lz
build-linux/assets/graphics/pokenav/ribbons/list_bg.bin.lz := defined
build-linux/assets/graphics/pokenav/ribbons/list_bg.bin.lz: graphics/pokenav/ribbons/list_bg.bin
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/ribbons/list_bg.png.4bpp
build-linux/assets/graphics/pokenav/ribbons/list_bg.png.4bpp := defined
build-linux/assets/graphics/pokenav/ribbons/list_bg.png.4bpp: graphics/pokenav/ribbons/list_bg.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/ribbons/list_bg.png.gbapal
build-linux/assets/graphics/pokenav/ribbons/list_bg.png.gbapal := defined
build-linux/assets/graphics/pokenav/ribbons/list_bg.png.gbapal: graphics/pokenav/ribbons/list_bg.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/ribbons/list_ui.pal.gbapal
build-linux/assets/graphics/pokenav/ribbons/list_ui.pal.gbapal := defined
build-linux/assets/graphics/pokenav/ribbons/list_ui.pal.gbapal: graphics/pokenav/ribbons/list_ui.pal
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
