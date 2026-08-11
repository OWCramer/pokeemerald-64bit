build-linux/native-sdl3/src/berry_tag_screen.o: build-linux/assets/graphics/bag/berry_tag_screen.pal.gbapal include/berry.h include/berry_tag_screen.h include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/item.h include/constants/items.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/tms_hms.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/event_object_movement.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/international_string_util.h include/item.h include/item_menu.h include/item_menu_icons.h include/item_use.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/menu_helpers.h include/overworld.h include/palette.h include/pokemon.h include/scanline_effect.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/window.h
build-linux/native-sdl3/src/berry_tag_screen.d: include/berry.h include/berry_tag_screen.h include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/item.h include/constants/items.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/tms_hms.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/event_object_movement.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/international_string_util.h include/item.h include/item_menu.h include/item_menu_icons.h include/item_use.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/menu_helpers.h include/overworld.h include/palette.h include/pokemon.h include/scanline_effect.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/window.h
build-linux/assets/graphics/bag/berry_tag_screen.pal.gbapal:
include/berry.h:
include/berry_tag_screen.h:
include/bg.h:
include/config.h:
include/constants/berry.h:
include/constants/characters.h:
include/constants/easy_chat.h:
include/constants/event_object_movement.h:
include/constants/flags.h:
include/constants/game_stat.h:
include/constants/global.h:
include/constants/item.h:
include/constants/items.h:
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
include/constants/tms_hms.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
include/decompress.h:
include/event_object_movement.h:
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
include/international_string_util.h:
include/item.h:
include/item_menu.h:
include/item_menu_icons.h:
include/item_use.h:
include/list_menu.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/menu_helpers.h:
include/overworld.h:
include/palette.h:
include/pokemon.h:
include/scanline_effect.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/window.h:
ifndef build-linux/assets/graphics/bag/berry_tag_screen.pal.gbapal
build-linux/assets/graphics/bag/berry_tag_screen.pal.gbapal := defined
build-linux/assets/graphics/bag/berry_tag_screen.pal.gbapal: graphics/bag/berry_tag_screen.pal
	@mkdir -p 'build-linux/assets/graphics/bag'
	$(GFX) $< $@ 
endif
