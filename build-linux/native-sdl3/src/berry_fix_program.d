build-linux/native-sdl3/src/berry_fix_program.o: build-linux/assets/graphics/berry_fix/text.pal.gbapal include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/m4a.h include/main.h include/malloc.h include/menu.h include/multiboot.h include/music_player.h include/pokemon.h include/scanline_effect.h include/sound_mixer.h include/sprite.h include/task.h include/text.h include/window.h
build-linux/native-sdl3/src/berry_fix_program.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/m4a.h include/main.h include/malloc.h include/menu.h include/multiboot.h include/music_player.h include/pokemon.h include/scanline_effect.h include/sound_mixer.h include/sprite.h include/task.h include/text.h include/window.h
build-linux/assets/graphics/berry_fix/text.pal.gbapal:
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
include/gametypes.h:
include/gba/defines.h:
include/gba/gba.h:
include/gba/io_reg.h:
include/gba/isagbprint.h:
include/gba/m4a_internal.h:
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
include/m4a.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/multiboot.h:
include/music_player.h:
include/pokemon.h:
include/scanline_effect.h:
include/sound_mixer.h:
include/sprite.h:
include/task.h:
include/text.h:
include/window.h:
ifndef build-linux/assets/graphics/berry_fix/text.pal.gbapal
build-linux/assets/graphics/berry_fix/text.pal.gbapal := defined
build-linux/assets/graphics/berry_fix/text.pal.gbapal: graphics/berry_fix/text.pal
	@mkdir -p 'build-linux/assets/graphics/berry_fix'
	$(GFX) $< $@ 
endif
