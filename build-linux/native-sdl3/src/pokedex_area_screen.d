build-linux/native-sdl3/src/pokedex_area_screen.o: build-linux/assets/graphics/pokedex/area_glow.png.4bpp.lz build-linux/assets/graphics/pokedex/area_glow.png.gbapal build-linux/assets/graphics/pokedex/area_marker.png.4bpp build-linux/assets/graphics/pokedex/area_marker.png.gbapal include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/region_map_sections.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/constants/wild_encounter.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/malloc.h include/menu.h include/overworld.h include/palette.h include/pokedex_area_region_map.h include/pokedex_area_screen.h include/pokemon.h include/region_map.h include/roamer.h include/sound.h include/sprite.h include/string_util.h include/task.h include/text.h include/trig.h include/wild_encounter.h include/window.h src/data/pokedex_area_glow.h
build-linux/native-sdl3/src/pokedex_area_screen.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/region_map_sections.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/constants/wild_encounter.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/malloc.h include/menu.h include/overworld.h include/palette.h include/pokedex_area_region_map.h include/pokedex_area_screen.h include/pokemon.h include/region_map.h include/roamer.h include/sound.h include/sprite.h include/string_util.h include/task.h include/text.h include/trig.h include/wild_encounter.h include/window.h src/data/pokedex_area_glow.h
build-linux/assets/graphics/pokedex/area_glow.png.4bpp.lz:
build-linux/assets/graphics/pokedex/area_glow.png.gbapal:
build-linux/assets/graphics/pokedex/area_marker.png.4bpp:
build-linux/assets/graphics/pokedex/area_marker.png.gbapal:
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
include/constants/region_map_sections.h:
include/constants/rematches.h:
include/constants/rgb.h:
include/constants/songs.h:
include/constants/sound.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
include/constants/wild_encounter.h:
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
include/malloc.h:
include/menu.h:
include/overworld.h:
include/palette.h:
include/pokedex_area_region_map.h:
include/pokedex_area_screen.h:
include/pokemon.h:
include/region_map.h:
include/roamer.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/task.h:
include/text.h:
include/trig.h:
include/wild_encounter.h:
include/window.h:
src/data/pokedex_area_glow.h:
ifndef build-linux/assets/graphics/pokedex/area_glow.png.4bpp
build-linux/assets/graphics/pokedex/area_glow.png.4bpp := defined
build-linux/assets/graphics/pokedex/area_glow.png.4bpp: graphics/pokedex/area_glow.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokedex/area_glow.png.gbapal
build-linux/assets/graphics/pokedex/area_glow.png.gbapal := defined
build-linux/assets/graphics/pokedex/area_glow.png.gbapal: graphics/pokedex/area_glow.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokedex/area_marker.png.4bpp
build-linux/assets/graphics/pokedex/area_marker.png.4bpp := defined
build-linux/assets/graphics/pokedex/area_marker.png.4bpp: graphics/pokedex/area_marker.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokedex/area_marker.png.gbapal
build-linux/assets/graphics/pokedex/area_marker.png.gbapal := defined
build-linux/assets/graphics/pokedex/area_marker.png.gbapal: graphics/pokedex/area_marker.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
