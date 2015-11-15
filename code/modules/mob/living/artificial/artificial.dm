#define BUSY		-1
#define IDLE		0
#define MOVING		1

/mob/living/artificial	//Generic type for mobs controlled with an AI that demand more intelligence than simple mobs.
	name = "AI controlled mob"
	desc = "If you can see me, tell a coder that the game is broken again."
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot_old"
	var/task = IDLE
	var/target_loc = null
	var/target = null
	var/list/path = list()
	var/stuck = 0					//Counter for how many steps we failed to move, used to prevent a unit from being stuck forever.
	var/step_delay = 3				//How long the mob waits between steps.  Lower numbers equal faster speed.
	var/list/proc_queue = list()	//Used to queue up more than one action at once.
	var/processing_queue = 0		//Indicates if the mob is currently waiting for a proc in the queue to finish.

/mob/living/artificial/proc/process_queue()
	if(proc_queue.len == 0 || processing_queue) //Nothing to do or we're busy.
		return
	else
		processing_queue = 1
		var/proc_name = proc_queue[1]
		var/second_arg = proc_queue[proc_name]
//		world << "proc_name equals [proc_name]."
//		world << "second_arg equals [second_arg]."
//		world << "Attempting to call [proc_name]([second_arg])."
		call(src,proc_name)(second_arg)
		proc_queue.Remove(proc_name)
		processing_queue = 0

/mob/living/artificial/proc/add_to_queue(var/proc_name, var/second_arg = null)
	proc_queue[proc_name] = second_arg

/mob/living/artificial/proc/clear_queue()
	proc_queue.Cut()
	processing_queue = 0

//For when we need a proc done *right now*, and nothing else to inturrupt it.
/mob/living/artificial/proc/urgent_call(var/proc_name, var/second_arg = null)
	processing_queue = 1 //Suspend the queue.
	call(src,proc_name)(second_arg)
	processing_queue = 0 //All done, resume as normal.


/mob/living/artificial/Life()
	..()
	process_queue()

/mob/living/artificial/proc/calculate_path(var/turf/targeted_loc)
	if(!path.len || !path)
		spawn(0)
			path = AStar(loc, targeted_loc, /turf/proc/CardinalTurfsIgnoreAccess, /turf/proc/Distance, 0, 100, id = null)
			world << "[src] is making new path to [targeted_loc]."
			world << "targeted_loc's type is [targeted_loc.type]"
			if(!path)
				path = list()
				world << "[src] failed to get a path."
		return

/mob/living/artificial/proc/walk_path(var/targeted_loc)
	if(path.len)
		step_to(src, path[1])
		path -= path[1]
		return
	else
		if(targeted_loc)
			calculate_path(targeted_loc)

/mob/living/artificial/proc/walk_loop(var/targeted_loc)
	if(task == BUSY)
		return 0
	task = BUSY
	world << "walk_loop() called.  Will walk to [targeted_loc]."
	calculate_path(targeted_loc)
	if(!targeted_loc)
		return 0
	if(path.len == 0)
		calculate_path(targeted_loc)
	while(loc != targeted_loc)
//	while(path.len != 0)
		walk_path(targeted_loc)
		sleep(step_delay)
	world << "Done loop"
	task = IDLE
	return 1

/mob/living/artificial/proc/walk_reset()
	task = IDLE
	target_loc = null
	stuck = 0
	path = list()

/******************************************************************/
// Navigation procs
// Used for A-star pathfinding


// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsIgnoreAccess(var/obj/item/weapon/card/id/ID)
	var/L[] = new()

	//	for(var/turf/simulated/t in oview(src,1))

	for(var/d in cardinal)
		var/turf/simulated/T = get_step(src, d)
		if(istype(T) && !T.density)
			if(!LinkBlockedIgnoreAccess(src, T, ID))
				L.Add(T)
	return L


// Returns true if a link between A and B is blocked
// Movement through doors allowed if a door exists, regardless of access.
/proc/LinkBlockedIgnoreAccess(turf/A, turf/B)

	if(A == null || B == null) return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//	diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlockedIgnoreAccess(A,iStep) && !LinkBlockedIgnoreAccess(iStep,B))
			return 0

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlockedIgnoreAccess(A,pStep) && !LinkBlockedIgnoreAccess(pStep,B))
			return 0
		return 1

	if(DirBlockedIgnoreAccess(A,adir))
		return 1

	if(DirBlockedIgnoreAccess(B,rdir))
		return 1

	for(var/obj/O in B)
		if(O.density && !istype(O, /obj/machinery/door) && !(O.flags & ON_BORDER))
			return 1

	return 0

// Returns true if direction is blocked from loc
// Checks doors against access with given ID
/proc/DirBlockedIgnoreAccess(turf/loc,var/dir)
	for(var/obj/structure/window/D in loc)
		if(!D.density)			continue
		if(D.dir == SOUTHWEST)	return 1
		if(D.dir == dir)		return 1

	for(var/obj/machinery/door/D in loc)
		if(!D.density)			continue
		if(istype(D, /obj/machinery/door/window))
//			if( dir & D.dir )	return !D.check_access(ID)
			if( dir & D.dir )	return 0

			//if((dir & SOUTH) && (D.dir & (EAST|WEST)))		return !D.check_access(ID)
			//if((dir & EAST ) && (D.dir & (NORTH|SOUTH)))	return !D.check_access(ID)
//		else return !D.check_access(ID)	// it's a real, air blocking door
		else return 0	// it's a real, air blocking door
	return 0