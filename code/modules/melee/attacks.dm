/decl/weapon_attack
	/// Used for bookkeeping and showing to players when choosing a special attack.
	var/name = "strike"
	var/strike_past_tense = "struck"
	// How long it takes for the attack to actually happen.
	var/delay = 0.4 SECONDS
	var/damage_modifier = 1.0
	var/strike_icon_state = "slash"
	var/marker_type = /obj/effect/melee_marker
	/** List of relative coordinates that the attack will target.
	Coordinates assume a NORTH-facing attacker. In-game, it will be rotated if attacking in other directions automatically.
	E.g. list( list(0,1) ) will target the tile directly in front of the attacker.
	*/
	var/list/strike_area

// Override for special effects specific to a `/weapon attack`, after a successful attack, like injecting poison or stunning the target.
/decl/weapon_attack/proc/apply_special_effect(mob/living/user, mob/living/target)

/decl/weapon_attack/thrust
	name = "thrust"
	strike_past_tense = "pierced"
	delay = 0.4 SECONDS
	strike_area = list(
		list(0,1),
		list(0,2)
	)

/decl/weapon_attack/slash
	name = "slash"
	strike_past_tense = "slashed"
	delay = 0.4 SECONDS
	strike_area = list(
		list(-1,1),
		list(0,1),
		list(1,1)
	)

/// Used for bats and other big blunt things.
/decl/weapon_attack/staggering_blow
	name = "stagger"
	strike_past_tense = "staggered"
	strike_icon_state = "smash"
	delay = 0.5 SECONDS
	damage_modifier = 1.3
	strike_area = list(
		list(0,1)
	)

/decl/weapon_attack/staggering_blow/apply_special_effect(mob/living/user, mob/living/target)
	var/amount = target.apply_knockback(2, user) // Hit a tesh for a home run!
	if(amount > 0) // Don't stagger if it didn't actually do knockback.
		target.AdjustStunned(max(amount / 2, 1))
		target.add_modifier(/datum/modifier/staggered, amount SECONDS, user)


/// Attack style used by polearm-like weapons such as spears, that have an extended reach.
/decl/weapon_attack/reaching_thrust
	name = "thrust"
	strike_past_tense = "pierced"
	delay = 0.8 SECONDS
	strike_area = list(
		list(0,2)
	)

/// Axe-specific attack. Hits mobs in a semi-circle in front of the user.
/decl/weapon_attack/cleave
	name = "cleave"
	strike_past_tense = "cleaved"
	delay = 0.5 SECONDS
	damage_modifier = 0.7
	strike_area = list(
		lisr(-1,0),
		list(-1,1),
		list(0,1),
		list(1,1),
		list(1,0)
	)


/// Marker for an attack that is going to happen very soon.
/obj/effect/melee_marker
	name = "approaching melee attack"
	desc = "Watch out!"
	icon = 'icons/effects/melee_marker.dmi'
	icon_state = "marker"
	alpha = 0
	simulated = FALSE

/obj/effect/melee_marker/Initialize(mapload, attack_delay)
	. = ..(mapload)
	color = COLOR_YELLOW
	animate(src, alpha = 255, color = COLOR_RED, time = attack_delay)

/// Marker for an attack that just happened. Seen by everyone.
/obj/effect/temporary_effect/strike_marker
	icon = 'icons/effects/melee_marker.dmi'
	icon_state = "blank"
	simulated = FALSE
	time_to_die = 1 SECOND

/obj/effect/temporary_effect/strike_marker/proc/do_strike(decl/weapon_attack/pending_attack, mob/pending_attacker, obj/item/pending_attacking_with)
	set waitfor = FALSE
	name = pending_attack.name
	flick(pending_attack.strike_icon_state, src)
	for(var/mob/M in loc)
		pending_attacking_with.resolve_attackby(M, pending_attacker, pending_attack.damage_modifier)
		pending_attack.apply_special_effect(pending_attacker, M)

