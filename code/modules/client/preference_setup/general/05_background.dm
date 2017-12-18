/datum/category_item/player_setup_item/general/background
	name = "Background"
	sort_order = 5

/datum/category_item/player_setup_item/general/background/load_character(var/savefile/S)
	S["med_record"]				>> pref.med_record
	S["sec_record"]				>> pref.sec_record
	S["gen_record"]				>> pref.gen_record
	S["citizenship"]			>> pref.citizenship
	S["residence"]				>> pref.residence
	S["party_affiliation"]		>> pref.party_affiliation
	S["employer"]				>> pref.employer
	S["religion"]				>> pref.religion

/datum/category_item/player_setup_item/general/background/save_character(var/savefile/S)
	S["med_record"]				<< pref.med_record
	S["sec_record"]				<< pref.sec_record
	S["gen_record"]				<< pref.gen_record
	S["citizenship"]			<< pref.citizenship
	S["residence"]				<< pref.residence
	S["party_affiliation"]		<< pref.party_affiliation
	S["employer"]				<< pref.employer
	S["religion"]				<< pref.religion

/datum/category_item/player_setup_item/general/background/sanitize_character()
	if(!pref.religion)    pref.religion =    "None"

	var/mob/preference_mob = preference_mob()

	var/datum/category_group/backstory/group = backstory_collection.categories_by_name["Residence"]
	var/datum/category_item/backstory/item = group.items_by_name[pref.residence]
	if(!item || item.test_for_invalidity(src))
		pref.residence = group.default_value
		to_chat(preference_mob, "<span class='warning'>Your character's Residence was reset due to becoming invalid or nonexistant.</span>")

	group = backstory_collection.categories_by_name["Employer"]
	item = group.items_by_name[pref.employer]
	if(!item || item.test_for_invalidity(src))
		pref.residence = group.default_value
		to_chat(preference_mob, "<span class='warning'>Your character's Employer was reset due to becoming invalid or nonexistant.</span>")

	group = backstory_collection.categories_by_name["Citizenship"]
	item = group.items_by_name[pref.citizenship]
	if(!item || item.test_for_invalidity(src))
		pref.residence = group.default_value
		to_chat(preference_mob, "<span class='warning'>Your character's Citizenship was reset due to becoming invalid or nonexistant.</span>")

	group = backstory_collection.categories_by_name["Party Affiliation"]
	item = group.items_by_name[pref.party_affiliation]
	if(!item || item.test_for_invalidity(src))
		pref.residence = group.default_value
		to_chat(preference_mob, "<span class='warning'>Your character's Party Affiliation was reset due to becoming invalid or nonexistant.</span>")

// Moved from /datum/preferences/proc/copy_to()
/datum/category_item/player_setup_item/general/background/copy_to_mob(var/mob/living/carbon/human/character)
	character.med_record		= pref.med_record
	character.sec_record		= pref.sec_record
	character.gen_record		= pref.gen_record
	character.citizenship		= pref.citizenship
	character.residence			= pref.residence
	character.party_affiliation	= pref.party_affiliation
	character.employer			= pref.employer
	character.religion			= pref.religion

/datum/category_item/player_setup_item/general/background/content(var/mob/user)
	. += "<b>Background Information</b><br>"
	. += "Employer: <a href='?src=\ref[src];show_backstory_group=\ref[backstory_collection.categories_by_name["Employer"]]'>[pref.employer]</a><br/>"
	. += "Citizenship: <a href='?src=\ref[src];show_backstory_group=\ref[backstory_collection.categories_by_name["Citizenship"]]'>[pref.citizenship]</a><br/>"
	. += "Residence: <a href='?src=\ref[src];show_backstory_group=\ref[backstory_collection.categories_by_name["Residence"]]'>[pref.residence]</a><br/>"
	. += "Party Affiliation: <a href='?src=\ref[src];show_backstory_group=\ref[backstory_collection.categories_by_name["Party Affiliation"]]'>[pref.party_affiliation]</a><br/>"

	. += "<br/><b>Records</b>:<br/>"
	if(jobban_isbanned(user, "Records"))
		. += "<span class='danger'>You are banned from using character records.</span><br>"
	else
		. += "Medical Records:<br>"
		. += "<a href='?src=\ref[src];set_medical_records=1'>[TextPreview(pref.med_record,40)]</a><br><br>"
		. += "Employment Records:<br>"
		. += "<a href='?src=\ref[src];set_general_records=1'>[TextPreview(pref.gen_record,40)]</a><br><br>"
		. += "Security Records:<br>"
		. += "<a href='?src=\ref[src];set_security_records=1'>[TextPreview(pref.sec_record,40)]</a><br>"

