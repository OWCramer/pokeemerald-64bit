build-linux/native-sdl3/src/union_room_chat.o: build-linux/assets/graphics/union_room_chat/chat_messages_window.pal.gbapal build-linux/assets/graphics/union_room_chat/interface.pal.gbapal build-linux/assets/graphics/union_room_chat/keyboard_cursor.png.4bpp.lz build-linux/assets/graphics/union_room_chat/r_button.png.4bpp.lz build-linux/assets/graphics/union_room_chat/text_entry_arrow.png.4bpp.lz build-linux/assets/graphics/union_room_chat/text_entry_cursor.png.4bpp.lz build-linux/assets/graphics/union_room_chat/unused.pal.gbapal include/AgbRfu_LinkManager.h include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/dma3.h include/dynamic_placeholder_text_util.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/librfu.h include/link.h include/link_rfu.h include/load_save.h include/main.h include/malloc.h include/menu.h include/overworld.h include/palette.h include/pokemon.h include/pokemon_storage_system.h include/save.h include/scanline_effect.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/union_room_chat.h include/window.h
build-linux/native-sdl3/src/union_room_chat.d: include/AgbRfu_LinkManager.h include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/dma3.h include/dynamic_placeholder_text_util.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/librfu.h include/link.h include/link_rfu.h include/load_save.h include/main.h include/malloc.h include/menu.h include/overworld.h include/palette.h include/pokemon.h include/pokemon_storage_system.h include/save.h include/scanline_effect.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/text_window.h include/union_room_chat.h include/window.h
build-linux/assets/graphics/union_room_chat/chat_messages_window.pal.gbapal:
build-linux/assets/graphics/union_room_chat/interface.pal.gbapal:
build-linux/assets/graphics/union_room_chat/keyboard_cursor.png.4bpp.lz:
build-linux/assets/graphics/union_room_chat/r_button.png.4bpp.lz:
build-linux/assets/graphics/union_room_chat/text_entry_arrow.png.4bpp.lz:
build-linux/assets/graphics/union_room_chat/text_entry_cursor.png.4bpp.lz:
build-linux/assets/graphics/union_room_chat/unused.pal.gbapal:
include/AgbRfu_LinkManager.h:
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
include/dma3.h:
include/dynamic_placeholder_text_util.h:
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
include/librfu.h:
include/link.h:
include/link_rfu.h:
include/load_save.h:
include/main.h:
include/malloc.h:
include/menu.h:
include/overworld.h:
include/palette.h:
include/pokemon.h:
include/pokemon_storage_system.h:
include/save.h:
include/scanline_effect.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/text_window.h:
include/union_room_chat.h:
include/window.h:
ifndef build-linux/assets/graphics/union_room_chat/chat_messages_window.pal.gbapal
build-linux/assets/graphics/union_room_chat/chat_messages_window.pal.gbapal := defined
build-linux/assets/graphics/union_room_chat/chat_messages_window.pal.gbapal: graphics/union_room_chat/chat_messages_window.pal
	@mkdir -p 'build-linux/assets/graphics/union_room_chat'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/union_room_chat/interface.pal.gbapal
build-linux/assets/graphics/union_room_chat/interface.pal.gbapal := defined
build-linux/assets/graphics/union_room_chat/interface.pal.gbapal: graphics/union_room_chat/interface.pal
	@mkdir -p 'build-linux/assets/graphics/union_room_chat'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/union_room_chat/keyboard_cursor.png.4bpp
build-linux/assets/graphics/union_room_chat/keyboard_cursor.png.4bpp := defined
build-linux/assets/graphics/union_room_chat/keyboard_cursor.png.4bpp: graphics/union_room_chat/keyboard_cursor.png
	@mkdir -p 'build-linux/assets/graphics/union_room_chat'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/union_room_chat/r_button.png.4bpp
build-linux/assets/graphics/union_room_chat/r_button.png.4bpp := defined
build-linux/assets/graphics/union_room_chat/r_button.png.4bpp: graphics/union_room_chat/r_button.png
	@mkdir -p 'build-linux/assets/graphics/union_room_chat'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/union_room_chat/text_entry_arrow.png.4bpp
build-linux/assets/graphics/union_room_chat/text_entry_arrow.png.4bpp := defined
build-linux/assets/graphics/union_room_chat/text_entry_arrow.png.4bpp: graphics/union_room_chat/text_entry_arrow.png
	@mkdir -p 'build-linux/assets/graphics/union_room_chat'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/union_room_chat/text_entry_cursor.png.4bpp
build-linux/assets/graphics/union_room_chat/text_entry_cursor.png.4bpp := defined
build-linux/assets/graphics/union_room_chat/text_entry_cursor.png.4bpp: graphics/union_room_chat/text_entry_cursor.png
	@mkdir -p 'build-linux/assets/graphics/union_room_chat'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/union_room_chat/unused.pal.gbapal
build-linux/assets/graphics/union_room_chat/unused.pal.gbapal := defined
build-linux/assets/graphics/union_room_chat/unused.pal.gbapal: graphics/union_room_chat/unused.pal
	@mkdir -p 'build-linux/assets/graphics/union_room_chat'
	$(GFX) $< $@ 
endif
