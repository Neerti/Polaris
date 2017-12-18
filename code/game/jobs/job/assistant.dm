/datum/job/assistant
	title = "Assistant"
	flag = ASSISTANT
	department = "Civilian"
	department_flag = CIVILIAN
	faction = TSC_NT
	total_positions = -1
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#515151"
	economic_modifier = 1
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	outfit_type = /decl/hierarchy/outfit/job/assistant
	alt_titles = list("Technical Assistant","Medical Intern","Research Assistant",
					"Visitor" = /decl/hierarchy/outfit/job/assistant/visitor,
					"Resident" = /decl/hierarchy/outfit/job/assistant/resident)
	alt_titles_faction = list(
		"Visitor" = null,
		"Resident" = null
		)
	alt_titles_manifest_hide = list(
		"Visitor"
		)

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()
