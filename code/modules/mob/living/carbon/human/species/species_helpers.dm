var/list/stored_shock_by_ref = list()

/mob/living/proc/apply_stored_shock_to(var/mob/living/target)
	if(stored_shock_by_ref["\ref[src]"])
		target.electrocute_act(stored_shock_by_ref["\ref[src]"]*0.9, src)
		stored_shock_by_ref["\ref[src]"] = 0

// Takes a define such as SPECIES_HUMAN, and outputs 1 or 0 if its the same species.
/datum/species/proc/is_species(compare_to)
	return name_id == compare_to

// Compares two species datums together to see if they are the same.
/datum/species/proc/same_species(datum/species/other)
	return src == other