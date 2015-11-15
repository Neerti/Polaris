/mob/living/artificial/swarm
	var/mob/commander/swarm/master = null //Reference to the master mob, who makes all the high-level decisions.
	var/datum/effect/effect/system/spark_spread/spark_system
	var/damage = 10
	var/attack_delay = 10
	var/armor = list(melee = 0, bullet = 0, laser = 0, emp = 0, bomb = 50)
	var/current_weapon = null
	var/list/weapons = list()

	var/list/hostile_mobs = list()



/mob/living/artificial/swarm/New()
	name = "[initial(name)] ([rand(1,999)])"
	master = assign_commander()
	master.owned_units.Add(src)
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	..()

/mob/living/artificial/swarm/Destroy()
	master.owned_units.Remove(src)
	master = null
	spark_system = null
	..()

/mob/living/artificial/swarm/proc/assign_commander(var/i)
	if(ai_commanders)
		if(i)
			return ai_commanders[i]
		else
			return ai_commanders[1]
	else
		var/mob/commander/swarm/master
		master = new master(src.loc)
		return master

/mob/living/artificial/swarm/examine(mob/user)
	..(user)
	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	msg += "<span class='warning'>"
	if (src.getBruteLoss())
		if (src.getBruteLoss() < (maxHealth / 2))
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
	if (src.getFireLoss())
		if (src.getFireLoss() < (maxHealth / 2))
			msg += "It looks slightly charred.\n"
		else
			msg += "<B>It looks severely burnt and heat-warped!</B>\n"
	msg += "</span>"
	msg += "*---------*</span>"

	user << msg



/mob/living/artificial/swarm/UnarmedAttack(var/atom/A, var/proximity)

	if(!..())
		return 0
	if(!current_weapon)
		A.attack_generic(src,damage)

/mob/living/artificial/swarm/proc/self_terminate(var/reason)
	if(master)
		master << "[src] is self terminating.  Reason: [reason]."
	death()

/mob/living/artificial/swarm/walk_path()
	..()
	handle_door()

/mob/living/artificial/swarm/proc/handle_door()
	var/turf/T = get_step(src,dir)
	if(T)
		for(var/obj/machinery/door/D in T.contents)
			if(D.check_access() && D.density) //Try to open it
				spawn(1)
					D.open()
			else if(D.density) //We couldn't open it, so let's robust it open.
				while(D.health != 0)
					UnarmedAttack(D)
					sleep(attack_delay)
				visible_message("<span class='danger'>[src] forces the [D] open!</span>")
				D.open(1)

/mob/living/artificial/swarm/proc/capture_area()
	if(master)
		var/area/my_area = get_area(src)
		var/vacant = 1
		for(var/mob/living/carbon/C in my_area.contents) //Check for living things.
			if(C.client || !C.stat) //We ignore helpless and SSD players.
				vacant = 0
				break
		for(var/mob/living/silicon/S in my_area.contents) //Also for borgs.
			if(S.client || !S.stat) //We ignore helpless and SSD players.
				vacant = 0
				break
		if(vacant)
			scorched_earth()
			master.say("[my_area] is now under control.")
			master.captured_areas |= my_area

/mob/living/artificial/swarm/proc/scorched_earth() //We're gonna make sure it's hard to take back what we just took.
	if(task == BUSY)
		return
	task = BUSY
	var/area/my_area = get_area(src)
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in my_area.contents) //Get all the cameras in the area.
		if(isturf(C.loc))
			var/turf/T = C.loc
			if(!T.get_density()) //Don't add unreachable cameras.
				if(!(C.stat & BROKEN)) //Don't add cameras that are already broken.
					cameras.Add(C)

	for(var/obj/machinery/camera/C in cameras) //Now we're gonna smash them all!
//		target_loc = C.loc
		calculate_path(C.loc)
		world << "Calculated new path to camera."
		while(C)
			walk_path(C.loc)
			world << "Called walk_path() in scorched_earth()"
			if(path.len == 0)
				calculate_path(C.loc)
//			if(!path || path.len==0) //No valid path found.
//				message_admins("AI Error: [src] couldn't find a path to a camera.")
//				break
//			if(stuck > 20) //welp
//				message_admins("AI Error: [src] got stuck at [x],[y],[z].")
//				walk_reset()
//				break
//			if(Adjacent(C))
			if(loc == C.loc)
				C.destroy()
				visible_message("<span class='danger'>[src] destroys \the [C]!</span>")
				if(master)
					master.say("Destroyed enemy camera in [my_area].")
				break
			sleep(step_delay)
	task = IDLE


/obj/structure/commander
	invisibility = 0
	icon = 'icons/obj/commander.dmi'

/obj/structure/commander/move_to
	name = "move to"
	desc = "Units are moving to this spot."
	icon_state = "move"


//*Very* expensible unit used for quickly capturing territory.
/mob/living/artificial/swarm/invader
	name = "invader"
	desc = "It looks cheaply put together."
	health = 50
	maxHealth = 50

//Ranged unit made for fighting.
/mob/living/artificial/swarm/soldier
	name = "soldier"
	desc = "It's rather sturdy and appears to be wearing armor plating."
	health = 100
	maxHealth = 100
	armor = list(melee = 20, bullet = 20, laser = 20, emp = 20, bomb = 70)



