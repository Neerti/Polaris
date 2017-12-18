var/datum/category_collection/backstory/backstory_collection = new()

/datum/category_collection/backstory
	category_group_type = /datum/category_group/backstory

/datum/category_group/backstory
	var/desc = "Nobody wrote a description for this."
	var/effects = "No in-game effects."
	var/default_value = null

/datum/category_item/backstory
	var/desc = "Nobody wrote a description for this."	// In-character(ish) description of what the option entails.
	var/effects = "No in-game effects."					// Out-of-character statement on what selecting this option will do mechanically.
	var/sort_order = 0									// Determines how the list is sorted when it gets initialized.
	var/important = FALSE								// If true, gets bolded in the selection list.

/datum/category_item/backstory/proc/display()
	var/list/dat = list()
	dat += "<center><h2>[name]</h2><hr>"
	dat += "[desc]"
	dat += "<font color='0000AA'><i>([effects])</i></font>"
	return dat.Join("<br>")

/datum/category_item/backstory/proc/display_name()
	var/result = name
	if(important)
		result = "<font size='5'>[result]</font>"
	return result

datum/category_item/backstory/dd_SortValue()
	return sort_order

// Use this to give or do things to the mob when they spawn in.
/datum/category_item/backstory/proc/post_spawn(var/mob/living/carbon/human/H)
	return

// Use this to restrict an option by certain criteria. It takes the setup datum so you can test for many things,
// from whitelists, to FBPness, to being bald and 30.
// Returns null if there is no issue, otherwise returns a string explaining why they're not allowed to choose this.
/datum/category_item/backstory/proc/test_for_invalidity(var/datum/category_item/player_setup_item/general/background/setup)
	return null
