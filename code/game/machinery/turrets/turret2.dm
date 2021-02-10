// Base type for rewritten turrets, designed to hopefully be cleaner and more fun to use and fight against.
// Use the subtypes for 'real' turrets.

/obj/machinery/turret
	name = "don't use me"
	catalogue_data = list(/datum/category_item/catalogue/technology/turret)
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turret_barrel"
	anchored = TRUE
	idle_power_usage = 500
	active_power_usage = 60000 // This determines how fast the internal cell gets charged.

	transform_animate_time = 0.2 SECONDS

	// Observation.
	var/list/turf_observation_constallation = list() // List of turfs that are visible, or potentially could become visible to the turret.
	var/vision_range = 7 // How many tiles away the turret can see. Values higher than 7 will let the turret shoot offscreen, which might be unsporting.

	// Visuals.
	var/image/turret_stand = null
	var/image/turret_ray = null

	// Sounds
	var/to_idle_sound = 'sound/machines/buzzbeep.ogg' // Played when turret goes to idle state.
	var/to_turning_sound = 'sound/machines/boobeebeep.ogg' // Ditto, for turning state.
	var/to_engaging_sound = 'sound/machines/buttonbeep.ogg' // Ditto, for engaging state.
	var/turn_on_sound = null // Played when turret goes from off to on.
	var/turn_off_sound = null // The above, in reverse.

	// Firing
	var/obj/item/weapon/gun/installed_gun = null // Instance of the gun inside the turret. It's not actually fired but its vars are read extensively.
	var/gun_type = /obj/item/weapon/gun/energy/laser/practice // The type of gun to put in the above var on init.
	var/initial_mode_index = null // If set, the gun that gets spawned inside will have its fire mode switched to this index.
	var/last_fired_time = null // world.time when the turret last fired, used to simulate the internal gun's firing delay.
	var/gun_looting_prob = 25 // If the turret dies and then is disassembled, this is the odds of getting the gun.

	// Power
	var/obj/item/weapon/cell/internal_cell = null // The battery that is used to fire the gun and for the turret to work semi-independantly of the powernet.
	var/cell_type = /obj/item/weapon/cell/high // The type this turret will have on initialization.
	var/can_charge_cell = TRUE // If FALSE, the battery has to be swapped out manually.
	var/can_swap_cell = FALSE // If TRUE, the cell can be replaced with a screwdriver.
	var/cell_looting_prob = 25 // Similar story as the gun looting var.

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

/obj/machinery/turret/Initialize(mapload)
	IFF = new default_iff_type(src)
	installed_gun = new gun_type(src)
	internal_cell = new cell_type(src)
	setup_turret()
	update_icon()

	GLOB.dir_set_event.register(src, src, .proc/on_self_dir_changed)
	GLOB.moved_event.register(src, src, .proc/on_moved)

	return ..()

/obj/machinery/turret/Destroy()
	clear_vision_constallation()

	GLOB.dir_set_event.unregister(src, src, .proc/on_self_dir_changed)
	GLOB.moved_event.unregister(src, src, .proc/on_moved)

	QDEL_NULL(IFF)
	return ..()

/obj/machinery/turret/process()
	process_power()


//	if(stat & BROKEN)
//		set_state(TURRET_OFF)
//		return

	switch(turret_state)
		if(TURRET_OFF, TURRET_DEPOWERED)
			return PROCESS_KILL // Stop processing until something wakes us.
		if(TURRET_IDLE)
			return
		if(TURRET_TURNING)
			handle_turning()
			return
		if(TURRET_ENGAGING)
			handle_engaging()
			return

