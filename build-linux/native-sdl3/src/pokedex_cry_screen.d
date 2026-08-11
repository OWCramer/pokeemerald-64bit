build-linux/native-sdl3/src/pokedex_cry_screen.o: build-linux/assets/graphics/pokedex/cry_meter.png.4bpp.lz build-linux/assets/graphics/pokedex/cry_meter.png.gbapal build-linux/assets/graphics/pokedex/cry_meter_needle.png.4bpp build-linux/assets/graphics/pokedex/cry_meter_needle.png.gbapal build-linux/assets/graphics/pokedex/cry_screen_bg.png.4bpp build-linux/assets/graphics/pokedex/cry_screen_bg.png.gbapal graphics/pokedex/cry_meter_map.bin include/bg.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/m4a.h include/main.h include/malloc.h include/music_player.h include/palette.h include/pokedex_cry_screen.h include/pokemon.h include/sound.h include/sound_mixer.h include/sprite.h include/trig.h include/window.h
build-linux/native-sdl3/src/pokedex_cry_screen.d: include/bg.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/m4a_internal.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/m4a.h include/main.h include/malloc.h include/music_player.h include/palette.h include/pokedex_cry_screen.h include/pokemon.h include/sound.h include/sound_mixer.h include/sprite.h include/trig.h include/window.h
build-linux/assets/graphics/pokedex/cry_meter.png.4bpp.lz:
build-linux/assets/graphics/pokedex/cry_meter.png.gbapal:
build-linux/assets/graphics/pokedex/cry_meter_needle.png.4bpp:
build-linux/assets/graphics/pokedex/cry_meter_needle.png.gbapal:
build-linux/assets/graphics/pokedex/cry_screen_bg.png.4bpp:
build-linux/assets/graphics/pokedex/cry_screen_bg.png.gbapal:
graphics/pokedex/cry_meter_map.bin:
include/bg.h:
include/config.h:
include/constants/berry.h:
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
include/gba/m4a_internal.h:
include/gba/macro.h:
include/gba/multiboot.h:
include/gba/syscall.h:
include/gba/types.h:
include/global.berry.h:
include/global.fieldmap.h:
include/global.h:
include/global.tv.h:
include/m4a.h:
include/main.h:
include/malloc.h:
include/music_player.h:
include/palette.h:
include/pokedex_cry_screen.h:
include/pokemon.h:
include/sound.h:
include/sound_mixer.h:
include/sprite.h:
include/trig.h:
include/window.h:
ifndef build-linux/assets/graphics/pokedex/cry_meter.png.4bpp
build-linux/assets/graphics/pokedex/cry_meter.png.4bpp := defined
build-linux/assets/graphics/pokedex/cry_meter.png.4bpp: graphics/pokedex/cry_meter.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokedex/cry_meter.png.gbapal
build-linux/assets/graphics/pokedex/cry_meter.png.gbapal := defined
build-linux/assets/graphics/pokedex/cry_meter.png.gbapal: graphics/pokedex/cry_meter.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokedex/cry_meter_needle.png.4bpp
build-linux/assets/graphics/pokedex/cry_meter_needle.png.4bpp := defined
build-linux/assets/graphics/pokedex/cry_meter_needle.png.4bpp: graphics/pokedex/cry_meter_needle.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokedex/cry_meter_needle.png.gbapal
build-linux/assets/graphics/pokedex/cry_meter_needle.png.gbapal := defined
build-linux/assets/graphics/pokedex/cry_meter_needle.png.gbapal: graphics/pokedex/cry_meter_needle.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokedex/cry_screen_bg.png.4bpp
build-linux/assets/graphics/pokedex/cry_screen_bg.png.4bpp := defined
build-linux/assets/graphics/pokedex/cry_screen_bg.png.4bpp: graphics/pokedex/cry_screen_bg.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokedex/cry_screen_bg.png.gbapal
build-linux/assets/graphics/pokedex/cry_screen_bg.png.gbapal := defined
build-linux/assets/graphics/pokedex/cry_screen_bg.png.gbapal: graphics/pokedex/cry_screen_bg.png
	@mkdir -p 'build-linux/assets/graphics/pokedex'
	$(GFX) $< $@ 
endif
