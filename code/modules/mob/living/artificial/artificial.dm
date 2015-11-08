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
	var/stuck = 0				//Counter for how many steps we failed to move, used to prevent a unit from being stuck forever.
	var/step_delay = 10			//How long the mob waits between steps.  Lower numbers equal faster speed.

/mob/living/artificial/proc/calculate_path()
	if(!path.len)
		spawn(0)
			path = AStar(loc, target_loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 100, id = null)
			if(!path)
				path = list()
		return

/mob/living/artificial/proc/walk_path()
	if(path.len)
		step_to(src, path[1])
		path -= path[1]
		return

/mob/living/artificial/proc/walk_loop()
	if(!target_loc)
		return
	calculate_path()
	while(loc != target_loc)
		walk_path()
		sleep(step_delay)

/mob/living/artificial/proc/walk_reset()
	task = IDLE
	target_loc = null
	stuck = 0
	path = list()
