// A defining feature of Unix is that 'everything is a file', so to help replicate that, a lot of things are gonna inherit from this.
// This includes regular text files, directories, executables, devices, symbolic links, etc.

// Base file type, probably shouldn't be used directly.
/datum/file
	var/name = "fix me"		// Name of the file displayed.
	var/file_type = "error"	// Type shown when 'stat' command is used.
	var/desc = "error"		// More in-depth description of what kind of file this is.
	var/owner = "root"		// What account owns the file. Defaults to the root account, which always exists.

/datum/file/New(new_name)
	name = new_name

// The input received, generally from the user, but may also be a file's contents, or maybe even another program's output, utilizing pipes.
/datum/file/proc/stdin(input)
	return

// The output, generally sent to the fake tty, however sometimes it is redirected to other programs or written to a file.
/datum/file/proc/stdout(output)
	return

// Another form of output, that is used if something goes wrong (ICly), and like the above it usually goes to the tty, but can go elsewhere.
/datum/file/proc/stderr(error_output)
	return
