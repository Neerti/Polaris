/obj/item
	var/datum/identification/identity = null
	var/identity_type = /datum/identification
	var/init_hide_identity = FALSE // Set to true to automatically unidentify the object on initialization.

/obj/item/initialize()
	..()
	if(init_hide_identity)
		identity = new identity_type(src)

/obj/item/Destroy()
	if(identity)
		qdel_null(identity)
	return ..()

/obj/item/proc/hide_identity() // Mostly for admins to make things secret.
	if(!identity)
		identity = new identity_type(src)
	else
		identity.unidentify()

/obj/item/proc/identify(mob/user)
	if(identity)
		identity.identify(user)

/obj/item/proc/is_identified()
	if(!identity) // No identification datum means nothing to hide.
		return TRUE
	return identity.identified

// This is a datum attached to objects to make their 'identity' be unknown initially.
// The identitiy and properties of an unidentified object can be determined in various ways.
// This is very similar to a traditional roguelike's identification system, and as such will use certain terms from those to describe them.

/datum/identification
	var/obj/holder = null									// The thing the datum is 'attached' to.
	var/true_name = null									// The real name of the object. Is copied automatically from holder, on the datum being instantiated.
	var/true_desc = null									// Ditto, for desc.
	var/true_description_info = null						// Ditto, for helpful examine panel entries.
	var/true_description_fluff = null						// Ditto, for lore.
	var/true_description_antag = null						// Ditto, for antag info (this probably won't get used).
	var/unidentified_name = null							// The name given to the object when not identified.

	var/identified = FALSE									// If it's been 'formally' identified.

/datum/identification/New(new_holder)
	holder = new_holder
	if(!holder)
		message_admins("ERROR: Identification datum was not given a holder!")
	record_true_identity() // Get all the identifying features from the holder.
	if(!identified)
		update_name() // Then hide them for awhile.

/datum/identification/Destroy()
	holder = null
	return ..()

// Formally identifies the holder.
/datum/identification/proc/identify(mob/user)
	if(identified == TRUE) // Already done.
		return

	identified = TRUE
	if(user)
		to_chat(user, "<span class='notice'>You've identified \the [holder] as a [true_name].</span>")
	update_name()
	holder.update_icon()

// Reverses identification for whatever reason.
/datum/identification/proc/unidentify(mob/user)
	identified = FALSE
	update_name()
	holder.update_icon()
	if(user)
		to_chat(user, "<span class='warning'>You forgot what \the [holder] did...</span>")

// Records the object's inital identifiying features to the datum for future safekeeping.
/datum/identification/proc/record_true_identity()
	true_name = holder.name
	true_desc = holder.desc
	true_description_info = holder.description_info
	true_description_fluff = holder.description_fluff
	true_description_antag = holder.description_antag

/datum/identification/proc/update_name()
	if(identified)
		holder.name = true_name
		holder.desc = true_desc
		holder.description_info = true_description_info
		holder.description_fluff = true_description_fluff
		holder.description_antag = true_description_antag
		return

	if(!unidentified_name)
		unidentified_name = generate_unidentified_name()

	holder.name = unidentified_name
	holder.desc = "You're not too sure what this is."
	holder.description_info = "This object is unidentified, and as such its properties are unknown. Using this object may be dangerous."
	holder.description_fluff = null
	holder.description_antag = null

/datum/identification/proc/generate_unidentified_name()
	return "unidentified object"

/datum/identification/mechanical/generate_unidentified_name()
	var/list/first_word = list(
		"unidentified",
		"unknown",
		"strange",
		"weird",
		"unfamiliar",
		"peculiar",
		"mysterious",
		"bizarre",
		"odd"
	)
	var/list/second_word = list(
		"device",
		"apparatus",
		"gadget",
		"mechanism",
		"appliance",
		"machine",
		"equipment",
		"invention",
		"contraption"
	)
	return "[pick(first_word)] [pick(second_word)]"
