build-linux/native-sdl3/src/trainer_see.o: build-linux/assets/graphics/field_effects/pics/emotion_exclamation.png.4bpp build-linux/assets/graphics/field_effects/pics/emotion_heart.png.4bpp build-linux/assets/graphics/field_effects/pics/emotion_question.png.4bpp include/battle_pyramid.h include/battle_setup.h include/config.h include/constants/battle_pyramid.h include/constants/battle_setup.h include/constants/berry.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/event_objects.h include/constants/field_effects.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_event_ids.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/species.h include/constants/trainer_hill.h include/constants/trainer_types.h include/constants/tv.h include/constants/vars.h include/event_data.h include/event_object_movement.h include/field_effect.h include/field_player_avatar.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gym_leader_rematch.h include/pokemon.h include/script.h include/script_movement.h include/sprite.h include/task.h include/trainer_hill.h include/trainer_see.h include/util.h
build-linux/native-sdl3/src/trainer_see.d: include/battle_pyramid.h include/battle_setup.h include/config.h include/constants/battle_pyramid.h include/constants/battle_setup.h include/constants/berry.h include/constants/easy_chat.h include/constants/event_object_movement.h include/constants/event_objects.h include/constants/field_effects.h include/constants/flags.h include/constants/game_stat.h include/constants/global.h include/constants/map_event_ids.h include/constants/map_groups.h include/constants/maps.h include/constants/opponents.h include/constants/pokedex.h include/constants/pokemon.h include/constants/rematches.h include/constants/species.h include/constants/trainer_hill.h include/constants/trainer_types.h include/constants/tv.h include/constants/vars.h include/event_data.h include/event_object_movement.h include/field_effect.h include/field_player_avatar.h include/gametypes.h include/gba/defines.h include/gba/gba.h include/gba/io_reg.h include/gba/isagbprint.h include/gba/macro.h include/gba/multiboot.h include/gba/syscall.h include/gba/types.h include/global.berry.h include/global.fieldmap.h include/global.h include/global.tv.h include/gym_leader_rematch.h include/pokemon.h include/script.h include/script_movement.h include/sprite.h include/task.h include/trainer_hill.h include/trainer_see.h include/util.h
build-linux/assets/graphics/field_effects/pics/emotion_exclamation.png.4bpp:
build-linux/assets/graphics/field_effects/pics/emotion_heart.png.4bpp:
build-linux/assets/graphics/field_effects/pics/emotion_question.png.4bpp:
include/battle_pyramid.h:
include/battle_setup.h:
include/config.h:
include/constants/battle_pyramid.h:
include/constants/battle_setup.h:
include/constants/berry.h:
include/constants/easy_chat.h:
include/constants/event_object_movement.h:
include/constants/event_objects.h:
include/constants/field_effects.h:
include/constants/flags.h:
include/constants/game_stat.h:
include/constants/global.h:
include/constants/map_event_ids.h:
include/constants/map_groups.h:
include/constants/maps.h:
include/constants/opponents.h:
include/constants/pokedex.h:
include/constants/pokemon.h:
include/constants/rematches.h:
include/constants/species.h:
include/constants/trainer_hill.h:
include/constants/trainer_types.h:
include/constants/tv.h:
include/constants/vars.h:
include/event_data.h:
include/event_object_movement.h:
include/field_effect.h:
include/field_player_avatar.h:
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
include/gym_leader_rematch.h:
include/pokemon.h:
include/script.h:
include/script_movement.h:
include/sprite.h:
include/task.h:
include/trainer_hill.h:
include/trainer_see.h:
include/util.h:
ifndef build-linux/assets/graphics/field_effects/pics/emotion_exclamation.png.4bpp
build-linux/assets/graphics/field_effects/pics/emotion_exclamation.png.4bpp := defined
build-linux/assets/graphics/field_effects/pics/emotion_exclamation.png.4bpp: graphics/field_effects/pics/emotion_exclamation.png
	@mkdir -p 'build-linux/assets/graphics/field_effects/pics'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/field_effects/pics/emotion_heart.png.4bpp
build-linux/assets/graphics/field_effects/pics/emotion_heart.png.4bpp := defined
build-linux/assets/graphics/field_effects/pics/emotion_heart.png.4bpp: graphics/field_effects/pics/emotion_heart.png
	@mkdir -p 'build-linux/assets/graphics/field_effects/pics'
	$(GFX) $< $@ 
endif
ifndef build-linux/assets/graphics/field_effects/pics/emotion_question.png.4bpp
build-linux/assets/graphics/field_effects/pics/emotion_question.png.4bpp := defined
build-linux/assets/graphics/field_effects/pics/emotion_question.png.4bpp: graphics/field_effects/pics/emotion_question.png
	@mkdir -p 'build-linux/assets/graphics/field_effects/pics'
	$(GFX) $< $@ 
endif
