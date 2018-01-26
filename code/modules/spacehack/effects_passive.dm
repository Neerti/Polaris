// This is used for things that are always on, like wearing clothing.
/datum/intrinsic/passive
	var/item_prefix = null // Words to place before the name of holder, e.g. "insulated vest".
	var/item_suffix = null // Ditto, but after the name, e.g. "goggles of detection".


/datum/intrinsic/passive/proc/apply_to_holder()
	return

/datum/intrinsic/passive/adjust_quality(new_quality)
	..(new_quality)
	apply_to_holder()