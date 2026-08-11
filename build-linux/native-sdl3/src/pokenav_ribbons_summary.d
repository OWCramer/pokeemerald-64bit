build-linux/native-sdl3/src/pokenav_ribbons_summary.o: build-linux/assets/graphics/pokenav/ribbons/icons.png.4bpp.lz build-linux/assets/graphics/pokenav/ribbons/icons1.pal.gbapal build-linux/assets/graphics/pokenav/ribbons/icons2.pal.gbapal build-linux/assets/graphics/pokenav/ribbons/icons3.pal.gbapal build-linux/assets/graphics/pokenav/ribbons/icons4.pal.gbapal build-linux/assets/graphics/pokenav/ribbons/icons5.pal.gbapal build-linux/assets/graphics/pokenav/ribbons/icons_big.png.4bpp.lz build-linux/assets/graphics/pokenav/ribbons/mon_info.pal.gbapal include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/dynamic_placeholder_text_util.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/graphics.h include/international_string_util.h include/list_menu.h include/main.h include/menu.h include/palette.h include/pokemon.h include/pokemon_storage_system.h include/pokenav.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/trainer_pokemon_sprites.h include/window.h src/data/text/gift_ribbon_descriptions.h src/data/text/ribbon_descriptions.h
build-linux/native-sdl3/src/pokenav_ribbons_summary.d: include/bg.h include/config.h include/constants/berry.h include/constants/characters.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/dynamic_placeholder_text_util.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/graphics.h include/international_string_util.h include/list_menu.h include/main.h include/menu.h include/palette.h include/pokemon.h include/pokemon_storage_system.h include/pokenav.h include/sound.h include/sprite.h include/string_util.h include/strings.h include/task.h include/text.h include/trainer_pokemon_sprites.h include/window.h src/data/text/gift_ribbon_descriptions.h src/data/text/ribbon_descriptions.h
build-linux/assets/graphics/pokenav/ribbons/icons.png.4bpp.lz:
build-linux/assets/graphics/pokenav/ribbons/icons1.pal.gbapal:
build-linux/assets/graphics/pokenav/ribbons/icons2.pal.gbapal:
build-linux/assets/graphics/pokenav/ribbons/icons3.pal.gbapal:
build-linux/assets/graphics/pokenav/ribbons/icons4.pal.gbapal:
build-linux/assets/graphics/pokenav/ribbons/icons5.pal.gbapal:
build-linux/assets/graphics/pokenav/ribbons/icons_big.png.4bpp.lz:
build-linux/assets/graphics/pokenav/ribbons/mon_info.pal.gbapal:
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
include/constants/songs.h:
include/constants/sound.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
include/decompress.h:
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
include/graphics.h:
include/international_string_util.h:
include/list_menu.h:
include/main.h:
include/menu.h:
include/palette.h:
include/pokemon.h:
include/pokemon_storage_system.h:
include/pokenav.h:
include/sound.h:
include/sprite.h:
include/string_util.h:
include/strings.h:
include/task.h:
include/text.h:
include/trainer_pokemon_sprites.h:
include/window.h:
src/data/text/gift_ribbon_descriptions.h:
src/data/text/ribbon_descriptions.h:
ifndef build-linux/assets/graphics/pokenav/ribbons/icons.png.4bpp
build-linux/assets/graphics/pokenav/ribbons/icons.png.4bpp := defined
build-linux/assets/graphics/pokenav/ribbons/icons.png.4bpp: graphics/pokenav/ribbons/icons.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/ribbons/icons1.pal.gbapal
build-linux/assets/graphics/pokenav/ribbons/icons1.pal.gbapal := defined
build-linux/assets/graphics/pokenav/ribbons/icons1.pal.gbapal: graphics/pokenav/ribbons/icons1.pal
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/ribbons/icons2.pal.gbapal
build-linux/assets/graphics/pokenav/ribbons/icons2.pal.gbapal := defined
build-linux/assets/graphics/pokenav/ribbons/icons2.pal.gbapal: graphics/pokenav/ribbons/icons2.pal
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/ribbons/icons3.pal.gbapal
build-linux/assets/graphics/pokenav/ribbons/icons3.pal.gbapal := defined
build-linux/assets/graphics/pokenav/ribbons/icons3.pal.gbapal: graphics/pokenav/ribbons/icons3.pal
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/ribbons/icons4.pal.gbapal
build-linux/assets/graphics/pokenav/ribbons/icons4.pal.gbapal := defined
build-linux/assets/graphics/pokenav/ribbons/icons4.pal.gbapal: graphics/pokenav/ribbons/icons4.pal
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/ribbons/icons5.pal.gbapal
build-linux/assets/graphics/pokenav/ribbons/icons5.pal.gbapal := defined
build-linux/assets/graphics/pokenav/ribbons/icons5.pal.gbapal: graphics/pokenav/ribbons/icons5.pal
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/ribbons/icons_big.png.4bpp
build-linux/assets/graphics/pokenav/ribbons/icons_big.png.4bpp := defined
build-linux/assets/graphics/pokenav/ribbons/icons_big.png.4bpp: graphics/pokenav/ribbons/icons_big.png
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/pokenav/ribbons/mon_info.pal.gbapal
build-linux/assets/graphics/pokenav/ribbons/mon_info.pal.gbapal := defined
build-linux/assets/graphics/pokenav/ribbons/mon_info.pal.gbapal: graphics/pokenav/ribbons/mon_info.pal
	@mkdir -p 'build-linux/assets/graphics/pokenav/ribbons'
	$(GFX) $< $@ 
endif
