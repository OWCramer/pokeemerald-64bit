/* Generated: flat TM/HM item constants, one .set per line.
   The upstream mechanism expands FOREACH_TM into a single line of
   `enum A; enum B; ...`. clang's arm64 assembler treats ';' as a comment,
   so all but the first stay undefined and become external 2-byte
   relocations that Mach-O cannot express. Executing the enum macro that
   many times also crashes Apple clang 21's integrated assembler, so this
   avoids macro invocation entirely. */
	.set ITEM_TM_FOCUS_PUNCH, 289
	.set ITEM_TM_DRAGON_CLAW, 290
	.set ITEM_TM_WATER_PULSE, 291
	.set ITEM_TM_CALM_MIND, 292
	.set ITEM_TM_ROAR, 293
	.set ITEM_TM_TOXIC, 294
	.set ITEM_TM_HAIL, 295
	.set ITEM_TM_BULK_UP, 296
	.set ITEM_TM_BULLET_SEED, 297
	.set ITEM_TM_HIDDEN_POWER, 298
	.set ITEM_TM_SUNNY_DAY, 299
	.set ITEM_TM_TAUNT, 300
	.set ITEM_TM_ICE_BEAM, 301
	.set ITEM_TM_BLIZZARD, 302
	.set ITEM_TM_HYPER_BEAM, 303
	.set ITEM_TM_LIGHT_SCREEN, 304
	.set ITEM_TM_PROTECT, 305
	.set ITEM_TM_RAIN_DANCE, 306
	.set ITEM_TM_GIGA_DRAIN, 307
	.set ITEM_TM_SAFEGUARD, 308
	.set ITEM_TM_FRUSTRATION, 309
	.set ITEM_TM_SOLAR_BEAM, 310
	.set ITEM_TM_IRON_TAIL, 311
	.set ITEM_TM_THUNDERBOLT, 312
	.set ITEM_TM_THUNDER, 313
	.set ITEM_TM_EARTHQUAKE, 314
	.set ITEM_TM_RETURN, 315
	.set ITEM_TM_DIG, 316
	.set ITEM_TM_PSYCHIC, 317
	.set ITEM_TM_SHADOW_BALL, 318
	.set ITEM_TM_BRICK_BREAK, 319
	.set ITEM_TM_DOUBLE_TEAM, 320
	.set ITEM_TM_REFLECT, 321
	.set ITEM_TM_SHOCK_WAVE, 322
	.set ITEM_TM_FLAMETHROWER, 323
	.set ITEM_TM_SLUDGE_BOMB, 324
	.set ITEM_TM_SANDSTORM, 325
	.set ITEM_TM_FIRE_BLAST, 326
	.set ITEM_TM_ROCK_TOMB, 327
	.set ITEM_TM_AERIAL_ACE, 328
	.set ITEM_TM_TORMENT, 329
	.set ITEM_TM_FACADE, 330
	.set ITEM_TM_SECRET_POWER, 331
	.set ITEM_TM_REST, 332
	.set ITEM_TM_ATTRACT, 333
	.set ITEM_TM_THIEF, 334
	.set ITEM_TM_STEEL_WING, 335
	.set ITEM_TM_SKILL_SWAP, 336
	.set ITEM_TM_SNATCH, 337
	.set ITEM_TM_OVERHEAT, 338
	.set ITEM_HM_CUT, 339
	.set ITEM_HM_FLY, 340
	.set ITEM_HM_SURF, 341
	.set ITEM_HM_STRENGTH, 342
	.set ITEM_HM_FLASH, 343
	.set ITEM_HM_ROCK_SMASH, 344
	.set ITEM_HM_WATERFALL, 345
	.set ITEM_HM_DIVE, 346
