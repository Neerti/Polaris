#define EXONET_SESSION_USER		"user"
#define EXONET_SESSION_ADMIN	"admin"

// This is a hopefully simple way to handle a stateful session between two Exonet machines.
// Note that a session is unidirectional, but exonet datums can have an arbitrary number of sessions.
/datum/exonet_session
	var/datum/exonet_protocol/us = null // Us
	var/datum/exonet_protocol/them = null // Them
	var/privilage = EXONET_SESSION_USER

/datum/exonet_session/New(var/datum/exonet_protocol/new_us, var/datum/exonet_protocol/new_them)
	if(!new_us || !new_them)
		CRASH("Error: /datum/exonet_session/New() failed to receive both inputs.")
	us = new_us
	them = new_them

	us.current_sessions.Add(src)
	them.current_sessions.Add(src)

/datum/exonet_session/Destroy()
	us.current_sessions.Remove(src)
	them.current_sessions.Remove(src)
	..()

// Exonet Protocol Defines
/datum/exonet_protocol
	var/list/accounts = list(EXONET_SESSION_USER = null) // Assoc list.  Format is username = password.
//	var/password = null // Used to restrict certain actions over the Exonet if unauthenticated.
	var/list/current_sessions = list()
	var/datum/exonet_session/current_session = null

/datum/exonet_protocol/unary // Subtype that only allows one outgoing session at a time.

// Exonet Protocol Procs

// Proc: open_session()
// Parameters: 1 (target_address - The other address that the session will include)
// Description: Creates a new exonet_session with target_address.
/datum/exonet_protocol/proc/open_session(var/target_address)
	world << "open_session([target_address]) called."
	if(has_session(target_address))
		return TRUE // Already done.
	if(!can_transmit())
		world << "Failed to get connection."
		return FALSE
	var/datum/exonet_protocol/them = get_exonet_datum(target_address)
	if(them)
		new /datum/exonet_session(src, them) // Adding this to current_sessions is done in the session's New().
		world << "Found address.  Made session."
		return TRUE
	world << "Failed to find address."
	return FALSE // Address not found.

/datum/exonet_protocol/unary/open_session(var/target_address)
	// Close the outbound session first.
	qdel(current_session)
	// Now make a new one and assign it.
	if(..(target_address))
		for(var/datum/exonet_session/ES in current_sessions)
			if(ES.us == src)
				current_session = ES
				break
		return TRUE
	return FALSE

// Proc: close_session()
// Parameters: 1 (target_address - The address which (presumably) currently has a session with us, that we need to kill)
// Description: Deletes all sessions with target_address.
/datum/exonet_protocol/proc/close_session(var/target_address)
	var/datum/exonet_protocol/them = get_exonet_datum(target_address)
	if(them)
		for(var/datum/exonet_session/ES in current_sessions)
			if(ES.them == them)
				qdel(ES)

/datum/exonet_protocol/proc/has_session(var/target_address)
	var/datum/exonet_protocol/them = get_exonet_datum(target_address)
	if(them)
		for(var/datum/exonet_session/ES in current_sessions)
			if(ES.them == them)
				return TRUE
	return FALSE

/datum/exonet_protocol/proc/get_session(var/target_address)
	var/datum/exonet_protocol/them = get_exonet_datum(target_address)
	if(them)
		for(var/datum/exonet_session/ES in current_sessions)
			if(ES.them == them)
				return ES

// Retrieves the current OUTGOING session.
/datum/exonet_protocol/unary/proc/get_current_session()
	for(var/datum/exonet_session/ES in current_sessions)
		if(ES.us == src)
			return ES

/datum/exonet_protocol/proc/push_command_over_session(var/target_address, var/command)
	var/datum/exonet_session/ES = get_session(target_address)
	if(ES)
		if(!can_transmit())
			return FALSE
	//	ES.them.receive_exonet_session_command(holder, src.address, command, ES.privilage)

/atom/movable/proc/receive_exonet_session_command(var/atom/origin_atom, origin_address, message, privilage)
	world << "I did it!"
	return

/datum/exonet_protocol/proc/make_account(var/new_username, var/new_password)
	accounts[new_username] = new_password

// Note that this needs to be called on 'their' side, not 'our' side.
/datum/exonet_protocol/proc/is_authorized(var/target_address)
	var/datum/exonet_session/ES = get_session(target_address)
	if(ES)
		return ES.privilage

/datum/exonet_protocol/proc/authenticate(var/target_address, var/username, var/password)
	var/datum/exonet_session/ES = get_session(target_address)
	if(ES)
		return ES.authenticate(username, password)

/datum/exonet_session/proc/authenticate(var/username, var/password)
	if(username in them.accounts)
		if(!them.accounts[username]) // No password means we're in.
			privilage = username
			return TRUE
		else
			if(password == them.accounts[username])
				return TRUE
	return FALSE
/*
	if(!them.password) // No password means we're in.
		privilage = EXONET_SESSION_ADMIN
		return TRUE
	else
		if(password == them.password)
			privilage = EXONET_SESSION_ADMIN
			return TRUE
		return FALSE
*/


