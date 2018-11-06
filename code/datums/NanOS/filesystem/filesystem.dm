/* This is the filesystem for NanOS machines.

The system hierarchy is very similar to the Unix one, however it is a lot smaller due to this still being a game.
Generally systems will be layed out like this;
	/						- Root directory, all others descend from this one.
		/bin				- Contains executable files that can be called anywhere in the terminal and not the current directory.
		/boot				- Contains snowflake files that do nothing but the machine will fail if removed and rebooted.
		/dev				- Device files that are spooky.
			/dev/null		- Eats everything piped inside of it.
		/etc				- Contains settings for the system, like if remote connections are allowed.
			/etc/sudoers	- File containing a list of users allowed to use the sudo command, allowing them privilage escalation.
		/home				- Contains personal directories for each user.
			/home/[user]	- Specific directory for the user. ~ is an alias for the current user's home directory.
		/var				- Contains 'variable' information like logs.
			/var/logs		- Logs of the system. Note that it is impossible to completely remove logs as deleting files makes a log...
			/var/mail		- Messages for other users, however most likely will only be used to see who tried running sudo w/o access.

*/


// The object which holds directories, which in turn hold files or more directories.
/datum/filesystem
	var/list/file_tree = list()
	var/datum/file/directory/root_directory = null


// Tries to return the file object corrisponding to a fake path.
// E.g. "/var/log/log.txt" will hopefully return that data file if it exists.
/datum/filesystem/proc/resolve_path(filepath_to_find, datum/file/device/tty/terminal,  steps_to_skip = 0)
	ASSERT(istext(filepath_to_find))
//	world << "Going to substitute [filepath_to_find]."
	filepath_to_find = substitute_tilde(filepath_to_find, terminal)
//	world << "Substituted, now it is [filepath_to_find]."

	var/is_absolute_path = findtext(filepath_to_find, "/", 1, 2)
	var/datum/file/directory/starting_point = null		// Where we start the search from. Can be from current directory or from the root one.
	var/datum/file/directory/current_position = null	// Where we currently are. We give up immediately if asked to go to a nonexistant directory.
	var/datum/file/found_file = null					// The file we found, if it exists.

	if(is_absolute_path)
		starting_point = root_directory
//		world << "Was absolute path."
	else
		starting_point = terminal.current_directory
//		world << "Was relative path."

	current_position = starting_point
//	world << "Current starting point is [starting_point.name]."

	var/list/steps = splittext(filepath_to_find, "/")
//	world << "Made a list of steps [steps.len] long. ([english_list(steps)])."

	if(steps_to_skip) // Sometimes we don't want the exact path, but a directory below it.
		if(steps.len <= steps_to_skip)
			steps.Cut()
		else
			steps.Cut(steps.len - steps_to_skip)

	for(var/S in steps)
		if(!S)
			continue // Empty string.

		if(!istype(current_position)) // We found a regular file and we're not the last step.
			terminal.stderr("[filepath_to_find]: No such file or directory")
//			world << "Regular file was found and was not last."
			return null

		if(S == ".") // Means 'this directory'.
//			world << "Dot operator, skipping."
			continue

		if(S == "..") // Means 'go up one directory'.
			if(current_position.parent)
				current_position = current_position.parent
//				world << "Moved up tree to [current_position.name]."
			else
//				world << "At root, skipping."
				continue // .. at root directory technically changes it to itself in real Unix but faster to just ignore it here.

		// Otherwise look for a match.
		var/datum/file/F = current_position.contents["[S]"]
		if(!istype(F))
//			world << "File or directory does not exist."
			terminal.stderr("[filepath_to_find]: No such file or directory")
			return null

		current_position = F
		found_file = F
//		world << "Found file or directory [F.name]."

//	world << "Final result: [current_position]."
	return found_file


/datum/filesystem/proc/change_directory(new_path, datum/file/device/tty/terminal)
	var/datum/file/directory/new_directory = resolve_path(new_path, terminal, 0)
	if(istype(new_directory))
		world << "Found new directory."
		terminal.current_directory = new_directory

/datum/filesystem/proc/make_directory(filepath, datum/file/device/tty/terminal)
	var/datum/file/directory/D = resolve_path(filepath, terminal, 1)
	if(istype(D))
		// Now get the name, which is at the very end of the path.
		var/list/split_filepath = splittext(filepath, "/")
		var/new_directory_name = split_filepath[split_filepath.len] // Very end of the list.
		if(D.contents[new_directory_name])
			terminal.stderr("File or directory already exists")
			return FALSE
		D.contents[new_directory_name] = new /datum/file/directory(new_directory_name, D)


// Replaces ~ with the path to user's home directory (assuming one exists).
/datum/filesystem/proc/substitute_tilde(filepath, datum/file/device/tty/terminal)
	var/home_directory_guess = "/home/[terminal.username]"
	filepath = replacetext(filepath, "~", home_directory_guess)
	return filepath


// Todo: Make better using make_directory() calls.
/datum/filesystem/full/New()
	var/new_root = new /datum/file/directory/root("/", null)
	file_tree = list(new_root)
	root_directory = new_root