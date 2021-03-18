/datum/intrinsic/passive/fire_resist
	name = "fire resistance"
	desc = "Protects the wearer from high temperatures and fire, in the areas this covers."
	short_desc = "Protects from fire."
	icon_state = "fire_resist"
	item_prefix = "fireproof"
	blessed_prob = 5
	cursed_prob = 50

/datum/intrinsic/passive/fire_resist/apply_to_holder()
	switch(quality)
		if(ITEM_BLESSED, ITEM_ARTIFACT)
			holder.max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE // As good as a firesuit.
		if(ITEM_UNCURSED)
			holder.max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE / 2 // Half as good.
		if(ITEM_CURSED)
			holder.max_heat_protection_temperature = null // Worthless.

/obj/item/clothing/suit/unidentified/fire_resist
	intrinsic_type = /datum/intrinsic/passive/fire_resist