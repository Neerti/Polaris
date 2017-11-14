//	Observer Pattern Implementation: Recieved Sound
//		Registration type: /mob
//
//		Raised when: A mob hears a sound from the playsound_local proc, which is called from the general playsound proc.
//
//		Arguments that the called proc should expect:
//			/mob/hearer: The mob that received the sound.
//			/turf/source: The tile that the sound orginated from.
//			sound_file: The file that the mob most likely had played to them.
//			volume: How loud the sound was when it finally reached the mob.  This takes things like low pressure into account.
//			is_global: If the sound was heard by everyone on the z-level.


var/decl/observ/received_sound/received_sound_event = new()

/decl/observ/received_sound
	name = "Received Sound"
	expected_type = /mob

/*************************
* Receive Sound Handling *
*************************/

/mob/playsound_local(var/turf/turf_source, soundin, vol as num, vary, frequency, falloff, is_global)
	if(..()) // Don't trigger if they didn't receive a sound, e.g. while deaf.
		received_sound_event.raise_event(src, turf_source, soundin, vol, is_global)


/mob/verb/test_sound_observation()
	received_sound_event.register_global(src, /mob/proc/do_sound_test)

/mob/proc/do_sound_test(var/mob/hearer, var/turf/source, var/sound_file, var/volume, var/is_global)
	world << "[hearer] heard [sound_file] at [volume] volume, from [source ? "[source] ([source.x],[source.y])" : "nowhere"].  It was [is_global ? "" :"not"] global."