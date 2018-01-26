/datum/intrinsic/active/charging
	name = "charging"
	desc = "Allows you to restore charges to other strange devices you may have found."
	short_desc = "It can recharge strange devices."
	icon_state = "charging"
	holder_name = "recharger"
	max_charges = 3
	min_charges = 1
	rechargable = FALSE // To avoid infinite recharging.

/datum/intrinsic/active/charging/one_use
	charges = 1
	max_charges = 1
	delete_on_depletion = TRUE
/*
/datum/intrinsic/active/charging/can_waste_check(obj/item/I)
	return istype(I) && src.is_identified(IDENTITY_PROPERTIES) && I.is_identified(IDENTITY_PROPERTIES)

// Note that the user is not told of the maximum charge potential, so testing for it here would be cheating, even if it would be a waste.
/datum/intrinsic/active/charging/waste_check(obj/item/I, mob/user)
	if(istype(I, /obj/item/unidentified))
		var/obj/item/unidentified/target = I
		if(!target.effect.use_charges)
			to_chat(user, "<span class='warning'>\The [target] is incompatible with \the [holder].</span>")
			return FALSE
		if(!target.effect.rechargable)
			to_chat(user, "<span class='warning'>\The [target] is not rechargable.</span>")
			return FALSE
	return TRUE
*/
/datum/intrinsic/active/charging/do_effect_item(obj/item/I, mob/user)
	if(istype(I) && I.intrinsic && istype(I.intrinsic, /datum/intrinsic/active))
		var/datum/intrinsic/active/A = I.intrinsic

		if(!A.use_charges || !A.rechargable) // Cannot recharge.
			to_chat(user, "<span class='warning'>[MESSAGE_NOTHING]</span>")
			return TRUE

		var/changed_charges = A.charges != A.max_charges
		var/amount_to_give = 0
		switch(quality)
			if(ITEM_BLESSED) // Always give max.
				amount_to_give = A.max_recharge
			if(ITEM_UNCURSED) // Give between min and max.
				amount_to_give = rand(A.max_recharge, A.min_recharge)
			if(ITEM_CURSED) // Take between min and max.
				amount_to_give = -rand(A.max_recharge, A.min_recharge)

		A.adjust_charges(amount_to_give)

		if(I.is_identified(IDENTITY_PROPERTIES) && changed_charges) // If the user can see that it modified the charge of an item, identify the holder.
			if(quality != ITEM_CURSED)
				to_chat(user, "<span class='notice'>\The [I] appears to have been recharged by \the [holder].</span>")
			else
				to_chat(user, "<span class='warning'>\The [I] appears to have been discharged by \the [holder].</span>")
			src.identify(user, IDENTITY_PROPERTIES)

		else // User does not know what it did to the target item.
			to_chat(user, "<span class='notice'>[MESSAGE_UNKNOWN]</span>")

	else // Regular item.
		if(src.is_identified(IDENTITY_PROPERTIES))
			to_chat(user, "<span class='warning'>\The [holder] seems to not be compatible with \the [I]. You decide against using it further.</span>")
			return FALSE
		else
			to_chat(user, "<span class='warning'>[MESSAGE_NOTHING]</span>")

	return TRUE