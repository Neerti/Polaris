// Web shuttles can have components attached to it that influence the capabilities of the shuttle.

// This is the base type
/obj/structure/shuttle_component
	name = "shuttle component"
	desc = "It doesn't seem to do anything."
	icon = 'icons/obj/shuttle_parts.dmi'
	density = TRUE
	anchored = FALSE // Will be true if attached to a mount point. initialize() will attach itself to one automatically if it exists.

	var/active = TRUE				// Components can be toggled on or off. If turned off, the component obviously won't work.

	var/can_take_damage = TRUE
	var/integrity = null			// The 'health' of a component. Bad things can happen if components are damaged, such as faults. Set to max on init if null.
	var/max_integrity = 100			// The 'max health' of a component.
	var/attrition_amount = 1		// How much attrition to give to a component.
	var/attrition_modifier = 1.0	// Some components receive less attrition than other similar kinds in its type.
	var/resilience = 0				// Resilience gives a chance for the component to resist attrition-based damage.
	var/can_be_repaired = TRUE		// If false, any damage accumulated is permanent. Treat with care.
	var/reliable = FALSE			// If true, faults are one level weaker than they actually are. Critical faults will still permanently break the component.

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

	if(I)
		playsound(src, I.usesound, 75, 1)

	return TRUE

/obj/structure/shuttle_component/attackby(obj/item/I, mob/user)
	if(I.is_wrench())
		if(mount_point)
			return unmount(I, user)
		else
			return mount(I, user)

	// Todo: Repair interactions here.

	return ..()
