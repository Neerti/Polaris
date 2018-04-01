/datum/job/private_bill
	title = "Private Bill"
	flag = ASSISTANT
	department = "Cargo"
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "Major Bill"
	selection_color = "#515151"
	economic_modifier = 1
	access = list()
	minimal_access = list()
	outfit_type = /decl/hierarchy/outfit/job/private_bill

/decl/hierarchy/outfit/job/private_bill
	name = OUTFIT_JOB_NAME("Private Bill")
	hierarchy_type = /decl/hierarchy/outfit/job
	l_ear = /obj/item/device/radio/headset/headset_cargo
	gloves = /obj/item/clothing/gloves/black
	shoes = /obj/item/clothing/shoes/boots/jackboots
	uniform = /obj/item/clothing/under/mbill
	head = /obj/item/clothing/head/soft/mbill

	id_type = /obj/item/weapon/card/id/cargo/cargo_tech
	id_slot = slot_wear_id
	pda_slot = slot_belt
	pda_type = /obj/item/device/pda/cargo