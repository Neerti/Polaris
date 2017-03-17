/obj/item/device/remote_terminal
	name = "remote access terminal"
	desc = "This allows a skilled systems administrator to remotely monitor and control various systems."
	icon_state = "retail_idle" //placeholder
	var/obj/machinery/exonet_node/node = null	// Reference to the Exonet node.
	var/list/aliases = list()					// The user can define short-hands for specific addresses.  This is an assoc list.
//	var/list/text_output = list()				// This shows the output.  Note that the output shown is actually reversed.
	var/input = ""								// What the user has typed in the command box, which will be parsed.
	var/authentication = ""						// A password saved in the device, so the user doesn't need to type it 100x times.
	var/list/reserved_aliases = list(			// These words are reserved, and are disallowed from being used as aliases,
		"ping", "help", "status",
		"clear", "alias", "clearalias",
		"scan"
	)
	var/datum/console_program/remote_terminal/console			// This datum handles the UI.
	var/datum/exonet_protocol/remote_connection = null // Reference to the current machine's exonet we're controlling.

/obj/item/device/remote_terminal/New()
	..()
	exonet = new /datum/exonet_protocol/unary(src)
	exonet.make_address("remote_terminal-[rand(1,100)]")
	node = get_exonet_node()
	console = new(src)
	console.initialize()
//	text_output = list("Initialization complete.",
//		"Successfully connected to local exonet node.  This device's address is '[exonet.address]'.",
//		"Type 'help' for a list of commands.")
	aliases["self"] = exonet.address

/obj/item/device/remote_terminal/Destroy()
	if(exonet)
		exonet.remove_address()
		qdel(exonet)
	node = null
	if(console)
		qdel(console)
	..()

/obj/item/device/remote_terminal/proc/add_output(var/text)
	var/list/lines = textwrap(text, console.max_line_length)
	for(var/line in lines)
		console.AddLine(line)
		sleep(1) // Looks more HACKERish if it scrolls a bit slower.


//	console.AddLine(text)
//	if(text_output.len >= 30)
//		text_output.Remove(text_output[1]) // Remove the oldest message first.
//	text_output.Add(text)


/proc/textwrap(text, line_limit)
	var/list/result = list()
	if(length(text) < line_limit) // No need to split.
		result.Add(text)
		return result

	var/list/split_list = splittext(text, " ")
	var/list/temp_list = split_list.Copy()

	var/new_line = ""
	while(temp_list.len)
//		world << "temp_list len is [temp_list.len]."
//		sleep(2 SECONDS)
		temp_list = split_list.Copy()
		for(var/word in temp_list)
//			world << "Looking at [word]."
			if(isnull(word) || word == "")
				split_list.Remove(word)
//				world << "Removed [word] for being empty."
				continue

			if(length(new_line) + length(word) < line_limit)
//				world << "new_line [new_line] + [word] is short enough."
				if(new_line == "")
					new_line = word
				else
					new_line = new_line + " [word]"
				split_list.Remove(word)

				if(!split_list.len)
					result.Add(new_line)
					break
			else
//				world << "Adding [new_line] to result."
				result.Add(new_line)
				new_line = ""
				break
	return result


/obj/item/device/remote_terminal/proc/parse_input(var/input)
	add_output("user@terminal ~ $ [input]")
	if(!input)
		return
	var/list/words = splittext(input," ")

	var/first_word = lowertext(words[1])
	var/second_word = null
	var/third_word = null
	if(words.len >= 2)
		second_word = lowertext(words[2])
	if(words.len >= 3)
		third_word = lowertext(words[3])

	switch(first_word)
		if("connect")
			if(second_word)
				if(exonet.open_session(second_word))
					add_output("Connected to [second_word].")
				else
					add_output("Failed to connect to [second_word].")
			else
				add_output("Please provide an EPv2 address to connect to.")
		if("login")
			if(!exonet.current_session)
				add_output("Not connected to a remote host.  Please connect to one and try again.")
			if(exonet.current_session.authenticate(second_word, third_word))
				add_output("Now logged in as admin.")
			else
				add_output("Username or password incorrect.")
		if("logout")
			if(!exonet.current_session)
				add_output("Not connected to a remote host.")
		if("disconnect")
			if(!exonet.current_session)
				add_output("Not connected to a remote host.")
			else
				qdel(exonet.current_session)
				add_output("Connection to remote host terminated.")
	update_console()

