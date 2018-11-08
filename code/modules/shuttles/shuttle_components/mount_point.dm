// Components are 'attached' to special points on the shuttle physically.
// Components can generally be attached and detached by using a wrench on the component itself.
// The shuttle datum uses these to access the actual components and their stats, as well.

/obj/structure/shuttle_mount_point
	name = "mount point"
	desc = "Components for a vessel are mounted onto this."
	icon = 'icons/obj/shuttle_parts.dmi'
	icon_state = "mount_point"
	plane = OBJ_PLANE
	layer = UNDER_JUNK_LAYER // Below the regular stuff, especially our components.
	var/obj/structure/shuttle_component/attached_component = null
	var/allowed_component_type = null // Only this type of component can be attached.

/obj/structure/shuttle_mount_point/Destroy()
	if(attached_component)
		attached_component.unmount()
	return ..()

// The mount points themselves should be indestructable.
/obj/structure/shuttle_mount_point/ex_act()
	return

/obj/structure/shuttle_mount_point/thruster
	name = "thruster mount point"
	desc = "A thruster for a vessel can be mounted onto this."
	allowed_component_type = /obj/structure/shuttle_component/thruster

/obj/structure/shuttle_mount_point/initialize()
	// Add ourselves to the web shuttle datum's mount point list.
	// Unfortunately this requires a stupid way.
	var/area/my_area = get_area(src)
	if(!my_area) // Spawned in null space or something.
		return INITIALIZE_HINT_QDEL

	// Check literally every shuttle to see one is the one we want.
	for(var/i in SSshuttles.shuttles)
		var/datum/shuttle/S = SSshuttles.shuttles[i]
		if(istype(S, /datum/shuttle/web_shuttle))
			var/datum/shuttle/web_shuttle/WS = S
			if(WS.current_area == my_area) // If the shuttle's in our area then this is what we want.
				WS.mount_points += src
				break

	return ..()

/obj/structure/shuttle_mount_point/Destroy()
	// Like the above, we need to use a stupid way of removing our reference from the shuttle datum.
	for(var/i in SSshuttles.shuttles)
		var/datum/shuttle/S = SSshuttles.shuttles[i]
		if(istype(S, /datum/shuttle/web_shuttle))
			var/datum/shuttle/web_shuttle/WS = S
			WS.mount_points -= src

	return ..()