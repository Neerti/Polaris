var/database/sqlite_db

// Called on server startup to connect to the database file.
/proc/establish_sqlite_connection()
	if(!config.sqlite_enabled)
		qdel(sqlite_db)
		return FALSE

	if(!sqlite_db)
		// Create or load the database.
		sqlite_db = new("data/sqlite/sqlite.db") // The path has to be hardcoded or BYOND silently fails.

		world.log << "SQLite database loaded."

		// Insert your schemas for tables below.

		// Feedback table.
		// Note that this is for direct feedback from players using the in-game feedback system and NOT for stat tracking.
		// Player ckeys are not stored in this table as a unique key due to a config option to hash the keys to encourage more honest feedback.
		/*
		 * id					- Primary unique key to ID a specific piece of feedback. NOT used to id people submitting feedback.
		 * author				- The person who submitted it. Will be the ckey, or a hash of the ckey based on the server's config.
		 * content				- What the author decided to write to the staff.
		 * time_of_submission	- When the author submitted their feedback, acts as a timestamp.
		 */
		var/database/query/init_schema = new(
		"CREATE TABLE IF NOT EXISTS feedback \
		(\
		id INTEGER PRIMARY KEY NOT NULL UNIQUE, \
		author TEXT NOT NULL, \
		content TEXT NOT NULL, \
		time_of_submission DATETIME NOT NULL \
		);")
		init_schema.Execute(sqlite_db)
		sqlite_check_for_errors(init_schema, "establish_sqlite_connection - feedback schema")

		// Add more schemas below this if the SQLite DB gets expanded.



		if(!sqlite_db)
			world.log << "Failed to load or create an SQLite database."
			log_debug("ERROR: SQLite database is active in config but failed to load.")




// General error checking for SQLite.
// Returns true if something went wrong. Also writes a log.
/proc/sqlite_check_for_errors(var/database/query/query_used, var/desc)
	if(query_used && query_used.ErrorMsg())
		log_debug("SQLite Error: [desc] : [query_used.ErrorMsg()]")
		return TRUE
	return FALSE