//A unit specialized to spaceflight.  It can traverse z-levels to attack objectives that other units are unable to get a foothold into.
/mob/living/artificial/swarm/raider
	name = "raider"
	desc = "You can roughly make out several propulsion tanks, thrusters, and reaction wheels inside of this thing.  It's been built for spaceflight."
	health = 80
	maxHealth = 80
	armor = list(melee = 0, bullet = 10, laser = 10, emp = 10, bomb = 70)
	weapons = list(new /obj/item/weapon/gun/energy/laser/swarm)

/mob/living/artificial/swarm/raider/Process_Spacemove(var/check_drift = 0)
	return 1

/obj/item/weapon/gun/energy/laser/swarm
	name = "rapid fire laser gun"
	desc = "A weapon that sacrifices killing power for vast effiency and firing rate, designed to be used en mass by a group.  It's very similar to an \
	xray rifle."
	icon_state = "xray"
	item_state = "xray"
	fire_sound = 'sound/weapons/laser3.ogg'
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 4, TECH_MAGNET = 3, TECH_ILLEGAL = 3)
	charge_cost = 100
	max_shots = 20
	fire_delay = 0
	self_recharge = 1
	projectile_type = /obj/item/projectile/beam/swarm_weak

/obj/item/projectile/beam/swarm_weak
	name = "laser beam"
	icon_state = "xray"
	damage = 10
	armor_penetration = 5

	muzzle_type = /obj/effect/projectile/xray/muzzle
	tracer_type = /obj/effect/projectile/xray/tracer
	impact_type = /obj/effect/projectile/xray/impact