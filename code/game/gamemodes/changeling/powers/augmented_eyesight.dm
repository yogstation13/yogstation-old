//Augmented Eyesight: Gives you thermal and night vision - bye bye, flashlights. Also, high DNA cost because of how powerful it is.
//Possible todo: make a custom message for directing a penlight/flashlight at the eyes - not sure what would display though.

/obj/item/organ/internal/ability_organ/changeling/augmented_eyesight
	name = "Organic Eye Augments"
	desc = "optical receptors capable of seeing in the dark and detecting the heat of living creatures through walls."
	slot = "changeling_eyes"
	zone = "eyes"
	changeling_only_powers = list(/obj/effect/proc_holder/resource_ability/changeling/augmented_eyesight)

/obj/effect/proc_holder/resource_ability/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates heat receptors in our eyes and dramatically increases light sensing ability."
	helptext = "Grants us night vision and thermal vision. It may be toggled on or off. We will become more vulnerable to flash-based devices while active."
	resource_cost = 0
	dna_cost = 2 //Would be 1 without thermal vision
	organtype = /obj/item/organ/internal/ability_organ/changeling/augmented_eyesight
	var/active = 0 //Whether or not vision is enhanced

/obj/effect/proc_holder/resource_ability/changeling/augmented_eyesight/sting_action(mob/living/carbon/human/user)
	if(!istype(user))
		return
	active = !active
	if(active)
		user << "<span class='notice'>We feel a minute twitch in our eyes, and darkness creeps away.</span>"
		user.weakeyes = 1
		user.sight |= SEE_MOBS
		user.permanent_sight_flags |= SEE_MOBS
		user.see_in_dark = 8
		user.dna.species.invis_sight = SEE_INVISIBLE_MINIMUM
	else
		user << "<span class='notice'>Our vision dulls. Shadows gather.</span>"
		user.weakeyes = 0
		user.sight &= ~SEE_MOBS
		user.permanent_sight_flags &= ~SEE_MOBS
		user.see_in_dark = 0
		user.dna.species.invis_sight = initial(user.dna.species.invis_sight)
	return 1

/obj/effect/proc_holder/resource_ability/changeling/augmented_eyesight/on_lose(mob/living/carbon/user)
	user << "<span class='notice'>Our vision dulls. Shadows gather.</span>"
	user.weakeyes = 0
	user.sight &= ~SEE_MOBS
	user.permanent_sight_flags &= ~SEE_MOBS
	user.see_in_dark = 0
	user.dna.species.invis_sight = initial(user.dna.species.invis_sight)
	user.update_sight()