/decl/weapon_attack/proc/mark_strike_area(mob/attacker, atom/movable/attacking_with, atom/target)
	attacking_with = attacking_with || attacker
	var/turf/origin = get_turf(attacker)
	var/turf/last_turf = origin
	var/attack_dir = (target && get_dist(origin, get_turf(target))) || attacker.dir
	for(var/point = 1 to length(strike_area))

		var/list/point_to_strike = strike_area[point]
		var/use_x = attacker.x
		var/use_y = attacker.y
		if(attack_dir & NORTH)
			use_x += point_to_strike[1]
			use_y += point_to_strike[2]
		else if(attack_dir & SOUTH)
			use_x -= point_to_strike[1]
			use_y -= point_to_strike[2]
		else if(attack_dir & EAST)
			use_x += point_to_strike[2]
			use_y += point_to_strike[1]
		else if(attack_dir & WEST)
			use_x -= point_to_strike[2]
			use_y -= point_to_strike[1]

		var/turf/marking = locate(use_x, use_y, attacker.z)
		if(marking && last_turf.CanPass(attacking_with, marking) && origin.CanPass(attacking_with, marking))
			last_turf = marking
			var/image/I = image(null)
			I.appearance = attacking_with
			I.pixel_x = 0
			I.pixel_y = 0
			I.pixel_z = 0
			I.pixel_w = 0
			I.layer = FLOAT_LAYER
			var/obj/effect/marker = new marker_type(marking, delay)
			I.plane = marker.plane
			marker.overlays += I
			LAZYADD(., marker)

/decl/weapon_attack/proc/show_message(var/atom/target, var/atom/target)
	return

// TODO
/mob/Bump(var/atom/A)
	if(a_intent == I_HURT && !incapacitated())
		var/obj/item/weapon = get_active_hand()
		if(weapon?.try_special_attack(src, A))
			return
	. = ..()

/obj/item
	var/performing_special_attack = FALSE
	var/list/special_attack_types

/obj/item/weapon/material/sword
	special_attack_types = list(/decl/weapon_attack/slash)

/obj/item/weapon/material/twohanded/spear
	special_attack_types = list(/decl/weapon_attack/reaching_thrust)

/obj/item/weapon/material/twohanded/baseballbat
	special_attack_types = list(/decl/weapon_attack/staggering_blow)

/obj/item/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(performing_special_attack || proximity_flag || !try_special_attack(user, target))
		return ..()

/// Initiates a special attack onto a target.
/obj/item/proc/try_special_attack(var/mob/living/user, var/atom/target)
	if(!length(special_attack_types))
		return FALSE
	if(!istype(user))
		return FALSE
	var/attack_type = pick(special_attack_types) // TODO
	var/decl/weapon_attack/pending_attack = GET_DECL(attack_type)
	var/list/markers = pending_attack.mark_strike_area(user, src)
	if(!length(markers))
		return FALSE
	performing_special_attack = TRUE
	var/initial_attacker_loc = user.loc
	var/initial_attacker_dir = user.dir
//	var/attack_delay = pending_attack.delay // todo: modify by combat skill

	// Click delay modifiers also affect telegraphing time.
	// This means berserked enemies will leave less time to dodge.
	var/true_attack_delay = pending_attack.delay
	for(var/datum/modifier/M in user.modifiers)
		if(!isnull(M.attack_speed_percent))
			true_attack_delay *= M.attack_speed_percent

	user.do_windup_animation(target, true_attack_delay)

	addtimer(CALLBACK(src, /obj/item/proc/finish_special_attack, markers, user, pending_attack), true_attack_delay)
	do_after(user, true_attack_delay, target)
	/*
	while(performing_special_attack)
		if(QDELETED(src) || QDELETED(user))
			break
		if(user.get_active_hand() != src)
			break
		if(user.loc != initial_attacker_loc || user.dir != initial_attacker_dir)
			break
		if(user.incapacitated())
			break
		sleep(1)
	*/

	performing_special_attack = FALSE
	for(var/atom/movable/marker in markers)
		if(!QDELETED(marker))
			qdel(marker)
	return TRUE


/// Callback for when a special attack actually happens.
/obj/item/proc/finish_special_attack(list/markers, mob/user, decl/weapon_attack/pending_attack)
	performing_special_attack = FALSE
	var/hit_something
	for(var/atom/movable/marker in markers)
		if(!QDELETED(marker))
			hit_something = get_turf(marker)
			var/obj/effect/temporary_effect/strike_marker/strike = new(get_turf(marker))
			strike.do_strike(pending_attack, user, src)
			qdel(marker)
	if(hit_something)
		user.do_attack_animation(hit_something, src)
