build-linux/native-sdl3/src/slot_machine.o: build-linux/assets/graphics/slot_machine/flashing_lights_inside.pal.gbapal build-linux/assets/graphics/slot_machine/flashing_lights_middle.pal.gbapal build-linux/assets/graphics/slot_machine/flashing_lights_outside.pal.gbapal build-linux/assets/graphics/slot_machine/pokeball_shining_0.pal.gbapal build-linux/assets/graphics/slot_machine/pokeball_shining_1.pal.gbapal build-linux/assets/graphics/slot_machine/pokeball_shining_2.pal.gbapal build-linux/assets/graphics/slot_machine/reel_time_gfx.4bpp.lz graphics/slot_machine/reel_time_window.bin include/bg.h include/coins.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/coins.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/slot_machine.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/field_effect.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/main_menu.h include/malloc.h include/menu.h include/overworld.h include/palette.h include/pokemon.h include/random.h include/slot_machine.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/tv.h include/util.h include/window.h
build-linux/native-sdl3/src/slot_machine.d: include/bg.h include/coins.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/coins.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/slot_machine.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/field_effect.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/main_menu.h include/malloc.h include/menu.h include/overworld.h include/palette.h include/pokemon.h include/random.h include/slot_machine.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/trig.h include/tv.h include/util.h include/window.h
build-linux/assets/graphics/slot_machine/flashing_lights_inside.pal.gbapal:
build-linux/assets/graphics/slot_machine/flashing_lights_middle.pal.gbapal:
build-linux/assets/graphics/slot_machine/flashing_lights_outside.pal.gbapal:
build-linux/assets/graphics/slot_machine/pokeball_shining_0.pal.gbapal:
build-linux/assets/graphics/slot_machine/pokeball_shining_1.pal.gbapal:
build-linux/assets/graphics/slot_machine/pokeball_shining_2.pal.gbapal:
build-linux/assets/graphics/slot_machine/reel_time_gfx.4bpp.lz:
graphics/slot_machine/reel_time_window.bin:
include/bg.h:
include/coins.h:
include/config.h:
include/constants/berry.h:
include/constants/characters.h:
include/constants/coins.h:
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
include/constants/slot_machine.h:
include/constants/songs.h:
include/constants/sound.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
include/decompress.h:
include/field_effect.h:
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
include/main_menu.h:
include/malloc.h:
include/menu.h:
include/overworld.h:
include/palette.h:
include/pokemon.h:
include/random.h:
include/slot_machine.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/trig.h:
include/tv.h:
include/util.h:
include/window.h:
ifndef build-linux/assets/graphics/slot_machine/flashing_lights_inside.pal.gbapal
build-linux/assets/graphics/slot_machine/flashing_lights_inside.pal.gbapal := defined
build-linux/assets/graphics/slot_machine/flashing_lights_inside.pal.gbapal: graphics/slot_machine/flashing_lights_inside.pal
	@mkdir -p 'build-linux/assets/graphics/slot_machine'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/slot_machine/flashing_lights_middle.pal.gbapal
build-linux/assets/graphics/slot_machine/flashing_lights_middle.pal.gbapal := defined
build-linux/assets/graphics/slot_machine/flashing_lights_middle.pal.gbapal: graphics/slot_machine/flashing_lights_middle.pal
	@mkdir -p 'build-linux/assets/graphics/slot_machine'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/slot_machine/flashing_lights_outside.pal.gbapal
build-linux/assets/graphics/slot_machine/flashing_lights_outside.pal.gbapal := defined
build-linux/assets/graphics/slot_machine/flashing_lights_outside.pal.gbapal: graphics/slot_machine/flashing_lights_outside.pal
	@mkdir -p 'build-linux/assets/graphics/slot_machine'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/slot_machine/pokeball_shining_0.pal.gbapal
build-linux/assets/graphics/slot_machine/pokeball_shining_0.pal.gbapal := defined
build-linux/assets/graphics/slot_machine/pokeball_shining_0.pal.gbapal: graphics/slot_machine/pokeball_shining_0.pal
	@mkdir -p 'build-linux/assets/graphics/slot_machine'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/slot_machine/pokeball_shining_1.pal.gbapal
build-linux/assets/graphics/slot_machine/pokeball_shining_1.pal.gbapal := defined
build-linux/assets/graphics/slot_machine/pokeball_shining_1.pal.gbapal: graphics/slot_machine/pokeball_shining_1.pal
	@mkdir -p 'build-linux/assets/graphics/slot_machine'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/slot_machine/pokeball_shining_2.pal.gbapal
build-linux/assets/graphics/slot_machine/pokeball_shining_2.pal.gbapal := defined
build-linux/assets/graphics/slot_machine/pokeball_shining_2.pal.gbapal: graphics/slot_machine/pokeball_shining_2.pal
	@mkdir -p 'build-linux/assets/graphics/slot_machine'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/slot_machine/reel_time_gfx.4bpp.lz
build-linux/assets/graphics/slot_machine/reel_time_gfx.4bpp.lz := defined
build-linux/assets/graphics/slot_machine/reel_time_gfx.4bpp.lz: graphics/slot_machine/reel_time_gfx.4bpp
	@mkdir -p 'build-linux/assets/graphics/slot_machine'
	$(GFX) $< $@ 
endif
