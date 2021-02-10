// Deployable turrets are those that can be moved around by deploying and undeploying them.
// They can be used anywhere, even places without any power, however their power cell can run out if they shoot a lot.

/obj/machinery/turret/deployable
    name = "deployable turret"
    desc = "A type of automated turret, this one is designed for short-term use by being able to be folded up and carried."
    turning_rate = 180 // Faster turning rate to make up for the limited arc of fire.


/obj/machinery/turret/deployable/player_built
    gun_looting_prob = 100 // Turrets made in-round will always give back the parts used to build them.
    cell_looting_prob = 100