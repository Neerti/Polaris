/datum/intrinsic/passive/protection
	name = "protection"
	desc = "Provides additional armor on top of whatever this may have already had, against blunt force, bullets, and lasers."
	short_desc = "Increased protection against blunt force, bullets, and lasers."
	icon_state = "protection"
	item_prefix = "reinforced"
	blessed_prob = 5
	cursed_prob = 50

/datum/intrinsic/passive/protection/apply_to_holder()
	var/list/initial_armor = initial(holder.armor)
	var/initial_melee = initial_armor["melee"]
	var/initial_bullet = initial_armor["bullet"]
	var/initial_laser = initial_armor["laser"]
	var/new_melee
	var/new_bullet
	var/new_laser

	switch(quality)
		if(ITEM_BLESSED, ITEM_ARTIFACT)
			new_melee = min(initial_melee + 40, 80)
			new_bullet = min(initial_bullet + 20, 80)
			new_laser = min(initial_laser + 20, 80)
		if(ITEM_UNCURSED)
			new_melee = min(initial_melee + 30, 80)
			new_bullet = min(initial_bullet + 15, 80)
			new_laser = min(initial_laser + 15, 80)
		if(ITEM_CURSED)
			new_melee = 0
			new_bullet = 0
			new_laser = 0

	var/list/holder_armor = holder.armor
	holder_armor["melee"] = new_melee
	holder_armor["bullet"] = new_bullet
	holder_armor["laser"] = new_laser

/obj/item/clothing/suit/unidentified/protection
	intrinsic_type = /datum/intrinsic/passive/protection