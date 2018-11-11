// Web shuttles can have components attached to it that influence the capabilities of the shuttle.

// This is the base type
/obj/structure/shuttle_component
	name = "shuttle component"
	desc = "It doesn't seem to do anything."
	icon = 'icons/obj/shuttle_parts.dmi'
	density = TRUE
	anchored = FALSE // Will be true if attached to a mount point. initialize() will attach itself to one automatically if it exists.

	var/active_overlay = null // Shown when the comonent is toggled active.
	var/operable_overlay = null // Shown while the thruster remains operable.

	var/active = TRUE				// Components can be toggled on or off. If turned off, the component obviously won't work.
	var/always_active = FALSE		// If true, the component cannot be turned off, except by unmounting. Intended for non-electronic things like hull augments.

	var/can_take_damage = TRUE
	var/integrity = null			// The 'health' of a component. Bad things can happen if components are damaged, such as faults. Set to max on init if null.
	var/max_integrity = 100			// The 'max health' of a component.
	var/attrition_amount = 1		// How much attrition to give to a component.
	var/attrition_modifier = 1.0	// Some components receive less attrition than other similar kinds in its type.
	var/resilience = 0				// Resilience gives a chance for the component to resist attrition-based damage.
	var/can_be_repaired = TRUE		// If false, any damage accumulated is permanent. Treat with care.
	var/reliable = FALSE			// If true, faults are one level weaker than they actually are. Critical faults will still permanently break the component.
	var/disposable = FALSE			// 'Disposable' components generally always receive damage when used, cannot be repaired, but cannot suffer faults.

	var/fault = SHUTTLE_FAULT_NONE	// Components with a fault will have various problems. All non-critical faults can be repaired. Critical failure requires a replacement.

	var/obj/structure/shuttle_mount_point/mount_point // The object this is "attached" to. It exists as a physical object on the actual shuttle.
	var/mount_delay = 10 SECONDS // How long it takes to un/mount a component. Userless un/mounting is instant.

	var/datum/effect/effect/system/spark_spread/sparks = null

/obj/structure/shuttle_component/initialize()
	mount()
	if(isnull(integrity))
		integrity = max_integrity
	sparks = new()
	sparks.set_up(5, 0, src)
	sparks.attach(src)
	return ..()

/obj/structure/shuttle_component/Destroy()
	unmount()
	qdel(sparks)
	return ..()

/obj/structure/shuttle_component/update_icon()
	cut_overlays()
	if(operable_overlay && operable())
		add_overlay(operable_overlay)
	if(active_overlay && active)
		add_overlay(active_overlay)

/obj/structure/shuttle_component/ex_act(severity)
	adjust_integrity(max_integrity / severity)
	sparks.start()

/obj/structure/shuttle_component/proc/operable()
	if(!mount_point)
		return FALSE
	if(!active)
		return FALSE
	if(integrity <= 0)
		return FALSE
	if(fault >= SHUTTLE_FAULT_CRITICAL)
		return FALSE
	return TRUE

// Attaches the component to a suitable shuttle_mount_point.
/obj/structure/shuttle_component/proc/mount(obj/item/I, mob/living/user)
	if(mount_point) // Already mounted.
		to_chat(user, span("warning", "\The [src] is already mounted onto \the [mount_point]."))
		return FALSE

	var/obj/structure/shuttle_mount_point/M = locate() in loc
	if(!M)
		to_chat(user, span("warning", "There is no mount point below to attach \the [src] to."))
		return FALSE

	if(M.attached_component)
		to_chat(user, span("warning", "\The [M] already has \the [M.attached_component] mounted onto it."))
		return FALSE

	if(!istype(src, M.allowed_component_type))
		to_chat(user, span("warning", "\The [src] is not designed to mount onto \the [M]."))
		return FALSE

	if(user && I)
		to_chat(user, span("notice", "You begin the process of attaching \the [src] to \the [mount_point]..."))
		playsound(src, I.usesound, 75, 1)
		if(!do_after(user, mount_delay * I.toolspeed, src))
			to_chat(user, span("warning", "You stop mounting \the [src] to \the [mount_point]."))
			return FALSE

	M.attached_component = src
	mount_point = M
	anchored = TRUE
	set_dir(M.dir)
	update_icon()

	if(I)
		playsound(src, I.usesound, 75, 1)

	to_chat(user, span("notice", "\The [src] is mounted onto \the [M]."))
	return TRUE

