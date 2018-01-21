/datum/item_effect/active/charging
	name = "charging"
	desc = "Allows you to restore charges to other strange devices you may have found."
	short_desc = "It can recharge strange devices."
	icon_state = "charging"
	holder_name = "recharger"
	max_charges = 3
	min_charges = 1
	rechargable = FALSE // To avoid infinite recharging.

/datum/item_effect/active/charging/one_use
	charges = 1
	max_charges = 1
	delete_on_depletion = TRUE

/datum/item_effect/active/charging/can_waste_check(obj/item/I)
	return istype(I) && src.is_identified() && I.is_identified()

// Note that the user is not told of the maximum charge potential, so testing for it here would be cheating, even if it would be a waste.
/datum/item_effect/active/charging/waste_check(obj/item/I, mob/user)
	if(istype(I, /obj/item/unidentified))
		var/obj/item/unidentified/target = I
		if(!target.effect.use_charges)
			to_chat(user, "<span class='warning'>\The [target] is incompatible with \the [holder].</span>")
			return FALSE
		if(!target.effect.rechargable)
			to_chat(user, "<span class='warning'>\The [target] is not rechargable.</span>")
			return FALSE
	return TRUE

/datum/item_effect/active/charging/do_effect_item(obj/item/I, mob/user)
	if(istype(I, /obj/item/unidentified))
		var/obj/item/unidentified/target = I

		if(!target.effect.use_charges || !target.effect.rechargable) // Cannot recharge.
			to_chat(user, "<span class='warning'>[MESSAGE_NOTHING]</span>")
			return TRUE

		var/changed_charges = target.effect.charges != target.effect.max_charges
		var/amount_to_give = 0
		switch(quality)
			if(ITEM_BLESSED) // Always give max.
				amount_to_give = target.effect.max_recharge
			if(ITEM_NORMAL) // Give between min and max.
				amount_to_give = rand(target.effect.max_recharge, target.effect.min_recharge)
			if(ITEM_CURSED) // Take between min and max.
				amount_to_give = -rand(target.effect.max_recharge, target.effect.min_recharge)

		target.effect.adjust_charges(amount_to_give)

		if(target.is_identified() && changed_charges) // If the user can see that it modified the charge of an item, identify the holder.
			if(quality != ITEM_CURSED)
				to_chat(user, "<span class='notice'>\The [target] appears to have been recharged by \the [holder].</span>")
			else
				to_chat(user, "<span class='warning'>\The [target] appears to have been discharged by \the [holder].</span>")
			src.identify(user)

		else // User does not know what it did to the target item.
			to_chat(user, "<span class='notice'>[MESSAGE_UNKNOWN]</span>")

	else // Regular item.
		if(src.is_identified())
			to_chat(user, "<span class='warning'>\The [holder] seems to not be compatible with \the [I]. You decide against using it further.</span>")
			return FALSE
		else
			to_chat(user, "<span class='warning'>[MESSAGE_NOTHING]</span>")

	return TRUE