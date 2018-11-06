// Directories, which hold files and other directories.

/datum/file/directory
	file_type = "directory"
	var/list/contents = list()				// The contents of the directory, using 'contents["directory_name"] = instance'

/datum/file/directory/New(new_name, datum/file/directory/new_parent)
	if(new_parent)
		parent = new_parent
	..()

// Deleting a directory deletes its contents.
/datum/file/directory/Destroy()
	for(var/datum/file/F in contents)
		qdel(F)
	return ..()


// Todo: Make better.
/datum/file/directory/root/New()
	contents["bin/"] = new /datum/file/directory("bin/", src)
	contents["boot/"] = new /datum/file/directory("boot/", src)
	contents["dev/"] = new /datum/file/directory("dev/", src)
	contents["etc/"] = new /datum/file/directory("etc/", src)
	contents["home/"] = new /datum/file/directory("home/", src)
	contents["var/"] = new /datum/file/directory("var/", src)
	..()
