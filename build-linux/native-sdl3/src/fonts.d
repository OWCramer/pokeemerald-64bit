build-linux/native-sdl3/src/fonts.o: build-linux/assets/graphics/fonts/japanese_frlg_female.png.fwjpnfont build-linux/assets/graphics/fonts/japanese_frlg_male.png.fwjpnfont build-linux/assets/graphics/fonts/japanese_normal.png.hwjpnfont build-linux/assets/graphics/fonts/japanese_short.png.fwjpnfont build-linux/assets/graphics/fonts/japanese_small.png.hwjpnfont build-linux/assets/graphics/fonts/latin_narrow.png.latfont build-linux/assets/graphics/fonts/latin_normal.png.latfont build-linux/assets/graphics/fonts/latin_short.png.latfont build-linux/assets/graphics/fonts/latin_small.png.latfont build-linux/assets/graphics/fonts/latin_small_narrow.png.latfont include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/pokemon.h include/sprite.h
build-linux/native-sdl3/src/fonts.d: include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/pokemon.h include/sprite.h
build-linux/assets/graphics/fonts/japanese_frlg_female.png.fwjpnfont:
build-linux/assets/graphics/fonts/japanese_frlg_male.png.fwjpnfont:
build-linux/assets/graphics/fonts/japanese_normal.png.hwjpnfont:
build-linux/assets/graphics/fonts/japanese_short.png.fwjpnfont:
build-linux/assets/graphics/fonts/japanese_small.png.hwjpnfont:
build-linux/assets/graphics/fonts/latin_narrow.png.latfont:
build-linux/assets/graphics/fonts/latin_normal.png.latfont:
build-linux/assets/graphics/fonts/latin_short.png.latfont:
build-linux/assets/graphics/fonts/latin_small.png.latfont:
build-linux/assets/graphics/fonts/latin_small_narrow.png.latfont:
include/config.h:
include/constants/berry.h:
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
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/tv.h:
include/constants/vars.h:
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
include/pokemon.h:
include/sprite.h:
ifndef build-linux/assets/graphics/fonts/japanese_frlg_female.png.fwjpnfont
build-linux/assets/graphics/fonts/japanese_frlg_female.png.fwjpnfont := defined
build-linux/assets/graphics/fonts/japanese_frlg_female.png.fwjpnfont: graphics/fonts/japanese_frlg_female.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/japanese_frlg_male.png.fwjpnfont
build-linux/assets/graphics/fonts/japanese_frlg_male.png.fwjpnfont := defined
build-linux/assets/graphics/fonts/japanese_frlg_male.png.fwjpnfont: graphics/fonts/japanese_frlg_male.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/japanese_normal.png.hwjpnfont
build-linux/assets/graphics/fonts/japanese_normal.png.hwjpnfont := defined
build-linux/assets/graphics/fonts/japanese_normal.png.hwjpnfont: graphics/fonts/japanese_normal.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/japanese_short.png.fwjpnfont
build-linux/assets/graphics/fonts/japanese_short.png.fwjpnfont := defined
build-linux/assets/graphics/fonts/japanese_short.png.fwjpnfont: graphics/fonts/japanese_short.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/japanese_small.png.hwjpnfont
build-linux/assets/graphics/fonts/japanese_small.png.hwjpnfont := defined
build-linux/assets/graphics/fonts/japanese_small.png.hwjpnfont: graphics/fonts/japanese_small.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/latin_narrow.png.latfont
build-linux/assets/graphics/fonts/latin_narrow.png.latfont := defined
build-linux/assets/graphics/fonts/latin_narrow.png.latfont: graphics/fonts/latin_narrow.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/latin_normal.png.latfont
build-linux/assets/graphics/fonts/latin_normal.png.latfont := defined
build-linux/assets/graphics/fonts/latin_normal.png.latfont: graphics/fonts/latin_normal.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/latin_short.png.latfont
build-linux/assets/graphics/fonts/latin_short.png.latfont := defined
build-linux/assets/graphics/fonts/latin_short.png.latfont: graphics/fonts/latin_short.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/latin_small.png.latfont
build-linux/assets/graphics/fonts/latin_small.png.latfont := defined
build-linux/assets/graphics/fonts/latin_small.png.latfont: graphics/fonts/latin_small.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/fonts/latin_small_narrow.png.latfont
build-linux/assets/graphics/fonts/latin_small_narrow.png.latfont := defined
build-linux/assets/graphics/fonts/latin_small_narrow.png.latfont: graphics/fonts/latin_small_narrow.png
	@mkdir -p 'build-linux/assets/graphics/fonts'
	$(GFX) $< $@ 
endif
