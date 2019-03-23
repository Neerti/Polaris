var/datum/species/shapeshifter/promethean/prometheans

// Species definition follows.
/datum/species/shapeshifter/promethean

	name =             SPECIES_PROMETHEAN
	name_plural =      "Prometheans"
	blurb =            "Prometheans (Macrolimus artificialis) are a species of artificially-created gelatinous humanoids, \
	chiefly characterized by their primarily liquid bodies and ability to change their bodily shape and color in order to  \
	mimic many forms of life. Derived from the Aetolian giant slime (Macrolimus vulgaris) inhabiting the warm, tropical planet \
	of Aetolus, they are a relatively new lab-created sapient species, and as such many things about them have yet to be comprehensively studied. \
	What has Science done?"
	catalogue_data = list(/datum/category_item/catalogue/fauna/promethean)
	show_ssd =         "totally quiescent"
	death_message =    "rapidly loses cohesion, splattering across the ground..."
	knockout_message = "collapses inwards, forming a disordered puddle of goo."
	remains_type = /obj/effect/decal/cleanable/ash

	blood_color = "#05FF9B"
	flesh_color = "#05FFFB"

	hunger_factor =    0.2
	reagent_tag =      IS_SLIME
	mob_size =         MOB_SMALL
	bump_flag =        SLIME
	swap_flags =       MONKEY|SLIME|SIMPLE_ANIMAL
	push_flags =       MONKEY|SLIME|SIMPLE_ANIMAL
	flags =            NO_SCAN | NO_SLIP | NO_MINOR_CUT | NO_HALLUCINATION | NO_INFECT
	appearance_flags = HAS_SKIN_COLOR | HAS_EYE_COLOR | HAS_HAIR_COLOR | RADIATION_GLOWS | HAS_UNDERWEAR
	spawn_flags		 = SPECIES_CAN_JOIN | SPECIES_IS_WHITELISTED
	health_hud_intensity = 2
	num_alternate_languages = 3
	species_language = LANGUAGE_SOL_COMMON
	secondary_langs = list(LANGUAGE_SOL_COMMON)	// For some reason, having this as their species language does not allow it to be chosen.
	assisted_langs = list(LANGUAGE_ROOTGLOBAL, LANGUAGE_VOX)	// Prometheans are weird, let's just assume they can use basically any language.

	breath_type = null
	poison_type = null

	speech_bubble_appearance = "slime"

	male_cough_sounds = list('sound/effects/slime_squish.ogg')
	female_cough_sounds = list('sound/effects/slime_squish.ogg')

	min_age =		1
	max_age =		10

	economic_modifier = 3

	gluttonous =	1
	virus_immune =	1
	blood_volume =	560
	brute_mod =		0.75
	burn_mod =		2
	oxy_mod =		0
	flash_mod =		0.5 //No centralized, lensed eyes.
	item_slowdown_mod = 1.33

	cloning_modifier = /datum/modifier/cloning_sickness/promethean

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 240 //Default 200
	cold_level_3 = 130 //Default 120

	heat_level_1 = 320 //Default 360
	heat_level_2 = 370 //Default 400
	heat_level_3 = 600 //Default 1000

	body_temperature = T20C	// Room temperature

	rarity_value = 5

	genders = list(MALE, FEMALE, NEUTER, PLURAL)

	unarmed_types = list(/datum/unarmed_attack/slime_glomp)
	has_organ =     list(O_BRAIN = /obj/item/organ/internal/brain/slime) // Slime core.

	dispersed_eyes = TRUE

	has_limbs = list(
		BP_TORSO =  list("path" = /obj/item/organ/external/chest/unbreakable/slime),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin/unbreakable/slime),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/unbreakable/slime),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm/unbreakable/slime),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/unbreakable/slime),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg/unbreakable/slime),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/unbreakable/slime),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand/unbreakable/slime),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right/unbreakable/slime),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot/unbreakable/slime),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right/unbreakable/slime)
		)
	heat_discomfort_strings = list("You feel too warm.")
	cold_discomfort_strings = list("You feel too cool.")

	inherent_verbs = list(
		/mob/living/carbon/human/proc/shapeshifter_select_shape,
		/mob/living/carbon/human/proc/shapeshifter_select_colour,
		/mob/living/carbon/human/proc/shapeshifter_select_hair,
		/mob/living/carbon/human/proc/shapeshifter_select_eye_colour,
		/mob/living/carbon/human/proc/shapeshifter_select_hair_colors,
		/mob/living/carbon/human/proc/shapeshifter_select_gender,
		/mob/living/carbon/human/proc/regenerate
		)

	valid_transform_species = list(SPECIES_HUMAN, SPECIES_HUMAN_VATBORN, SPECIES_UNATHI, SPECIES_TAJ, SPECIES_SKRELL, SPECIES_DIONA, SPECIES_TESHARI, SPECIES_MONKEY)

	var/heal_rate = 0.5 // Temp. Regen per tick.

