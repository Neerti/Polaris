#define REMOTE_ALLOW	"allow"		// Allows the "packet" to arrive to the machine.
#define REMOTE_REJECT	"reject"	// Does not allow the "packet", and tells the sender that it was rejected.
#define REMOTE_DROP		"drop"		// Same as above but the sender is not informed if it ever reached them.

/*
NanOS is a fake in-game CLI Operating System that superficially resembles some kind of Unix system.

This is the main object that contains the other components needed for a functional system.
Components held inside this container include,
	Accounts with username/password pairs,
	Filesystem,
	Receiving input from external source and passing it to stdin,
	Displaying output from stdout/stderr,
	TTYs, local and remote,

Some notes about this system:
	For most types, the system is not instantiated until a player tries to interact with something involving the fake OS.
	Commands are actually files held in the /bin folder. Deleting these files can wreck your system.

*/

/datum/nano_os
	var/name = "system"						// Name displayed in terminal when connected locally/remotely.
	var/atom/movable/holder = null			// Whatever our physical object is supposed to be. It's AM so borgs/AIs can have this.
	var/datum/filesystem/filesystem = null	// Object which holds the files and their directories.

	// Settings.
	var/ping_response = REMOTE_ALLOW // If the machine should respond to pings.