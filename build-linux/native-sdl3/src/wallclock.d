build-linux/native-sdl3/src/wallclock.o: build-linux/assets/graphics/wallclock/hand.png.4bpp.lz build-linux/assets/graphics/wallclock/text_prompt.pal.gbapal include/bg.h include/clock.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/menu.h include/palette.h include/pokemon.h include/rtc.h include/scanline_effect.h include/siirtc.h include/sound.h include/sprite.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/wallclock.h include/window.h
build-linux/native-sdl3/src/wallclock.d: include/bg.h include/clock.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/menu.h include/palette.h include/pokemon.h include/rtc.h include/scanline_effect.h include/siirtc.h include/sound.h include/sprite.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/wallclock.h include/window.h
build-linux/assets/graphics/wallclock/hand.png.4bpp.lz:
build-linux/assets/graphics/wallclock/text_prompt.pal.gbapal:
include/bg.h:
include/clock.h:
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
include/constants/songs.h:
include/constants/sound.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
include/decompress.h:
include/event_data.h:
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
include/graphics.h:
include/main.h:
include/menu.h:
include/palette.h:
include/pokemon.h:
include/rtc.h:
include/scanline_effect.h:
include/siirtc.h:
include/sound.h:
include/sprite.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/trig.h:
include/wallclock.h:
include/window.h:
ifndef build-linux/assets/graphics/wallclock/hand.png.4bpp
build-linux/assets/graphics/wallclock/hand.png.4bpp := defined
build-linux/assets/graphics/wallclock/hand.png.4bpp: graphics/wallclock/hand.png
	@mkdir -p 'build-linux/assets/graphics/wallclock'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/wallclock/text_prompt.pal.gbapal
build-linux/assets/graphics/wallclock/text_prompt.pal.gbapal := defined
build-linux/assets/graphics/wallclock/text_prompt.pal.gbapal: graphics/wallclock/text_prompt.pal
	@mkdir -p 'build-linux/assets/graphics/wallclock'
	$(GFX) $< $@ 
endif
