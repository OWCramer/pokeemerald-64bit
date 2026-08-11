build-linux/native-sdl3/src/starter_choose.o: build-linux/assets/graphics/starter_choose/birch_bag.bin.lz build-linux/assets/graphics/starter_choose/birch_grass.bin.lz build-linux/assets/graphics/starter_choose/pokeball_selection.png.4bpp.lz build-linux/assets/graphics/starter_choose/pokeball_selection.png.gbapal build-linux/assets/graphics/starter_choose/starter_circle.png.4bpp.lz build-linux/assets/graphics/starter_choose/starter_circle.png.gbapal build-linux/assets/graphics/starter_choose/tiles.png.4bpp.lz build-linux/assets/graphics/starter_choose/tiles.png.gbapal include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/data.h include/decompress.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/international_string_util.h include/list_menu.h include/main.h include/menu.h include/palette.h include/pokedex.h include/pokemon.h include/scanline_effect.h include/sound.h include/sprite.h include/starter_choose.h include/strings.h include/task.h include/text.h include/text_window.h include/trainer_pokemon_sprites.h include/trig.h include/window.h
build-linux/native-sdl3/src/starter_choose.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/data.h include/decompress.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/international_string_util.h include/list_menu.h include/main.h include/menu.h include/palette.h include/pokedex.h include/pokemon.h include/scanline_effect.h include/sound.h include/sprite.h include/starter_choose.h include/strings.h include/task.h include/text.h include/text_window.h include/trainer_pokemon_sprites.h include/trig.h include/window.h
build-linux/assets/graphics/starter_choose/birch_bag.bin.lz:
build-linux/assets/graphics/starter_choose/birch_grass.bin.lz:
build-linux/assets/graphics/starter_choose/pokeball_selection.png.4bpp.lz:
build-linux/assets/graphics/starter_choose/pokeball_selection.png.gbapal:
build-linux/assets/graphics/starter_choose/starter_circle.png.4bpp.lz:
build-linux/assets/graphics/starter_choose/starter_circle.png.gbapal:
build-linux/assets/graphics/starter_choose/tiles.png.4bpp.lz:
build-linux/assets/graphics/starter_choose/tiles.png.gbapal:
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
include/decompress.h:
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
include/international_string_util.h:
include/list_menu.h:
include/main.h:
include/menu.h:
include/palette.h:
include/pokedex.h:
include/pokemon.h:
include/scanline_effect.h:
include/sound.h:
include/sprite.h:
include/starter_choose.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/trainer_pokemon_sprites.h:
include/trig.h:
include/window.h:
ifndef build-linux/assets/graphics/starter_choose/birch_bag.bin.lz
build-linux/assets/graphics/starter_choose/birch_bag.bin.lz := defined
build-linux/assets/graphics/starter_choose/birch_bag.bin.lz: graphics/starter_choose/birch_bag.bin
	@mkdir -p 'build-linux/assets/graphics/starter_choose'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/starter_choose/birch_grass.bin.lz
build-linux/assets/graphics/starter_choose/birch_grass.bin.lz := defined
build-linux/assets/graphics/starter_choose/birch_grass.bin.lz: graphics/starter_choose/birch_grass.bin
	@mkdir -p 'build-linux/assets/graphics/starter_choose'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/starter_choose/pokeball_selection.png.4bpp
build-linux/assets/graphics/starter_choose/pokeball_selection.png.4bpp := defined
build-linux/assets/graphics/starter_choose/pokeball_selection.png.4bpp: graphics/starter_choose/pokeball_selection.png
	@mkdir -p 'build-linux/assets/graphics/starter_choose'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/starter_choose/pokeball_selection.png.gbapal
build-linux/assets/graphics/starter_choose/pokeball_selection.png.gbapal := defined
build-linux/assets/graphics/starter_choose/pokeball_selection.png.gbapal: graphics/starter_choose/pokeball_selection.png
	@mkdir -p 'build-linux/assets/graphics/starter_choose'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/starter_choose/starter_circle.png.4bpp
build-linux/assets/graphics/starter_choose/starter_circle.png.4bpp := defined
build-linux/assets/graphics/starter_choose/starter_circle.png.4bpp: graphics/starter_choose/starter_circle.png
	@mkdir -p 'build-linux/assets/graphics/starter_choose'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/starter_choose/starter_circle.png.gbapal
build-linux/assets/graphics/starter_choose/starter_circle.png.gbapal := defined
build-linux/assets/graphics/starter_choose/starter_circle.png.gbapal: graphics/starter_choose/starter_circle.png
	@mkdir -p 'build-linux/assets/graphics/starter_choose'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/starter_choose/tiles.png.4bpp
build-linux/assets/graphics/starter_choose/tiles.png.4bpp := defined
build-linux/assets/graphics/starter_choose/tiles.png.4bpp: graphics/starter_choose/tiles.png
	@mkdir -p 'build-linux/assets/graphics/starter_choose'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/starter_choose/tiles.png.gbapal
build-linux/assets/graphics/starter_choose/tiles.png.gbapal := defined
build-linux/assets/graphics/starter_choose/tiles.png.gbapal: graphics/starter_choose/tiles.png
	@mkdir -p 'build-linux/assets/graphics/starter_choose'
	$(GFX) $< $@ 
endif
