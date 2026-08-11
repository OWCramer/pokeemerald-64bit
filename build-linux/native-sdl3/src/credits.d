build-linux/native-sdl3/src/credits.o: build-linux/assets/graphics/credits/credits.pal.gbapal build-linux/assets/graphics/credits/the_end_copyright.png.4bpp.lz include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/international_string_util.h include/intro_credits_graphics.h include/list_menu.h include/m4a.h include/main.h include/malloc.h include/menu.h include/music_player.h include/palette.h include/pokedex.h include/pokemon.h include/random.h include/sound.h include/sound_mixer.h include/sprite.h include/starter_choose.h include/task.h include/text.h include/trainer_pokemon_sprites.h include/trig.h include/window.h src/data/credits.h
build-linux/native-sdl3/src/credits.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/international_string_util.h include/intro_credits_graphics.h include/list_menu.h include/m4a.h include/main.h include/malloc.h include/menu.h include/music_player.h include/palette.h include/pokedex.h include/pokemon.h include/random.h include/sound.h include/sound_mixer.h include/sprite.h include/starter_choose.h include/task.h include/text.h include/trainer_pokemon_sprites.h include/trig.h include/window.h src/data/credits.h
build-linux/assets/graphics/credits/credits.pal.gbapal:
build-linux/assets/graphics/credits/the_end_copyright.png.4bpp.lz:
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
include/international_string_util.h:
include/intro_credits_graphics.h:
include/list_menu.h:
include/m4a.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/music_player.h:
include/palette.h:
include/pokedex.h:
include/pokemon.h:
include/random.h:
include/sound.h:
include/sound_mixer.h:
include/sprite.h:
include/starter_choose.h:
include/task.h:
include/text.h:
include/trainer_pokemon_sprites.h:
include/trig.h:
include/window.h:
src/data/credits.h:
ifndef build-linux/assets/graphics/credits/credits.pal.gbapal
build-linux/assets/graphics/credits/credits.pal.gbapal := defined
build-linux/assets/graphics/credits/credits.pal.gbapal: graphics/credits/credits.pal
	@mkdir -p 'build-linux/assets/graphics/credits'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/credits/the_end_copyright.png.4bpp
build-linux/assets/graphics/credits/the_end_copyright.png.4bpp := defined
build-linux/assets/graphics/credits/the_end_copyright.png.4bpp: graphics/credits/the_end_copyright.png
	@mkdir -p 'build-linux/assets/graphics/credits'
	$(GFX) $< $@ 
endif