/datum/category_item/player_setup_item/general/background/OnTopic(var/href,var/list/href_list, var/mob/user)
	if(href_list["show_backstory_group"])
		if(!CanUseTopic(user))
			return TOPIC_NOACTION
		var/datum/category_group/backstory/group = locate(href_list["show_backstory_group"])
		display_backstory_group(user, group)
		return TOPIC_NOACTION

	else if(href_list["show_backstory_item"])
		if(!CanUseTopic(user))
			return TOPIC_NOACTION
		var/datum/category_item/backstory/item = locate(href_list["show_backstory_item"])
		display_backstory_item(user, item)
		return TOPIC_NOACTION

	else if(href_list["select_backstory_item"])
		var/datum/category_item/backstory/item = locate(href_list["select_backstory_item"])
		var/datum/category_group/backstory/group = item.category
		var/invalidity = item.test_for_invalidity(src)
		if(invalidity)
			to_chat(user, "<span class='danger'>Cannot select '[item.name]'. Reason: [invalidity]</span>")
			return TOPIC_NOACTION

		if(item && group)
			switch(group.name)
				if("Employer")
					pref.employer = item.name
				if("Citizenship")
					pref.citizenship = item.name
				if("Residence")
					pref.residence = item.name
				if("Party Affiliation")
					pref.party_affiliation = item.name
				if("Religion")
					pref.religion = item.name
			user << browse(null, "window=backstory_group;size=700x400")
			return TOPIC_REFRESH
		return TOPIC_NOACTION

	else if(href_list["set_medical_records"])
		var/new_medical = sanitize(input(user,"Enter medical information here.","Character Preference", html_decode(pref.med_record)) as message|null, MAX_RECORD_LENGTH, extra = 0)
		if(!isnull(new_medical) && !jobban_isbanned(user, "Records") && CanUseTopic(user))
			pref.med_record = new_medical
		return TOPIC_REFRESH

	else if(href_list["set_general_records"])
		var/new_general = sanitize(input(user,"Enter employment information here.","Character Preference", html_decode(pref.gen_record)) as message|null, MAX_RECORD_LENGTH, extra = 0)
		if(!isnull(new_general) && !jobban_isbanned(user, "Records") && CanUseTopic(user))
			pref.gen_record = new_general
		return TOPIC_REFRESH

	else if(href_list["set_security_records"])
		var/sec_medical = sanitize(input(user,"Enter security information here.","Character Preference", html_decode(pref.sec_record)) as message|null, MAX_RECORD_LENGTH, extra = 0)
		if(!isnull(sec_medical) && !jobban_isbanned(user, "Records") && CanUseTopic(user))
			pref.sec_record = sec_medical
		return TOPIC_REFRESH

	return ..()

/datum/category_item/player_setup_item/general/background/proc/display_backstory_group(mob/user, var/datum/category_group/backstory/group)
	var/list/dat = list()
	dat += "<head><title>[group.name]</title></head>"
	dat += "<body>"
	dat += "<center><h2>[group.name]</h2><br>"
	dat += "[group.desc]<br>"
	dat += "<font color='0000AA'>([group.effects])</font><br>"
	dat += "<hr>"

	for(var/datum/category_item/backstory/item in group.items)
		dat += "<a href='?src=\ref[src];show_backstory_item=\ref[item]'>[item.display_name()]</a><br>"

	dat += "</center>"
	dat += "</body>"
	user << browse(dat.Join(), "window=backstory_group;size=700x400")

