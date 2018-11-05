// These files can actually do things.

/datum/file/executable
	file_type = "binary executable"

/datum/file/executable/stdin(input)
	var/result = execute(input)
	stdout(result)

/datum/file/executable/proc/execute(input)
	return