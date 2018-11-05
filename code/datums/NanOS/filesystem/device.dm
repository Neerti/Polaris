// These files represent abstract system devices.
// The most useful to us is being able to use these to pass TTYs as files so the output goes to the right place.

/datum/file/device
	file_type = "device"

// A "file" which holds our session state, like the current directory or the output to display. It also passes I/O to the user, even if they're a remote one.
// This is a file both for semi-realism and also makes it easier for executables to output without having to care what will receive the data.
/datum/file/device/tty
	name = "tty1" // Gets incrimented if tty1 already exists, to tty2, and so on.
	var/datum/nano_os/system = null						// The system we are attached to.
	var/datum/file/device/tty/remote_session = null		// The remote tty we are sending and receiving data from, if any.
	var/datum/file/directory/current_directory = null	// Directory we are currently inside of, IE the result of "." .

// TTYs utilizing remote connections actually go through two terminals.
// It generally goes;
// User <-> [Local Terminal] <-> (EPv2) <-> [Remote Terminal] <-> Remote Machine
// E.g. User sends a command into their local terminal. The local terminal is in a remote session with the remote machine, so
// the local terminal sends the command over the EPv2 network. If everything went well, the remote terminal receives the command,
// then executes it on the remote machine. If the command had any output (stdout/stderr), the process repeats in reverse.


// Represents a local terminal (from the machine's PoV). May or may not have a session with a remote terminal.
// stdin is generally from the user directly, and stdout/stderr will usually be displayed to the user.
// stdin is redirected to the remote terminal on another machine if remote_session exists.
/datum/file/device/tty/local

/datum/file/device/tty/local/stdin(input)
	if(remote_session)
		return remote_session.stdin(input) // Todo: EPv2 networking
	return ..(input)

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