// Detaches the component from its shuttle_mount_point.
/obj/structure/shuttle_component/proc/unmount(obj/item/I, mob/living/user)
	if(!mount_point) // Already mounted.
		to_chat(user, span("warning", "\The [src] is not mounted onto anything."))
		return FALSE

	if(user && I)
		to_chat(user, span("notice", "You begin the process of detaching \the [src] from \the [mount_point]..."))
		playsound(src, I.usesound, 75, 1)
		if(!do_after(user, mount_delay * I.toolspeed, src))
			to_chat(user, span("warning", "You stop unmounting \the [src] from \the [mount_point]."))
			return FALSE

	to_chat(user, span("notice", "\The [src] is unmounted from \the [mount_point]."))

	mount_point.attached_component = null
	mount_point = null
	anchored = FALSE
	update_icon()

	if(I)
		playsound(src, I.usesound, 75, 1)

	return TRUE

// Used to damage or repair a component.
// Damage has a chance to cause a fault, which is repaired seperately.
/obj/structure/shuttle_component/proc/adjust_integrity(amount)
	if(fault == SHUTTLE_FAULT_CRITICAL) // It's ruined.
		return

	if(amount < 0) // Being damaged.
		integrity = max(0, integrity + amount)

		// Determine if this componet is at risk of receiving a fault.
		if(!disposable && (integrity / max_integrity) < 0.8) // Components over 80% integrity, or that are designed to disintegrate when used, will not receive a fault.
			var/percentage_lost = amount / max_integrity
			var/missing_integrity = abs(integrity - max_integrity)
			var/fault_risk = 0

			// Receiving a large spike of damage can induce a fault.
			// This is likely to come from encounters that end badly.
			if(percentage_lost > 0.2)
				fault_risk += percentage_lost * 100

			// Already being damaged increases the odds of something going wrong.
			// This is usually from attrition.
			fault_risk += (missing_integrity / max_integrity) * amount

			// Inactive components are less likely to receive faults (but they still take the integrity hit).
			if(!active)
				fault_risk /= 3

			if(prob(fault_risk))
				suffer_fault(1)

	else // Being repaired.
		integrity = min(integrity + amount, max_integrity)

// Called periodically to slowly wear away at components.
/obj/structure/shuttle_component/proc/receive_attrition(external_modifier)
	if(!active) // Inactive components didn't do any work so they don't get attrition.
		return
	if(prob(resilience))
		return

	var/damage = attrition_amount * attrition_modifier * external_modifier
	adjust_integrity(-damage)

// Causes the component to suffer a fault, or worsen to a more severe fault.
/obj/structure/shuttle_component/proc/suffer_fault(amount)
	if(fault < SHUTTLE_FAULT_CRITICAL)
		fault = min(fault + amount, SHUTTLE_FAULT_CRITICAL)
		sparks.start()
		on_fault(fault)

		if(fault == SHUTTLE_FAULT_CRITICAL)
			integrity = 0
			update_icon()

// Repairs a fault. Severe faults may require multiple rounds of repair.
/obj/structure/shuttle_component/proc/repair_fault(amount)
	if(fault >= SHUTTLE_FAULT_CRITICAL)
		return
	fault = max(fault - amount, SHUTTLE_FAULT_NONE)

/obj/structure/shuttle_component/proc/on_fault(fault_level)
	return // Todo: Warn pilot when this happens.


/obj/structure/shuttle_component/attackby(obj/item/I, mob/user)
	if(I.is_wrench())
		if(mount_point)
			return unmount(I, user)
		else
			return mount(I, user)

	// Todo: Repair interactions here.

	return ..()