/obj/machinery/turret/proc/set_state(new_state)
	var/list/off_states = list(TURRET_OFF, TURRET_DEPOWERED)
	var/list/fast_states = list(TURRET_TURNING, TURRET_ENGAGING)
	var/list/slow_states = list(TURRET_IDLE)
	var/old_state = turret_state
	
	turret_state = new_state
	update_icon()

	// Sounds.
	switch(turret_state)
		if(TURRET_IDLE)
			if(to_idle_sound)
				playsound(src, to_idle_sound, 50, TRUE)
		if(TURRET_TURNING)
			if(to_turning_sound)
				playsound(src, to_turning_sound, 75, TRUE)
		if(TURRET_ENGAGING)
			if(to_engaging_sound)
				playsound(src, to_engaging_sound, 100, TRUE)

	if(new_state in off_states)
		speed_process = FALSE
		STOP_PROCESSING(SSfastprocess, src)
		STOP_MACHINE_PROCESSING(src)
		return
	else if(old_state in off_states)
		START_MACHINE_PROCESSING(src)

	if(speed_process && (new_state in slow_states)) // Currently in fast mode.
		speed_process = FALSE
		STOP_PROCESSING(SSfastprocess, src)
		START_MACHINE_PROCESSING(src)
	else if(!speed_process && (new_state in fast_states)) // Currently in slow mode.
		speed_process = TRUE
		STOP_MACHINE_PROCESSING(src)
		START_PROCESSING(SSfastprocess, src)

// Handles power-related stuff, mostly involving the power cell.
/obj/machinery/turret/proc/process_power()
	// If the turret is dead or turned off, don't draw any power.
	if((stat & BROKEN) || !internal_cell)
		update_use_power(USE_POWER_OFF)
		set_state(TURRET_DEPOWERED)
		return
	
	// Draw idle power from cell if the area has no regular power.
	else if(stat & NOPOWER)
		// See if the turret should lose power.
		if(!internal_cell.check_charge(idle_power_usage * CELLRATE))
			update_use_power(USE_POWER_OFF)
			set_state(TURRET_DEPOWERED)
			return
		else
			internal_cell.use(idle_power_usage * CELLRATE)

	// Charge the cell if possible.
	else if(can_charge_cell && !internal_cell.fully_charged())
		var/power_to_give = active_power_usage * CELLRATE
		var/multiplier = time_per_process() / SSobj.wait // This is used so when the turret is using SSfastprocess it doesn't get supercharged.
		internal_cell.give(power_to_give * multiplier)
		update_use_power(USE_POWER_ACTIVE)
	// Draw idle power from APC.
	else
		update_use_power(USE_POWER_IDLE)
	return
	

/obj/machinery/turret/proc/handle_turning()
	if(!target)
		set_state(TURRET_IDLE)
		return
	if(!is_valid_target(target))
		lose_target()
		return

	var/angle = get_target_angle(target)
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
	// If someone smarter than me knows how to make that work then please tell me how.
	if(!angle_within_traverse(current_bearing + adjustment))
		adjustment = adjustment * -1

	adjust_bearing(current_bearing + adjustment)

	// Are we close enough -now-?
	if(within_bearing())
		set_state(TURRET_ENGAGING) // Immediately shoot if within tolerence.
		handle_engaging()

/obj/machinery/turret/proc/handle_engaging()
	if(!is_valid_target(target))
		lose_target()
		return

	target_bearing = get_target_angle(target)
	if(!within_bearing())
		set_state(TURRET_TURNING)
		return
	if(can_fire())
		fire(target)

