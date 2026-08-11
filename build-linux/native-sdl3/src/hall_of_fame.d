build-linux/native-sdl3/src/hall_of_fame.o: build-linux/assets/graphics/misc/japanese_hof.png.gbapal build-linux/assets/graphics/misc/japanese_hof.png_num_tiles_29__Wnum_tiles.4bpp.lz include/bg.h include/confetti_util.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/credits.h include/data.h include/decompress.h include/event_data.h include/fldeff_misc.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/hall_of_fame.h include/international_string_util.h include/list_menu.h include/m4a.h include/main.h include/malloc.h include/menu.h include/music_player.h include/overworld.h include/palette.h include/pokemon.h include/random.h include/save.h include/scanline_effect.h include/sound.h include/sound_mixer.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trainer_pokemon_sprites.h include/trig.h include/util.h include/window.h
build-linux/native-sdl3/src/hall_of_fame.d: include/bg.h include/confetti_util.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/credits.h include/data.h include/decompress.h include/event_data.h include/fldeff_misc.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/hall_of_fame.h include/international_string_util.h include/list_menu.h include/m4a.h include/main.h include/malloc.h include/menu.h include/music_player.h include/overworld.h include/palette.h include/pokemon.h include/random.h include/save.h include/scanline_effect.h include/sound.h include/sound_mixer.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trainer_pokemon_sprites.h include/trig.h include/util.h include/window.h
build-linux/assets/graphics/misc/japanese_hof.png.gbapal:
build-linux/assets/graphics/misc/japanese_hof.png_num_tiles_29__Wnum_tiles.4bpp.lz:
include/bg.h:
include/confetti_util.h:
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
include/credits.h:
include/data.h:
include/decompress.h:
include/event_data.h:
include/fldeff_misc.h:
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
include/hall_of_fame.h:
include/international_string_util.h:
include/list_menu.h:
include/m4a.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/music_player.h:
include/overworld.h:
include/palette.h:
include/pokemon.h:
include/random.h:
include/save.h:
include/scanline_effect.h:
include/sound.h:
include/sound_mixer.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/trainer_pokemon_sprites.h:
include/trig.h:
include/util.h:
include/window.h:
ifndef build-linux/assets/graphics/misc/japanese_hof.png.gbapal
build-linux/assets/graphics/misc/japanese_hof.png.gbapal := defined
build-linux/assets/graphics/misc/japanese_hof.png.gbapal: graphics/misc/japanese_hof.png
	@mkdir -p 'build-linux/assets/graphics/misc'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/misc/japanese_hof.png_num_tiles_29__Wnum_tiles.4bpp
build-linux/assets/graphics/misc/japanese_hof.png_num_tiles_29__Wnum_tiles.4bpp := defined
build-linux/assets/graphics/misc/japanese_hof.png_num_tiles_29__Wnum_tiles.4bpp: graphics/misc/japanese_hof.png
	@mkdir -p 'build-linux/assets/graphics/misc'
	$(GFX) $< $@ -num_tiles 29 -Wnum_tiles
endif
