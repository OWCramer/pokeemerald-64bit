build-linux/native-sdl3/src/battle_transition_frontier.o: build-linux/assets/graphics/battle_transitions/frontier_logo_center.bin.lz build-linux/assets/graphics/battle_transitions/frontier_logo_center.png_num_tiles_43__Wnum_tiles.4bpp.lz build-linux/assets/graphics/battle_transitions/frontier_logo_circles.png.4bpp.lz build-linux/assets/graphics/battle_transitions/frontier_logo_circles.png.gbapal include/battle_transition.h include/battle_transition_frontier.h include/bg.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/palette.h include/pokemon.h include/sprite.h include/task.h include/trig.h
build-linux/native-sdl3/src/battle_transition_frontier.d: include/battle_transition.h include/battle_transition_frontier.h include/bg.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/palette.h include/pokemon.h include/sprite.h include/task.h include/trig.h
build-linux/assets/graphics/battle_transitions/frontier_logo_center.bin.lz:
build-linux/assets/graphics/battle_transitions/frontier_logo_center.png_num_tiles_43__Wnum_tiles.4bpp.lz:
build-linux/assets/graphics/battle_transitions/frontier_logo_circles.png.4bpp.lz:
build-linux/assets/graphics/battle_transitions/frontier_logo_circles.png.gbapal:
include/battle_transition.h:
include/battle_transition_frontier.h:
include/bg.h:
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
include/constants/rgb.h:
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
include/gpu_regs.h:
include/palette.h:
include/pokemon.h:
include/sprite.h:
include/task.h:
include/trig.h:
ifndef build-linux/assets/graphics/battle_transitions/frontier_logo_center.bin.lz
build-linux/assets/graphics/battle_transitions/frontier_logo_center.bin.lz := defined
build-linux/assets/graphics/battle_transitions/frontier_logo_center.bin.lz: graphics/battle_transitions/frontier_logo_center.bin
	@mkdir -p 'build-linux/assets/graphics/battle_transitions'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/battle_transitions/frontier_logo_center.png_num_tiles_43__Wnum_tiles.4bpp
build-linux/assets/graphics/battle_transitions/frontier_logo_center.png_num_tiles_43__Wnum_tiles.4bpp := defined
build-linux/assets/graphics/battle_transitions/frontier_logo_center.png_num_tiles_43__Wnum_tiles.4bpp: graphics/battle_transitions/frontier_logo_center.png
	@mkdir -p 'build-linux/assets/graphics/battle_transitions'
	$(GFX) $< $@ -num_tiles 43 -Wnum_tiles
endif
ifndef build-linux/assets/graphics/battle_transitions/frontier_logo_circles.png.4bpp
build-linux/assets/graphics/battle_transitions/frontier_logo_circles.png.4bpp := defined
build-linux/assets/graphics/battle_transitions/frontier_logo_circles.png.4bpp: graphics/battle_transitions/frontier_logo_circles.png
	@mkdir -p 'build-linux/assets/graphics/battle_transitions'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/battle_transitions/frontier_logo_circles.png.gbapal
build-linux/assets/graphics/battle_transitions/frontier_logo_circles.png.gbapal := defined
build-linux/assets/graphics/battle_transitions/frontier_logo_circles.png.gbapal: graphics/battle_transitions/frontier_logo_circles.png
	@mkdir -p 'build-linux/assets/graphics/battle_transitions'
	$(GFX) $< $@ 
endif
