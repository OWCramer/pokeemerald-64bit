build-linux/native-sdl3/src/minigame_countdown.o: build-linux/assets/graphics/link/321start.png.4bpp.lz build-linux/assets/graphics/link/321start.png.gbapal build-linux/assets/graphics/link/321start_static.png.4bpp.lz build-linux/assets/graphics/link/321start_static.png.gbapal include/AgbRfu_LinkManager.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/librfu.h include/link.h include/link_rfu.h include/main.h include/minigame_countdown.h include/pokemon.h include/sound.h include/sprite.h include/task.h include/trig.h
build-linux/native-sdl3/src/minigame_countdown.d: include/AgbRfu_LinkManager.h include/config.h include/constants/berry.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/decompress.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/librfu.h include/link.h include/link_rfu.h include/main.h include/minigame_countdown.h include/pokemon.h include/sound.h include/sprite.h include/task.h include/trig.h
build-linux/assets/graphics/link/321start.png.4bpp.lz:
build-linux/assets/graphics/link/321start.png.gbapal:
build-linux/assets/graphics/link/321start_static.png.4bpp.lz:
build-linux/assets/graphics/link/321start_static.png.gbapal:
include/AgbRfu_LinkManager.h:
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
include/librfu.h:
include/link.h:
include/link_rfu.h:
include/main.h:
include/minigame_countdown.h:
include/pokemon.h:
include/sound.h:
include/sprite.h:
include/task.h:
include/trig.h:
ifndef build-linux/assets/graphics/link/321start.png.4bpp
build-linux/assets/graphics/link/321start.png.4bpp := defined
build-linux/assets/graphics/link/321start.png.4bpp: graphics/link/321start.png
	@mkdir -p 'build-linux/assets/graphics/link'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/link/321start.png.gbapal
build-linux/assets/graphics/link/321start.png.gbapal := defined
build-linux/assets/graphics/link/321start.png.gbapal: graphics/link/321start.png
	@mkdir -p 'build-linux/assets/graphics/link'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/link/321start_static.png.4bpp
build-linux/assets/graphics/link/321start_static.png.4bpp := defined
build-linux/assets/graphics/link/321start_static.png.4bpp: graphics/link/321start_static.png
	@mkdir -p 'build-linux/assets/graphics/link'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/link/321start_static.png.gbapal
build-linux/assets/graphics/link/321start_static.png.gbapal := defined
build-linux/assets/graphics/link/321start_static.png.gbapal: graphics/link/321start_static.png
	@mkdir -p 'build-linux/assets/graphics/link'
	$(GFX) $< $@ 
endif
