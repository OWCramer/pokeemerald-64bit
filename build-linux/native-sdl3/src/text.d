build-linux/native-sdl3/src/text.o: build-linux/assets/graphics/fonts/down_arrow.png.4bpp build-linux/assets/graphics/fonts/down_arrow_alt.png.4bpp build-linux/assets/graphics/fonts/japanese_bold.png.hwjpnfont build-linux/assets/graphics/fonts/keypad_icons.png.4bpp build-linux/assets/graphics/fonts/unused_frlg_blanked_down_arrow.png.4bpp build-linux/assets/graphics/fonts/unused_frlg_down_arrow.png.4bpp include/battle.h include/battle_ai_switch_items.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/blit.h include/config.h include/constants/battle.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/dynamic_placeholder_text_util.h include/fonts.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/m4a.h include/main.h include/menu.h include/music_player.h include/palette.h include/pokeball.h include/pokemon.h include/sound.h include/sound_mixer.h include/sprite.h include/string_util.h include/task.h include/text.h include/window.h
build-linux/native-sdl3/src/text.d: include/battle.h include/battle_ai_switch_items.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/blit.h include/config.h include/constants/battle.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/dynamic_placeholder_text_util.h include/fonts.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/m4a.h include/main.h include/menu.h include/music_player.h include/palette.h include/pokeball.h include/pokemon.h include/sound.h include/sound_mixer.h include/sprite.h include/string_util.h include/task.h include/text.h include/window.h
build-linux/assets/graphics/fonts/down_arrow.png.4bpp:
build-linux/assets/graphics/fonts/down_arrow_alt.png.4bpp:
build-linux/assets/graphics/fonts/japanese_bold.png.hwjpnfont:
build-linux/assets/graphics/fonts/keypad_icons.png.4bpp:
build-linux/assets/graphics/fonts/unused_frlg_blanked_down_arrow.png.4bpp:
build-linux/assets/graphics/fonts/unused_frlg_down_arrow.png.4bpp:
include/battle.h:
include/battle_ai_switch_items.h:
include/battle_bg.h:
include/battle_gfx_sfx_util.h:
include/battle_main.h:
include/battle_message.h:
include/battle_script_commands.h:
include/battle_util.h:
include/battle_util2.h:
include/blit.h:
include/config.h:
include/constants/battle.h:
include/constants/battle_script_commands.h:
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
include/dynamic_placeholder_text_util.h:
include/fonts.h:
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
include/m4a.h:
include/main.h:
include/menu.h:
include/music_player.h:
include/palette.h:
include/pokeball.h:
include/pokemon.h:
include/sound.h:
include/sound_mixer.h:
include/sprite.h:
include/string_util.h:
include/task.h:
include/text.h:
include/window.h:
ifndef build-linux/assets/graphics/fonts/down_arrow.png.4bpp
build-linux/assets/graphics/fonts/down_arrow.png.4bpp := defined
build-linux/assets/graphics/fonts/down_arrow.png.4bpp: graphics/fonts/down_arrow.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/down_arrow_alt.png.4bpp
build-linux/assets/graphics/fonts/down_arrow_alt.png.4bpp := defined
build-linux/assets/graphics/fonts/down_arrow_alt.png.4bpp: graphics/fonts/down_arrow_alt.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/japanese_bold.png.hwjpnfont
build-linux/assets/graphics/fonts/japanese_bold.png.hwjpnfont := defined
build-linux/assets/graphics/fonts/japanese_bold.png.hwjpnfont: graphics/fonts/japanese_bold.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/keypad_icons.png.4bpp
build-linux/assets/graphics/fonts/keypad_icons.png.4bpp := defined
build-linux/assets/graphics/fonts/keypad_icons.png.4bpp: graphics/fonts/keypad_icons.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/unused_frlg_blanked_down_arrow.png.4bpp
build-linux/assets/graphics/fonts/unused_frlg_blanked_down_arrow.png.4bpp := defined
build-linux/assets/graphics/fonts/unused_frlg_blanked_down_arrow.png.4bpp: graphics/fonts/unused_frlg_blanked_down_arrow.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/unused_frlg_down_arrow.png.4bpp
build-linux/assets/graphics/fonts/unused_frlg_down_arrow.png.4bpp := defined
build-linux/assets/graphics/fonts/unused_frlg_down_arrow.png.4bpp: graphics/fonts/unused_frlg_down_arrow.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
