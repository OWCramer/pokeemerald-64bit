build-linux/native-sdl3/src/move_relearner.o: build-linux/assets/graphics/interface/ui_learn_move.png.4bpp build-linux/assets/graphics/interface/ui_learn_move.png.gbapal include/battle.h include/battle_ai_switch_items.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/bg.h include/config.h include/constants/battle.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/contest_effect.h include/data.h include/event_data.h include/field_screen_effect.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/menu_helpers.h include/menu_specialized.h include/move_relearner.h include/overworld.h include/palette.h include/player_pc.h include/pokeball.h include/pokemon.h include/pokemon_summary_screen.h include/script.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/window.h
build-linux/native-sdl3/src/move_relearner.d: include/battle.h include/battle_ai_switch_items.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/bg.h include/config.h include/constants/battle.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/contest_effect.h include/data.h include/event_data.h include/field_screen_effect.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/menu_helpers.h include/menu_specialized.h include/move_relearner.h include/overworld.h include/palette.h include/player_pc.h include/pokeball.h include/pokemon.h include/pokemon_summary_screen.h include/script.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/window.h
build-linux/assets/graphics/interface/ui_learn_move.png.4bpp:
build-linux/assets/graphics/interface/ui_learn_move.png.gbapal:
include/battle.h:
include/battle_ai_switch_items.h:
include/battle_bg.h:
include/battle_gfx_sfx_util.h:
include/battle_main.h:
include/battle_message.h:
include/battle_script_commands.h:
include/battle_util.h:
include/battle_util2.h:
include/bg.h:
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
include/constants/moves.h:
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
include/contest_effect.h:
include/data.h:
include/event_data.h:
include/field_screen_effect.h:
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
include/list_menu.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/menu_helpers.h:
include/menu_specialized.h:
include/move_relearner.h:
include/overworld.h:
include/palette.h:
include/player_pc.h:
include/pokeball.h:
include/pokemon.h:
include/pokemon_summary_screen.h:
include/script.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/window.h:
ifndef build-linux/assets/graphics/interface/ui_learn_move.png.4bpp
build-linux/assets/graphics/interface/ui_learn_move.png.4bpp := defined
build-linux/assets/graphics/interface/ui_learn_move.png.4bpp: graphics/interface/ui_learn_move.png
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/interface/ui_learn_move.png.gbapal
build-linux/assets/graphics/interface/ui_learn_move.png.gbapal := defined
build-linux/assets/graphics/interface/ui_learn_move.png.gbapal: graphics/interface/ui_learn_move.png
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
