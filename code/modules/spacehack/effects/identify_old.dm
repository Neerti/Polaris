/datum/item_effect/identify
	name = "identification"
	desc = "Allows you to discern the properties and characteristics of a specific unidentified object."
	short_desc = "It can identify unknown items."
	holder_name = "analyzer"
	max_charges = 8
	min_charges = 4

/datum/item_effect/identify/one_use
	charges = 1
	max_charges = 1
	rechargable = FALSE
	delete_on_depletion = TRUE

/datum/item_effect/identify/can_waste_check(obj/item/I)
	return istype(I) && src.is_identified() && I.is_identified()

/datum/item_effect/identify/waste_check(mob/user, obj/item/I)
	to_chat(user, "<span class='warning'>You already know what \the [I] does, using \the [holder] would waste it.</span>")
	return FALSE // can_waste_check() passing already tells us we're doing something wrong since this is the most basic of checks.

/datum/item_effect/identify/proc/identify_item(mob/user, obj/item/I)
	if(can_waste_check(I))
		if(!waste_check(user, I))
			return

	to_chat(user, "<span class='notice'>You use \the [holder] on \the [I]...</span>")

	if(I.identity) // Using it on a potentially unidentified item.
		to_chat(user, "<span class='notice'>\The [holder] allowed you to discern the true function of \the [I].</span>")
		if(I.is_identified()) // We accidentally wasted it.
			to_chat(user, "<span class='warning'>Unfortunately, you already knew that.</span>")
		else
			I.identify(user)

		src.identify(user) // Identifying something also identifies the holder.

	else // Using it on a regular item.
		if(is_identified())
			to_chat(user, "<span class='warning'>\The [I] appears rather mundane...</span>")
		else // User doesn't know the effect was identification, and so it doesn't identify the holder.
			to_chat(user, "<span class='warning'>Nothing happens.</span>")

	adjust_charges(-1)

/datum/item_effect/identify/do_on_item(mob/user, obj/item/I)
	identify_item(user, I)