// These files represent mysterious abstract system things.
// The most useful to us is being able to use these to pass TTYs as files so the output goes to the right place.

/datum/file/device
	file_type = "device"

// A "file" which holds our session state, like the current directory or where to send the output to. It also passes I/O to the user, even if they're a remote one.
// This is a file both for semi-realism and also makes it easier for executables to output without having to care what will receive the data.
/datum/file/device/tty
	name = "tty1" // Gets incrimented if tty1 already exists, to tty2, and so on.

	var/username = "todo"
	var/is_superuser = FALSE
	var/datum/nano_os/system = null						// The system we are attached to.
	var/datum/file/device/tty/remote_session = null		// The remote tty we are sending and receiving data from, if any.
	var/datum/file/directory/current_directory = null	// Directory we are currently inside of, IE the result of "." .

// TTYs utilizing remote connections actually go through two terminals.
// It generally goes;
// User <-> [Local Terminal] <-> (EPv2) <-> [Remote Terminal] <-> Remote Machine
// E.g. User sends a command into their local terminal. The local terminal is in a remote session with the remote machine, so
// the local terminal sends the command over the EPv2 network. If everything went well, the remote terminal receives the command,
// then executes it on the remote machine. If the command had any output (stdout/stderr), the process repeats in reverse.

/datum/file/device/tty/New(datum/nano_os/new_system)
	ASSERT(new_system)
	system = new_system
	if(system.filesystem)
		// Todo: Switch to home directory if it exists first.
		// For now just dump us at root directory.
		current_directory = system.filesystem.file_tree[1] // More todo: Implement internal cd call.

// Input function used by both local and remote terminals.
// Note that this runs after everything else.
/datum/file/device/tty/stdin(input, datum/file/target)
	// Todo: Make this happen after file system is working.

	// Split the input into chunks, as there might be ";" characters, denoting seperate statements.

	// For each statement, evaluate them.
	// The first word in the statement will get compared to fake executable file names inside /bin
	// If a match is found, that fake executable is ran, with the other words in front being placed inside that file's stdin().

	// Testing, later on should use fake executables inside /bin .
	var/list/words = splittext(input, " ")
	world << "words is now [english_list(words)]."
	switch(words[1])
		if("cd")
			words -= words[1]
			world << "words is now [english_list(words)]."
			system.filesystem.change_directory(words.Join(" "), src)
			return TRUE
		if("mkdir")
			words -= words[1]
			system.filesystem.make_directory(words.Join(" "), src)
			return TRUE
	//	else
	//		stderr("[input]: command not found")
	/*
	var/test = system.filesystem.resolve_path(input, src, 0)
	if(test)
		stdout("Found [test].")
		return TRUE
	*/
	// If we get to this point, we don't know what to do, so tell the user that.
	//stderr("[input]: command not found")
	return FALSE


// Represents a local terminal (from the machine's PoV). May or may not have a session with a remote terminal.
// stdin is generally from the user directly, and stdout/stderr will usually be displayed to the user.
// stdin is redirected to the remote terminal on another machine if remote_session exists.
/datum/file/device/tty/local

/datum/file/device/tty/local/stdin(input, datum/file/target)
	var/echo = "[username]@[system.name]:[current_directory.get_filepath()][is_superuser ? "#":"$"] [input]"
	stdout(echo)

	// If we're remotely connected to another machine, send ALL input to them.
	if(remote_session)
		return remote_session.stdin(input, target) // Todo: EPv2 networking

	// Otherwise we are doing things on our own machine.
	return ..(input, target)

/datum/file/device/tty/local/stdout(output) // WIP, will need UI later.
	system.holder.visible_message(output)

/datum/file/device/tty/local/stderr(error_output) // WIP, will need UI later.
	system.holder.visible_message(error_output)

// Represents an external (from the machine's PoV) terminal, which is directly connected to a local tty on the other machine.
// stdout/stderr is redirected to the user's local terminal, generally to display it.
/datum/file/device/tty/remote

/datum/file/device/tty/remote/stdout(output)
	if(remote_session)
		return remote_session.stdout(output)  // Todo: EPv2 networking
	qdel(src) // If their local tty doesn't exist than we have no point existing.

/datum/file/device/tty/remote/stderr(error_output)
	if(remote_session)
		return remote_session.stderr(error_output)  // Todo: EPv2 networking
	qdel(src)