build-linux/native-sdl3/src/mon_markings.o: build-linux/assets/graphics/interface/mon_markings.png.4bpp build-linux/assets/graphics/interface/mon_markings.png.gbapal include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/dma3.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/graphics.h include/list_menu.h include/main.h include/mon_markings.h include/pokemon.h include/sound.h include/sprite.h include/text_window.h include/window.h
build-linux/native-sdl3/src/mon_markings.d: include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/dma3.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/graphics.h include/list_menu.h include/main.h include/mon_markings.h include/pokemon.h include/sound.h include/sprite.h include/text_window.h include/window.h
build-linux/assets/graphics/interface/mon_markings.png.4bpp:
build-linux/assets/graphics/interface/mon_markings.png.gbapal:
include/config.h:
include/constants/berry.h:
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
include/graphics.h:
include/list_menu.h:
include/main.h:
include/mon_markings.h:
include/pokemon.h:
include/sound.h:
include/sprite.h:
include/text_window.h:
include/window.h:
ifndef build-linux/assets/graphics/interface/mon_markings.png.4bpp
build-linux/assets/graphics/interface/mon_markings.png.4bpp := defined
build-linux/assets/graphics/interface/mon_markings.png.4bpp: graphics/interface/mon_markings.png
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/interface/mon_markings.png.gbapal
build-linux/assets/graphics/interface/mon_markings.png.gbapal := defined
build-linux/assets/graphics/interface/mon_markings.png.gbapal: graphics/interface/mon_markings.png
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
