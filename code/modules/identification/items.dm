#define SPACEHACK_DEVICE_ICON_RANGE		9 // How many distinct 'device' sprites are in spacehack.dmi. If you add new sprites, change this number to match.
#define SPACEHACK_WAND_ICON_RANGE		2 // Ditto, for 'wand' sprites.

/obj/item/unidentified
	name = "strange technology"
	icon = 'icons/obj/spacehack.dmi'
	icon_state = "device1"
	identity_type = /datum/identification/mechanical
	init_hide_identity = TRUE

	var/datum/item_effect/active/effect = null
	var/effect_type = null
	var/base_state = null // The 'base' icon_state, because initial() won't work as it is not set at compile time.

/obj/item/unidentified/initialize()
	if(!effect_type) // Not hardcoded.
		effect_type = get_random_effect_type()
	effect = new effect_type(src)
	name = effect.holder_name
	base_state = "device[rand(1, SPACEHACK_DEVICE_ICON_RANGE)]"
	update_icon() // Incase we start empty for some reason.
	..()

/obj/item/unidentified/Destroy()
	qdel_null(effect)
	return ..()

/obj/item/unidentified/update_icon()
	if(effect)
		// Kill overlays incase this was dropped.
		overlays.Cut()

		// Handle charges.
		if(effect.use_charges)
			if(effect.charges > 0)
				icon_state = base_state
			else
				icon_state = "[base_state]_inert"

		// Now for the helper icon to make it obvious what this is.
		// But only if identified.
		if(!isturf(loc))
			var/state = is_identified() ? effect.icon_state : "unidentified"
			ASSERT(state)
			var/image/symbol = image('icons/obj/spacehack_indicators.dmi', src, state)
			symbol.pixel_x += 16
			overlays += symbol


/obj/item/unidentified/pickup(mob/user)
	..()
	update_icon()

/obj/item/unidentified/dropped(mob/user)
	..()
	update_icon()

/obj/item/unidentified/attack_hand()
	..()
	update_icon()

/obj/item/unidentified/examine(mob/user)
	..()
	effect.describe(user)

/* Interaction */
/obj/item/unidentified/attack_self(mob/user)
	effect.use_inhand(user)

/obj/item/unidentified/resolve_attackby(obj/item/I, mob/user)
	if(!istype(I))
		return ..()
	if(!istype(I, /obj/item/weapon/storage)) // Let's not accidentially melt our backpack.
		effect.handle_item(I, user)
	return ..()
/*
/obj/item/unidentified/afterattack(mob/living/L, mob/user, proximity_flag, click_parameters)
	if(!istype(L))
		return ..()
	effect.use_on_mob(user, L)


*/

/obj/item/unidentified/identify
	effect_type = /datum/item_effect/active/identify

/obj/item/unidentified/repair
	effect_type = /datum/item_effect/active/repair

/obj/item/unidentified/proc/get_random_effect_type()
	return pick(subtypesof(/datum/item_effect/active))
//	return // This will cause a runtime if this isn't overrided, which is intentional.