/obj/machinery/turret/proc/get_power_cost_per_shot()
	// For ballistic turrets, we're gonna use energy for them anyways,
	// because having to manage ammo would be really tedious both ingame and code-wise.
	// Think of it as the turret having a mini-RCD for bullets or something.
	if(istype(installed_gun, /obj/item/weapon/gun/projectile))
		return 50 // TODO: Come up with a number for this and probably var it.
	else if(istype(installed_gun, /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/E = installed_gun
		return E.charge_cost
	return 0

/obj/machinery/turret/proc/can_fire()
	if(!can_act())
		return FALSE // Can't do anything.
	if(last_fired_time + installed_gun.fire_delay > world.time)
		return FALSE // Too soon to fire again.
	if(!internal_cell || !internal_cell.check_charge(get_power_cost_per_shot()))
		return FALSE // Battery's dry.
	return TRUE

/obj/machinery/turret/proc/can_act()
	if(turret_state in list(TURRET_OFF, TURRET_DEPOWERED))
		return FALSE
	if(stat & BROKEN)
		return FALSE
	return TRUE

/obj/machinery/turret/proc/fire(atom/A)
	var/obj/item/projectile/P = new installed_gun.projectile_type(loc)
	P.launch_projectile(A, null, null, null, current_bearing)
	
	last_fired_time = world.time

	var/firing_sound = installed_gun.fire_sound ? installed_gun.fire_sound : P.fire_sound
	if(firing_sound)
		playsound(src, firing_sound, 50, TRUE)
	
	visible_message(
		span("danger", "\The [src] shoots \a [P] at \the [A]!"),
		span("warning", "You hear a [installed_gun.fire_sound_text]!")
		)
	internal_cell.use(get_power_cost_per_shot())

/obj/machinery/turret/proc/within_bearing()
	var/distance_from_target_bearing = closer_angle_difference(current_bearing, target_bearing)
	if(abs(distance_from_target_bearing) <= bearing_tolerence)
		return TRUE
	return FALSE

// Instantly turns the turret to a specific absolute angle.
/obj/machinery/turret/proc/adjust_bearing(new_angle)
	current_bearing = SIMPLIFY_DEGREES(new_angle)
	adjust_rotation(current_bearing)

/obj/machinery/turret/proc/is_valid_target(atom/A, hostile_only = FALSE)
	// Fundemental checks for if something should be shot at, regardless of IFF settings.
	if(A == src) // Let's not shoot ourselves.
		return FALSE
	if(!can_see(src, A, vision_range)) // Perhaps someday we can add thermal turrets.
		return FALSE
	var/angle = get_target_angle(A)
	if(!angle_within_traverse(angle))
		return FALSE
	// Now for IFF stuff for the settings that can be changed or might be different based on inheritence.
	return check_IFF(A, hostile_only)

/obj/machinery/turret/proc/check_IFF(atom/A, hostile_only = FALSE)
	var/result = IFF.can_shoot(A)
	if(hostile_only)
		return result & (IFF_HOSTILE)
	return result & (IFF_HOSTILE|IFF_NEUTRAL)


/obj/machinery/turret/proc/set_target(atom/new_target)
	if(!is_valid_target(new_target))
		return
	target = new_target
	if(target)
		target_bearing = get_target_angle(new_target)
		set_state(TURRET_TURNING)
	else
		set_state(TURRET_IDLE)

/obj/machinery/turret/proc/lose_target()
	target = find_new_target()
	if(!target)
		set_state(TURRET_IDLE)
	else
		set_state(TURRET_TURNING)

/obj/machinery/turret/proc/calculate_turn_rate_per_process()
	return turning_rate / (1 SECOND / SSfastprocess.wait)

/obj/machinery/turret/proc/time_per_process()
	return speed_process ? SSfastprocess.wait : SSobj.wait

// Calculates the bearing to the target.
// If called multiple times when the target has not moved, it returns the previous value to avoid recalculating.
/obj/machinery/turret/proc/get_target_angle(atom/A)
//	if(!target_x || A.x != target_x || A.y != target_y)
//		target_x = A.x
//		target_y = A.y
//		world << "Getting new angle."
//		return Get_Angle(src, A)
//	world << "Returning cached angle."
//	return target_bearing
	return Get_Angle(src, A)

/obj/machinery/turret/update_icon()
	if(!turret_stand)
		turret_stand = image(icon, "turret_cover_normal")
		turret_stand.layer = src.layer - 0.01
		turret_stand.appearance_flags = KEEP_APART|RESET_TRANSFORM|TILE_BOUND|PIXEL_SCALE
		add_overlay(turret_stand)

	if(!turret_ray)
		turret_ray = image(icon, "turret_ray")
		turret_ray.plane = PLANE_LIGHTING_ABOVE // Should it go below lighting?
		turret_ray.appearance_flags = KEEP_APART|RESET_COLOR|TILE_BOUND|PIXEL_SCALE
		turret_ray.mouse_opacity = FALSE

		var/matrix/M = matrix(turret_ray.transform)
		// Offset away from the parent, so that when the parent rotates, this rotates with it correctly.
		M.Translate(0, (1 * WORLD_ICON_SIZE * 0.50)+4) // 20?
		world << (1 * WORLD_ICON_SIZE * 0.50)+4
		M.Scale(1, 4)

		turret_ray.transform = M
		add_overlay(turret_ray)
	else
		// Changes the ray color based on state.
		cut_overlay(turret_ray)
		var/new_color
		switch(turret_state)
			if(TURRET_OFF)
				new_color = "#00000000"
			if(TURRET_IDLE)
				new_color = "#00FF00FF"
			if(TURRET_TURNING)
				new_color = "#FFFF00FF"
			if(TURRET_ENGAGING)
				new_color = "#FF0000FF"

		turret_ray.color = new_color
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


// Sets up the observer pattern-based vision for the turrets.
// Only needs to be called once on init, and whenever the turret is moved or dir-changed.
// Using the observed turf method makes turrets be able to react to someone coming into vision instantly,
// and avoids needless `process()` calls.
/obj/machinery/turret/proc/build_vision_constallation()
	for(var/thing in RANGE_TURFS(vision_range, src))
		var/turf/T = thing
		var/angle_to_T = Get_Angle(src, T)
		if(!angle_within_traverse(angle_to_T))
			continue
		turf_observation_constallation += T
		turf_changed_event.register(T, src, .proc/on_watched_turf_changed)
		GLOB.turf_entered_event.register(T, src, .proc/on_watched_turf_entered)

// Called by event when a watched tile has something move into it.
/obj/machinery/turret/proc/on_watched_turf_entered(turf/T, atom/movable/AM, atom/old_loc)
//	world << "Watched turf \the [T] had \the [AM] entered from \the [old_loc]."
	if(IFF.can_shoot(AM) & IFF_HOSTILE)
		add_target(AM)

// Called by event when a watched tile is changed.
/obj/machinery/turret/proc/on_watched_turf_changed(turf/T, old_density, new_density, old_opacity, new_opacity)
	world << "Watched turf \the [T] had old density [old_density], new density [new_density], old opacity [old_opacity], new opacity [new_opacity]."

// Called by event when the turret is moved by some means.
/obj/machinery/turret/proc/on_moved(atom/movable/AM, old_loc, new_loc)
	if(old_loc != new_loc)
		setup_turret()

// Called by eventwhen the turret's dir is changed.
/obj/machinery/turret/proc/on_self_dir_changed(atom/movable/AM, old_dir, new_dir)
	if(old_dir != new_dir)
		setup_turret()


// Clears all tiles being watched.
// Called when the turret is being deleted, when it gets moved, or when dir changes, so the constallation can be rebuilt.
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
	if(!can_act())
		return
	if(target == A || (A in potential_targets))
		return
	if(!is_valid_target(A))
		return

	if(!target)
		set_target(A)
	else
		potential_targets += A

/obj/machinery/turret/proc/find_new_target()
	if(!potential_targets.len)
		return null
	while(potential_targets.len)
		var/atom/A = pick(potential_targets)
		potential_targets -= A
		if(!is_valid_target(A))
			continue
		return A
	return null

/obj/machinery/turret/proc/setup_turret()
	target_bearing = dir2angle(dir)
	adjust_bearing(target_bearing)
	calculate_traverse()
	rebuild_vision_constallation()

/obj/machinery/turret/proc/turn_on()
	if(turret_state != TURRET_OFF)
		return
	set_state(TURRET_IDLE)

/obj/machinery/turret/proc/turn_off()
	if(turret_state == TURRET_OFF)
		return
	set_state(TURRET_OFF)

/obj/machinery/turret/attack_hand(mob/user)
	if(stat & BROKEN)
		return
	tgui_interact(user)

// TGUI code.
/obj/machinery/turret/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Turret", name, 300, 250, master_ui, state)
		ui.open()

/obj/machinery/turret/tgui_data(mob/user)
	var/list/data = list()
	data["isOn"] = turret_state != TURRET_OFF
	data["cellChargePercent"] = internal_cell ? internal_cell.percent() : 0
	data["weaponName"] = installed_gun.name

	var/list/firemode_strings = list()
	for(var/thing in installed_gun.firemodes)
		var/datum/firemode/F = thing
		firemode_strings += F.name
	
	data["weaponModes"] = firemode_strings

	return data

/obj/machinery/turret/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return
	
	if(stat & BROKEN)
		return

	switch(action)
		if("turnOn")
			turn_on()
		if("turnOff")
			turn_off()


	return TRUE
