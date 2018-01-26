/datum/intrinsic/passive/shock_resist
	name = "shock resistance"
	desc = "Reduces or eliminates the amount of electricity reaching the wearer."
	short_desc = "Protects from electric shock."
	icon_state = "shock_resist"
	item_prefix = "insulated"
	blessed_prob = 5
	cursed_prob = 50

/datum/intrinsic/passive/shock_resist/apply_to_holder()
	var/new_siemens
	var/is_gloves = istype(holder, /obj/item/clothing/gloves) // Gloves block all shock.
	switch(quality)
		if(ITEM_BLESSED, ITEM_ARTIFACT)
			new_siemens = is_gloves ? 0.0 : 0.1 // Block 90% of shock.
		if(ITEM_UNCURSED)
			new_siemens = is_gloves ? 0.0 : 0.3 // Block 70% of shock.
		if(ITEM_CURSED)
			new_siemens = 2.0 // Double the shock.
	holder.siemens_coefficient = new_siemens

/obj/item/clothing/suit/unidentified/shock_resist
	intrinsic_type = /datum/intrinsic/passive/shock_resist