// These files can actually do things.

/datum/file/executable
	file_type = "binary executable"

/datum/file/executable/stdin(input, datum/file/target)
	var/result = execute(input, target)
	if(result)
		stdout(result, target)

/datum/file/executable/proc/execute(input, datum/file/target)
	return