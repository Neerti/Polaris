/datum/intrinsic/passive/frost_resist
	name = "frost resistance"
	desc = "Protects the wearer from low temperatures, in the areas this covers."
	short_desc = "Protects from cold."
	icon_state = "frost_resist"
	item_prefix = "winterized"
	blessed_prob = 5
	cursed_prob = 50

/datum/intrinsic/passive/frost_resist/apply_to_holder()
	switch(quality)
		if(ITEM_BLESSED, ITEM_ARTIFACT)
			holder.min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE // As good as winter coat. Should change this someday if they get reworked.
		if(ITEM_UNCURSED)
			holder.min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE // Less good.
		if(ITEM_CURSED)
			holder.min_cold_protection_temperature = null // Worthless.

/obj/item/clothing/suit/unidentified/frost_resist
	intrinsic_type = /datum/intrinsic/passive/frost_resist