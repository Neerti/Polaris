// This is a cache for the various sound icons the game will make.
// By using a cache, the game only has to build one icon per unique sound heard, instead of building a new icon every time a sound is heard.
// Because of how images work, we still need to instantiate multiple instances of them as they cannot exist in more than one spot at a time as a non-overlay.
// Hopefully copying the finished and cached image's appearance var onto the new instance is more performant than just building all the new images w/o caching.
var/global/list/sound_vision_cache = list()

/mob/proc/grant_sound_vision()
	received_sound_event.register_global(src, /mob/proc/show_sound_visual)

/mob/proc/remove_sound_vision()
	received_sound_event.unregister_global(src, /mob/proc/show_sound_visual)

/mob/Destroy()
	received_sound_event.unregister_global(src, /mob/proc/show_sound_visual)
	return ..()

// Hearer is a bit redundant but the observer datum supplies it anyways.
/mob/proc/show_sound_visual(var/mob/hearer, var/turf/source, var/sound_file, var/volume, var/is_global)
	spawn(0) // Don't hold up anything else.
		if(source)
			// First, get the correct /image.
			var/image/sound_image = image(source)
			sound_image = get_cached_sound_image(sound_image, sound_file)

			// Now attach the image to the location causing the sound.
			sound_image.loc = source

			// Show the image to the hearer.
			src << sound_image

			// Get rid of the image after a short period of time.
			animate(sound_image, alpha = 0, 3 SECONDS)
			sleep(3 SECONDS)
			if(src && src.client)
				src.client.images -= sound_image
			qdel(sound_image)

/mob/proc/get_cached_sound_image(var/image/sound_image, var/sound_file)
	if(sound_file in sound_vision_cache)
		var/image/cached_image = sound_vision_cache[sound_file]
		// We still need to produce multiple instances of images, but hopefully cloning them like this is faster than building all the images manually.
		sound_image.appearance = cached_image.appearance
	else
		var/image/image_to_cache = sound_file_to_icon(sound_file)
		sound_image.appearance = image_to_cache.appearance
		sound_vision_cache[sound_file] = image_to_cache // Put it in the cache so this only needs to occur once.
	return sound_image


