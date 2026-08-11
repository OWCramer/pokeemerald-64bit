build-linux/native-sdl3/src/naming_screen.o: build-linux/assets/graphics/naming_screen/keyboard.pal.gbapal build-linux/assets/graphics/naming_screen/pc_icon_off.png.4bpp build-linux/assets/graphics/naming_screen/pc_icon_on.png.4bpp build-linux/assets/graphics/naming_screen/rival.pal.gbapal include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/event_objects.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_event_ids.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/data.h include/event_data.h include/event_object_movement.h include/field_effect.h include/field_player_avatar.h include/field_specials.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/malloc.h include/menu.h include/naming_screen.h include/overworld.h include/palette.h include/pokemon.h include/pokemon_icon.h include/pokemon_storage_system.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/walda_phrase.h include/window.h
build-linux/native-sdl3/src/naming_screen.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/event_objects.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_event_ids.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/data.h include/event_data.h include/event_object_movement.h include/field_effect.h include/field_player_avatar.h include/field_specials.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/malloc.h include/menu.h include/naming_screen.h include/overworld.h include/palette.h include/pokemon.h include/pokemon_icon.h include/pokemon_storage_system.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/walda_phrase.h include/window.h
build-linux/assets/graphics/naming_screen/keyboard.pal.gbapal:
build-linux/assets/graphics/naming_screen/pc_icon_off.png.4bpp:
build-linux/assets/graphics/naming_screen/pc_icon_on.png.4bpp:
build-linux/assets/graphics/naming_screen/rival.pal.gbapal:
include/bg.h:
include/config.h:
include/constants/berry.h:
include/constants/characters.h:
include/constants/easy_chat.h:
include/constants/event_object_movement.h:
include/constants/event_objects.h:
include/constants/flags.h:
include/constants/game_stat.h:
include/constants/global.h:
include/constants/map_event_ids.h:
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
include/data.h:
include/event_data.h:
include/event_object_movement.h:
include/field_effect.h:
include/field_player_avatar.h:
include/field_specials.h:
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
include/malloc.h:
include/menu.h:
include/naming_screen.h:
include/overworld.h:
include/palette.h:
include/pokemon.h:
include/pokemon_icon.h:
include/pokemon_storage_system.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/trig.h:
include/walda_phrase.h:
include/window.h:
ifndef build-linux/assets/graphics/naming_screen/keyboard.pal.gbapal
build-linux/assets/graphics/naming_screen/keyboard.pal.gbapal := defined
build-linux/assets/graphics/naming_screen/keyboard.pal.gbapal: graphics/naming_screen/keyboard.pal
	@mkdir -p 'build-linux/assets/graphics/naming_screen'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/naming_screen/pc_icon_off.png.4bpp
build-linux/assets/graphics/naming_screen/pc_icon_off.png.4bpp := defined
build-linux/assets/graphics/naming_screen/pc_icon_off.png.4bpp: graphics/naming_screen/pc_icon_off.png
	@mkdir -p 'build-linux/assets/graphics/naming_screen'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/naming_screen/pc_icon_on.png.4bpp
build-linux/assets/graphics/naming_screen/pc_icon_on.png.4bpp := defined
build-linux/assets/graphics/naming_screen/pc_icon_on.png.4bpp: graphics/naming_screen/pc_icon_on.png
	@mkdir -p 'build-linux/assets/graphics/naming_screen'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/naming_screen/rival.pal.gbapal
build-linux/assets/graphics/naming_screen/rival.pal.gbapal := defined
build-linux/assets/graphics/naming_screen/rival.pal.gbapal: graphics/naming_screen/rival.pal
	@mkdir -p 'build-linux/assets/graphics/naming_screen'
	$(GFX) $< $@ 
endif
