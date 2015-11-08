#define EARLYGAME		1
#define MIDGAME			2
#define ENDGAME			3


/var/global/list/ai_commanders = list()

//The "leader" of the swarm.  It doesn't exist in the game world as a normal mob, and instead takes a commander role and makes all the high-level decisions.
/mob/commander/swarm
	name = "The Director"
	desc = "A manifestation of an artificial intelligence's will being projected from an unknown world."
	icon = 'icons/mob/swarm.dmi'
	icon_state = "master"

	var/list/owned_units = list()
	var/list/selected_units = list()	//All units 'selected' are relayed a set of instructions.
	var/list/parties = list()			//A party is a saved group of units that can be selected at any time.

	var/list/captured_areas = list()

	//Areas which the AI will never attempt to capture, for various reasons.
	var/list/blacklisted_areas = list(/area/space, 			//One does not simply capture all of space.
								/area/crew_quarters/sleep,	//Dorms are off limits to human antags, so they're off limits to us too.
								/area/gateway,				//Ditto
								/area/mine,					//Asteroid's fucking huge.
								/area/shuttle/arrival,		//No camping arrivals.
								/area/shuttle/cryo,			//Humans get banned if they do this, so we won't do it as well.
								/area/shuttle/escape,		//Only the worst humans dare attack on the escape shuttle.
								/area/hallway/escape,		//As well as camping the escape hallway.
								/area/hallway/entry,		//Lots of arrivals areas :(
								/area/shuttle/escape_pod1,  //Perfect example of subclassing needed.
								/area/shuttle/escape_pod2,
								/area/shuttle/escape_pod3,
								/area/shuttle/escape_pod4,
								/area/shuttle/escape_pod5,
								/area/shuttle/escape_pod3,
								/area/shuttle/large_escape_pod1,
								/area/shuttle/large_escape_pod1
								)

	var/list/hostile_mobs = list()		//A list of all mobs that have ever attacked a unit.

	//AI variables
	var/campaign = null
	var/strategy = null
	var/task	 = null

/mob/commander/swarm/New()
	ai_commanders.Add(src)
	..()

/mob/commander/swarm/Destroy()
	ai_commanders.Remove(src)
	owned_units = null
	selected_units = null
	..()

