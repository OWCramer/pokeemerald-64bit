build-linux/native-sdl3/src/title_screen.o: build-linux/assets/graphics/title_screen/clouds.png.4bpp.lz build-linux/assets/graphics/title_screen/logo_shine.png.4bpp.lz build-linux/assets/graphics/title_screen/rayquaza.bin.lz build-linux/assets/graphics/title_screen/rayquaza.png.4bpp.lz build-linux/assets/graphics/title_screen/unused.pal.gbapal include/battle.h include/battle_ai_switch_items.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/berry_fix_program.h include/clear_save_data_menu.h include/config.h include/constants/battle.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/intro.h include/m4a.h include/main.h include/main_menu.h include/music_player.h include/palette.h include/pokeball.h include/pokemon.h include/reset_rtc_screen.h include/scanline_effect.h include/sound.h include/sound_mixer.h include/sprite.h include/task.h include/title_screen.h include/trig.h
build-linux/native-sdl3/src/title_screen.d: include/battle.h include/battle_ai_switch_items.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/berry_fix_program.h include/clear_save_data_menu.h include/config.h include/constants/battle.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/intro.h include/m4a.h include/main.h include/main_menu.h include/music_player.h include/palette.h include/pokeball.h include/pokemon.h include/reset_rtc_screen.h include/scanline_effect.h include/sound.h include/sound_mixer.h include/sprite.h include/task.h include/title_screen.h include/trig.h
build-linux/assets/graphics/title_screen/clouds.png.4bpp.lz:
build-linux/assets/graphics/title_screen/logo_shine.png.4bpp.lz:
build-linux/assets/graphics/title_screen/rayquaza.bin.lz:
build-linux/assets/graphics/title_screen/rayquaza.png.4bpp.lz:
build-linux/assets/graphics/title_screen/unused.pal.gbapal:
include/battle.h:
include/battle_ai_switch_items.h:
include/battle_bg.h:
include/battle_gfx_sfx_util.h:
include/battle_main.h:
include/battle_message.h:
include/battle_script_commands.h:
include/battle_util.h:
include/battle_util2.h:
include/berry_fix_program.h:
include/clear_save_data_menu.h:
include/config.h:
include/constants/battle.h:
include/constants/battle_script_commands.h:
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
include/intro.h:
include/m4a.h:
include/main.h:
include/main_menu.h:
include/music_player.h:
include/palette.h:
include/pokeball.h:
include/pokemon.h:
include/reset_rtc_screen.h:
include/scanline_effect.h:
include/sound.h:
include/sound_mixer.h:
include/sprite.h:
include/task.h:
include/title_screen.h:
include/trig.h:
ifndef build-linux/assets/graphics/title_screen/clouds.png.4bpp
build-linux/assets/graphics/title_screen/clouds.png.4bpp := defined
build-linux/assets/graphics/title_screen/clouds.png.4bpp: graphics/title_screen/clouds.png
	@mkdir -p 'build-linux/assets/graphics/title_screen'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/title_screen/logo_shine.png.4bpp
build-linux/assets/graphics/title_screen/logo_shine.png.4bpp := defined
build-linux/assets/graphics/title_screen/logo_shine.png.4bpp: graphics/title_screen/logo_shine.png
	@mkdir -p 'build-linux/assets/graphics/title_screen'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/title_screen/rayquaza.bin.lz
build-linux/assets/graphics/title_screen/rayquaza.bin.lz := defined
build-linux/assets/graphics/title_screen/rayquaza.bin.lz: graphics/title_screen/rayquaza.bin
	@mkdir -p 'build-linux/assets/graphics/title_screen'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/title_screen/rayquaza.png.4bpp
build-linux/assets/graphics/title_screen/rayquaza.png.4bpp := defined
build-linux/assets/graphics/title_screen/rayquaza.png.4bpp: graphics/title_screen/rayquaza.png
	@mkdir -p 'build-linux/assets/graphics/title_screen'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/title_screen/unused.pal.gbapal
build-linux/assets/graphics/title_screen/unused.pal.gbapal := defined
build-linux/assets/graphics/title_screen/unused.pal.gbapal: graphics/title_screen/unused.pal
	@mkdir -p 'build-linux/assets/graphics/title_screen'
	$(GFX) $< $@ 
endif
