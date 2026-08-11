build-linux/native-sdl3/src/menu.o: build-linux/assets/graphics/interface/hof_pc_topbar.pal.gbapal build-linux/assets/graphics/interface/std_menu.pal.gbapal include/bg.h include/blit.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/dma3.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/graphics.h include/main.h include/malloc.h include/menu.h include/menu_helpers.h include/palette.h include/pokedex.h include/pokemon.h include/pokemon_icon.h include/region_map.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/window.h
build-linux/native-sdl3/src/menu.d: include/bg.h include/blit.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/dma3.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/graphics.h include/main.h include/malloc.h include/menu.h include/menu_helpers.h include/palette.h include/pokedex.h include/pokemon.h include/pokemon_icon.h include/region_map.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/window.h
build-linux/assets/graphics/interface/hof_pc_topbar.pal.gbapal:
build-linux/assets/graphics/interface/std_menu.pal.gbapal:
include/bg.h:
include/blit.h:
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
include/constants/songs.h:
include/constants/sound.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
include/dma3.h:
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
include/graphics.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/menu_helpers.h:
include/palette.h:
include/pokedex.h:
include/pokemon.h:
include/pokemon_icon.h:
include/region_map.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/window.h:
ifndef build-linux/assets/graphics/interface/hof_pc_topbar.pal.gbapal
build-linux/assets/graphics/interface/hof_pc_topbar.pal.gbapal := defined
build-linux/assets/graphics/interface/hof_pc_topbar.pal.gbapal: graphics/interface/hof_pc_topbar.pal
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/interface/std_menu.pal.gbapal
build-linux/assets/graphics/interface/std_menu.pal.gbapal := defined
build-linux/assets/graphics/interface/std_menu.pal.gbapal: graphics/interface/std_menu.pal
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
