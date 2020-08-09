// A datum that holds logic and vars for telling a turret whether or not to shoot something.
// Also, IFF stands for Identification, Friend or Foe.
/datum/turret_iff
	var/obj/machinery/turret/my_turret = null // Reference to the turret holding this.

/datum/turret_iff/New(new_turret)
	my_turret = new_turret