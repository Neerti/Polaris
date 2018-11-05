// A reference to a specific file.
// As it is a weakref, it is possible for the file to get deleted and for this to go nowhere.
// This just so happens to also be true with real Unix symlinks.

/datum/file/symbolic_link
	file_type = "symbolic link"
	var/datum/weakref/linked = null	// Weakref to the file we are linked to.

/datum/file/symbolic_link/stdin(input)
	var/datum/file/real_file = linked.resolve()
	if(istype(real_file))
		return linked.stdin(input)
	return FALSE

/datum/file/symbolic_link/New(new_name, /datum/file/to_link)
	linked = weakref(to_link)
	..()

/datum/file/symbolic_link/Destroy()
	linked = null
	return ..()