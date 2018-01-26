// Essentially an uncurse scroll.

/datum/intrinsic/active/repair
	name = "repair"
	desc = "Allows you to repair a faulty, damaged, or otherwise unsafe machine, making it hopefully safer. It can also heal synthetic entities."
	short_desc = "It can remove the 'faulty' quality from an item. Also heals synthetics."
	icon_state = "repair"
	holder_name = "auto-repair kit"
	max_charges = 3
	min_charges = 1
	blessed_prob = 5
	cursed_prob = 30

/datum/intrinsic/active/repair/one_use
	charges = 1
	max_charges = 1
	rechargable = FALSE
	delete_on_depletion = TRUE

// Synth repair not implemented yet.
/*
/datum/intrinsic/active/repair/can_waste_check(obj/item/I)
	return istype(I) && src.is_identified(IDENTITY_PROPERTIES) && I.is_identified(IDENTITY_PROPERTIES)

/datum/intrinsic/active/repair/waste_check(obj/item/I, mob/user)
	if(istype(I, /obj/item/unidentified))
		var/obj/item/unidentified/target = I
		switch(quality)
			if(ITEM_BLESSED, ITEM_UNCURSED)
				if(target.effect.quality != ITEM_CURSED)
					to_chat(user, "<span class='warning'>\The [target] isn't broken.</span>")
					return FALSE
			if(ITEM_CURSED)
				if(target.effect.quality == ITEM_CURSED)
					to_chat(user, "<span class='warning'>\The [target] is already broken.</span>")
					return FALSE
	return TRUE
*/
/datum/intrinsic/active/repair/do_effect_item(obj/item/I, mob/user)
	if(istype(I) && I.intrinsic)
		var/datum/intrinsic/A = I.intrinsic

		var/old_quality = A.quality
		switch(quality)
			if(ITEM_BLESSED, ITEM_UNCURSED) // Repairs it.
				A.adjust_quality(ITEM_UNCURSED)
			if(ITEM_CURSED) // Breaks it.
				A.adjust_quality(ITEM_CURSED)


		if(I.is_identified(IDENTITY_BUC)) // Does the user know its quality?
			if(A.quality == old_quality) // Nothing really changed.
				to_chat(user, "<span class='warning'>[MESSAGE_UNKNOWN]</span>")
			else
				if(A.quality == ITEM_CURSED) // It broke it!
					to_chat(user, "<span class='warning'>\The [holder] appears to have broken \the [I].</span>")
				else // It fixed it.
					to_chat(user, "<span class='notice'>\The [I] appears to have been repaired by \the [holder].</span>")
				src.identify(user, IDENTITY_FULL) // User now knows this things fixes or breaks things.


	else // Regular item.
		if(src.is_identified(IDENTITY_PROPERTIES))
			to_chat(user, "<span class='warning'>\The [holder] seems to not be compatible with \the [I]. You decide against using it further.</span>")
			return FALSE
		else
			to_chat(user, "<span class='warning'>[MESSAGE_NOTHING]</span>")

	return TRUE