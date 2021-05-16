/mob/living/proc/apply_knockback(amount, atom/source)
	ASSERT(source)
	var/throwdir = get_dir(source, src)

	// Adjust for size.
	var/opposing_size = MOB_MEDIUM // If it's not a mob doing it, assume baseline size.
	if(isliving(source))
		var/mob/living/L = source
		opposing_size = L.mob_size
	amount *= (opposing_size / mob_size) // A tesh getting knockback goes twice as far. Three times as far if from an unathi.

	// Adjust for modifiers.
	for(var/thing in modifiers)
		var/datum/modifier/M = thing
		if(!isnull(M.disable_duration_percent))
			amount *= M.disable_duration_percent
	
	amount = FLOOR(amount, 1)

	if(amount > 0)
		var/turf/T = get_turf(src)
		for(var/i = 1 to amount)
			var/turf/next_step = get_step(T, throwdir)
			if(next_step) // Don't walk off the map.
				T = next_step
		throw_at(T, amount, 1, source)
		// TODO: Have it do extra damage and maybe a stun if they hit a wall or something else that's solid?
		visible_message(SPAN_DANGER("\The [src] was [pick(list("staggered", "knocked back", "thrown backwards"))] by \the [source]!"))
	return amount

// A short term debuff generally applied when recently suffering knockback.
/datum/modifier/staggered
	name = "staggered"
	desc = "You were knocked off balance, and trying to not fall on your face."

	on_created_text = "<span class='danger'>You've been knocked off balance.</span>"
	on_expired_text = "<span class='notice'>You regain your balance.</span>"
	stacks = MODIFIER_STACK_EXTEND

	slowdown = 1
	attack_speed_percent = 1.2
	outgoing_melee_damage_percent = 0.8
	disable_duration_percent = 1.25
	accuracy = -20
	accuracy_dispersion = 1
	evasion = -20