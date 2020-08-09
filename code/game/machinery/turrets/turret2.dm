#define TURRET_OFF		0 // Not processing and inert until something turns it back on.
#define TURRET_IDLE		1 // Not doing anything but still processing slowly.
#define TURRET_TURNING	2 // In the process of turning to face the current target, processing fast. May instantly switch to TURRET_ENGAGING if close enough.
#define TURRET_ENGAGING	3 // Actively fighting the target, processing fast.


// Base type for rewritten turrets, designed to hopefully be cleaner and more fun to use and fight against.
// Use the subtypes for 'real' turrets.

/obj/machinery/turret
	name = "don't use me"
	catalogue_data = list(/datum/category_item/catalogue/technology/turret)
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turret_barrel"
	anchored = TRUE

	transform_animate_time = 0.2 SECONDS

	// Observation.
	var/list/turf_observation_constallation = list() // List of turfs that are visible, or potentially could become visible to the turret.
	var/vision_range = 7 // How many tiles away the turret can see. Values higher than 7 will let the turret shoot offscreen, which might be unsporting.

	// Visuals.
	var/image/turret_stand = null
	var/image/turret_ray = null

	// Targeting.
	var/datum/turret_iff/IFF = null // Datum that determines whether or not to shoot something.
	var/default_iff_type = /datum/turret_iff
	var/atom/target = null // Current target it wants to shoot, if any.
	var/target_x = null // Used to cache the current desired angle. If the target's x/y coordinate equals these, then the turret can save some processing.
	var/target_y = null
	var/list/potential_targets = list() // List of other targets the turret can switch to later if needed.

	var/turret_state = TURRET_IDLE

	// Remember that in BYOND, NORTH equals 0 absolute degrees, and not 90.
	var/traverse = 180 // Determines how wide the turret can turn to shoot things, in degrees. The 'front' of the turret is determined by it's dir variable.
	var/leftmost_traverse = null // How far left or right the turret can turn. Set automatically using the above variable and the inital dir value.
	var/rightmost_traverse = null
	var/current_bearing = 0 // Current absolute angle the turret has, used to calculate if it needs to turn to try to shoot the target.
	var/target_bearing = 0 // The desired bearing. If the current bearing is too far from this, the turret will turn towards it until within tolerence.
	var/bearing_tolerence = 5 // Degrees that the turret must be within to be able to shoot at the target.
	var/turning_rate = 90 // Degrees per second.

/obj/machinery/turret/Initialize()
	IFF = new default_iff_type(src)
	target_bearing = dir2angle(dir)
	adjust_bearing(target_bearing)
	calculate_traverse()
	build_vision_constallation()
	update_icon()

//	set_state(TURRET_TURNING) // WIP
	return ..()

/obj/machinery/turret/Destroy()
	clear_vision_constallation()
	QDEL_NULL(IFF)
	return ..()

/obj/machinery/turret/process()
	switch(turret_state)
		if(TURRET_OFF)
			turret_ray.color = "#0000FF"
			return PROCESS_KILL // Stop processing until something wakes us.
		if(TURRET_IDLE)
			cut_overlay(turret_ray)
			turret_ray.color = "#00FF00"
			add_overlay(turret_ray)
			return
		if(TURRET_TURNING)
			cut_overlay(turret_ray)
			turret_ray.color = "#FFFF00"
			add_overlay(turret_ray)
			handle_turning()
			return
		if(TURRET_ENGAGING)
			cut_overlay(turret_ray)
			turret_ray.color = "#FF0000"
			add_overlay(turret_ray)
			handle_engaging()
			return

/obj/machinery/turret/proc/set_state(new_state)
	var/list/fast_states = list(TURRET_TURNING, TURRET_ENGAGING)
	var/list/slow_states = list(TURRET_IDLE)

	turret_state = new_state

	if(new_state == TURRET_OFF)
		speed_process = FALSE
		STOP_PROCESSING(SSfastprocess, src)
		STOP_MACHINE_PROCESSING(src)
		return

	if(speed_process && (new_state in slow_states)) // Currently in fast mode.
		speed_process = FALSE
		STOP_PROCESSING(SSfastprocess, src)
		START_MACHINE_PROCESSING(src)
	else if(!speed_process && (new_state in fast_states)) // Currently in slow mode.
		speed_process = TRUE
		STOP_MACHINE_PROCESSING(src)
		START_PROCESSING(SSfastprocess, src)

/obj/machinery/turret/proc/handle_turning()
	if(!target)
		set_state(TURRET_IDLE)
		return
	var/angle = get_target_angle(target)
	if(!angle_within_traverse(angle))
		find_new_target()
		return
	target_bearing = angle

	// Are we close enough?
	if(within_bearing())
		set_state(TURRET_ENGAGING) // Immediately shoot if within tolerence.
		handle_engaging()
		return

	// If not, turn to get closer.
	var/distance_from_target_bearing = closer_angle_difference(current_bearing, target_bearing)
	var/distance_this_step = min(calculate_turn_rate_per_process(), abs(distance_from_target_bearing))
	var/adjustment = distance_this_step * SIGN(distance_from_target_bearing)
	// This probably won't work if traverse is greater than 180.
	if(!angle_within_traverse(current_bearing + adjustment))
		adjustment = adjustment * -1
	adjust_bearing(current_bearing + adjustment)

	// Are we close enough -now-?
	if(within_bearing())
		set_state(TURRET_ENGAGING) // Immediately shoot if within tolerence.
		handle_engaging()

