/obj/structure/AIcore
	density = 1
	anchored = 0
	name = "\improper AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	var/state = 0
	var/datum/ai_laws/laws = new()
	var/obj/item/weapon/circuitboard/circuit = null
	var/obj/item/device/mmi/brain = null


/obj/structure/AIcore/attackby(obj/item/P, mob/user, params)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				user << "<span class='notice'>You start wrenching the frame into place...</span>"
				if(do_after(user, 20, target = src))
					user << "<span class='notice'>You wrench the frame into place.</span>"
					adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): wrenched into place")
					anchored = 1
					state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = P
				if(!WT.isOn())
					user << "<span class='warning'>The welder must be on for this task!</span>"
					return
				playsound(loc, 'sound/items/Welder.ogg', 50, 1)
				user << "<span class='notice'>You start to deconstruct the frame...</span>"
				if(do_after(user, 20, target = src))
					if(!src || !WT.remove_fuel(0, user)) return
					user << "<span class='notice'>You deconstruct the frame.</span>"
					adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): frame deconstructed")
					new /obj/item/stack/sheet/plasteel( loc, 4)
					qdel(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				user << "<span class='notice'>You start to unfasten the frame...</span>"
				if(do_after(user, 20, target = src))
					user << "<span class='notice'>You unfasten the frame.</span>"
					adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): frame unfastened")
					anchored = 0
					state = 0
			if(istype(P, /obj/item/weapon/circuitboard/aicore) && !circuit)
				if(!user.drop_item())
					return
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "<span class='notice'>You place the circuit board inside the frame.</span>"
				adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): circuit board inserted")
				icon_state = "1"
				circuit = P
				P.loc = src
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You screw the circuit board into place.</span>"
				adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): circuit board screwed in")
				state = 2
				icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "<span class='notice'>You remove the circuit board.</span>"
				adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): circuit board removed")
				state = 1
				icon_state = "0"
				circuit.loc = loc
				circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You unfasten the circuit board.</span>"
				adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): circuit board unfastened")
				state = 1
				icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "<span class='notice'>You start to add cables to the frame...</span>"
					if(do_after(user, 20, target = src))
						if (C.get_amount() >= 5 && state == 2)
							C.use(5)
							user << "<span class='notice'>You add cables to the frame.</span>"
							adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): cables added")
							state = 3
							icon_state = "3"
				else
					user << "<span class='warning'>You need five lengths of cable to wire the AI core!</span>"
					return
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				if (brain)
					user << "<span class='warning'>Get that brain out of there first!</span>"
				else
					playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
					user << "<span class='notice'>You remove the cables.</span>"
					adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): cables removed")
					state = 2
					icon_state = "2"
					var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
					A.amount = 5

			if(istype(P, /obj/item/stack/sheet/rglass))
				var/obj/item/stack/sheet/rglass/G = P
				if(G.get_amount() >= 2)
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "<span class='notice'>You start to put in the glass panel...</span>"
					if(do_after(user, 20, target = src))
						if (G.get_amount() >= 2 && state == 3)
							G.use(2)
							user << "<span class='notice'>You put in the glass panel.</span>"
							adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): glass panel added")
							state = 4
							icon_state = "4"
				else
					user << "<span class='warning'>You need two sheets of reinforced glass to insert them into AI core!</span>"
					return

			if(istype(P, /obj/item/weapon/aiModule/core/full)) //Allows any full core boards to be applied to AI cores.
				var/obj/item/weapon/aiModule/core/M = P
				laws.clear_inherent_laws()
				laws.clear_zeroth_law(0)
				for(var/templaw in M.laws)
					laws.add_inherent_law(templaw)
				usr << "<span class='notice'>Law module applied.</span>"
				adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): law module applied")

			if(istype(P, /obj/item/weapon/aiModule/reset/purge))
				laws.clear_inherent_laws()
				laws.clear_zeroth_law(0)
				usr << "<span class='notice'>Laws cleared applied.</span>"
				adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): laws cleared applied")


			if(istype(P, /obj/item/weapon/aiModule/supplied/freeform) || istype(P, /obj/item/weapon/aiModule/core/freeformcore))
				var/obj/item/weapon/aiModule/supplied/freeform/M = P
				if(M.laws[1] == "")
					return
				laws.add_inherent_law(M.laws[1])
				usr << "<span class='notice'>Added a freeform law.</span>"
				adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): added freeform law")

			if(istype(P, /obj/item/device/mmi))
				var/obj/item/device/mmi/M = P
				if(!M.brainmob)
					user << "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose!</span>"
					return
				if(M.brainmob.stat == DEAD)
					user << "<span class='warning'>Sticking a dead brain into the frame would sort of defeat the purpose!</span>"
					return

				if(!M.brainmob.client)
					user << "<span class='warning'>Sticking an inactive brain into the frame would sort of defeat the purpose.</span>"
					return

				if((config) && (!config.allow_ai))
					user << "<span class='warning'>This MMI does not seem to fit!</span>"
					return

				if(jobban_check_mob(M.brainmob, "AI"))
					user << "<span class='warning'>This MMI does not seem to fit!</span>"
					return

				if(M.syndiemmi)
					user << "<span class='warning'>This MMI does not seem to fit!</span>"
					return

				if(!M.brainmob.mind)
					user << "<span class='warning'>This MMI is mindless!</span>"
					return

				if(!user.drop_item())
					return

				ticker.mode.remove_cultist(M.brainmob.mind, 1)
				ticker.mode.remove_revolutionary(M.brainmob.mind, 1)
				ticker.mode.remove_gangster(M.brainmob.mind, 1, remove_bosses=1)

				M.loc = src
				brain = M
				usr << "<span class='notice'>Added a brain.</span>"
				adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): added a brain")
				icon_state = "3b"

			if(istype(P, /obj/item/weapon/crowbar) && brain)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "<span class='notice'>You remove the brain.</span>"
				adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): brain removed")
				brain.loc = loc
				brain = null
				icon_state = "3"

		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "<span class='notice'>You remove the glass panel.</span>"
				adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): glass panel removed")
				state = 3
				if (brain)
					icon_state = "3b"
				else
					icon_state = "3"
				new /obj/item/stack/sheet/rglass(loc, 2)
				return

			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You connect the monitor.</span>"
				adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): monitor connected")
				if(!laws.inherent.len) //If laws isn't set to null but nobody supplied a board, the AI would normally be created lawless. We don't want that.
					laws = null
				new /mob/living/silicon/ai (loc, laws, brain)
				feedback_inc("cyborg_ais_created",1)
				qdel(src)

