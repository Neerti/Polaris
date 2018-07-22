// This file handles the 'backend' for the in-game feedback system, with database manipulation.
// The part that players and admins interact with is found inside /code/modules/admin/player_feedback.dm .

// Adds someone's feedback to the database.
/proc/sqlite_insert_feedback(client/author, content)
	if(!author || !content)
		return FALSE
	if(!config.sqlite_enabled || !config.sqlite_feedback)
		to_chat(author, span("warning", "Unfortunately, it appears feedback is \
		disabled for this server. You shouldn't have gotten this far if it is, so \
		you might want to make a bug report."))
		return FALSE

	// By default, the submitter's ckey is shown.
	var/author_name = ckey(author.key)

	// See if the server desires privacy for people submitting feedback.
	if(config.sqlite_feedback_privacy)
		author_name = sqlite_feedback_obfuscate_name(author)
		if(!author_name) // Null return means something went wrong and the user wants to abort.
			return FALSE


	// Sanitize everything to avoid sneaky stuff.
	var/sqlite_author = sql_sanitize_text(author_name)
	var/sqlite_content = sql_sanitize_text(content)

	establish_sqlite_connection()
	if(!sqlite_db)
		log_game("SQLite ERROR during feedback submission. Failed to connect.")
		to_chat(author, span("warning", "Unfortunately, the server failed to connect to the SQLite database, so your feedback cannot be submitted."))
		return FALSE

	var/database/query/query = new("INSERT INTO feedback (\
		author, \
		content, \
		time_of_submission) \
		\
		VALUES (\
		'[sqlite_author]', \
		'[sqlite_content]', \
		datetime('now'))"
		)
	query.Execute(sqlite_db)

	if(sqlite_check_for_errors(query, "sqlite_insert_feedback"))
		to_chat(author, span("warning", "Unfortunately, an error occured with submitting your feedback to the database."))
	else
		to_chat(author, span("notice", "Your feedback has been submitted."))

// This hashes the submitter's ckey, in an effort to encourage more honest feedback.
// Might be worth investing effort in an external hasher to use something better later.
// Note that if this returns false, the user does not wish to continue submitting.
/proc/sqlite_feedback_obfuscate_name(client/author)
	var/submitter_name = ckey(author.key)
	var/error = FALSE

	var/pepper = sqlite_feedback_get_pepper()
	if(!pepper) // Something went wrong.
		log_debug("ERROR: SQLite Feedback Privacy pepper string is missing or inaccessible. \
			This reduces the potential privacy of players.")
		error = TRUE

	// More things could be implemented here later if desired, just set error to TRUE if something fucks up.

	if(error)
		// Warn the player.
		if(alert(author, "The server has failed to correctly implement certain privacy elements. \
		Your obfuscated ckey could be uncovered by a determined staff member. Do you still \
		wish to submit your feedback?", "Privacy Risk", "No", "Yes") == "No")
			return
		// In case of a misclick.
		if(alert(author, "Really submit despite the elevated risk?", "Privacy Risk", "No", "Yes") == "No")
			return

	submitter_name = sqlite_feedback_get_author(submitter_name, pepper)

	return submitter_name

// A Pepper is like a Salt but only one exists and is supposed to be outside of a database.
// If the file is properly protected, it can only be viewed/copied by sys-admins generating a log, which is much more conspicious than accessing/copying a DB.
// This stops admins from guessing the author by shoving names in an MD5 hasher until they pick the right one.
/proc/sqlite_feedback_get_pepper()
	var/pepper_file = file2list(config.sqlite_feedback_pepper_file)
	var/pepper = null
	for(var/line in pepper_file)
		if(!line)
			continue
		if(length(line) == 0)
			continue
		else if(copytext(line, 1, 2) == "#")
			continue
		else
			pepper = line
			break
	return pepper

// A non-interactive proc for the database to turn a key to a hash (if required to).
/proc/sqlite_feedback_get_author(key, pepper)
	if(config.sqlite_feedback_privacy)
		return md5(key+pepper)
	return key

// Checks if a client is allowed to give feedback.
/proc/sqlite_can_submit_feedback(client/C, silent = TRUE)
	if(!C)
		return FALSE

	// Is it on?
	if(!config.sqlite_enabled || !config.sqlite_feedback)
		if(!silent)
			to_chat(C, span("warning", "Unfortunately, it appears feedback is \
			disabled for this server."))
		return FALSE

	establish_sqlite_connection()

	// Check if the player age restrictions are active, and if so, if this player is too new.
	if(config.sqlite_feedback_min_age)
		if(get_player_age(C.key) < config.sqlite_feedback_min_age)
			if(!silent)
				to_chat(C, span("warning", "You have first joined the server too recently. \n\
				Try again in about [config.sqlite_feedback_min_age - get_player_age(C.key)] days."))
			return FALSE

	// Check if rate limiting is on, and if so, if its too soon to give more feedback.
	if(config.sqlite_feedback_cooldown > 0)
		// First query to get the most recent time the client has submitted feedback.
		var/database/query/query = new(
			"SELECT max(time_of_submission) \
			AS 'most_recent_datetime' \
			FROM feedback \
			WHERE (author == ?);",
			sqlite_feedback_get_author(C.ckey, sqlite_feedback_get_pepper())
			)
		query.Execute(sqlite_db)
		sqlite_check_for_errors(query, "can submit feedback (1)")
		// It is possible this is their first time. If so, there won't be a next row.

		if(query.NextRow()) // If this is true, the user has submitted feedback at least once.
			var/list/row_data = query.GetRowData()
			var/last_submission_datetime = row_data["most_recent_datetime"]

			// Now we have the datetime, we need to do something to compare it.
			// Second query is to calculate the difference between two datetimes.
			// This is done on the SQLite side because parsing datetimes with BYOND is probably a bad idea.
			query = new(
				"SELECT julianday('now') - julianday(?) \
				AS 'datediff';",
				last_submission_datetime
				)
			query.Execute(sqlite_db)
			sqlite_check_for_errors(query, "can submit feedback (2)")

			query.NextRow()
			row_data = query.GetRowData()
			var/datediff = row_data["datediff"]

			// Now check if it's too soon to give more feedback.
			if(text2num(datediff) < config.sqlite_feedback_cooldown) // Too soon.
				if(!silent)
					to_chat(C, span("warning", "It is too soon to submit more feedback. \n\
						The server is configured to allow feedback submission once every [config.sqlite_feedback_cooldown] days per user. \n\
						Please wait another [round(config.sqlite_feedback_cooldown - datediff, 0.1)] days."))
				return FALSE

	// All is well.
	return TRUE



