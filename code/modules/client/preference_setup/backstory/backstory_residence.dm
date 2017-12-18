
/************
* Residence *
************/

/datum/category_group/backstory/residence
	name = "Residence"
	desc = "Determines roughly where your character lives."
	effects = "Small effect on available roles."
	category_item_type = /datum/category_item/backstory/residence
	default_value = "Unspecified"

/datum/category_item/backstory/residence/unspecified
	name = "Unspecified"
	effects = "No effect."
	sort_order = 1

/datum/category_item/backstory/residence/northern_star
	name = "NCS Northern Star"
	effects = "Can join as Resident, on the Northern Star map. Adds records and manifest entry if not already included."
	sort_order = 2