/obj/machinery/turret/proc/handle_engaging()
//	target_bearing = Get_Angle(src, target)
	target_bearing = get_target_angle(target)
	if(!within_bearing())
		set_state(TURRET_TURNING)
		return
	// TODO: shooting.

/obj/machinery/turret/proc/within_bearing()
	var/distance_from_target_bearing = closer_angle_difference(current_bearing, target_bearing)
	if(abs(distance_from_target_bearing) <= bearing_tolerence)
		return TRUE
	return FALSE

// Instantly turns the turret to a specific absolute angle.
/obj/machinery/turret/proc/adjust_bearing(new_angle)
	current_bearing = SIMPLIFY_DEGREES(new_angle)
	adjust_rotation(current_bearing)

/obj/machinery/turret/proc/set_target(atom/new_target)
	target = new_target
	if(target)
		target_bearing = get_target_angle(new_target)
		set_state(TURRET_TURNING)
	else
		set_state(TURRET_IDLE)

/obj/machinery/turret/proc/calculate_turn_rate_per_process()
	return turning_rate / (1 SECOND / SSfastprocess.wait)

// Calculates the bearing to the target.
// If called multiple times when the target has not moved, then this avoids recalculating.
/obj/machinery/turret/proc/get_target_angle(atom/A)
	if(!target_x || A.x != target_x || A.y != target_y)
		target_x = A.x
		target_y = A.y
		return Get_Angle(src, A)
	return target_bearing

/obj/machinery/turret/update_icon()
	if(!turret_stand)
		turret_stand = image(icon, "turret_cover_normal")
		turret_stand.layer = src.layer - 0.01
		turret_stand.appearance_flags = KEEP_APART|RESET_TRANSFORM|TILE_BOUND|PIXEL_SCALE
		add_overlay(turret_stand)
	if(!turret_ray)
		turret_ray = image(icon, "turret_ray")
		turret_ray.plane = PLANE_LIGHTING_ABOVE // Should it go below lighting?
		turret_ray.appearance_flags = KEEP_APART|PIXEL_SCALE|RESET_COLOR
		turret_ray.mouse_opacity = FALSE

		var/matrix/M = matrix(turret_ray.transform)
		// Offset away from the parent, so that when the parent rotates, this rotates with it correctly.
		M.Translate(0, (1 * WORLD_ICON_SIZE * 0.50)+4) // 20?
		world << (1 * WORLD_ICON_SIZE * 0.50)+4
		M.Scale(1, 4)

		turret_ray.transform = M
		add_overlay(turret_ray)

/obj/machinery/turret/proc/calculate_traverse()
	if(traverse >= 360)
		return

	var/half_arc = traverse / 2
	leftmost_traverse = SIMPLIFY_DEGREES(dir2angle(dir) - half_arc)
	rightmost_traverse = SIMPLIFY_DEGREES(dir2angle(dir) + half_arc)

// Returns TRUE if the input is within the two angles that determine the traverse.
/obj/machinery/turret/proc/angle_within_traverse(angle)
	if(traverse >= 360)
		return TRUE
	return angle_between_two_angles(leftmost_traverse, angle, rightmost_traverse)


// Sets up the observation-based vision for the turrets.
// Only needs to be called once on init, and whenever the turret is moved or dir-changed.
/obj/machinery/turret/proc/build_vision_constallation()
	for(var/thing in RANGE_TURFS(vision_range, src))
		var/turf/T = thing
		var/angle_to_T = Get_Angle(src, T)
		if(!angle_within_traverse(angle_to_T))
			continue
		turf_observation_constallation += T
		turf_changed_event.register(T, src, .proc/on_watched_turf_changed)
		GLOB.turf_entered_event.register(T, src, .proc/on_watched_turf_entered)

// Called when a watched tile has something move into it.
/obj/machinery/turret/proc/on_watched_turf_entered(turf/T, atom/movable/AM, atom/old_loc)
	world << "Watched turf \the [T] had \the [AM] entered from \the [old_loc]."
	add_target(AM)

// Called when a watched tile is changed.
/obj/machinery/turret/proc/on_watched_turf_changed(turf/T, old_density, new_density, old_opacity, new_opacity)
	world << "Watched turf \the [T] had old density [old_density], new density [new_density], old opacity [old_opacity], new opacity [new_opacity]."

//src, old_density, density, old_opacity, opacity

// Clears all tiles being watched.
// Called when the turret is being deleted or when it gets moved, so the constallation can be rebuilt.
/obj/machinery/turret/proc/clear_vision_constallation()
	for(var/thing in turf_observation_constallation)
		var/turf/T = thing
		turf_observation_constallation -= thing
		turf_changed_event.unregister(T, src, .proc/on_watched_turf_changed)
		GLOB.turf_entered_event.unregister(T, src, .proc/on_watched_turf_entered)

/obj/machinery/turret/proc/rebuild_vision_constallation()
	clear_vision_constallation()
	build_vision_constallation()

/obj/machinery/turret/proc/add_target(atom/A)
	if(target == A || (A in potential_targets))
		return
	if(!target)
		set_target(A)
	else
		potential_targets += A

/obj/machinery/turret/proc/find_new_target()
	if(!potential_targets.len)
		set_target(null)
		return
	while(potential_targets.len)
		var/atom/A = pick(potential_targets)
		potential_targets -= A
		var/new_target_angle = get_target_angle(A)
		if(angle_within_traverse(new_target_angle))
			set_target(A)
			break
	set_target(null)