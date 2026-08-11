build-linux/native-sdl3/src/mirage_tower.o: build-linux/assets/graphics/misc/mirage_tower.png_num_tiles_73__Wnum_tiles.4bpp build-linux/assets/graphics/misc/mirage_tower_crumbles.png.4bpp build-linux/assets/graphics/misc/mirage_tower_crumbles.png.gbapal build-linux/assets/graphics/object_events/pics/misc/fossil.png.4bpp build-linux/assets/graphics/object_events/pics/misc/fossil.png.gbapal graphics/misc/mirage_tower.bin include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/event_objects.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_event_ids.h include/constants/map_groups.h include/constants/maps.h include/constants/metatile_labels.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/event_data.h include/event_object_movement.h include/field_camera.h include/fieldmap.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/malloc.h include/menu.h include/palette.h include/palette_util.h include/platform/framedraw.h include/pokemon.h include/random.h include/script.h include/sound.h include/sprite.h include/task.h include/text.h include/window.h
build-linux/native-sdl3/src/mirage_tower.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/event_objects.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_event_ids.h include/constants/map_groups.h include/constants/maps.h include/constants/metatile_labels.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/event_data.h include/event_object_movement.h include/field_camera.h include/fieldmap.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/malloc.h include/menu.h include/palette.h include/palette_util.h include/platform/framedraw.h include/pokemon.h include/random.h include/script.h include/sound.h include/sprite.h include/task.h include/text.h include/window.h
build-linux/assets/graphics/misc/mirage_tower.png_num_tiles_73__Wnum_tiles.4bpp:
build-linux/assets/graphics/misc/mirage_tower_crumbles.png.4bpp:
build-linux/assets/graphics/misc/mirage_tower_crumbles.png.gbapal:
build-linux/assets/graphics/object_events/pics/misc/fossil.png.4bpp:
build-linux/assets/graphics/object_events/pics/misc/fossil.png.gbapal:
graphics/misc/mirage_tower.bin:
include/bg.h:
include/config.h:
include/constants/berry.h:
include/constants/characters.h:
include/constants/easy_chat.h:
include/constants/event_object_movement.h:
include/constants/event_objects.h:
include/constants/flags.h:
include/constants/game_stat.h:
include/constants/global.h:
include/constants/map_event_ids.h:
include/constants/map_groups.h:
include/constants/maps.h:
include/constants/metatile_labels.h:
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
include/event_data.h:
include/event_object_movement.h:
include/field_camera.h:
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
include/gpu_regs.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/palette.h:
include/palette_util.h:
include/platform/framedraw.h:
include/pokemon.h:
include/random.h:
include/script.h:
include/sound.h:
include/sprite.h:
include/task.h:
include/text.h:
include/window.h:
ifndef build-linux/assets/graphics/misc/mirage_tower.png_num_tiles_73__Wnum_tiles.4bpp
build-linux/assets/graphics/misc/mirage_tower.png_num_tiles_73__Wnum_tiles.4bpp := defined
build-linux/assets/graphics/misc/mirage_tower.png_num_tiles_73__Wnum_tiles.4bpp: graphics/misc/mirage_tower.png
	@mkdir -p 'build-linux/assets/graphics/misc'
	$(GFX) $< $@ -num_tiles 73 -Wnum_tiles
endif
ifndef build-linux/assets/graphics/misc/mirage_tower_crumbles.png.4bpp
build-linux/assets/graphics/misc/mirage_tower_crumbles.png.4bpp := defined
build-linux/assets/graphics/misc/mirage_tower_crumbles.png.4bpp: graphics/misc/mirage_tower_crumbles.png
	@mkdir -p 'build-linux/assets/graphics/misc'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/misc/mirage_tower_crumbles.png.gbapal
build-linux/assets/graphics/misc/mirage_tower_crumbles.png.gbapal := defined
build-linux/assets/graphics/misc/mirage_tower_crumbles.png.gbapal: graphics/misc/mirage_tower_crumbles.png
	@mkdir -p 'build-linux/assets/graphics/misc'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/object_events/pics/misc/fossil.png.4bpp
build-linux/assets/graphics/object_events/pics/misc/fossil.png.4bpp := defined
build-linux/assets/graphics/object_events/pics/misc/fossil.png.4bpp: graphics/object_events/pics/misc/fossil.png
	@mkdir -p 'build-linux/assets/graphics/object_events/pics/misc'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/object_events/pics/misc/fossil.png.gbapal
build-linux/assets/graphics/object_events/pics/misc/fossil.png.gbapal := defined
build-linux/assets/graphics/object_events/pics/misc/fossil.png.gbapal: graphics/object_events/pics/misc/fossil.png
	@mkdir -p 'build-linux/assets/graphics/object_events/pics/misc'
	$(GFX) $< $@ 
endif
