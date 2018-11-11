// Thrusters are required on all shuttles utilizing the new component system.
// They provide a linear amount of "thrust" to their ship.
// Thrusters are required on all shuttles in order to move, or to stay in the air when in an atmosphere
// More thrusters equals more speed, however generally a shuttle already has the maximum amount of thrusters attached
// to their mount points, therefore, better thrusters are needed for increased speed.

// A minor fault will make the thruster work less hard than it otherwise could.
// A major fault will make the thruster barely work at all, or fail entirely.
// If all thrusters fail or otherwise reach a low enough threshold to be unable to support the shuttle, it may crash, if in a gravity well.
// A critical fault will make the thruster permanently nonfunctional.

/obj/structure/shuttle_component/thruster
	name = "thruster"
	desc = "Point away from face."
	icon_state = "thruster"
	max_integrity = 100
	resilience = 10
	active_overlay = "thruster_overlay_active"
	operable_overlay = "thuster_overlay_default"
	var/thrust_power = 0	// Measured in AUD, or Arbitrary Unit of Distance.
	var/efficiency = 0.1		// Thrusters can be more or less efficent with their power consumption. Generally the faster thrusters are more wasteful.


// The default thrusters for the station's two shuttles.
/obj/structure/shuttle_component/thruster/default
	name = "standard thruster"
	desc = "A commonly seen type of thruster typically mounted onto small civilian craft."
	thrust_power = 25 // The crew shuttles have four thrusters, equaling 100, which is a nice easy baseline number.
	efficiency = 0.7

// Pretty awful all around, but is cheap to buy from Cargo.
// Should only ever be used if thrusters fail and nothing else can be afforded.
/obj/structure/shuttle_component/thruster/cheap
	name = "obsolute thruster"
	desc = "These thrusters are abyssmal, their only saving grace is that they are generally inexpensive to obtain. \
	They have other costs associated with their use, however..."
	thrust_power = 10
	efficiency = 0.5
	max_integrity = 50
	resilience = 0

/obj/structure/shuttle_component/thruster/durable
	name = "hardened thruster"
	desc = "A thruster explicitly designed to be tough and dependable. It's not as performant as the others, \
	however it is very reliable and can withstand a lot of abuse, which can be desirable in some situations."
	thrust_power = 20
	efficiency = 0.6
	max_integrity = 200
	resilience = 40
	reliable = TRUE

// 90% efficent, which is very good and only has a -5 power hit.
// Might be good for far away away mission flights.
/obj/structure/shuttle_component/thruster/efficent
	name = "optimized thruster"
	desc = "This model is more efficent than the standard model, only suffering a small amount of decreased output. \
	Useful for long-haul in-system flights."
	thrust_power = 20
	efficiency = 0.9

// For when you got to go fast.
/obj/structure/shuttle_component/thruster/overclocked
	name = "overclocked thruster"
	desc = "This thruster adopts the 'MORE POWER' method of achieving massive amounts of thrust. \
	It certainly works for this model, however it also consumes massive amounts of power, and will \
	require much more maintenance."
	operable_overlay = "thuster_overlay_overclocked"
	thrust_power = 45
	efficiency = 0.4
	max_integrity = 40
	resilience = 0

// For when you got to go super fast a few times.
// For best results, turn it off until you actually need it, like to escape an encounter.
/obj/structure/shuttle_component/thruster/afterburner
	name = "afterburner"
	desc = "Instead of a traditional thruster, this model is not intended to be permanent. \
	It provides extreme amounts of thrust on demand, however it will not last very long while active, and cannot be repaired."
	active = FALSE // Start disabled to avoid accidentally ruining the engine for nothing.
	can_be_repaired = FALSE
	thrust_power = 150
	max_integrity = 50
	efficiency = 0.9
	resilience = 0
	attrition_amount = 20


/obj/structure/shuttle_component/thruster/proc/get_thrust_power()
	if(fault == SHUTTLE_FAULT_CRITICAL)
		return 0 // Complete failure.

	var/modified_fault_level = fault
	if(reliable)
		modified_fault_level -= 1

	switch(modified_fault_level)
		if(SHUTTLE_FAULT_NONE)
			return thrust_power // Always at full power.
		if(SHUTTLE_FAULT_MINOR)
			return thrust_power * min(integrity/max_integrity, 0.75) // Capped to 75% power, lowered with integrity.
		if(SHUTTLE_FAULT_MAJOR)
			return thrust_power * min( (integrity/max_integrity) - 0.30 , 0.50) // Capped to 50% power, lowered with integrity, and fails at 30 integrity.