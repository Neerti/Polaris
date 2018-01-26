// This is used for things that need to be manually triggered and have an effect.
/datum/intrinsic/active
	var/use_charges = TRUE			// If false, does not use the charges system, cannot be recharged, etc. Generally there is another cost to useful this instead.
	var/charges = 0					// Integer for how many times this effet can be triggered before becoming inert.
	var/max_charges = 0				// Max range for charges this can start with or be recharged up to.
	var/min_charges = 0				// Ditto, but only determines bounds for initial charges.
	var/rechargable = TRUE			// If charges can be brought back by certain means.
	var/max_recharge = 0			// Upper bound for recharging.
	var/min_recharge = 0			// Lower bound for above.
	var/delete_on_depletion = FALSE // If the item should delete itself when out of charges.

// These are used to represent 'scrolls'.
/datum/intrinsic/active/one_use
	charges = 1
	max_charges = 1
	rechargable = FALSE
	delete_on_depletion = TRUE

/datum/intrinsic/active/New(new_holder)
	..(new_holder)

	charges = rand(min_charges, max_charges)

	// If some vars weren't supplied, automatically set them.
	if(use_charges && rechargable)
		if(!max_recharge)
			max_recharge = between(1, max_charges - 2, max_charges) // E.g. something with max_charge of 18 would get 16 max_recharge.
		if(!min_recharge)
			min_recharge = 1

/datum/intrinsic/active/proc/adjust_charges(amount, mob/user, force = FALSE)
	if(amount > 0 && !rechargable && !force)
		return

	charges = between(0, charges + amount, max_charges)
	holder.update_icon() // Holder might have different icons for charges.

	if(charges == 0)
		if(delete_on_depletion) // Lost forever.
			to_chat(user, "<span class='danger'>\The [holder] disintegrates!</span>")
			qdel(holder)

		else if(is_identified(IDENTITY_PROPERTIES)) // Otherwise just a waste of space until recharged.
			to_chat(user, "<span class='warning'>\The [holder] seems to go inert...</span>")

/datum/intrinsic/active/describe(mob/user)
	..(user)
	if(is_identified(IDENTITY_PROPERTIES) || isobserver(user))
		if(use_charges)
			if(charges)
				to_chat(user, "\The [holder] has [charges] more charge\s.")
			else
				to_chat(user, "\The [holder] appears to have been depleted, and is inert.")



/* Interactions */

// Clicking it inhand.
/datum/intrinsic/active/proc/use_inhand(mob/user)
	if(can_use(user))
		do_inhand(user)

/datum/intrinsic/active/proc/do_inhand(mob/user)
	to_chat(user, "<span class='warning'>\The [holder] doesn't seem to do anything when used like that.</span>")

/* Processes */

// Check if the thing is usable.
// Currently this just checks if the thing is charged.
/datum/intrinsic/active/proc/can_use(mob/user, charges_needed = 1)
	if(charges - charges_needed < 0) // This will fail if it has 1 charge left but needs two.
		if(is_identified(IDENTITY_PROPERTIES))
			to_chat(user, "<span class='warning'>\The [holder] seems inert.</span>")
		else // User has no idea if it's empty or they're just doing it wrong.
			to_chat(user, "<span class='warning'>[MESSAGE_NOTHING]</span>")
		return FALSE
	return TRUE


// Used to see if we can attempt to stop someone from accidentially wasting a charge, if the user has enough information available to them.
// E.g. Someone using a known identification object on another object already identified will be prevented from doing so, but would not be stopped if
// the device being used or the target was unknown to the user.
/datum/intrinsic/active/proc/can_waste_check(obj/item/I)
	return FALSE

// Used to check if doing something would be foolish if given complete knowledge. The test for complete knowledge is the proc above.
// Return TRUE to let the effect happen, and FALSE to stop it.
/datum/intrinsic/active/proc/waste_check(atom/A, mob/user)
	return TRUE

// The actual 'do the effect' proc. Return true if charge should be deducted, and false otherwise.
// Override this to actually do things.
/datum/intrinsic/active/proc/do_effect_item(obj/item/I, mob/user)
	to_chat(user, "<span class='warning'>\The [holder] doesn't seem to do anything to \the [I].</span>")
	return FALSE

// Generic handler for applying to other items.
/datum/intrinsic/active/proc/handle_item(obj/item/I, mob/user)
	if(!can_use(user)) // Do nothing if empty.
		return FALSE

	if(can_waste_check(I)) // Check if we can check if this is a waste.
		if(!waste_check(I, user)) // If we can, and it's wasteful, don't do it.
			return FALSE

	// Produce the same style of line, every time.
	to_chat(user, "<span class='notice'>You use \the [holder] on \the [I]...</span>")

	if(do_effect_item(I, user)) // Does the actual effect. Returns true if charge should be deducted.
		adjust_charges(-1)
		return TRUE
	return FALSE