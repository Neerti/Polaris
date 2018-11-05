// Directories, which hold files and other directories.

/datum/file/directory
	file_type = "directory"
	var/datum/file/directory/parent = null	// Parent directory, if one exists. All directories except for / will have one.
	var/list/contents = list()				// The contents of the directory.

/datum/file/directory/New(new_name, /datum/file/directory/parent/new_parrent)
	if(new_parent)
		parent = new_parent
	..()

// Deleting a directory deletes its contents.
/datum/file/directory/Destory()
	for(var/datum/file/F in contents)
		qdel(F)
	return ..()

// Todo: Make better.
/datum/file/directory/root/New()
	contents = list(
		new /datum/file/directory("bin", src),
		new /datum/file/directory("boot", src),
		new /datum/file/directory("home", src),
		new /datum/file/directory("boot", src),
		new /datum/file/directory("var", src),
		)