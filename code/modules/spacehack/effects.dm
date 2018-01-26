// Datum that tells a holder object to do special things.

/* Base type */
/datum/intrinsic
	var/obj/item/holder = null
	var/name = "an effect"			// Name of the actual effect.
	var/desc = "Does a thing."		// Short summary of what it does.
	var/icon_state = null			// Icon to use inside icons/obj/spacehack_indicators.dmi for the small symbol on the bottom right that is visible when held and identified.
	var/short_desc = "Does thing."	// Shorter summary of what it does, in one line.
	var/holder_name = "thingy"		// What the holder possessing this effect should be called when identified.

	var/quality = ITEM_UNCURSED		// Some items go above and beyond. Some others make you regret using it in the first place.
	var/blessed_prefix = "todo"		// The prefix for "blessed" objects, which are generally better than regular objects of the same type.
	var/cursed_prefix = "faulty"	// Ditto, but for "cursed" objects that generally are deterimental to use and make blindly using objects dangerous.

	var/cursed_prob = 0				// Likelyhood of the quality being set to ITEM_CURSED when initialized.
	var/blessed_prob = 0			// Ditto but for ITEM_BLESSED. Otherwise it is ITEM_UNCURSED.
									// Note both of these are independant probabilities, so 50% bless/50% curse does two rolls for 50% odds.

/* Regular procs */
/datum/intrinsic/New(new_holder)
	ASSERT(new_holder)

	// Set things up.
	holder = new_holder

	// Now to curse/bless ourselves.
	if(prob(cursed_prob))
		adjust_quality(ITEM_CURSED)
	else if(prob(blessed_prob))
		adjust_quality(ITEM_BLESSED)

/datum/intrinsic/Destroy()
	holder = null
	return ..()

/datum/intrinsic/proc/identify(mob/user, new_identity = IDENTITY_FULL) // Shortcut for identifying the item if it becomes obvious what it does to the user (e.g. lightning comes out).
	holder.identify(user, new_identity)

/datum/intrinsic/proc/is_identified(identity_type) // Shortcut for holder.is_identified()
	return holder.is_identified(identity_type)

/datum/intrinsic/proc/describe(mob/user)
	if(is_identified(IDENTITY_PROPERTIES) || isobserver(user)) // Ghosts can see if someone is about to explode themselves with something on the floor.
		to_chat(user, "\The [holder] has the function of <b>[name]</b>.")
		to_chat(user, desc)
	if(is_identified(IDENTITY_BUC) || isobserver(user))
		if(quality != ITEM_UNCURSED)
			var/line
			switch(quality)
				if(ITEM_CURSED)
					line = "<span class='warning'>It appears [cursed_prefix]...</span>"
				if(ITEM_BLESSED)
					line = "<span class='warning'>It appears [blessed_prefix]!</span>"
			to_chat(user, line)

/datum/intrinsic/proc/adjust_quality(new_quality)
	if(quality == ITEM_ARTIFACT)
		return // Artifacts never decay.
	if(new_quality < quality && quality == ITEM_BLESSED && prob(80))
		return // Blessed items resist cursing 4 out of 5 times.

	quality = new_quality
	holder.update_icon()

	if(istype(holder, /obj/item/clothing))
		if(quality == ITEM_CURSED)
			holder.canremove = FALSE
		else
			holder.canremove = TRUE
