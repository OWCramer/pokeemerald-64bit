build-linux/native-sdl3/src/battle_anim_effects_3.o: build-linux/assets/graphics/battle_anims/unused/unknown.pal.gbapal include/battle.h include/battle_ai_switch_items.h include/battle_anim.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/bg.h include/config.h include/constants/battle.h include/constants/battle_anim.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/contest.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/constants/weather.h include/contest.h include/data.h include/decompress.h include/dma3.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/malloc.h include/palette.h include/pokeball.h include/pokemon.h include/pokemon_icon.h include/random.h include/scanline_effect.h include/sound.h include/sprite.h include/task.h include/trig.h include/util.h
build-linux/native-sdl3/src/battle_anim_effects_3.d: include/battle.h include/battle_ai_switch_items.h include/battle_anim.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/bg.h include/config.h include/constants/battle.h include/constants/battle_anim.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/contest.h include/constants/easy_chat.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/moves.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/rgb.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/constants/weather.h include/contest.h include/data.h include/decompress.h include/dma3.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/graphics.h include/main.h include/malloc.h include/palette.h include/pokeball.h include/pokemon.h include/pokemon_icon.h include/random.h include/scanline_effect.h include/sound.h include/sprite.h include/task.h include/trig.h include/util.h
build-linux/assets/graphics/battle_anims/unused/unknown.pal.gbapal:
include/battle.h:
include/battle_ai_switch_items.h:
include/battle_anim.h:
include/battle_bg.h:
include/battle_gfx_sfx_util.h:
include/battle_main.h:
include/battle_message.h:
include/battle_script_commands.h:
include/battle_util.h:
include/battle_util2.h:
include/bg.h:
include/config.h:
include/constants/battle.h:
include/constants/battle_anim.h:
include/constants/battle_script_commands.h:
include/constants/berry.h:
include/constants/contest.h:
include/constants/easy_chat.h:
include/constants/flags.h:
include/constants/game_stat.h:
include/constants/global.h:
include/constants/map_groups.h:
include/constants/maps.h:
include/constants/moves.h:
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
include/constants/weather.h:
include/contest.h:
include/data.h:
include/decompress.h:
include/dma3.h:
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
include/malloc.h:
include/palette.h:
include/pokeball.h:
include/pokemon.h:
include/pokemon_icon.h:
include/random.h:
include/scanline_effect.h:
include/sound.h:
include/sprite.h:
include/task.h:
include/trig.h:
include/util.h:
ifndef build-linux/assets/graphics/battle_anims/unused/unknown.pal.gbapal
build-linux/assets/graphics/battle_anims/unused/unknown.pal.gbapal := defined
build-linux/assets/graphics/battle_anims/unused/unknown.pal.gbapal: graphics/battle_anims/unused/unknown.pal
	@mkdir -p 'build-linux/assets/graphics/battle_anims/unused'
	$(GFX) $< $@ 
endif
