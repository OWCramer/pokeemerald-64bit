build-linux/native-sdl3/src/menu_specialized.o: build-linux/assets/graphics/pokenav/condition/pokeball.png.4bpp build-linux/assets/graphics/pokenav/condition/pokeball_placeholder.png.4bpp build-linux/assets/graphics/pokenav/condition/sparkle.png.4bpp build-linux/assets/graphics/pokenav/condition/sparkle.png.gbapal include/battle_main.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/contest_effect.h include/data.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/international_string_util.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/menu_specialized.h include/move_relearner.h include/palette.h include/player_pc.h include/pokemon.h include/pokemon_storage_system.h include/pokemon_summary_screen.h include/scanline_effect.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/window.h
build-linux/native-sdl3/src/menu_specialized.d: include/battle_main.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/contest_effect.h include/data.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/international_string_util.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/menu_specialized.h include/move_relearner.h include/palette.h include/player_pc.h include/pokemon.h include/pokemon_storage_system.h include/pokemon_summary_screen.h include/scanline_effect.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/window.h
build-linux/assets/graphics/pokenav/condition/pokeball.png.4bpp:
build-linux/assets/graphics/pokenav/condition/pokeball_placeholder.png.4bpp:
build-linux/assets/graphics/pokenav/condition/sparkle.png.4bpp:
build-linux/assets/graphics/pokenav/condition/sparkle.png.gbapal:
include/battle_main.h:
include/config.h:
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
include/constants/songs.h:
include/constants/sound.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
include/contest_effect.h:
include/data.h:
include/decompress.h:
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
include/international_string_util.h:
include/list_menu.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/menu_specialized.h:
include/move_relearner.h:
include/palette.h:
include/player_pc.h:
include/pokemon.h:
include/pokemon_storage_system.h:
include/pokemon_summary_screen.h:
include/scanline_effect.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/trig.h:
include/window.h:
ifndef build-linux/assets/graphics/pokenav/condition/pokeball.png.4bpp
build-linux/assets/graphics/pokenav/condition/pokeball.png.4bpp := defined
build-linux/assets/graphics/pokenav/condition/pokeball.png.4bpp: graphics/pokenav/condition/pokeball.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/condition'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/condition/pokeball_placeholder.png.4bpp
build-linux/assets/graphics/pokenav/condition/pokeball_placeholder.png.4bpp := defined
build-linux/assets/graphics/pokenav/condition/pokeball_placeholder.png.4bpp: graphics/pokenav/condition/pokeball_placeholder.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/condition'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/condition/sparkle.png.4bpp
build-linux/assets/graphics/pokenav/condition/sparkle.png.4bpp := defined
build-linux/assets/graphics/pokenav/condition/sparkle.png.4bpp: graphics/pokenav/condition/sparkle.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/condition'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/condition/sparkle.png.gbapal
build-linux/assets/graphics/pokenav/condition/sparkle.png.gbapal := defined
build-linux/assets/graphics/pokenav/condition/sparkle.png.gbapal: graphics/pokenav/condition/sparkle.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/condition'
	$(GFX) $< $@ 
endif
