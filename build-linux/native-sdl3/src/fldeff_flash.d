build-linux/native-sdl3/src/fldeff_flash.o: build-linux/assets/graphics/cave_transition/black.pal.gbapal build-linux/assets/graphics/cave_transition/enter.pal.gbapal build-linux/assets/graphics/cave_transition/tilemap.bin.lz build-linux/assets/graphics/cave_transition/tiles.png.4bpp.lz build-linux/assets/graphics/cave_transition/white.pal.gbapal include/braille_puzzles.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/map_types.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/event_data.h include/event_scripts.h include/field_effect.h include/fldeff.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/overworld.h include/palette.h include/party_menu.h include/pokemon.h include/script.h include/sound.h include/sprite.h include/task.h
build-linux/native-sdl3/src/fldeff_flash.d: include/braille_puzzles.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/map_types.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/event_data.h include/event_scripts.h include/field_effect.h include/fldeff.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/overworld.h include/palette.h include/party_menu.h include/pokemon.h include/script.h include/sound.h include/sprite.h include/task.h
build-linux/assets/graphics/cave_transition/black.pal.gbapal:
build-linux/assets/graphics/cave_transition/enter.pal.gbapal:
build-linux/assets/graphics/cave_transition/tilemap.bin.lz:
build-linux/assets/graphics/cave_transition/tiles.png.4bpp.lz:
build-linux/assets/graphics/cave_transition/white.pal.gbapal:
include/braille_puzzles.h:
include/config.h:
include/constants/berry.h:
include/constants/easy_chat.h:
include/constants/flags.h:
include/constants/game_stat.h:
include/constants/global.h:
include/constants/map_groups.h:
include/constants/map_types.h:
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
include/event_data.h:
include/event_scripts.h:
include/field_effect.h:
include/fldeff.h:
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
include/overworld.h:
include/palette.h:
include/party_menu.h:
include/pokemon.h:
include/script.h:
include/sound.h:
include/sprite.h:
include/task.h:
ifndef build-linux/assets/graphics/cave_transition/black.pal.gbapal
build-linux/assets/graphics/cave_transition/black.pal.gbapal := defined
build-linux/assets/graphics/cave_transition/black.pal.gbapal: graphics/cave_transition/black.pal
	@mkdir -p 'build-linux/assets/graphics/cave_transition'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/cave_transition/enter.pal.gbapal
build-linux/assets/graphics/cave_transition/enter.pal.gbapal := defined
build-linux/assets/graphics/cave_transition/enter.pal.gbapal: graphics/cave_transition/enter.pal
	@mkdir -p 'build-linux/assets/graphics/cave_transition'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/cave_transition/tilemap.bin.lz
build-linux/assets/graphics/cave_transition/tilemap.bin.lz := defined
build-linux/assets/graphics/cave_transition/tilemap.bin.lz: graphics/cave_transition/tilemap.bin
	@mkdir -p 'build-linux/assets/graphics/cave_transition'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/cave_transition/tiles.png.4bpp
build-linux/assets/graphics/cave_transition/tiles.png.4bpp := defined
build-linux/assets/graphics/cave_transition/tiles.png.4bpp: graphics/cave_transition/tiles.png
	@mkdir -p 'build-linux/assets/graphics/cave_transition'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/cave_transition/white.pal.gbapal
build-linux/assets/graphics/cave_transition/white.pal.gbapal := defined
build-linux/assets/graphics/cave_transition/white.pal.gbapal: graphics/cave_transition/white.pal
	@mkdir -p 'build-linux/assets/graphics/cave_transition'
	$(GFX) $< $@ 
endif