// Returns an image of what the sound might be associated with (e.g. a small wrench when the ratchet sound is heard).
// This looks intense, but should only need to run once per unique sound heard.
/proc/sound_file_to_icon(var/sound)
	var/image/sound_image = null
	var/image/background_image = null

	var/icon_file = 'icons/mob/screen1_sound_vision.dmi'
	var/sound_state = null
	var/background_state = null
	var/layer_offset = 0 // This is used so more 'important' sounds (explosions) are layered above the less important sounds (foot steps).

	// The icon in the center.
	switch(sound)
		// Footsteps.
		if('sound/effects/footstep/floor1.ogg', 'sound/effects/footstep/floor2.ogg', 'sound/effects/footstep/floor3.ogg', 'sound/effects/footstep/floor4.ogg', 'sound/effects/footstep/floor5.ogg')
			sound_state = "footstep_normal"
		if('sound/effects/footstep/wood1.ogg', 'sound/effects/footstep/wood2.ogg', 'sound/effects/footstep/wood3.ogg', 'sound/effects/footstep/wood4.ogg', 'sound/effects/footstep/wood5.ogg')
			sound_state = "footstep_wood"
		if('sound/effects/footstep/carpet1.ogg', 'sound/effects/footstep/carpet2.ogg', 'sound/effects/footstep/carpet3.ogg', 'sound/effects/footstep/carpet4.ogg', 'sound/effects/footstep/carpet5.ogg')
			sound_state = "footstep_carpet"
		if('sound/effects/footstep/plating1.ogg', 'sound/effects/footstep/plating2.ogg', 'sound/effects/footstep/plating3.ogg', 'sound/effects/footstep/plating4.ogg', 'sound/effects/footstep/plating5.ogg')
			sound_state = "footstep_plating"
		if('sound/effects/footstep/hull1.ogg', 'sound/effects/footstep/hull2.ogg', 'sound/effects/footstep/hull3.ogg', 'sound/effects/footstep/hull4.ogg', 'sound/effects/footstep/hull5.ogg')
			sound_state = "footstep_hull"
		if('sound/effects/footstep/catwalk1.ogg', 'sound/effects/footstep/catwalk2.ogg', 'sound/effects/footstep/catwalk3.ogg', 'sound/effects/footstep/catwalk4.ogg', 'sound/effects/footstep/catwalk5.ogg')
			sound_state = "footstep_catwalk"
		if('sound/effects/glass_step.ogg')
			sound_state = "footstep_glass"

		// Airlocks.
		if('sound/machines/airlockclose.ogg')
			sound_state = "door_close"
		if('sound/machines/airlock.ogg')
			sound_state = "door_open"
		if('sound/machines/airlockforced.ogg', 'sound/machines/airlock_creaking.ogg')
			sound_state = "door_openforced"
		if('sound/machines/boltsdown.ogg')
			sound_state = "door_lock"
		if('sound/machines/boltsup.ogg')
			sound_state = "door_unlock"
		if('sound/machines/deniedbeep.ogg')
			sound_state = "door_reject"
		if('sound/machines/windowdoor.ogg')
			sound_state = "door_glass"
		if('sound/machines/firelockopen.ogg')
			sound_state = "door_fireopen"
		if('sound/machines/firelockclose.ogg')
			sound_state = "door_fireclose"

		// Fighting
		if('sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg', 'sound/weapons/punchmiss.ogg')
			sound_state = "punch"
		if('sound/effects/bonebreak1.ogg', 'sound/effects/bonebreak2.ogg', 'sound/effects/bonebreak3.ogg', 'sound/effects/bonebreak4.ogg')
			sound_state = "broken_bone"
		if('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
			sound_state = "harmbaton"
		if('sound/weapons/armbomb.ogg')
			sound_state = "grenade_prime"

		// Guns
		if('sound/weapons/Gunshot.ogg', 'sound/weapons/Gunshot_heavy.ogg', 'sound/weapons/Gunshot_old.ogg', 'sound/weapons/gunshot_pathetic.ogg', 'sound/weapons/gunshot2.ogg', 'sound/weapons/gunshot3.ogg', 'sound/weapons/gunshot4.ogg', 'sound/weapons/rifleshot.ogg')
			sound_state = "gunfire"
		if('sound/weapons/shotgun.ogg')
			sound_state = "shotgun_fire"
		if('sound/weapons/shotgunpump.ogg')
			sound_state = "shotgun_pump"

		// Glass
		if('sound/effects/glassknock.ogg')
			sound_state = "glass_knock"
		if('sound/effects/Glasshit.ogg')
			sound_state = "glass_hit"
		if('sound/effects/Glassbr1.ogg', 'sound/effects/Glassbr2.ogg', 'sound/effects/Glassbr3.ogg')
			sound_state = "glass_break"

		// Tools
		if('sound/items/ratchet.ogg')
			sound_state = "wrench"
		if('sound/items/screwdriver.ogg')
			sound_state = "screwdriver"
		if('sound/items/wirecutter.ogg')
			sound_state = "wirecutters"
		if('sound/items/Welder.ogg', 'sound/items/Welder2.ogg', 'sound/items/welderactivate.ogg')
			sound_state = "welder"
		if('sound/items/welderdeactivate.ogg')
			sound_state = "welder_off"
		if('sound/items/crowbar.ogg')
			sound_state = "crowbar"
		if('sound/items/jaws_pry.ogg', 'sound/items/change_drill.ogg')
			sound_state = "power_crowbar"
		if('sound/items/jaws_cut.ogg')
			sound_state = "power_wirecutters"
		if('sound/items/drill_use.ogg', 'sound/items/change_drill.ogg') // This is also used for the screwdriver mode.
			sound_state = "power_wrench"


		// Misc
		if('sound/effects/bubbles.ogg', 'sound/effects/bubbles2.ogg')
			sound_state = "bubbles"
		if('sound/weapons/smash.ogg')
			sound_state = "smash"
		if('sound/machines/click.ogg')
			sound_state = "click"

		if('sound/effects/Explosion1.ogg', 'sound/effects/Explosion2.ogg', 'sound/effects/Explosion3.ogg', 'sound/effects/Explosion4.ogg', 'sound/effects/Explosion5.ogg', 'sound/effects/Explosion6.ogg', 'sound/effects/explosionfar.ogg')
			sound_state = "boom"

		if('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg', 'sound/effects/sparks4.ogg', 'sound/effects/sparks5.ogg', 'sound/effects/sparks6.ogg', 'sound/effects/sparks7.ogg')
			sound_state = "zap"
		else
			sound_state = "sound_unknown" // Anything not classified gets a question mark.

	// The surrounding 'sound waves'.
	switch(sound_state)
		// 'Holy shit' sounds.
		if("boom", "gunfire", "shotgun_fire")
			background_state = "sound_background_danger"
			layer_offset = 0.3
		// Loud/dangerous/scary sounds.
		if("punch", "broken_bone", "harmbaton", "grenade_prime", "glass_break", "shotgun_pump")
			background_state = "sound_background_red"
			layer_offset = 0.2
		// Concerning sounds.
		if("zap", "door_openforced", "door_fireopen", "door_fireclose", "glass_hit")
			background_state = "sound_background_yellow"
			layer_offset = 0.1
		else // Mundane sounds and anything else not classified.
			background_state = "sound_background_blue"


	sound_image = image(icon_file, sound_state)
	background_image = image(icon_file, background_state)
	sound_image.underlays += background_image

	sound_image.layer = LIGHTING_LAYER + layer_offset + 0.1 // So sounds aren't hidden by darkness.
	sound_image.mouse_opacity = 0 // Clicking on things gets harder otherwise.
	return sound_image