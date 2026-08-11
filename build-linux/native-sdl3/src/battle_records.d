build-linux/native-sdl3/src/battle_records.o: build-linux/assets/graphics/trainer_hill/records_window.png.4bpp build-linux/assets/graphics/trainer_hill/records_window.png.gbapal graphics/trainer_hill/records_window.bin include/battle.h include/battle_ai_switch_items.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_records.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/bg.h include/config.h include/constants/battle.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/international_string_util.h include/link.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/menu_helpers.h include/overworld.h include/palette.h include/pokeball.h include/pokemon.h include/scanline_effect.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trainer_card.h include/trainer_hill.h include/window.h
build-linux/native-sdl3/src/battle_records.d: include/battle.h include/battle_ai_switch_items.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_records.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/bg.h include/config.h include/constants/battle.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/international_string_util.h include/link.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/menu_helpers.h include/overworld.h include/palette.h include/pokeball.h include/pokemon.h include/scanline_effect.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trainer_card.h include/trainer_hill.h include/window.h
build-linux/assets/graphics/trainer_hill/records_window.png.4bpp:
build-linux/assets/graphics/trainer_hill/records_window.png.gbapal:
graphics/trainer_hill/records_window.bin:
include/battle.h:
include/battle_ai_switch_items.h:
include/battle_bg.h:
include/battle_gfx_sfx_util.h:
include/battle_main.h:
include/battle_message.h:
include/battle_records.h:
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
include/link.h:
include/list_menu.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/menu_helpers.h:
include/overworld.h:
include/palette.h:
include/pokeball.h:
include/pokemon.h:
include/scanline_effect.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/trainer_card.h:
include/trainer_hill.h:
include/window.h:
ifndef build-linux/assets/graphics/trainer_hill/records_window.png.4bpp
build-linux/assets/graphics/trainer_hill/records_window.png.4bpp := defined
build-linux/assets/graphics/trainer_hill/records_window.png.4bpp: graphics/trainer_hill/records_window.png
	@mkdir -p 'build-linux/assets/graphics/trainer_hill'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/trainer_hill/records_window.png.gbapal
build-linux/assets/graphics/trainer_hill/records_window.png.gbapal := defined
build-linux/assets/graphics/trainer_hill/records_window.png.gbapal: graphics/trainer_hill/records_window.png
	@mkdir -p 'build-linux/assets/graphics/trainer_hill'
	$(GFX) $< $@ 
endif
