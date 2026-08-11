build-linux/native-sdl3/src/cable_car.o: build-linux/assets/graphics/cable_car/bg_mountains.bin.lz build-linux/assets/graphics/cable_car/ground.bin.lz build-linux/assets/graphics/cable_car/pylon_pole.bin.lz build-linux/assets/graphics/cable_car/trees.bin.lz graphics/cable_car/pylon_top.bin include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/event_objects.h include/constants/field_weather.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_event_ids.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/constants/weather.h include/decompress.h include/event_data.h include/event_object_movement.h include/field_weather.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/malloc.h include/menu.h include/overworld.h include/palette.h include/pokemon.h include/random.h include/scanline_effect.h include/script.h include/sound.h include/sprite.h include/task.h include/text.h include/window.h
build-linux/native-sdl3/src/cable_car.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/event_objects.h include/constants/field_weather.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_event_ids.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/constants/weather.h include/decompress.h include/event_data.h include/event_object_movement.h include/field_weather.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/malloc.h include/menu.h include/overworld.h include/palette.h include/pokemon.h include/random.h include/scanline_effect.h include/script.h include/sound.h include/sprite.h include/task.h include/text.h include/window.h
build-linux/assets/graphics/cable_car/bg_mountains.bin.lz:
build-linux/assets/graphics/cable_car/ground.bin.lz:
build-linux/assets/graphics/cable_car/pylon_pole.bin.lz:
build-linux/assets/graphics/cable_car/trees.bin.lz:
graphics/cable_car/pylon_top.bin:
include/bg.h:
include/config.h:
include/constants/berry.h:
include/constants/characters.h:
include/constants/easy_chat.h:
include/constants/event_object_movement.h:
include/constants/event_objects.h:
include/constants/field_weather.h:
include/constants/flags.h:
include/constants/game_stat.h:
include/constants/global.h:
include/constants/map_event_ids.h:
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
include/decompress.h:
include/event_data.h:
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
include/graphics.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/overworld.h:
include/palette.h:
include/pokemon.h:
include/random.h:
include/scanline_effect.h:
include/script.h:
include/sound.h:
include/sprite.h:
include/task.h:
include/text.h:
include/window.h:
ifndef build-linux/assets/graphics/cable_car/bg_mountains.bin.lz
build-linux/assets/graphics/cable_car/bg_mountains.bin.lz := defined
build-linux/assets/graphics/cable_car/bg_mountains.bin.lz: graphics/cable_car/bg_mountains.bin
	@mkdir -p 'build-linux/assets/graphics/cable_car'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/cable_car/ground.bin.lz
build-linux/assets/graphics/cable_car/ground.bin.lz := defined
build-linux/assets/graphics/cable_car/ground.bin.lz: graphics/cable_car/ground.bin
	@mkdir -p 'build-linux/assets/graphics/cable_car'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/cable_car/pylon_pole.bin.lz
build-linux/assets/graphics/cable_car/pylon_pole.bin.lz := defined
build-linux/assets/graphics/cable_car/pylon_pole.bin.lz: graphics/cable_car/pylon_pole.bin
	@mkdir -p 'build-linux/assets/graphics/cable_car'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/cable_car/trees.bin.lz
build-linux/assets/graphics/cable_car/trees.bin.lz := defined
build-linux/assets/graphics/cable_car/trees.bin.lz: graphics/cable_car/trees.bin
	@mkdir -p 'build-linux/assets/graphics/cable_car'
	$(GFX) $< $@ 
endif
