build-linux/native-sdl3/src/item_menu_icons.o: build-linux/assets/graphics/bag/rotating_ball.png.4bpp build-linux/assets/graphics/bag/rotating_ball.png.gbapal build-linux/assets/graphics/unused/cherry.png.4bpp build-linux/assets/graphics/unused/cherry.png.gbapal include/berry.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/item.h include/constants/items.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/species.h include/constants/tms_hms.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/graphics.h include/item.h include/item_icon.h include/item_menu.h include/item_menu_icons.h include/main.h include/menu_helpers.h include/pokemon.h include/sprite.h include/task.h include/window.h
build-linux/native-sdl3/src/item_menu_icons.d: include/berry.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/item.h include/constants/items.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/species.h include/constants/tms_hms.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/graphics.h include/item.h include/item_icon.h include/item_menu.h include/item_menu_icons.h include/main.h include/menu_helpers.h include/pokemon.h include/sprite.h include/task.h include/window.h
build-linux/assets/graphics/bag/rotating_ball.png.4bpp:
build-linux/assets/graphics/bag/rotating_ball.png.gbapal:
build-linux/assets/graphics/unused/cherry.png.4bpp:
build-linux/assets/graphics/unused/cherry.png.gbapal:
include/berry.h:
include/config.h:
include/constants/berry.h:
include/constants/easy_chat.h:
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
include/constants/species.h:
include/constants/tms_hms.h:
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
include/graphics.h:
include/item.h:
include/item_icon.h:
include/item_menu.h:
include/item_menu_icons.h:
include/main.h:
include/menu_helpers.h:
include/pokemon.h:
include/sprite.h:
include/task.h:
include/window.h:
ifndef build-linux/assets/graphics/bag/rotating_ball.png.4bpp
build-linux/assets/graphics/bag/rotating_ball.png.4bpp := defined
build-linux/assets/graphics/bag/rotating_ball.png.4bpp: graphics/bag/rotating_ball.png
	@mkdir -p 'build-linux/assets/graphics/bag'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/bag/rotating_ball.png.gbapal
build-linux/assets/graphics/bag/rotating_ball.png.gbapal := defined
build-linux/assets/graphics/bag/rotating_ball.png.gbapal: graphics/bag/rotating_ball.png
	@mkdir -p 'build-linux/assets/graphics/bag'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/unused/cherry.png.4bpp
build-linux/assets/graphics/unused/cherry.png.4bpp := defined
build-linux/assets/graphics/unused/cherry.png.4bpp: graphics/unused/cherry.png
	@mkdir -p 'build-linux/assets/graphics/unused'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/unused/cherry.png.gbapal
build-linux/assets/graphics/unused/cherry.png.gbapal := defined
build-linux/assets/graphics/unused/cherry.png.gbapal: graphics/unused/cherry.png
	@mkdir -p 'build-linux/assets/graphics/unused'
	$(GFX) $< $@ 
endif
