/mob/living/artificial/swarm/attackby(var/obj/item/O, var/mob/user)
	//For whatever reason, inheriting from living results in certain weapons doing massive damage.  e.g. a stunbaton did 45 damage.
	//So have some copypasta from simple mobs.
	//Plus we'd make attack logs normally anyways, and we
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(!O.force)
		visible_message("<span class='warning'>[user] hits [src] with \the [O], but it has no effect.</span>")
		return

	if(istype(O,/obj/item))
		var/obj/item/I = O

		var/damage = I.force
		switch(I.damtype)
			if(HALLOSS)
				damage = 0
			if(BRUTE)
				damage = damage * ( (100 - armor["melee"]) / 100 )
				adjustBruteLoss(damage)
			if(BURN)
				damage = damage * ( (100 - armor["melee"]) / 100 )
				adjustFireLoss(damage)
			if(TOX)
				damage = 0
			if(OXY)
				damage = 0
			else
				damage = 0

		if(I.hitsound)
			playsound(loc, I.hitsound, 50, 1, -1)
		if(I.attack_verb.len)
			user.visible_message("<span class='danger'>[src] has been [pick(I.attack_verb)] with \the [I] by [user]!</span>")
		else
			user.visible_message("<span class='danger'>[src] has been attacked with \the [I] by [user]!</span>")
		user.do_attack_animation(src)
		if(damage)
			spark_system.start()
		updatehealth()
		attacked_act(I, user)

	else
		user << "<span class='notice'>Using \a [O] on \the [src] won't help you at all.</span>"

/mob/living/artificial/swarm/updatehealth()
	health = maxHealth - (getBruteLoss() + getFireLoss())
	if(health <= 0)
		death()
	return

/mob/living/artificial/swarm/proc/attacked_act(var/obj/item/O, var/mob/user)
	hostile_mobs |= user

/mob/living/artificial/swarm/death()
	visible_message("<span class='danger'>\The [src] falls to pieces!</span>")
	if(master) //Log who killed this unit to the master AI.
		if(master.hostile_mobs["[user.name]"]
			master.hostile_mobs["[user.name]"] += 1
		else
			master.hostile_mobs["[user.name]"] = 1
	qdel(src)

/mob/living/artificial/swarm/emp_act(severity)
	switch(severity)
		if(1)
			adjustFireLoss(40)
		if(2)
			adjustFireLoss(20)