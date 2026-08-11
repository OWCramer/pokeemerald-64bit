build-linux/native-sdl3/src/field_weather_effect.o: build-linux/assets/graphics/weather/ash.png.4bpp build-linux/assets/graphics/weather/bubble.png.4bpp build-linux/assets/graphics/weather/cloud.png.4bpp build-linux/assets/graphics/weather/cloud.png.gbapal build-linux/assets/graphics/weather/fog_diagonal.png.4bpp build-linux/assets/graphics/weather/fog_horizontal.png.4bpp build-linux/assets/graphics/weather/rain.png.4bpp build-linux/assets/graphics/weather/sandstorm.png.4bpp build-linux/assets/graphics/weather/sandstorm.png.gbapal build-linux/assets/graphics/weather/snow0.png.4bpp build-linux/assets/graphics/weather/snow1.png.4bpp include/battle.h include/battle_ai_switch_items.h include/battle_anim.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/config.h include/constants/battle.h include/constants/battle_anim.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/field_weather.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/constants/weather.h include/event_object_movement.h include/field_weather.h include/fieldmap.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/overworld.h include/pokeball.h include/pokemon.h include/random.h include/script.h include/sound.h include/sprite.h include/task.h include/trig.h
build-linux/native-sdl3/src/field_weather_effect.d: include/battle.h include/battle_ai_switch_items.h include/battle_anim.h include/battle_bg.h include/battle_gfx_sfx_util.h include/battle_main.h include/battle_message.h include/battle_script_commands.h include/battle_util.h include/battle_util2.h include/config.h include/constants/battle.h include/constants/battle_anim.h include/constants/battle_script_commands.h include/constants/berry.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/field_weather.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/songs.h include/constants/sound.h include/constants/species.h include/constants/trainer_hill.h include/constants/tv.h include/constants/vars.h include/constants/weather.h include/event_object_movement.h include/field_weather.h include/fieldmap.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gpu_regs.h include/main.h include/overworld.h include/pokeball.h include/pokemon.h include/random.h include/script.h include/sound.h include/sprite.h include/task.h include/trig.h
build-linux/assets/graphics/weather/ash.png.4bpp:
build-linux/assets/graphics/weather/bubble.png.4bpp:
build-linux/assets/graphics/weather/cloud.png.4bpp:
build-linux/assets/graphics/weather/cloud.png.gbapal:
build-linux/assets/graphics/weather/fog_diagonal.png.4bpp:
build-linux/assets/graphics/weather/fog_horizontal.png.4bpp:
build-linux/assets/graphics/weather/rain.png.4bpp:
build-linux/assets/graphics/weather/sandstorm.png.4bpp:
build-linux/assets/graphics/weather/sandstorm.png.gbapal:
build-linux/assets/graphics/weather/snow0.png.4bpp:
build-linux/assets/graphics/weather/snow1.png.4bpp:
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
include/config.h:
include/constants/battle.h:
include/constants/battle_anim.h:
include/constants/battle_script_commands.h:
include/constants/berry.h:
include/constants/easy_chat.h:
include/constants/event_object_movement.h:
include/constants/field_weather.h:
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
include/constants/weather.h:
include/event_object_movement.h:
include/field_weather.h:
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
include/overworld.h:
include/pokeball.h:
include/pokemon.h:
include/random.h:
include/script.h:
include/sound.h:
include/sprite.h:
include/task.h:
include/trig.h:
ifndef build-linux/assets/graphics/weather/ash.png.4bpp
build-linux/assets/graphics/weather/ash.png.4bpp := defined
build-linux/assets/graphics/weather/ash.png.4bpp: graphics/weather/ash.png
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/weather/bubble.png.4bpp
build-linux/assets/graphics/weather/bubble.png.4bpp := defined
build-linux/assets/graphics/weather/bubble.png.4bpp: graphics/weather/bubble.png
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/weather/cloud.png.4bpp
build-linux/assets/graphics/weather/cloud.png.4bpp := defined
build-linux/assets/graphics/weather/cloud.png.4bpp: graphics/weather/cloud.png
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/weather/cloud.png.gbapal
build-linux/assets/graphics/weather/cloud.png.gbapal := defined
build-linux/assets/graphics/weather/cloud.png.gbapal: graphics/weather/cloud.png
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/weather/fog_diagonal.png.4bpp
build-linux/assets/graphics/weather/fog_diagonal.png.4bpp := defined
build-linux/assets/graphics/weather/fog_diagonal.png.4bpp: graphics/weather/fog_diagonal.png
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/weather/fog_horizontal.png.4bpp
build-linux/assets/graphics/weather/fog_horizontal.png.4bpp := defined
build-linux/assets/graphics/weather/fog_horizontal.png.4bpp: graphics/weather/fog_horizontal.png
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/weather/rain.png.4bpp
build-linux/assets/graphics/weather/rain.png.4bpp := defined
build-linux/assets/graphics/weather/rain.png.4bpp: graphics/weather/rain.png
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/weather/sandstorm.png.4bpp
build-linux/assets/graphics/weather/sandstorm.png.4bpp := defined
build-linux/assets/graphics/weather/sandstorm.png.4bpp: graphics/weather/sandstorm.png
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/weather/sandstorm.png.gbapal
build-linux/assets/graphics/weather/sandstorm.png.gbapal := defined
build-linux/assets/graphics/weather/sandstorm.png.gbapal: graphics/weather/sandstorm.png
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/weather/snow0.png.4bpp
build-linux/assets/graphics/weather/snow0.png.4bpp := defined
build-linux/assets/graphics/weather/snow0.png.4bpp: graphics/weather/snow0.png
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/weather/snow1.png.4bpp
build-linux/assets/graphics/weather/snow1.png.4bpp := defined
build-linux/assets/graphics/weather/snow1.png.4bpp: graphics/weather/snow1.png
	@mkdir -p 'build-linux/assets/graphics/weather'
	$(GFX) $< $@ 
endif
