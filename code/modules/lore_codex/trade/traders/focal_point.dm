// Power and engineering stuff.
/datum/trader_faction/focal_point
	name = "Focal Point Energistics"

/datum/trader/focal_point/engines
	name = "Engines"
	class = "Engines"
	inventory = list(
		/obj/machinery/power/emitter = 450,
		/obj/machinery/power/rad_collector = 250,
		/obj/machinery/power/supermatter = 5500,
		/obj/machinery/power/generator = 600,
		/obj/machinery/atmospherics/binary/circulator = 400,
		/obj/machinery/power/port_gen/pacman = 500,
		/obj/machinery/power/port_gen/pacman/mrs = 1200,
		/obj/machinery/power/port_gen/pacman/super = 2500,
		/obj/machinery/the_singularitygen = 10000
		)

/datum/trader/focal_point/cells
	name = "Energy Transportation"
	class = "Powercells"
	inventory = list(
		/obj/item/weapon/smes_coil = 1250,
		/obj/item/weapon/cell = 40,
		/obj/item/weapon/cell/high = 200,
		/obj/item/weapon/cell/super = 500,
		/obj/item/weapon/cell/hyper = 1500,
		)