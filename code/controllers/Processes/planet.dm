var/datum/controller/process/planet/planet_controller = null

/datum/controller/process/planet
	var/list/planets = list()
	var/list/z_to_planet = list()

/datum/controller/process/planet/setup()
	name = "planet controller"
	planet_controller = src
	schedule_interval = 1 MINUTE

	var/list/planet_datums = typesof(/datum/planet) - /datum/planet
	for(var/P in planet_datums)
		var/datum/planet/NP = new P()
		planets.Add(NP)

	allocateTurfs()

/datum/controller/process/planet/proc/allocateTurfs()
	for(var/turf/simulated/OT in outdoor_turfs)
		for(var/datum/planet/P in planets)
			if(OT.z in P.expected_z_levels)
				P.planet_floors |= OT
				OT.vis_contents |= P.weather_holder.visuals
				break
	outdoor_turfs.Cut() //Why were you in there INCORRECTLY?

	for(var/turf/unsimulated/wall/planetary/PW in planetary_walls)
		for(var/datum/planet/P in planets)
			if(PW.type == P.planetary_wall_type)
				P.planet_walls |= PW
				break
	planetary_walls.Cut()

/datum/controller/process/planet/proc/unallocateTurf(var/turf/T)
	for(var/planet in planets)
		var/datum/planet/P = planet
		if(T.z in P.expected_z_levels)
			P.planet_floors -= T
			T.vis_contents -= P.weather_holder.visuals

/datum/controller/process/planet/doWork()
	if(outdoor_turfs.len || planetary_walls.len)
		allocateTurfs()

	for(var/datum/planet/P in planets)
		P.process(schedule_interval / 10)
		SCHECK //Your process() really shouldn't take this long...

		//Sun light needs changing
		if(P.needs_work & PLANET_PROCESS_SUN)
			P.needs_work &= ~PLANET_PROCESS_SUN
			//Redraw sun overlay
			var/new_brightness = P.sun["brightness"]
			var/new_color = P.sun["color"]
			for(var/A in P.planet_suns)
				var/obj/effect/sun/sun = A
				sun.set_light(sun.light_range, new_brightness, new_color)
				SCHECK

		//Temperature needs updating
		if(P.needs_work & PLANET_PROCESS_TEMP)
			P.needs_work &= ~PLANET_PROCESS_TEMP
			//Set new temperatures
			for(var/W in P.planet_walls)
				var/turf/unsimulated/wall/planetary/wall = W
				wall.set_temperature(P.weather_holder.temperature)
				SCHECK
