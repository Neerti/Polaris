// 'Stationary' turrets are the static, (almost) immovable turrets that guard a specific place.
// They can rotate a full 360 degrees, and charge their internal battery from the APC in the room.
// They're not pathed as /static because that's used an as alias for declaring a global variable in DM.
/obj/machinery/turret/stationary
    name = "static turret"
    traverse = 360


/obj/machinery/turret/stationary/player_built
    gun_looting_prob = 100 // Turrets made in-round will always give back the parts used to build them.
    cell_looting_prob = 100