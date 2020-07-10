// Extremely deadly melee fighter that has several special abilities to shread people apart up close.
/mob/living/simple_mob/mechanical/tech_horror/shredder
	maxHealth = 200
	health = 200

	icon_state = "abductor"
	icon_living = "abductor"
	icon_dead = "abductor_dead"

	movement_cooldown = 3
	hovering = TRUE // Won't trigger landmines.
	pass_flags = PASSTABLE
	mob_swap_flags = 0
	mob_push_flags = 0

	melee_attack_delay = 0.2 SECONDS
	melee_damage_lower = 15
	melee_damage_upper = 15
	base_attack_cooldown = 1.5 SECONDS
	attack_sharp = TRUE
	attack_edge = TRUE
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attacktext = list("slashed", "impaled", "gored", "ripped", "shredded")

	special_attack_min_range = 1
	special_attack_max_range = 1
	special_attack_cooldown = 0

	ai_holder_type = /datum/ai_holder/simple_mob/intentional/shredder

	var/overclock_time = 0 // world.time of last Overclock.
	var/overclock_cooldown = 20 SECONDS
	var/overclock_duration = 10 SECONDS
	var/overclock_attack_cap = 6 // How many rapid attacks can occur before the effect ends.
	var/overclock_hits_left = 0 // How many attacks until the rapid attack effect ends.
	var/overclock_self_damage = 5

	var/bonus_damage_per_attack = 5 // Each attack on a specific target does more and more damage, for awhile.


/mob/living/simple_mob/mechanical/tech_horror/shredder/can_special_attack(atom/A)
	if(..())
		return can_overclock()

/mob/living/simple_mob/mechanical/tech_horror/shredder/do_special_attack(atom/A)
	. = FALSE
	switch(a_intent)
		if(I_DISARM)
			return // TODO
		if(I_HURT)
			if(can_overclock())
				overclock()
				return TRUE
		if(I_GRAB)
			return // TODO


/mob/living/simple_mob/mechanical/tech_horror/shredder/apply_melee_effects(atom/A)
	if(overclock_hits_left)
		overclock_hits_left--
		inflict_heat_damage(overclock_self_damage)
		if(overclock_hits_left <= 0)
			end_overclock()
	if(isliving(A))
		var/mob/living/L = A
		L.add_modifier(/datum/modifier/shredder_attacked, 20 SECONDS, src)

/mob/living/simple_mob/mechanical/tech_horror/shredder/apply_bonus_melee_damage(atom/A, damage_amount)
	if(isliving(A))
		var/mob/living/L = A
		var/stacks = L.count_modifiers_of_type(/datum/modifier/shredder_attacked)
		return damage_amount + (bonus_damage_per_attack * stacks)
	return ..()


/mob/living/simple_mob/mechanical/tech_horror/shredder/proc/can_overclock()
	return overclock_time + overclock_cooldown < world.time

// Overclock gives the mob massive attack speed for a certain number of attacks.
// Each attack attempt hurts the technological horror, regardless if the attack succeeded.
// That generally isn't too big of a deal due to the passive Nanite Bloodstream.
/mob/living/simple_mob/mechanical/tech_horror/shredder/proc/overclock()
	overclock_hits_left = overclock_attack_cap
	overclock_time = world.time
	add_modifier(/datum/modifier/tech_horror_overclock, overclock_duration)

// Used to end Overclock after attacking a specific number of times.
/mob/living/simple_mob/mechanical/tech_horror/shredder/proc/end_overclock()
	remove_modifiers_of_type(/datum/modifier/tech_horror_overclock)
	overclock_hits_left = 0

// This probably shouldn't go on anything else because it would be extremely overpowered.
/datum/modifier/tech_horror_overclock
	name = "overclock"
	desc = "You are able to attack extremely fast a limited number of times. Each attack attempt will also hurt you slightly."
	client_color = "#FF5555" // Make everything red!
	mob_overlay_state = "berserk"

	on_created_text = "<span class='danger'>A surge of energy flows through your body, pushing both synthetic and organic parts to peak performance!</span>"
	on_expired_text = "<span class='notice'>The spike of energy has ceased, and your agility returns to baseline levels.</span>"

	icon_scale_x_percent = 1.2 // Look scarier.
	icon_scale_y_percent = 1.2
	attack_speed_percent = 0.2


// Acts as a counter for how many times someone was attacked.
// Each stack adds some more damage when attacked by the technological horror.
/datum/modifier/shredder_attacked
	name = "shredded"
	desc = "The monster fighting you dugs deeper into you with every attack, causing more damage."
	stacks = MODIFIER_STACK_ALLOWED



/datum/ai_holder/simple_mob/intentional/shredder
	var/mob/living/simple_mob/mechanical/tech_horror/shredder/shredder = null

/datum/ai_holder/simple_mob/intentional/shredder/New()
	..()
	ASSERT(istype(holder, /mob/living/simple_mob/mechanical/tech_horror/shredder))
	shredder = holder

// Changes the mob's intent, choosing a specific special attack to use.
/datum/ai_holder/simple_mob/intentional/shredder/pre_special_attack(atom/A)
	var/distance = get_dist(holder, A)
	if(distance <= 1 && shredder.can_overclock())
		holder.a_intent = I_HURT