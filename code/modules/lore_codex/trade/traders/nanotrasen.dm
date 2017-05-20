// Generalized and always available.
// NT dislikes it when you sell things to non-NT vendors for too low of a price.
/datum/trader_faction/nanotrasen
	name = "NanoTrasen"
	reputation_desc = "NT dislikes it when you sell things to non-NT traders for vastly lower prices.<br>\
	NT dislikes it when you sell sheets of material to non-NT traders, such as Grayson Manufactories."
	default_reputation = 40 // Our overlords like us by default.

/datum/trader/permanent/centcom
	name = "Overlords" // Replaced in New()
	faction = TSC_NT
	budget = 10000
	inventory = list(

	)
	desired_items = list(

	)

/datum/trader/permanent/centcom/New()
	..()
	name = "[using_map.boss_name] [name]" // So it says the correct Central Command

/datum/trader/permanent/centcom/minerals
	name = "Mineral Imports / Exports"
	class = "Mining and Materials"
	inventory = list(
		/obj/item/stack/material/phoron = 300,
		/obj/item/stack/material/gold = 120,
		/obj/item/stack/material/silver = 90,
		/obj/item/stack/material/uranium = 90,
		/obj/item/stack/material/plasteel = 400,
		/obj/item/stack/material/steel = 30,
		/obj/item/stack/material/glass = 15
		)
	desired_items = list(
		/obj/mecha/working/ripley = 1500,
		/obj/item/stack/material/phoron = 50,
		/obj/item/stack/material/gold = 35,
		/obj/item/stack/material/silver = 30,
		/obj/item/stack/material/uranium = 30,
		/obj/item/stack/material/diamond = 200,
		/obj/item/stack/material/durasteel = 500,
		/obj/item/stack/material/plasteel = 100,
		/obj/item/stack/material/steel = 10,
		/obj/item/stack/material/glass = 5
	)


/datum/trader/permanent/centcom/security
	name = "Security Supply Depot"
	class = "Armor and Weaponry"
	inventory = list(
		/obj/machinery/deployable/barrier = 100,
		/obj/item/weapon/melee/baton = 100,
		/obj/item/weapon/shield/riot = 500,
		/obj/item/weapon/storage/box/flashbangs = 400,
		/obj/item/weapon/storage/box/stunshells = 350,
		/obj/item/weapon/storage/box/flashshells = 100,
		/obj/item/weapon/storage/box/beanbags = 300,
		/obj/item/weapon/storage/box/blanks = 50,
		/obj/item/clothing/suit/storage/vest = 250,
		/obj/item/clothing/suit/armor/riot = 500,
		/obj/item/clothing/suit/armor/laserproof = 1000,
		/obj/item/clothing/suit/armor/bulletproof = 700,
		/obj/item/clothing/suit/armor/combat = 600,
		/obj/item/weapon/cell/device/weapon = 500,
		/obj/item/weapon/gun/energy/taser = 400,
		/obj/item/weapon/gun/energy/stunrevolver = 450,
		/obj/item/weapon/gun/energy/gun = 1200,
		/obj/item/weapon/gun/energy/laser = 1500,
		/obj/item/weapon/gun/energy/ionrifle/pistol = 1200
		)

	desired_items = list(
		/obj/mecha/combat/gygax = 5000,
		/obj/mecha/combat/durand = 3800,
		/obj/item/weapon/gun/energy/ionrifle = 1500,
		/obj/item/weapon/gun/energy/xray = 2500,
		/obj/item/weapon/gun/energy/gun/nuclear = 2000,
		/obj/item/weapon/gun/energy/toxgun = 1000,
		/obj/item/weapon/gun/energy/lasercannon = 2500,

	)

/datum/trader/permanent/centcom/engineering
	name = "Internal Engi Equipment Distribution"
	class = "Engineering"
	inventory = list(
		/obj/item/clothing/gloves/fyellow = 50,
		/obj/item/clothing/gloves/yellow = 150,
		/obj/item/weapon/storage/box/lights/mixed = 50,
		/obj/item/weapon/smes_coil = 2500,
		/obj/item/weapon/cell/device = 30,
		/obj/item/weapon/cell = 50,
		/obj/item/weapon/cell/high = 250,
		/obj/item/clothing/mask/gas = 50,
		/obj/item/weapon/tank/air = 50,
		/obj/item/weapon/storage/briefcase/inflatable = 100,
		/obj/machinery/recharger = 200,
		/obj/machinery/portable_atmospherics/canister = 100,
		/obj/machinery/portable_atmospherics/canister/air = 400,
		/obj/machinery/portable_atmospherics/canister/oxygen = 600,
		/obj/machinery/portable_atmospherics/canister/nitrogen = 300,
		/obj/machinery/portable_atmospherics/canister/phoron = 2500,
		/obj/machinery/portable_atmospherics/canister/sleeping_agent = 500,
		/obj/machinery/portable_atmospherics/canister/carbon_dioxide = 300,
		/obj/machinery/pipedispenser/orderable = 500,
		/obj/machinery/pipedispenser/disposal/orderable = 500,
		/obj/item/weapon/storage/belt/utility/full = 60,
		/obj/structure/reagent_dispensers/fueltank = 200,
		/obj/machinery/power/emitter = 1000,
		/obj/machinery/field_generator = 2500,
		/obj/machinery/power/rad_collector = 500,
		/obj/machinery/power/supermatter = 8000,
		/obj/machinery/power/generator = 1500,
		/obj/machinery/atmospherics/binary/circulator = 750,

		)