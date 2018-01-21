// Essentially an uncurse scroll.

/datum/item_effect/active/repair
	name = "repair"
	desc = "Allows you to repair a faulty, damaged, or otherwise unsafe machine, making it hopefully safer. It can also heal synthetic entities."
	short_desc = "It can remove the 'faulty' quality from an item. Also heals synthetics."
	icon_state = "repair"
	holder_name = "auto-repair kit"
	max_charges = 3
	min_charges = 1
	blessed_prob = 5
	cursed_prob = 30

/datum/item_effect/active/repair/one_use
	charges = 1
	max_charges = 1
	rechargable = FALSE
	delete_on_depletion = TRUE

// Synth repair not implemented yet.

/datum/item_effect/active/repair/can_waste_check(obj/item/I)
	return istype(I) && src.is_identified() && I.is_identified()

/datum/item_effect/active/repair/waste_check(obj/item/I, mob/user)
	if(istype(I, /obj/item/unidentified))
		var/obj/item/unidentified/target = I
		switch(quality)
			if(ITEM_BLESSED, ITEM_NORMAL)
				if(target.effect.quality != ITEM_CURSED)
					to_chat(user, "<span class='warning'>\The [target] isn't broken.</span>")
					return FALSE
			if(ITEM_CURSED)
				if(target.effect.quality == ITEM_CURSED)
					to_chat(user, "<span class='warning'>\The [target] is already broken.</span>")
					return FALSE
	return TRUE

/datum/item_effect/active/repair/do_effect_item(obj/item/I, mob/user)
	if(istype(I, /obj/item/unidentified))
		var/obj/item/unidentified/target = I

		var/old_quality = target.effect.quality
		switch(quality)
			if(ITEM_BLESSED, ITEM_NORMAL) // Repairs it.
				target.effect.quality = ITEM_NORMAL
			if(ITEM_CURSED) // Breaks it.
				target.effect.quality = ITEM_CURSED


		if(target.is_identified()) // Does the user know its quality?
			if(target.effect.quality == old_quality) // Nothing really changed.
				to_chat(user, "<span class='warning'>[MESSAGE_UNKNOWN]</span>")
			else
				if(target.effect.quality == ITEM_CURSED) // It broke it!
					to_chat(user, "<span class='warning'>\The [holder] appears to have broken \the [target].</span>")
				else // It fixed it.
					to_chat(user, "<span class='notice'>\The [target] appears to have been repaired by \the [holder].</span>")
				src.identify(user) // User now knows this things fixes or breaks things.


	else // Regular item.
		if(src.is_identified())
			to_chat(user, "<span class='warning'>\The [holder] seems to not be compatible with \the [I]. You decide against using it further.</span>")
			return FALSE
		else
			to_chat(user, "<span class='warning'>[MESSAGE_NOTHING]</span>")

	return TRUE