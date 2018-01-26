/obj/item/clothing/initialize()
	if(make_intrinsic)
		if(!intrinsic_type) // Not hardcoded.
			intrinsic_type = get_random_intrinsic_type()
		intrinsic = new intrinsic_type(src)
		if(istype(intrinsic, /datum/intrinsic/passive))
			var/datum/intrinsic/passive/P = intrinsic
			P.apply_to_holder()
			name = "[P.item_prefix ? "[P.item_prefix] " : ""][name][P.item_suffix ? " [P.item_suffix]" : ""]"
	..()

// These are ugly.
/obj/item/clothing/pickup(mob/user)
	..()
	update_icon()

/obj/item/clothing/dropped(mob/user)
	..()
	update_icon()

/obj/item/clothing/attack_hand()
	..()
	update_icon()

/obj/item/clothing/examine(mob/user)
	..()
	if(intrinsic)
		intrinsic.describe(user)

/obj/item/clothing/equipped(mob/user, slot)
	..()
	if(intrinsic)
		if(intrinsic.quality == ITEM_CURSED && !user.is_holding_item_of_type(src.type) ) // Implies canremove == 0.
			identify(user, IDENTITY_BUC) // Tell them they just put on a cursed/broken thing. They probably can't remove it now too.

/*
/obj/item/clothing/get_random_intrinsic_type()
	return pick(subtypesof(/datum/intrinsic/passive))
*/

/obj/item/clothing/get_random_intrinsic_type()
	return pick(prob(20);/datum/intrinsic/passive/weight,
				prob(5);/datum/intrinsic/passive/protection,
				prob(5);/datum/intrinsic/passive/fire_resist,
				prob(5);/datum/intrinsic/passive/frost_resist,
				prob(5);/datum/intrinsic/passive/shock_resist)

/obj/item/clothing/suit/unidentified
	name = "chestpiece"
	desc = "A suit that has strange wires and circuitry inside."
	icon_state = "cultrobes" // Placeholder
	identity_type = /datum/identification/mechanical
	init_hide_identity = TRUE
	make_intrinsic = TRUE
