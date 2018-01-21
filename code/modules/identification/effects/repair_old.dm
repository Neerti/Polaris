// Essentially an uncurse scroll.

/datum/item_effect/repair
	name = "repair"
	desc = "Allows you to repair a faulty, damaged, or otherwise unsafe machine, making it hopefully safer. It can also heal synthetic entities."
	short_desc = "It can remove the 'faulty' quality from an item. Also heals synthetics."
	holder_name = "auto-repair kit"
	max_charges = 3
	min_charges = 1

/datum/item_effect/repair/one_use
	charges = 1
	max_charges = 1
	rechargable = FALSE
	delete_on_depletion = TRUE

// Synth repair not implemented yet.

/datum/item_effect/repair/can_waste_check(obj/item/I)
	return istype(I) && src.is_identified() && I.is_identified()

/datum/item_effect/repair/waste_check(mob/user, obj/item/I)
	if(can_waste_check(I))
		if(istype(I, /obj/item/unidentified))
			var/obj/item/unidentified/U = I
			if(U.effect.quality != ITEM_CURSED)
				to_chat(user, "<span class='warning'>\The [I] isn't broken.</span>")
				return FALSE
	return TRUE

/datum/item_effect/repair/proc/repair_item(mob/user, obj/item/I)

	if(istype(I, /obj/item/unidentified))
		var/obj/item/unidentified/U = I

		if(U.identified() && U.effect.quality != ITEM_CURSED)
			to_chat(user, "<span class='warning'>\The [I] isn't broken.</span>")
				return

		to_chat(user, "<span class='notice'>You use \the [holder] on \the [I]...</span>")

		var/was_broken = U.effect.quality == ITEM_CURSED
		var/should_identify = FALSE // Identify the holder, that is.
		if(was_broken)
			U.effect.quality = ITEM_NORMAL // Repair it.

		if(U.is_identified()) // Does the user know its quality?
			if(was_broken)
				to_chat(user, "<span class='notice'>\The [U] appears to have been repaired by \the [holder].</span>")
				should_identify = TRUE
			else
				to_chat(user, "<span class='warning'>Nothing happens.</span>")

		if(should_identify)
			src.identify(user)


	else // Regular item.
		if(src.is_identified())
			to_chat(user, "<span class='warning'>\The [src] seems to not be compatible with \the [I]. You decide against using it.</span>")
			return
		else
			to_chat(user, "<span class='warning'>Nothing happens.</span>")

	adjust_charges(-1)

/datum/item_effect/repair/do_on_item(mob/user, obj/item/I)
	repair_item(user, I)