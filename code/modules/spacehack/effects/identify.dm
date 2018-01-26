/datum/intrinsic/active/identify
	name = "identification"
	desc = "Allows you to discern the properties and characteristics of a specific unidentified object."
	short_desc = "It can identify unknown items."
	icon_state = "identify"
	holder_name = "analyzer"
	max_charges = 8
	min_charges = 4
	blessed_prob = 5

/datum/intrinsic/active/identify/one_use
	charges = 1
	max_charges = 1
	rechargable = FALSE
	delete_on_depletion = TRUE
/*
/datum/intrinsic/active/identify/can_waste_check(obj/item/I)
	return istype(I) && src.is_identified(IDENTITY_FULL) && I.is_identified(IDENTITY_FULL)

/datum/intrinsic/active/identify/waste_check(obj/item/I, mob/user)
	to_chat(user, "<span class='warning'>You already know what \the [I] does, using \the [holder] would waste it.</span>")
	return FALSE // can_waste_check() passing already tells us we're doing something wrong since this is the most basic of checks.
*/
/datum/intrinsic/active/identify/do_effect_item(obj/item/I, mob/user)
	if(!istype(I))
		return

	if(I.identity) // Using it on a potentially unidentified item.
		to_chat(user, "<span class='notice'>\The [holder] allowed you to discern the true function of \the [I].</span>")
		if(I.is_identified(IDENTITY_FULL)) // We accidentally wasted it.
			to_chat(user, "<span class='warning'>Unfortunately, you already knew that.</span>")
		I.identify(user, IDENTITY_FULL)

		src.identify(user, IDENTITY_PROPERTIES) // Identifying something also identifies the holder.

	else // Using it on a regular item.
		if(is_identified(IDENTITY_PROPERTIES))
			to_chat(user, "<span class='warning'>\The [I] appears rather mundane...</span>")
		else // User doesn't know the effect was identification, and so it doesn't identify the holder.
			to_chat(user, "<span class='warning'>[MESSAGE_NOTHING]</span>")
	return TRUE