/datum/species/shapeshifter/promethean/New()
	..()
	prometheans = src

/datum/species/shapeshifter/promethean/equip_survival_gear(var/mob/living/carbon/human/H)
	var/boxtype = pick(typesof(/obj/item/weapon/storage/toolbox/lunchbox))
	var/obj/item/weapon/storage/toolbox/lunchbox/L = new boxtype(get_turf(H))
	var/mob/living/simple_mob/animal/passive/mouse/mouse = new (L)
	var/obj/item/weapon/holder/holder = new (L)
	mouse.forceMove(holder)
	holder.sync(mouse)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(L, slot_r_hand)
	else
		H.equip_to_slot_or_del(L, slot_in_backpack)

/datum/species/shapeshifter/promethean/hug(var/mob/living/carbon/human/H, var/mob/living/target)

	var/t_him = "them"
	if(ishuman(target))
		var/mob/living/carbon/human/T = target
		switch(T.identifying_gender)
			if(MALE)
				t_him = "him"
			if(FEMALE)
				t_him = "her"
	else
		switch(target.gender)
			if(MALE)
				t_him = "him"
			if(FEMALE)
				t_him = "her"

	H.visible_message("<span class='notice'>\The [H] glomps [target] to make [t_him] feel better!</span>", \
					"<span class='notice'>You glomp [target] to make [t_him] feel better!</span>")
	H.apply_stored_shock_to(target)

/datum/species/shapeshifter/promethean/handle_death(var/mob/living/carbon/human/H)
	spawn(1)
		if(H)
			H.gib()

/datum/species/shapeshifter/promethean/handle_environment_special(var/mob/living/carbon/human/H)
	var/healing = TRUE	// Switches to FALSE if the environment's bad

	if(H.fire_stacks < 0)	// If you're soaked, you're melting
		H.adjustToxLoss(2*heal_rate)	// Doubled because 0.5 is miniscule, and fire_stacks are capped in both directions
		healing = FALSE

	var/turf/T = get_turf(H)
	if(istype(T))
		var/obj/effect/decal/cleanable/C = locate() in T
		if(C && !(H.shoes || (H.wear_suit && (H.wear_suit.body_parts_covered & FEET))))
			qdel(C)
			if (istype(T, /turf/simulated))
				var/turf/simulated/S = T
				S.dirt = 0
			H.nutrition = min(500, max(0, H.nutrition + rand(15, 30)))

		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = environment.return_pressure()
		var/affecting_pressure = H.calculate_affecting_pressure(pressure)
		if(affecting_pressure <= hazard_low_pressure)	// If you're in a vacuum, you don't heal
			healing = FALSE

	if(H.bodytemperature > heat_level_1 || H.bodytemperature < cold_level_1)	// If you're too hot or cold, you don't heal
		healing = FALSE

	if(H.nutrition < 50)	// If you're starving, you don't heal
		healing = FALSE

	// Heal remaining damage.
	if(healing)
		if(H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss())

			var/nutrition_cost = 0		// The total amount of nutrition drained every tick, when healing
			var/starve_mod = 1			// Lowers healing, increases agony

			if(H.nutrition <= 150)	// This is when the icon goes red
				starve_mod = 0.75
			heal_rate *= starve_mod

			if(H.getBruteLoss())
				H.adjustBruteLoss(-heal_rate)
				nutrition_cost += heal_rate
			if(H.getFireLoss())
				H.adjustFireLoss(-heal_rate)
				nutrition_cost += heal_rate
			if(H.getOxyLoss())
				H.adjustOxyLoss(-heal_rate)
				nutrition_cost += heal_rate
			if(H.getToxLoss())
				H.adjustToxLoss(-heal_rate)
				nutrition_cost += heal_rate

			H.nutrition -= (3 * nutrition_cost) //Costs Nutrition when damage is being repaired, corresponding to the amount of damage being repaired.
			H.nutrition = max(0, H.nutrition) //Ensure it's not below 0.

			var/agony_to_apply = ((1 / starve_mod) * nutrition_cost) //Regenerating damage causes minor pain over time. Small injures will be no issue, large ones will cause problems.

			if((H.getHalLoss() + agony_to_apply) <= 70) // Don't permalock, but make it far easier to knock them down.
				H.apply_damage(agony_to_apply, HALLOSS)


/datum/species/shapeshifter/promethean/get_blood_colour(var/mob/living/carbon/human/H)
	return (H ? rgb(H.r_skin, H.g_skin, H.b_skin) : ..())

/datum/species/shapeshifter/promethean/get_flesh_colour(var/mob/living/carbon/human/H)
	return (H ? rgb(H.r_skin, H.g_skin, H.b_skin) : ..())