/*
+/datum/ban/proc/expired()
+	if(!data["expiration_datetime"])
+		return FALSE // No entry means it is a permaban.
+	var/database/query/query = new(
+		"SELECT id FROM ban \
+		WHERE (id == ? AND expiration_datetime < datetime('now'));", data["id"]
+		)
+	query.Execute(sqlite_db)
+	sqlite_check_for_errors(query, "expired (1)")
+	if(query.NextRow()) // If this is true, the ban ID provided is expired.
+		return TRUE
+	return FALSE // Tough luck otherwise.
*/

/*
	var/database/query/query = new("SELECT id FROM ban WHERE (id == ? AND expiration_datetime < datetime('now'));", data["id"])
*/

/client/verb/test_feedback_db_cooldown()
	establish_sqlite_connection()
	src << "Cooldown check returned: [sqlite_can_submit_feedback(src)]."

/client/verb/test_feedback_db_submit()
	var/text = input(usr, "Write some test text here.", "Testing") as null|message
	if(text)
		sqlite_insert_feedback(usr, text)

/*
/proc/sqlite_report_death(var/mob/living/L)
	if(!config.sqlite_enabled || !config.sqlite_stats)
		return
	if(!L)
		return
	if(!L.key || !L.mind)
		return

	var/area/death_area = get_area(L)
	var/area_name = death_area ? death_area.name : "Unknown area"
	var/sqlite_species = L.get_species() ? sql_sanitize_text(L.get_species()) : "Unknown species"
	// The prefix of 'sqlite_' indicates that the variable is sanitzed by sql_sanitize_text().

	var/sqlite_name = sql_sanitize_text(L.real_name)
	var/sqlite_key = sql_sanitize_text(ckey(L.key))
	var/sqlite_death_area = sql_sanitize_text(area_name)
	var/sqlite_special_role = sql_sanitize_text(L.mind.special_role)
	var/sqlite_job = sql_sanitize_text(L.mind.assigned_role)

	var/sqlite_killer_name
	var/sqlite_killer_key
	if(L.lastattacker && istype(L.lastattacker, /mob/living) )
		var/mob/living/killer = L.
		sqlite_killer_name = killer.real_name ? sql_sanitize_text(killer.real_name) : "Unknown name"
		sqlite_killer_key = killer.key ? sql_sanitize_text(killer.key) : "Unknown key"

	var/sqlite_time = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/coord = "[L.x], [L.y], [L.z]"

	establish_sqlite_connection()
	if(!sqlite_db)
		log_game("SQLite ERROR during death reporting. Failed to connect.")
	else
		var/database/query/query = new(
		"INSERT INTO death (\
		name, \
		byondkey, \
		job, \
		special_role, \
		death_area, \
		time_of_death, \
		killer_name, \
		killer_key, \
		gender, \
		species, \
		bruteloss, \
		fireloss, \
		brainloss, \
		oxyloss, \
		cloneloss, \
		coord) \
		\
		VALUES (\
		'[sqlite_name]', \
		'[sqlite_key]', \
		'[sqlite_job]', \
		'[sqlite_special_role]', \
		'[sqlite_death_area]', \
		'[sqlite_time]', \
		'[sqlite_killer_name]', \
		'[sqlite_killer_key]', \
		'[L.gender]', \
		'[sqlite_species]', \
		[L.getBruteLoss()], \
		[L.getFireLoss()], \
		[L.brainloss], \
		[L.getOxyLoss()], \
		[L.getCloneLoss()], \
		'[coord]')"
		)
		query.Execute(sqlite_db)
		sqlite_check_for_errors(query, "sqlite_report_death (1)")
/*
// Add a string to feedback table.
/proc/feedback_add_details(var/feedback_type, var/feedback_data)
	establish_sqlite_connection()
	if(!sqlite_db)
		return
	//TODO

// Overwrite a feedback table string.
/proc/feedback_set_details(var/feedback_type, var/feedback_data)
	establish_sqlite_connection()
	if(!sqlite_db)
		return
	//TODO

// Increment a feedback field.
/proc/feedback_inc(var/feedback_type, var/feedback_amt)
	establish_sqlite_connection()
	if(!sqlite_db)
		return
	//TODO

// Set a feedback val.
/proc/feedback_set(var/feedback_type, var/feedback_amt)
	establish_sqlite_connection()
	if(!sqlite_db)
		return
	//TODO
*/
*/