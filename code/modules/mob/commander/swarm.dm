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
	var/area/marked_area = null
	var/mob/marked_mob = null
	var/atom/marked_atom = null

	var/list/captured_areas = list()

	//Areas which the AI will never attempt to capture, for various reasons.
	var/list/blacklisted_areas = list(/area/space, 			//One does not simply capture all of space.
								/area/crew_quarters/sleep,	//Dorms are off limits to human antags, so they're off limits to us too.
								/area/gateway,				//Ditto
								/area/mine,					//Asteroid's fucking huge.
								/area/shuttle/arrival,		//No camping arrivals.
								/area/shuttle/cryo,			//Humans get banned if they do this, so we won't do it as well.
								/area/shuttle/escape,		//Only the worst humans dare attack on the escape shuttle.
//								/area/hallway/escape,		//As well as camping the escape hallway.
//								/area/hallway/entry,		//Lots of arrivals areas :(
								/area/shuttle
								)

	var/list/hostile_mobs = list()		//A list of all mobs that have ever attacked a unit.

	//AI variables
	var/campaign = null
	var/strategy = null
	var/task	 = null
	var/busy	 = 0

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

/mob/commander/swarm/proc/handle_ai()
	if(client || busy)
		return 0
	busy = 1
	if(captured_areas.len == 0)
		if(check_for_idle_units())
			ai_invade()
	else
		if(check_for_idle_units())
			ai_expand_borders()
	busy = 0

/mob/commander/swarm/Life()
	..()
	handle_ai()
	sleep(20)



/mob/verb/make_swarm()
	set name = "Make Swarm"
	set desc = "Quickly sets up a Swarm."
	set category = "Testing"
	set src = usr

	var/mob/commander/swarm/S = new /mob/commander/swarm(src.loc)
	S.key = src.key
	new /mob/living/artificial/swarm/invader(S.loc)

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

/mob/commander/swarm/verb/deselect()
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
			M.calculate_path(marked_atom)
			M.walk_path()

/mob/commander/swarm/verb/traverse_unit()
	set name = "Traverse Unit"
	set desc = "Moves your selected units repeatively."
	set category = "Commander"
	set src = usr

	var/mob/living/artificial/swarm/M
	for(M in src.selected_units)
		spawn(1)
			M.add_to_queue("calculate_path",marked_atom)
			M.add_to_queue("walk_loop",marked_atom)
//			M.walk_loop()

/mob/commander/swarm/verb/move_reset_unit()
	set name = "Move Reset Units"
	set desc = "Resets units' movements, if they bug up."
	set category = "Commander"
	set src = usr

	var/mob/living/artificial/swarm/M
	for(M in src.selected_units)
		M.walk_reset()
/*
/mob/commander/swarm/verb/mark_target_loc()
	set name = "Mark Target Location"
	set desc = "Designates a target for your units to walk to."
	set category = "Commander"
	set src = usr

	var/mob/living/artificial/swarm/M
	for(M in src.selected_units)
		M.target_loc = src.loc
		src << "Units given new target location."
*/
/mob/commander/swarm/verb/mark_target_loc()
	set name = "Mark Atom"
	set desc = "Designates a atom to use later."
	set category = "Commander"
	set src = usr

	marked_atom = get_turf(src)

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

	world << "capture_area called by [src]."

	var/mob/living/artificial/swarm/M
	for(M in src.selected_units)
		if(get_area(M) != get_area(src))
			mark_target_loc()
			traverse_unit()
		say("Capturing [get_area(src)].")
//		M.capture_area()
		M.add_to_queue("capture_area")
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
			sleep(1)
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

	var/turf/new_turf = null
	if(A) //Targeted area was supplied already, meaning the AI is using this verb.
		while(!new_turf)
			var/turf/T = pick(get_area_turfs(A))
			if(!T.get_density()) //Don't want to jump into a wall.
				new_turf = T
				break
		src.loc = new_turf
	else if(client && !A) //If not, a human is, so we can ask where they want to go.
		input(src,"Choose an area to jump to.","Teleporting") as anything in return_sorted_areas()
		if(A)
			while(!new_turf)
				var/turf/T = pick(get_area_turfs(A))
				if(!T.get_density())
					new_turf = T
					break
			src.loc = new_turf

/turf/proc/get_density() //Checks for walls and dense objects on top, like tables.
	if(density)
		return 1
	for(var/obj/O in contents)
		if(O.density == 1)
			return 1
	return 0

/mob/commander/swarm/verb/jump_to_current_area()
	set name = "Jump To Current Area"
	set desc = "Jump to a random spot in the current area."
	set category = "Commander"
	set src = usr

	jump_to_area(get_area(src))

/mob/commander/swarm/verb/pick_idle_unit()
	set name = "Pick Idle Unit"
	set desc = "Picks a unit that's not currently anything."
	set category = "Commander"
	set src = usr

	//First, check if we even have anyone to do anything.
	if(owned_units.len == 0)
		message_admins("AI Error: No owned units to command.")
		return 0

	for(var/mob/living/artificial/swarm/S in owned_units)
		if(S.task != 0)
			continue
		else
			return S

/mob/commander/swarm/proc/check_for_idle_units()
	if(owned_units.len == 0)
		message_admins("AI Error: No owned units to command.")
		return 0

	for(var/mob/living/artificial/swarm/S in owned_units)
		if(S.task == 0)
			return 1
	return 0



/mob/commander/swarm/verb/ai_invade()
	set name = "Invade"
	set desc = "Invade a room."
	set category = "Commander AI"
	set src = usr

	selected_units.Add(pick_idle_unit())

	if(selected_units.len == 0)
		return 0

	//Jump to our new selected unit.
	jump_to_selected()

	//Then check if we don't own the area.
	if(!(get_area(src) in captured_areas))
		//If we don't, change that.
		capture_area()

	else
		var/success = 0
		//Keep trying until we succeed.
		while(!success)
			//Jump in a random area in the current area, in case we just happen to be in a bad spot.
			jump_to_current_area()
			//Now explore for new areas to invade.
			var/new_area = find_nearby_area()
			//Now check if we don't already own it.
			if(new_area)
				if(!(new_area in captured_areas))
					success = 1
					break
		//Most likely, we found the new area while in a wall, so let's fix that.
		jump_to_current_area()
		mark_target_loc()
		traverse_unit()

/mob/commander/swarm/verb/ai_expand_borders()
	set name = "Expand Borders"
	set desc = "Invade a room."
	set category = "Commander AI"
	set src = usr

	selected_units.Add(pick_idle_unit())

	if(selected_units.len == 0)
		return 0

	//Jump to our new selected unit.
	jump_to_area(pick(captured_areas))

	var/success = 0
	//Keep trying until we succeed.
	while(!success)
		//Jump in a random area in the current area, in case we just happen to be in a bad spot.
		jump_to_current_area()
		//Now explore for new areas to invade.
		var/new_area = find_nearby_area()
		//Now check if we don't already own it.
		if(new_area)
			if(!(new_area in captured_areas))
				success = 1
				break
	//Most likely, we found the new area while in a wall, so let's fix that.
	jump_to_current_area()
	mark_target_loc()
	traverse_unit()
	capture_area()
	deselect()