/datum/category_item/player_setup_item/general/background/proc/display_backstory_item(mob/user, var/datum/category_item/backstory/item)
	var/list/dat = list()
	dat += "<head><title>[item.category.name]</title></head>"
	dat += "<body>"
	dat += "[item.display()]<br>"
	dat += "<h2>\[<a href='?src=\ref[src];show_backstory_group=\ref[item.category]'>Back</a>\] \
	\[<a href='?src=\ref[src];select_backstory_item=\ref[item]'>Select</a>\]</h2>"
	dat += "</center>"
	dat += "</body>"
	user << browse(dat.Join(), "window=backstory_group;size=700x400")

/*
/datum/category_item/player_setup_item/general/body/proc/SetSpecies(mob/user)
	if(!pref.species_preview || !(pref.species_preview in all_species))
		pref.species_preview = "Human"
	var/datum/species/current_species = all_species[pref.species_preview]
	var/dat = "<body>"
	dat += "<center><h2>[current_species.name] \[<a href='?src=\ref[src];show_species=1'>change</a>\]</h2></center><hr/>"
	dat += "<table padding='8px'>"
	dat += "<tr>"
	dat += "<td width = 400>[current_species.blurb]</td>"
	dat += "<td width = 200 align='center'>"
	if("preview" in icon_states(current_species.icobase))
		usr << browse_rsc(icon(current_species.icobase,"preview"), "species_preview_[current_species.name].png")
		dat += "<img src='species_preview_[current_species.name].png' width='64px' height='64px'><br/><br/>"
	dat += "<b>Language:</b> [current_species.species_language]<br/>"
	dat += "<small>"
	if(current_species.spawn_flags & SPECIES_CAN_JOIN)
		dat += "</br><b>Often present on human stations.</b>"
	if(current_species.spawn_flags & SPECIES_IS_WHITELISTED)
		dat += "</br><b>Whitelist restricted.</b>"
	if(!current_species.has_organ[O_HEART])
		dat += "</br><b>Does not have a circulatory system.</b>"
	if(!current_species.has_organ[O_LUNGS])
		dat += "</br><b>Does not have a respiratory system.</b>"
	if(current_species.flags & NO_SCAN)
		dat += "</br><b>Does not have DNA.</b>"
	if(current_species.flags & NO_PAIN)
		dat += "</br><b>Does not feel pain.</b>"
	if(current_species.flags & NO_SLIP)
		dat += "</br><b>Has excellent traction.</b>"
	if(current_species.flags & NO_POISON)
		dat += "</br><b>Immune to most poisons.</b>"
	if(current_species.appearance_flags & HAS_SKIN_TONE)
		dat += "</br><b>Has a variety of skin tones.</b>"
	if(current_species.appearance_flags & HAS_SKIN_COLOR)
		dat += "</br><b>Has a variety of skin colours.</b>"
	if(current_species.appearance_flags & HAS_EYE_COLOR)
		dat += "</br><b>Has a variety of eye colours.</b>"
	if(current_species.flags & IS_PLANT)
		dat += "</br><b>Has a plantlike physiology.</b>"
	dat += "</small></td>"
	dat += "</tr>"
	dat += "</table><center><hr/>"

	var/restricted = 0

	if(!(current_species.spawn_flags & SPECIES_CAN_JOIN))
		restricted = 2
	else if(!is_alien_whitelisted(preference_mob(),current_species))
		restricted = 1

	if(restricted)
		if(restricted == 1)
			dat += "<font color='red'><b>You cannot play as this species.</br><small>If you wish to be whitelisted, you can make an application post on <a href='?src=\ref[user];preference=open_whitelist_forum'>the forums</a>.</small></b></font></br>"
		else if(restricted == 2)
			dat += "<font color='red'><b>You cannot play as this species.</br><small>This species is not available for play as a station race..</small></b></font></br>"
	if(!restricted || check_rights(R_ADMIN, 0))
		dat += "\[<a href='?src=\ref[src];set_species=[pref.species_preview]'>select</a>\]"
	dat += "</center></body>"

	user << browse(dat, "window=species;size=700x400")
*/