build-linux/native-sdl3/src/diploma.o: build-linux/assets/graphics/diploma/hoenn.pal.gbapal build-linux/assets/graphics/diploma/national.pal.gbapal build-linux/assets/graphics/diploma/tilemap.bin.lz build-linux/assets/graphics/diploma/tiles.png.4bpp.lz include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/diploma.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/malloc.h include/menu.h include/overworld.h include/palette.h include/pokedex.h include/pokemon.h include/scanline_effect.h include/sprite.h include/string_util.h include/task.h include/text.h include/window.h
build-linux/native-sdl3/src/diploma.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/diploma.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/malloc.h include/menu.h include/overworld.h include/palette.h include/pokedex.h include/pokemon.h include/scanline_effect.h include/sprite.h include/string_util.h include/task.h include/text.h include/window.h
build-linux/assets/graphics/diploma/hoenn.pal.gbapal:
build-linux/assets/graphics/diploma/national.pal.gbapal:
build-linux/assets/graphics/diploma/tilemap.bin.lz:
build-linux/assets/graphics/diploma/tiles.png.4bpp.lz:
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
include/constants/rgb.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
include/decompress.h:
include/diploma.h:
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
include/gpu_regs.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/overworld.h:
include/palette.h:
include/pokedex.h:
include/pokemon.h:
include/scanline_effect.h:
include/sprite.h:
include/string_util.h:
include/task.h:
include/text.h:
include/window.h:
ifndef build-linux/assets/graphics/diploma/hoenn.pal.gbapal
build-linux/assets/graphics/diploma/hoenn.pal.gbapal := defined
build-linux/assets/graphics/diploma/hoenn.pal.gbapal: graphics/diploma/hoenn.pal
	@mkdir -p 'build-linux/assets/graphics/diploma'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/diploma/national.pal.gbapal
build-linux/assets/graphics/diploma/national.pal.gbapal := defined
build-linux/assets/graphics/diploma/national.pal.gbapal: graphics/diploma/national.pal
	@mkdir -p 'build-linux/assets/graphics/diploma'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/diploma/tilemap.bin.lz
build-linux/assets/graphics/diploma/tilemap.bin.lz := defined
build-linux/assets/graphics/diploma/tilemap.bin.lz: graphics/diploma/tilemap.bin
	@mkdir -p 'build-linux/assets/graphics/diploma'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/diploma/tiles.png.4bpp
build-linux/assets/graphics/diploma/tiles.png.4bpp := defined
build-linux/assets/graphics/diploma/tiles.png.4bpp: graphics/diploma/tiles.png
	@mkdir -p 'build-linux/assets/graphics/diploma'
	$(GFX) $< $@ 
endif
