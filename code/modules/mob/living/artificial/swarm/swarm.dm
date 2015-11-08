/mob/living/artificial/swarm
	var/mob/commander/swarm/master = null //Reference to the master mob, who makes all the high-level decisions.
	var/damage = 10
	var/attack_delay = 10
	var/armor = list(melee = 0, bullet = 0, laser = 0, emp = 0, bomb = 50)



/mob/living/artificial/swarm/New()
	name = "[initial(name)] ([rand(1,999)])"
	master = assign_commander()
	master.owned_units.Add(src)
	..()

/mob/living/artificial/swarm/Destroy()
	master.owned_units.Remove(src)
	master = null
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

/mob/living/artificial/swarm/emp_act(severity)
	switch(severity)
		if(1)
			adjustFireLoss(40)
		if(2)
			adjustFireLoss(20)

/mob/living/artificial/swarm/UnarmedAttack(var/atom/A, var/proximity)

	if(!..())
		return 0

	A.attack_generic(src,damage)

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
			if(C.client) //We ignore SSD players.
				vacant = 0
				break
		for(var/mob/living/silicon/S in my_area.contents) //Also for borgs.
			if(S.client) //We ignore SSD players.
				vacant = 0
				break
		if(vacant)
			scorched_earth()
			master.say("[my_area] is now under control.")
			master.captured_areas.Add(my_area)

/mob/living/artificial/swarm/proc/scorched_earth() //We're gonna make sure it's hard to take back what we just took.
	var/area/my_area = get_area(src)
	var/list/cameras = list()
	for(var/obj/machinery/camera/C in my_area.contents) //Get all the cameras in the area.
		cameras.Add(C)

	for(var/obj/machinery/camera/C in cameras) //Now we're gonna smash them all!
		target_loc = C.loc
		calculate_path()
		while(C)
			walk_path()
			if(stuck > 20) //welp
				world << "[src] got stuck!"
				walk_reset()
				break
			if(loc == target_loc)
				C.destroy()
				visible_message("<span class='danger'>[src] destroys \the [C]!</span>")
				if(master)
					master.say("Destroyed enemy camera in [my_area].")
				break
			sleep(step_delay)


/obj/structure/commander
	invisibility = 0
	icon = 'icons/obj/commander.dmi'

/obj/structure/commander/move_to
	name = "move to"
	desc = "Units are moving to this spot."
	icon_state = "move"


//*Very* expensible unit used for quickly capturing terratory.
/mob/living/artificial/swarm/invader
	name = "invader"
	desc = "It looks cheaply put together."
	health = 50
	maxHealth = 50
	var/crowbar = new /obj/item/weapon/crowbar

//A slow unit specialized in making "doors" for the other units.
/mob/living/artificial/swarm/destroyer
	name = "destroyer"
	desc = "It's big, menacing, and ready to destroy both structures, and you."
	health = 150
	maxHealth = 150

//A unit specialized to spaceflight.  It can traverse z-levels to attack objectives that other units are unable to get a foothold into.
/mob/living/artificial/swarm/raider
	name = "raider"
	desc = "You can roughly make out several propulsion tanks, thrusters, and reaction wheels inside of this thing.  It's been built for spaceflight."
	health = 80
	maxHealth = 80

/mob/living/artificial/swarm/raider/Process_Spacemove(var/check_drift = 0)
	return 1