/obj/item/device/remote_terminal/proc/update_console()
	console.update_footer()

	/*

	switch(first_word)
		if("help")
			add_output("== Remote Commands ==")
			add_output("connect ADDRESS - Attempts to establish a secure session with ADDRESS.")
			add_output("disconnect - Disconnects you from the current session.")
//			add_output("login ADDRESS PASSWORD - Attempts to authenticate yourself to ADDRESS.")
//			add_output("logout ADDRESS - If logged in, logs you out of ADDRESS.")
			add_output("ping ADDRESS - Sends a ping query to ADDRESS.")
			add_output("scan - Sends pings to all compatable networked machines associated with ADDRESS.")
			add_output("status ADDRESS - Asks ADDRESS for a general status update.")
			add_output("== Local Commands ==")
			add_output("alias NAME ADDRESS - Saves an EPv2 address, with NAME acting as a short-hand for it.")
			add_output("clear_alias NAME - Deletes NAME from memory.")
			add_output("clear - Clears the log.")
			add_output("help - Displays this text.")
//			add_output("scan - Sends pings to all compatable networked machines near this device.")
			add_output("show_aliases - Displays all aliases in memory.")
			return
//		if("connect")
//			if(second_word)

		if("alias")
			if(second_word && third_word)
				if(second_word in reserved_aliases)
					add_output("'[second_word]' is a reserved keyword.")
					return
				if(second_word in aliases)
					add_output("'[second_word]' is already an alias.")
					return
				aliases["[second_word]"] = third_word
				add_output("[second_word] is now an alias for [third_word].")
				return
//		if("clear")
//			text_output.Cut()
		if("clear_alias")
			if(second_word)
				if(second_word in aliases)
					aliases.Remove(second_word)
					add_output("[second_word] is no longer an alias.")
					return
				else
					add_output("[second_word] is not an alias.")
					return
		if("show_aliases")
			add_output("Displaying all aliases...")
			for(var/alias in aliases)
				add_output("[alias] = [aliases[alias]]")
			return
		if("scan")
			var/list/nearby_things = range(get_turf(src),5)
			for(var/atom/movable/AM in nearby_things)
				if(AM == src)
					continue
				if(AM.exonet && AM.exonet.address)
					exonet.send_message(AM.exonet.address, "ping")

	// If we get this far, we're probably doing an external command.

	var/target_address = null
	if(second_word in aliases)
		target_address = aliases[second_word]
	else
		target_address = second_word

	if(node && node.on)
		exonet.send_message(target_address, first_word, third_word)
		world << "called send_message([target_address],[first_word],[third_word])"
	else
		add_output("Cannot send external command.  Not connected to exonet node.")
	*/

/obj/item/device/remote_terminal/attack_self(mob/user)
	console.Run(user)

/obj/item/device/remote_terminal/Topic(href, href_list)
	if(..())
		return 1

	parse_input(href_list["commandEntered"])

//	switch(href_list["choice"])
//		if("command")
//			parse_input(href_list["command"])

	add_fingerprint(usr)

/obj/item/device/remote_terminal/receive_exonet_message(var/atom/origin_atom, origin_address, message, text)
	//add_output("Received message: [origin_address] [message] [text]")

	if(message == "message")
		add_output("[text]")

	if(message == "status")
		//exonet.send_message(origin_address, "[exonet.address] failed to reply to status query.")
		add_output("Received status query from [origin_address], ignoring.")
	..()