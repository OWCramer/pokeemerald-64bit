build-linux/native-sdl3/src/pokedex_area_region_map.o: build-linux/assets/graphics/pokedex/region_map.bin.lz build-linux/assets/graphics/pokedex/region_map.pal.gbapal build-linux/assets/graphics/pokedex/region_map.png_num_tiles_232__Wnum_tiles.8bpp.lz build-linux/assets/graphics/pokedex/region_map_affine.bin.lz build-linux/assets/graphics/pokedex/region_map_affine.png_num_tiles_233__Wnum_tiles.8bpp.lz include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/main.h include/malloc.h include/menu.h include/palette.h include/pokedex_area_region_map.h include/pokemon.h include/sprite.h include/task.h include/text.h include/window.h
build-linux/native-sdl3/src/pokedex_area_region_map.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/main.h include/malloc.h include/menu.h include/palette.h include/pokedex_area_region_map.h include/pokemon.h include/sprite.h include/task.h include/text.h include/window.h
build-linux/assets/graphics/pokedex/region_map.bin.lz:
build-linux/assets/graphics/pokedex/region_map.pal.gbapal:
build-linux/assets/graphics/pokedex/region_map.png_num_tiles_232__Wnum_tiles.8bpp.lz:
build-linux/assets/graphics/pokedex/region_map_affine.bin.lz:
build-linux/assets/graphics/pokedex/region_map_affine.png_num_tiles_233__Wnum_tiles.8bpp.lz:
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
include/main.h:
include/malloc.h:
include/menu.h:
include/palette.h:
include/pokedex_area_region_map.h:
include/pokemon.h:
include/sprite.h:
include/task.h:
include/text.h:
include/window.h:
ifndef build-linux/assets/graphics/pokedex/region_map.bin.lz
build-linux/assets/graphics/pokedex/region_map.bin.lz := defined
build-linux/assets/graphics/pokedex/region_map.bin.lz: graphics/pokedex/region_map.bin
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokedex/region_map.pal.gbapal
build-linux/assets/graphics/pokedex/region_map.pal.gbapal := defined
build-linux/assets/graphics/pokedex/region_map.pal.gbapal: graphics/pokedex/region_map.pal
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokedex/region_map.png_num_tiles_232__Wnum_tiles.8bpp
build-linux/assets/graphics/pokedex/region_map.png_num_tiles_232__Wnum_tiles.8bpp := defined
build-linux/assets/graphics/pokedex/region_map.png_num_tiles_232__Wnum_tiles.8bpp: graphics/pokedex/region_map.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ -num_tiles 232 -Wnum_tiles
endif
ifndef build-linux/assets/graphics/pokedex/region_map_affine.bin.lz
build-linux/assets/graphics/pokedex/region_map_affine.bin.lz := defined
build-linux/assets/graphics/pokedex/region_map_affine.bin.lz: graphics/pokedex/region_map_affine.bin
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokedex/region_map_affine.png_num_tiles_233__Wnum_tiles.8bpp
build-linux/assets/graphics/pokedex/region_map_affine.png_num_tiles_233__Wnum_tiles.8bpp := defined
build-linux/assets/graphics/pokedex/region_map_affine.png_num_tiles_233__Wnum_tiles.8bpp: graphics/pokedex/region_map_affine.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ -num_tiles 233 -Wnum_tiles
endif
