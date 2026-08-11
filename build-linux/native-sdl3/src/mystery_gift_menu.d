build-linux/native-sdl3/src/mystery_gift_menu.o: build-linux/assets/graphics/interface/mystery_gift_textbox_border.png.4bpp.lz build-linux/assets/graphics/interface/mystery_gift_textbox_border.png.gbapal include/AgbRfu_LinkManager.h include/bg.h include/config.h include/constants/berry.h include/constants/cable_club.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/mystery_gift.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/union_room.h include/constants/vars.h include/ereader_screen.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/international_string_util.h include/librfu.h include/link.h include/link_rfu.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/mystery_gift.h include/mystery_gift_client.h include/mystery_gift_link.h include/mystery_gift_menu.h include/mystery_gift_server.h include/mystery_gift_view.h include/palette.h include/pokemon.h include/save.h include/scanline_effect.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/title_screen.h include/union_room.h include/window.h include/wonder_news.h
build-linux/native-sdl3/src/mystery_gift_menu.d: include/AgbRfu_LinkManager.h include/bg.h include/config.h include/constants/berry.h include/constants/cable_club.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/mystery_gift.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/union_room.h include/constants/vars.h include/ereader_screen.h include/event_data.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/international_string_util.h include/librfu.h include/link.h include/link_rfu.h include/list_menu.h include/main.h include/malloc.h include/menu.h include/mystery_gift.h include/mystery_gift_client.h include/mystery_gift_link.h include/mystery_gift_menu.h include/mystery_gift_server.h include/mystery_gift_view.h include/palette.h include/pokemon.h include/save.h include/scanline_effect.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/title_screen.h include/union_room.h include/window.h include/wonder_news.h
build-linux/assets/graphics/interface/mystery_gift_textbox_border.png.4bpp.lz:
build-linux/assets/graphics/interface/mystery_gift_textbox_border.png.gbapal:
include/AgbRfu_LinkManager.h:
include/bg.h:
include/config.h:
include/constants/berry.h:
include/constants/cable_club.h:
include/constants/characters.h:
include/constants/easy_chat.h:
include/constants/flags.h:
include/constants/game_stat.h:
include/constants/global.h:
include/constants/map_groups.h:
include/constants/maps.h:
include/constants/mystery_gift.h:
include/constants/opponents.h:
include/constants/pokedex.h:
include/constants/pokemon.h:
include/constants/rematches.h:
include/constants/songs.h:
include/constants/sound.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/union_room.h:
include/constants/vars.h:
include/ereader_screen.h:
include/event_data.h:
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
include/international_string_util.h:
include/librfu.h:
include/link.h:
include/link_rfu.h:
include/list_menu.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/mystery_gift.h:
include/mystery_gift_client.h:
include/mystery_gift_link.h:
include/mystery_gift_menu.h:
include/mystery_gift_server.h:
include/mystery_gift_view.h:
include/palette.h:
include/pokemon.h:
include/save.h:
include/scanline_effect.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/title_screen.h:
include/union_room.h:
include/window.h:
include/wonder_news.h:
ifndef build-linux/assets/graphics/interface/mystery_gift_textbox_border.png.4bpp
build-linux/assets/graphics/interface/mystery_gift_textbox_border.png.4bpp := defined
build-linux/assets/graphics/interface/mystery_gift_textbox_border.png.4bpp: graphics/interface/mystery_gift_textbox_border.png
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/interface/mystery_gift_textbox_border.png.gbapal
build-linux/assets/graphics/interface/mystery_gift_textbox_border.png.gbapal := defined
build-linux/assets/graphics/interface/mystery_gift_textbox_border.png.gbapal: graphics/interface/mystery_gift_textbox_border.png
	@mkdir -p 'build-linux/assets/graphics/interface'
	$(GFX) $< $@ 
endif
