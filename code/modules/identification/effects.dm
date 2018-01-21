// Datum that tells a holder object to do special things.

/* Base type */
/datum/item_effect
	var/obj/item/holder = null
	var/name = "an effect"			// Name of the actual effect.
	var/desc = "Does a thing."		// Short summary of what it does.
	var/icon_state = null			// Icon to use inside icons/obj/spacehack_indicators.dmi for the small symbol on the bottom right that is visible when held and identified.
	var/short_desc = "Does thing."	// Shorter summary of what it does, in one line.
	var/holder_name = "thingy"		// What the holder possessing this effect should be called when identified.

	var/quality = ITEM_NORMAL		// Some items go above and beyond. Some others make you regret using it in the first place.
	var/blessed_prefix = "todo"		// The prefix for "blessed" objects, which are generally better than regular objects of the same type.
	var/cursed_prefix = "faulty"	// Ditto, but for "cursed" objects that generally are deterimental to use and make blindly using objects dangerous.

	var/cursed_prob = 0				// Likelyhood of the quality being set to ITEM_CURSED when initialized.
	var/blessed_prob = 0			// Ditto but for ITEM_BLESSED. Otherwise it is ITEM_NORMAL.
									// Note both of these are independant probabilities, so 50% bless/50% curse does two rolls for 50% odds.

/* Regular procs */
/datum/item_effect/New(new_holder)
	ASSERT(new_holder)

	// Set things up.
	holder = new_holder

	// Now to curse/bless ourselves.
	if(prob(cursed_prob))
		quality = ITEM_CURSED
	else if(prob(blessed_prob))
		quality = ITEM_BLESSED

/datum/item_effect/Destroy()
	holder = null
	return ..()

/datum/item_effect/proc/identify(mob/user) // Shortcut for identifying the item if it becomes obvious what it does to the user (e.g. lightning comes out).
	holder.identify(user)

/datum/item_effect/proc/is_identified() // Shortcut for holder.is_identified()
	return holder.is_identified()

/datum/item_effect/proc/describe(mob/user)
	if(is_identified() || isobserver(user)) // Ghosts can see if someone is about to explode themselves with something on the floor.
		to_chat(user, "\The [holder] has the function of <b>[name]</b>.")
		to_chat(user, desc)


