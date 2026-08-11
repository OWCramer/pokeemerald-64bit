build-linux/native-sdl3/src/field_weather.o: build-linux/assets/graphics/weather/fog.pal.gbapal graphics/weather/drought/colors_0.bin graphics/weather/drought/colors_1.bin graphics/weather/drought/colors_2.bin graphics/weather/drought/colors_3.bin graphics/weather/drought/colors_4.bin graphics/weather/drought/colors_5.bin include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/field_weather.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/constants/weather.h include/event_object_movement.h include/field_weather.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/menu.h include/palette.h include/pokemon.h include/random.h include/script.h include/sound.h include/sprite.h include/start_menu.h include/task.h include/text.h include/trig.h include/util.h include/window.h
build-linux/native-sdl3/src/field_weather.d: include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/field_weather.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/constants/weather.h include/event_object_movement.h include/field_weather.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/menu.h include/palette.h include/pokemon.h include/random.h include/script.h include/sound.h include/sprite.h include/start_menu.h include/task.h include/text.h include/trig.h include/util.h include/window.h
build-linux/assets/graphics/weather/fog.pal.gbapal:
graphics/weather/drought/colors_0.bin:
graphics/weather/drought/colors_1.bin:
graphics/weather/drought/colors_2.bin:
graphics/weather/drought/colors_3.bin:
graphics/weather/drought/colors_4.bin:
graphics/weather/drought/colors_5.bin:
include/config.h:
include/constants/berry.h:
include/constants/characters.h:
include/constants/easy_chat.h:
include/constants/event_object_movement.h:
include/constants/field_weather.h:
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
include/constants/weather.h:
include/event_object_movement.h:
include/field_weather.h:
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
include/main.h:
include/menu.h:
include/palette.h:
include/pokemon.h:
include/random.h:
include/script.h:
include/sound.h:
include/sprite.h:
include/start_menu.h:
include/task.h:
include/text.h:
include/trig.h:
include/util.h:
include/window.h:
ifndef build-linux/assets/graphics/weather/fog.pal.gbapal
build-linux/assets/graphics/weather/fog.pal.gbapal := defined
build-linux/assets/graphics/weather/fog.pal.gbapal: graphics/weather/fog.pal
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