/obj/structure/AIcore/deactivated
	name = "inactive AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	anchored = 1
	state = 20//So it doesn't interact based on the above. Not really necessary.

/obj/structure/AIcore/deactivated/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/device/aicard))//Is it?
		A.transfer_ai("INACTIVE","AICARD",src,user)
	if(istype(A, /obj/item/weapon/wrench))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("[user] [anchored ? "fastens" : "unfastens"] [src].", \
					 "<span class='notice'>You start to [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor...</span>")
		switch(anchored)
			if(0)
				if(do_after(user, 20, target = src))
					user << "<span class='notice'>You fasten the core into place.</span>"
					adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): core fastened")
					anchored = 1
			if(1)
				if(do_after(user, 20, target = src))
					user << "<span class='notice'>You unfasten the core.</span>"
					adm_action_log.enqueue("[gameTimestamp()] ([user] - [user] - [src]): core unfastened")
					anchored = 0
	return

/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/device/aicard/card)
	if(istype(card))
		if(card.flush)
			user << "<span class='boldannounce'>ERROR</span>: AI flush is in progress, cannot execute transfer protocol."
			return 0
	return 1


/obj/structure/AIcore/deactivated/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/device/aicard/card)
	if(!..())
		return
 //Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = 0
		AI.radio_enabled = 1
		AI.loc = loc//To replace the terminal.
		AI << "You have been uploaded to a stationary terminal. Remote device connection restored."
		user << "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed."
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		user << "There is no AI loaded on this terminal!"
