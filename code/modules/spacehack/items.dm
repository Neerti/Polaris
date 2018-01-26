#define SPACEHACK_DEVICE_ICON_RANGE		9 // How many distinct 'device' sprites are in spacehack.dmi. If you add new sprites, change this number to match.
#define SPACEHACK_WAND_ICON_RANGE		2 // Ditto, for 'wand' sprites.

/obj/item
	var/datum/intrinsic/intrinsic = null
	var/intrinsic_type = null
	var/make_intrinsic = FALSE

/obj/item/update_icon()
	if(intrinsic)
		// Now for the helper icon to make it obvious what this is.
		// But only if identified. And if it's actually special.
		overlays.Cut()

		if(!isturf(loc))
			var/state = is_identified(IDENTITY_PROPERTIES) ? intrinsic.icon_state : "unidentified"
			ASSERT(state)

			var/image/symbol = image(icon = 'icons/obj/spacehack_indicators.dmi', loc = src, icon_state = state)
			var/image/symbol_bg = image(icon = 'icons/obj/spacehack_indicators.dmi', loc = src, icon_state = "[state]-bg")
			symbol.pixel_x += 16
			symbol_bg.pixel_x += 16

			if(is_identified(IDENTITY_BUC))
				switch(intrinsic.quality)
					if(ITEM_ARTIFACT)
						symbol_bg.color = "#FF00FF" // Purple.
					if(ITEM_BLESSED)
						symbol_bg.color = "#00FFFF" // Cyan.
					if(ITEM_UNCURSED)
						symbol_bg.color = "#00FF00" // Green.
					if(ITEM_CURSED)
						symbol_bg.color = "#FF0000" // Red.

			overlays += symbol_bg
			overlays += symbol
	..()

/obj/item/proc/get_random_intrinsic_type()
	return // This will cause a runtime if this isn't overrided, which is intentional.

/obj/item/unidentified
	name = "strange technology"
	icon = 'icons/obj/spacehack.dmi'
	icon_state = "device1"
	identity_type = /datum/identification/mechanical
	init_hide_identity = TRUE

	var/base_state = null // The 'base' icon_state, because initial() won't work as it is not set at compile time.

/obj/item/unidentified/initialize()
	if(!intrinsic_type) // Not hardcoded.
		intrinsic_type = get_random_intrinsic_type()
	intrinsic = new intrinsic_type(src)
	name = intrinsic.holder_name
	base_state = "device[rand(1, SPACEHACK_DEVICE_ICON_RANGE)]"
	update_icon() // Incase we start empty for some reason.
	..()

/obj/item/unidentified/Destroy()
	qdel_null(intrinsic)
	return ..()

/obj/item/unidentified/update_icon()
	if(intrinsic)
		// Handle charges.
		if(istype(intrinsic, /datum/intrinsic/active))
			var/datum/intrinsic/active/A = intrinsic
			if(A.use_charges)
				if(A.charges > 0)
					icon_state = base_state
				else
					icon_state = "[base_state]_inert"

	..()


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
	intrinsic.describe(user)

/* Interaction */
/obj/item/unidentified/attack_self(mob/user)
	if(istype(intrinsic, /datum/intrinsic/active))
		var/datum/intrinsic/active/A = intrinsic
		A.use_inhand(user)

/obj/item/unidentified/resolve_attackby(obj/item/I, mob/user)
	if(!istype(I))
		return ..()
	if(!istype(I, /obj/item/weapon/storage)) // Let's not accidentially melt our backpack.
		if(istype(intrinsic, /datum/intrinsic/active))
			var/datum/intrinsic/active/A = intrinsic
			A.handle_item(I, user)
	return ..()
/*
/obj/item/unidentified/afterattack(mob/living/L, mob/user, proximity_flag, click_parameters)
	if(!istype(L))
		return ..()
	intrinsic.use_on_mob(user, L)


*/

/obj/item/unidentified/identify
	intrinsic_type = /datum/intrinsic/active/identify

/obj/item/unidentified/repair
	intrinsic_type = /datum/intrinsic/active/repair

/obj/item/unidentified/get_random_intrinsic_type()
	return pick(subtypesof(/datum/intrinsic/active))