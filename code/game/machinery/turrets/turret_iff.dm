// A datum that holds logic and vars for telling a turret whether or not to shoot something.
// Also, IFF stands for Identification, Friend or Foe.
/datum/turret_iff
	var/obj/machinery/turret/my_turret = null // Reference to the turret holding this.
	var/read_only = TRUE // If FALSE, the IFF settings can be changed. Most turrets have theirs unchangable. Custom turrets are an exception.

/datum/turret_iff/New(new_turret)
	my_turret = new_turret

// Determines if the turret it's attached to can shoot at something or not, using the three defines above.
/datum/turret_iff/proc/can_shoot(atom/A)
	if(isliving(A))
		return IFF_HOSTILE
	return IFF_NEUTRAL
