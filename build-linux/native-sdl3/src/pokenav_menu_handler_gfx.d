build-linux/native-sdl3/src/pokenav_menu_handler_gfx.o: build-linux/assets/graphics/pokenav/bg_dots.bin.lz build-linux/assets/graphics/pokenav/bg_dots.png.4bpp.lz build-linux/assets/graphics/pokenav/bg_dots.png.gbapal build-linux/assets/graphics/pokenav/blue_light.png.4bpp.lz build-linux/assets/graphics/pokenav/blue_light.png.gbapal build-linux/assets/graphics/pokenav/device_outline.png.gbapal build-linux/assets/graphics/pokenav/device_outline.png_num_tiles_53__Wnum_tiles.4bpp.lz build-linux/assets/graphics/pokenav/device_outline_map.bin.lz include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/gym_leader_rematch.h include/main.h include/malloc.h include/menu.h include/palette.h include/pokemon.h include/pokemon_storage_system.h include/pokenav.h include/scanline_effect.h include/sound.h include/sprite.h include/strings.h include/task.h include/text.h include/trig.h include/window.h
build-linux/native-sdl3/src/pokenav_menu_handler_gfx.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/gym_leader_rematch.h include/main.h include/malloc.h include/menu.h include/palette.h include/pokemon.h include/pokemon_storage_system.h include/pokenav.h include/scanline_effect.h include/sound.h include/sprite.h include/strings.h include/task.h include/text.h include/trig.h include/window.h
build-linux/assets/graphics/pokenav/bg_dots.bin.lz:
build-linux/assets/graphics/pokenav/bg_dots.png.4bpp.lz:
build-linux/assets/graphics/pokenav/bg_dots.png.gbapal:
build-linux/assets/graphics/pokenav/blue_light.png.4bpp.lz:
build-linux/assets/graphics/pokenav/blue_light.png.gbapal:
build-linux/assets/graphics/pokenav/device_outline.png.gbapal:
build-linux/assets/graphics/pokenav/device_outline.png_num_tiles_53__Wnum_tiles.4bpp.lz:
build-linux/assets/graphics/pokenav/device_outline_map.bin.lz:
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
include/gym_leader_rematch.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/palette.h:
include/pokemon.h:
include/pokemon_storage_system.h:
include/pokenav.h:
include/scanline_effect.h:
include/sound.h:
include/sprite.h:
include/strings.h:
include/task.h:
include/text.h:
include/trig.h:
include/window.h:
ifndef build-linux/assets/graphics/pokenav/bg_dots.bin.lz
build-linux/assets/graphics/pokenav/bg_dots.bin.lz := defined
build-linux/assets/graphics/pokenav/bg_dots.bin.lz: graphics/pokenav/bg_dots.bin
	@mkdir -p 'build-linux/assets/graphics/pokenav'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/bg_dots.png.4bpp
build-linux/assets/graphics/pokenav/bg_dots.png.4bpp := defined
build-linux/assets/graphics/pokenav/bg_dots.png.4bpp: graphics/pokenav/bg_dots.png
	@mkdir -p 'build-linux/assets/graphics/pokenav'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/bg_dots.png.gbapal
build-linux/assets/graphics/pokenav/bg_dots.png.gbapal := defined
build-linux/assets/graphics/pokenav/bg_dots.png.gbapal: graphics/pokenav/bg_dots.png
	@mkdir -p 'build-linux/assets/graphics/pokenav'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/blue_light.png.4bpp
build-linux/assets/graphics/pokenav/blue_light.png.4bpp := defined
build-linux/assets/graphics/pokenav/blue_light.png.4bpp: graphics/pokenav/blue_light.png
	@mkdir -p 'build-linux/assets/graphics/pokenav'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/blue_light.png.gbapal
build-linux/assets/graphics/pokenav/blue_light.png.gbapal := defined
build-linux/assets/graphics/pokenav/blue_light.png.gbapal: graphics/pokenav/blue_light.png
	@mkdir -p 'build-linux/assets/graphics/pokenav'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/device_outline.png.gbapal
build-linux/assets/graphics/pokenav/device_outline.png.gbapal := defined
build-linux/assets/graphics/pokenav/device_outline.png.gbapal: graphics/pokenav/device_outline.png
	@mkdir -p 'build-linux/assets/graphics/pokenav'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/device_outline.png_num_tiles_53__Wnum_tiles.4bpp
build-linux/assets/graphics/pokenav/device_outline.png_num_tiles_53__Wnum_tiles.4bpp := defined
build-linux/assets/graphics/pokenav/device_outline.png_num_tiles_53__Wnum_tiles.4bpp: graphics/pokenav/device_outline.png
	@mkdir -p 'build-linux/assets/graphics/pokenav'
	$(GFX) $< $@ -num_tiles 53 -Wnum_tiles
endif
ifndef build-linux/assets/graphics/pokenav/device_outline_map.bin.lz
build-linux/assets/graphics/pokenav/device_outline_map.bin.lz := defined
build-linux/assets/graphics/pokenav/device_outline_map.bin.lz: graphics/pokenav/device_outline_map.bin
	@mkdir -p 'build-linux/assets/graphics/pokenav'
	$(GFX) $< $@ 
endif
