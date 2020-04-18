/datum/technomancer/spell/beam
	name = "Beam"
	desc = "Fires a laser at your target.  Cheap, reliable, and a bit boring."
	spell_power_desc = "Increases damage dealt."
	cost = 100
	ability_icon_state = "tech_beam"
	obj_path = /obj/item/weapon/spell/projectile/beam
	category = OFFENSIVE_SPELLS

/obj/item/weapon/spell/projectile/beam
	name = "beam"
	icon_state = "beam"
	desc = "Boring, but practical."
	cast_methods = CAST_RANGED
	aspect = ASPECT_LIGHT
	spell_projectile = /obj/item/projectile/beam/blue
	energy_cost_per_shot = 400
	instability_per_shot = 3
	cooldown = 10
	fire_sound = 'sound/weapons/Laser.ogg'

