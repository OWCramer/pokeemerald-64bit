build-linux/native-sdl3/src/rotating_gate.o: build-linux/assets/graphics/rotating_gates/l1.png.4bpp build-linux/assets/graphics/rotating_gates/l2.png.4bpp build-linux/assets/graphics/rotating_gates/l3.png.4bpp build-linux/assets/graphics/rotating_gates/l4.png.4bpp build-linux/assets/graphics/rotating_gates/t1.png.4bpp build-linux/assets/graphics/rotating_gates/t2.png.4bpp build-linux/assets/graphics/rotating_gates/t3.png.4bpp build-linux/assets/graphics/rotating_gates/t4.png.4bpp include/bike.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/event_data.h include/event_object_movement.h include/fieldmap.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/main.h include/pokemon.h include/rotating_gate.h include/sound.h include/sprite.h
build-linux/native-sdl3/src/rotating_gate.d: include/bike.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/event_data.h include/event_object_movement.h include/fieldmap.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/main.h include/pokemon.h include/rotating_gate.h include/sound.h include/sprite.h
build-linux/assets/graphics/rotating_gates/l1.png.4bpp:
build-linux/assets/graphics/rotating_gates/l2.png.4bpp:
build-linux/assets/graphics/rotating_gates/l3.png.4bpp:
build-linux/assets/graphics/rotating_gates/l4.png.4bpp:
build-linux/assets/graphics/rotating_gates/t1.png.4bpp:
build-linux/assets/graphics/rotating_gates/t2.png.4bpp:
build-linux/assets/graphics/rotating_gates/t3.png.4bpp:
build-linux/assets/graphics/rotating_gates/t4.png.4bpp:
include/bike.h:
include/config.h:
include/constants/berry.h:
include/constants/easy_chat.h:
include/constants/event_object_movement.h:
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
include/event_data.h:
include/event_object_movement.h:
include/fieldmap.h:
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
include/pokemon.h:
include/rotating_gate.h:
include/sound.h:
include/sprite.h:
ifndef build-linux/assets/graphics/rotating_gates/l1.png.4bpp
build-linux/assets/graphics/rotating_gates/l1.png.4bpp := defined
build-linux/assets/graphics/rotating_gates/l1.png.4bpp: graphics/rotating_gates/l1.png
	@mkdir -p 'build-linux/assets/graphics/rotating_gates'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/rotating_gates/l2.png.4bpp
build-linux/assets/graphics/rotating_gates/l2.png.4bpp := defined
build-linux/assets/graphics/rotating_gates/l2.png.4bpp: graphics/rotating_gates/l2.png
	@mkdir -p 'build-linux/assets/graphics/rotating_gates'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/rotating_gates/l3.png.4bpp
build-linux/assets/graphics/rotating_gates/l3.png.4bpp := defined
build-linux/assets/graphics/rotating_gates/l3.png.4bpp: graphics/rotating_gates/l3.png
	@mkdir -p 'build-linux/assets/graphics/rotating_gates'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/rotating_gates/l4.png.4bpp
build-linux/assets/graphics/rotating_gates/l4.png.4bpp := defined
build-linux/assets/graphics/rotating_gates/l4.png.4bpp: graphics/rotating_gates/l4.png
	@mkdir -p 'build-linux/assets/graphics/rotating_gates'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/rotating_gates/t1.png.4bpp
build-linux/assets/graphics/rotating_gates/t1.png.4bpp := defined
build-linux/assets/graphics/rotating_gates/t1.png.4bpp: graphics/rotating_gates/t1.png
	@mkdir -p 'build-linux/assets/graphics/rotating_gates'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/rotating_gates/t2.png.4bpp
build-linux/assets/graphics/rotating_gates/t2.png.4bpp := defined
build-linux/assets/graphics/rotating_gates/t2.png.4bpp: graphics/rotating_gates/t2.png
	@mkdir -p 'build-linux/assets/graphics/rotating_gates'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/rotating_gates/t3.png.4bpp
build-linux/assets/graphics/rotating_gates/t3.png.4bpp := defined
build-linux/assets/graphics/rotating_gates/t3.png.4bpp: graphics/rotating_gates/t3.png
	@mkdir -p 'build-linux/assets/graphics/rotating_gates'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/rotating_gates/t4.png.4bpp
build-linux/assets/graphics/rotating_gates/t4.png.4bpp := defined
build-linux/assets/graphics/rotating_gates/t4.png.4bpp: graphics/rotating_gates/t4.png
	@mkdir -p 'build-linux/assets/graphics/rotating_gates'
	$(GFX) $< $@ 
endif
