/mob/commander
	density = 0

	see_in_dark = 7
	status_flags = GODMODE
	invisibility = INVISIBILITY_EYE
	see_invisible = SEE_INVISIBLE_MINIMUM

/mob/commander/Move(NewLoc, Dir = 0)
	if(NewLoc)
		loc = NewLoc
	else
		return 0