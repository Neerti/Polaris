/datum/intrinsic/passive/weight
	name = "weight"
	desc = "Increased weight for no benefit, it will slow the wearer down if worn."
	short_desc = "Slows the wearer."
	icon_state = "weight"
	item_prefix = "weighted"
	blessed_prob = 0
	cursed_prob = 90

/datum/intrinsic/passive/weight/apply_to_holder()
	holder.slowdown = initial(holder.slowdown) + 2

/obj/item/clothing/suit/unidentified/weight
	intrinsic_type = /datum/intrinsic/passive/weight