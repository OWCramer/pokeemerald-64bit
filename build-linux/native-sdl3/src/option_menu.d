build-linux/native-sdl3/src/option_menu.o: build-linux/assets/graphics/interface/option_menu_equals_sign.png.4bpp build-linux/assets/graphics/interface/option_menu_text.pal.gbapal include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/international_string_util.h include/list_menu.h include/main.h include/menu.h include/music_player.h include/option_menu.h include/palette.h include/platform.h include/pokemon.h include/scanline_effect.h include/siirtc.h include/sound.h include/sound_mixer.h include/sprite.h include/strings.h include/task.h include/text.h include/text_window.h include/window.h
build-linux/native-sdl3/src/option_menu.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/international_string_util.h include/list_menu.h include/main.h include/menu.h include/music_player.h include/option_menu.h include/palette.h include/platform.h include/pokemon.h include/scanline_effect.h include/siirtc.h include/sound.h include/sound_mixer.h include/sprite.h include/strings.h include/task.h include/text.h include/text_window.h include/window.h
build-linux/assets/graphics/interface/option_menu_equals_sign.png.4bpp:
build-linux/assets/graphics/interface/option_menu_text.pal.gbapal:
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
include/international_string_util.h:
include/list_menu.h:
include/main.h:
include/menu.h:
include/music_player.h:
include/option_menu.h:
include/palette.h:
include/platform.h:
include/pokemon.h:
include/scanline_effect.h:
include/siirtc.h:
include/sound.h:
include/sound_mixer.h:
include/sprite.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/window.h:
ifndef build-linux/assets/graphics/interface/option_menu_equals_sign.png.4bpp
build-linux/assets/graphics/interface/option_menu_equals_sign.png.4bpp := defined
build-linux/assets/graphics/interface/option_menu_equals_sign.png.4bpp: graphics/interface/option_menu_equals_sign.png
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/interface/option_menu_text.pal.gbapal
build-linux/assets/graphics/interface/option_menu_text.pal.gbapal := defined
build-linux/assets/graphics/interface/option_menu_text.pal.gbapal: graphics/interface/option_menu_text.pal
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
