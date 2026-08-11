build-linux/native-sdl3/src/reset_rtc_screen.o: build-linux/assets/graphics/reset_rtc_screen/arrow.pal.gbapal build-linux/assets/graphics/reset_rtc_screen/arrow_down.png.4bpp build-linux/assets/graphics/reset_rtc_screen/arrow_right.png.4bpp include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/menu.h include/palette.h include/pokemon.h include/reset_rtc_screen.h include/rtc.h include/save.h include/scanline_effect.h include/siirtc.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/window.h
build-linux/native-sdl3/src/reset_rtc_screen.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/menu.h include/palette.h include/pokemon.h include/reset_rtc_screen.h include/rtc.h include/save.h include/scanline_effect.h include/siirtc.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/window.h
build-linux/assets/graphics/reset_rtc_screen/arrow.pal.gbapal:
build-linux/assets/graphics/reset_rtc_screen/arrow_down.png.4bpp:
build-linux/assets/graphics/reset_rtc_screen/arrow_right.png.4bpp:
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
include/constants/songs.h:
include/constants/sound.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
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
include/main.h:
include/menu.h:
include/palette.h:
include/pokemon.h:
include/reset_rtc_screen.h:
include/rtc.h:
include/save.h:
include/scanline_effect.h:
include/siirtc.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/window.h:
ifndef build-linux/assets/graphics/reset_rtc_screen/arrow.pal.gbapal
build-linux/assets/graphics/reset_rtc_screen/arrow.pal.gbapal := defined
build-linux/assets/graphics/reset_rtc_screen/arrow.pal.gbapal: graphics/reset_rtc_screen/arrow.pal
	@mkdir -p 'build-linux/assets/graphics/reset_rtc_screen'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/reset_rtc_screen/arrow_down.png.4bpp
build-linux/assets/graphics/reset_rtc_screen/arrow_down.png.4bpp := defined
build-linux/assets/graphics/reset_rtc_screen/arrow_down.png.4bpp: graphics/reset_rtc_screen/arrow_down.png
	@mkdir -p 'build-linux/assets/graphics/reset_rtc_screen'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/reset_rtc_screen/arrow_right.png.4bpp
build-linux/assets/graphics/reset_rtc_screen/arrow_right.png.4bpp := defined
build-linux/assets/graphics/reset_rtc_screen/arrow_right.png.4bpp: graphics/reset_rtc_screen/arrow_right.png
	@mkdir -p 'build-linux/assets/graphics/reset_rtc_screen'
	$(GFX) $< $@ 
endif
