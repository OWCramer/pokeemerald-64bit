build-linux/native-sdl3/src/save_failed_screen.o: build-linux/assets/graphics/misc/clock_small.png.4bpp.lz build-linux/assets/graphics/misc/clock_small.png.gbapal include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/flash_internal.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/menu.h include/palette.h include/pokemon.h include/save.h include/sprite.h include/starter_choose.h include/task.h include/text.h include/text_window.h include/window.h
build-linux/native-sdl3/src/save_failed_screen.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/flash_internal.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/menu.h include/palette.h include/pokemon.h include/save.h include/sprite.h include/starter_choose.h include/task.h include/text.h include/text_window.h include/window.h
build-linux/assets/graphics/misc/clock_small.png.4bpp.lz:
build-linux/assets/graphics/misc/clock_small.png.gbapal:
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
include/gametypes.h:
include/gba/defines.h:
include/gba/flash_internal.h:
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
include/graphics.h:
include/main.h:
include/menu.h:
include/palette.h:
include/pokemon.h:
include/save.h:
include/sprite.h:
include/starter_choose.h:
include/task.h:
include/text.h:
include/text_window.h:
include/window.h:
ifndef build-linux/assets/graphics/misc/clock_small.png.4bpp
build-linux/assets/graphics/misc/clock_small.png.4bpp := defined
build-linux/assets/graphics/misc/clock_small.png.4bpp: graphics/misc/clock_small.png
	@mkdir -p 'build-linux/assets/graphics/misc'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/misc/clock_small.png.gbapal
build-linux/assets/graphics/misc/clock_small.png.gbapal := defined
build-linux/assets/graphics/misc/clock_small.png.gbapal: graphics/misc/clock_small.png
	@mkdir -p 'build-linux/assets/graphics/misc'
	$(GFX) $< $@ 
endif
