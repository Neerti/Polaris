/* This is the filesystem for NanOS machines.

The system hierarchy is very similar to the Unix one, however it is a lot smaller due to this still being a game.
Generally systems will be layed out like this;
	/						- Root directory, all others descend from this one.
		/bin				- Contains executable files that can be called anywhere in the terminal and not the current directory.
		/boot				- Contains snowflake files that do nothing but the machine will fail if removed and rebooted.
		/dev				- Device files that are spooky.
			/dev/null		- Eats everything piped inside of it.
		/etc				- Contains settings for the system, like if remote connections are allowed.
			/etc/sudoers	- File containing a list of users allowed to use the sudo command.
		/home				- Contains personal directories for each user.
			/home/[user]	- Specific directory for the user. ~ is an alias for the current user's home directory.
		/var				- Contains 'variable' information like logs.
			/var/logs		- Logs of the system. Note that it is impossible to completely remove logs as deleting files makes a log...
			/var/mail		- Messages for other users, however most likely will only be used to see who tried running sudo w/o access.

*/


// The object which holds directories, which in turn hold files or more directories.
/datum/filesystem
	var/list/file_tree = list()


// Tries to return the file object corrisponding to a fake path.
// E.g. "/var/log/log.txt" will hopefully return that data file if it exists.
/datum/filesystem/proc/resolve_path(path_to_find)
	// Todo: Look for ~ and go to current user's home.

	// Todo: . and ..



/datum/filesystem/proc/make_directory(new_name, new_path)
	if(!new_name || new_path)
		return FALSE


	return TRUE




/datum/filesystem/full/New()
	file_tree = list(new /datum/file/directory/root("/", null))