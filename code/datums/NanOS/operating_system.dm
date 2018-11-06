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

/atom/movable
	var/datum/nano_os/OS = null

/datum/nano_os
	var/name = "system"						// Name displayed in terminal when connected locally/remotely.
	var/atom/movable/holder = null			// Whatever our physical object is supposed to be. It's AM so borgs/AIs can have this.
	var/datum/filesystem/filesystem = null	// Object which holds the files and their directories.
	var/filesystem_type = /datum/filesystem/full

	// Sessions.
	var/datum/file/device/tty/local/active_local_session = null	// Locally, only one user can be 'active', due to only one keyboard/screen/etc existing at a time.

	// Settings.
	var/ping_response = REMOTE_ALLOW // If the machine should respond to pings.
	var/banner = "" // Message displayed when someone tries to connect to the machine, before being prompted for a username/password.
	var/motd = "" // Message displayed when successfully logging in.

/datum/nano_os/New(atom/movable/new_holder)
	ASSERT(new_holder)
	holder = new_holder
	if(filesystem_type)
		filesystem = new filesystem_type()

/datum/nano_os/proc/greet_user(datum/file/device/tty/terminal)
	if(motd)
		terminal.stdout(motd)


/datum/nano_os/proc/start_new_local_session() // Todo: Login/account stuff.
	active_local_session = new(src)
	greet_user(active_local_session)

// Test stuff. Yell at Neerti if it gets in live.

/obj/nano_os_tester
	name = "OS Tester"
	desc = "This is not the final product!"
	icon = 'icons/obj/computer3.dmi'
	icon_state = "serverframe"

/obj/nano_os_tester/initialize()
	OS = new(src)
	return ..()

/obj/nano_os_tester/Destroy()
	QDEL_NULL(OS)
	return ..()

/obj/nano_os_tester/attack_hand(mob/living/user)
	if(OS)
		var/I = input(user, "Enter a command.", "Prompt") as null|text
		if(I)
			if(!OS.active_local_session)
				OS.start_new_local_session()
			OS.active_local_session.stdin(I, OS.active_local_session)