/mob/commander/swarm/say(message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	swarm_talk(message)

/mob/commander/swarm/proc/swarm_talk(message)
	//Mostly intended to entertain deadchat by talking about what it plans to do.
	//We don't log what this says since 95% of the time, the game itself is playing it, and whenever a human is inside the mob, an admin did it, so...

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return
	//Robot Talk, Beep Boop states, "Beep."
	var/rendered = "<font color=\"#800000\"><i><span class='game say'>Swarm Link, <span class='name'>[name]</span> <span class='message'>encodes ,\"[message]\"</span></span></i></font>"

	for (var/mob/M in mob_list)
		if(isobserver(M))
			M.show_message(rendered, 2)
	src.show_message(rendered, 2)

/mob/commander/swarm/emote(act,m_type=1,message = null)
	return

/mob/commander/swarm/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/commander/swarm/verb/select_unit()
	set name = "Select Unit"
	set desc = "Selects a specific unit."
	set category = "Commander"
	set src = usr

	var/mob/living/artificial/swarm/M
	for(M in src.loc.contents)
		if(M in src.selected_units)
			src.selected_units.Remove(M)
			src << "You deselect [M]."
		else
			src.selected_units.Add(M)
			src << "You select [M]."

/mob/commander/swarm/verb/unselect()
	set name = "Unselect"
	set desc = "Unselects all units."
	set category = "Commander"
	set src = usr

	selected_units.Cut()

/mob/commander/swarm/verb/move_unit()
	set name = "Move Unit"
	set desc = "Moves your selected units."
	set category = "Commander"
	set src = usr

	var/mob/living/artificial/swarm/M
	for(M in src.selected_units)
		spawn(1)
			M.calculate_path()
			M.walk_path()

/mob/commander/swarm/verb/traverse_unit()
	set name = "Traverse Unit"
	set desc = "Moves your selected units repeatively."
	set category = "Commander"
	set src = usr

	var/mob/living/artificial/swarm/M
	for(M in src.selected_units)
		spawn(1)
			M.walk_loop()

/mob/commander/swarm/verb/move_reset_unit()
	set name = "Move Reset Units"
	set desc = "Resets units' movements, if they bug up."
	set category = "Commander"
	set src = usr

	var/mob/living/artificial/swarm/M
	for(M in src.selected_units)
		M.walk_reset()

/mob/commander/swarm/verb/mark_target_loc()
	set name = "Mark Target Location"
	set desc = "Designates a target for your units to walk to."
	set category = "Commander"
	set src = usr

	var/mob/living/artificial/swarm/M
	for(M in src.selected_units)
		M.target_loc = src.loc
		src << "Units given new target location."

/mob/commander/swarm/verb/make_party()
	set name = "Make Party"
	set desc = "Merge your selected units into a part for easy access later."
	set category = "Commander"
	set src = usr

	var/new_party = selected_units.Copy()
	if(new_party in parties) //Prevent duplicate parties.
		return 0
	parties.Add(new_party) //Welcome to the party!
	src << "Party created."

/mob/commander/swarm/verb/select_party(var/index as num)
	set name = "Select Party"
	set desc = "Select a saved party."
	set category = "Commander"
	set src = usr

	var/list/desired_party = list()

	if(parties.len == 1)
		desired_party = parties[1]
	else if(index)
		desired_party = parties[index]
	else if(!index)
		desired_party = input(src,"Choose a party","Party") as anything in parties

	if(desired_party)
		selected_units = desired_party.Copy()

/mob/commander/swarm/verb/capture_area()
	set name = "Capture Area"
	set desc = "Captures the area you're in."
	set category = "Commander"
	set src = usr

	var/mob/living/artificial/swarm/M
	for(M in src.selected_units)
		if(get_area(M) == get_area(src))
			say("Capturing [get_area(src)].")
			M.capture_area()
			break

/mob/commander/swarm/verb/find_nearby_area()
	set name = "Find Nearby Area"
	set desc = "Attempts to locate a nearby area."
	set category = "Commander"
	set src = usr

	var/old_loc = loc 					//Stores our old location, in case we fail to find something nearby.
	var/area/old_area = get_area(src) 	//Used to compare with new_area.
	var/area/new_area = null			//Compared to old_area, to see if they're different.
	var/area/found_area = null			//If we found a new area, this will be set to it.
	var/max_distance = 20				//How many tiles to search for a new area for.

	var/list/available_cardinals = cardinal.Copy()
	//alldirs
	while(!found_area && available_cardinals.len != 0)
		var/exploring_dir = pick(available_cardinals) //Pick a direction.
		available_cardinals.Remove(exploring_dir) //Don't want to go in the same direction twice.
		var/i = max_distance //Don't want to go too far.
		while(i)
			step(src,exploring_dir)
			new_area = get_area(src)
			i--
			if(old_area != new_area) //New area?
				if(is_type_in_list(new_area, blacklisted_areas)) //Bad area?
					break //Welp, try again.
				found_area = new_area
				break //We found one!
			sleep(5)
		if(!found_area)
			loc = old_loc //If we didn't find anything, try again where we started, but in another direction.
		sleep(5)
	if(found_area)
		say("Found [found_area].")
	else
		say("Unable to find anything.")
	return found_area

/mob/commander/swarm/verb/jump_to_selected()
	set name = "Jump To Selected"
	set desc = "Teleports you to your first selected mob."
	set category = "Commander"
	set src = usr

	if(selected_units.len != 0)
		var/mob/living/artificial/swarm/selected_unit = selected_units[1]
		loc = selected_unit.loc

/mob/commander/swarm/verb/jump_to_area(var/area/A)
	set name = "Jump To Area"
	set desc = "Jump to an area of your choosing."
	set category = "Commander"
	set src = usr

	if(A) //Targeted area was supplied already, meaning the AI is using this verb.
		src.loc = pick(get_area_turfs(A))
	else if(client && !A) //If not, a human is, so we can ask where they want to go.
		input(src,"Choose an area to jump to.","Teleporting") as anything in return_sorted_areas()
		if(A)
			src.loc = pick(get_area_turfs(A))

/*
/client/proc/Jump(var/area/A in return_sorted_areas())
	set name = "Jump to Area"
	set desc = "Area to jump to"
	set category = "Admin"
	if(!check_rights(R_ADMIN|R_MOD|R_DEBUG))
		return

	if(config.allow_admin_jump)
		usr.on_mob_jump()
		usr.loc = pick(get_area_turfs(A))

		log_admin("[key_name(usr)] jumped to [A]")
		message_admins("[key_name_admin(usr)] jumped to [A]", 1)
		feedback_add_details("admin_verb","JA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")
*/