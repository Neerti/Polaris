// Base type for 'technological horrors', a highly illegal mix of synthetic and organic parts, controlled by a drone.


/mob/living/simple_mob/mechanical/tech_horror
	name = "technological horror"
	desc = "A highly illegal fusion of biological and synthetic."
	icon = 'icons/mob/tech_horror.dmi'
	faction = "tech_horror"
	mob_class = MOB_CLASS_SYNTHETIC|MOB_CLASS_HUMANOID

/mob/living/simple_mob/mechanical/tech_horror/Initialize(mapload)
	add_modifier(/datum/modifier/nanite_bloodstream)
	return ..()

/datum/modifier/nanite_bloodstream
	name = "nanite bloodstream"
	desc = "Your dual nature as an organic and synthetic allows you to regenerate slowly."

	on_created_text = "<span class='notice'>Nanites circulate inside of yourself, maintaining you.</span>"
	on_expired_text = "<span class='warning'>You do not appear to have nanites inside of yourself anymore.</span>"

/datum/modifier/nanite_bloodstream/tick()
	holder.adjustBruteLoss(-2)
	holder.adjustFireLoss(-2)
	holder.adjustToxLoss(-2)
	holder.adjustOxyLoss(-2)
	holder.adjustCloneLoss(-2)