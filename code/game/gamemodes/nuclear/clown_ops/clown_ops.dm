/datum/game_mode
	var/list/datum/mind/clown_syndicates = list()//If I reuse the syndicates list, the end game results will be printed twice.


/datum/game_mode/clown_ops
	name = "clown ops"
	config_tag = "clown ops"
	required_players = 1 // 1 for easy debugging
	required_enemies = 1
	recommended_enemies = 1
	antag_flag = BE_OPERATIVE
	enemy_minimum_age = 0

	var/const/agents_possible = 5
	var/list/title_list = list("Honkmaster", "Head Honker", "Slipbringer", "Mimeslayer")

	var/nukes_left = 1
	var/nuke_off_station = 0
	var/syndies_didnt_escape = 0

/datum/game_mode/clown_ops/announce()
	world << "<B>The current game mode is - Clown Ops!</B>"
	world << "<B>A Clown Syndicate Strike Force is approaching [station_name()]!</B>"
	world << "\A bananium explosive was being transported by the Clown Federation to the clown planet. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It seemed quite unimportant at the time, so it was given to the clown. Now [syndicate_name()] Operatives have arrived to retake the disk and detonate SS13! Also, most likely [syndicate_name()] star ships are in the vicinity so take care not to lose the disk!\n<B>Clown Syndicate</B>: Reclaim the disk and detonate the bananium bomb anywhere on SS13.\n<B>Personnel</B>: Hold the disk and <B>escape with it</B> on the shuttle!"

/datum/game_mode/clown_ops/pre_setup()
	var/agent_number = 0
	if(antag_candidates.len > agents_possible)
		agent_number = agents_possible
	else
		agent_number = antag_candidates.len

	var/n_players = num_players()
	if(agent_number > n_players)
		agent_number = n_players/2

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick(antag_candidates)
		clown_syndicates += new_syndicate
		antag_candidates -= new_syndicate
		agent_number--

	for(var/datum/mind/synd_mind in clown_syndicates)
		synd_mind.assigned_role = "Clown Operative"
		synd_mind.special_role = "Clown Operative"
		log_game("[synd_mind.key] (ckey) has been selected as a clown operative")
	return 1


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/clown_ops/post_setup()

	var/list/turf/synd_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			continue

	var/obj/effect/landmark/uplinklocker = locate("landmark*Syndicate-Uplink")	//i will be rewriting this shortly
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")

	var/nuke_code = "[rand(10000, 99999)]"
	var/leader_selected = 0
	var/agent_number = 1
	var/spawnpos = 1

	for(var/datum/mind/synd_mind in clown_syndicates)
		if(spawnpos > synd_spawn.len)
			spawnpos = 2
		synd_mind.current.loc = synd_spawn[spawnpos]

		forge_syndicate_objectives(synd_mind)
		greet_syndicate(synd_mind)
		equip_syndicate(synd_mind.current)

		if (nuke_code)
			synd_mind.store_memory("<B>Clown Syndicate Bananium Bomb Code</B>: [nuke_code]", 0, 0)
			synd_mind.current << "The bananium authorization code is: <B>[nuke_code]</B>"

		if(!leader_selected)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
			agent_number++
		spawnpos++
		update_synd_icons_added(synd_mind)

	if(uplinklocker)
		new /obj/structure/closet/syndicate/nuclear(uplinklocker.loc)
	if(nuke_spawn && synd_spawn.len > 0)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb/bananium(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	return ..()


/datum/game_mode/clown_ops/prepare_syndicate_leader(datum/mind/synd_mind, nuke_code)
	var/leader_title = pick(title_list)
	spawn(1)
		NukeNameAssign(nukelastname(synd_mind.current),clown_syndicates)
	synd_mind.current.real_name = "[syndicate_name()] [leader_title]"
	synd_mind.current << "<B>HONK! You are the Clown Syndicate [leader_title] for this mission. You are responsible for the distribution of telecrystals and your ID is the only one who can open the launch bay doors.</B>"
	synd_mind.current << "<B>If you feel you are not up to this task, give your ID to another operative.</B>"
	synd_mind.current << "<B>In your hand you will find a special item capable of triggering a greater challenge for your team. Examine it carefully and consult with your fellow operatives before activating it.</B>"

	var/obj/item/device/nuclear_challenge/challenge = new /obj/item/device/nuclear_challenge
	synd_mind.current.equip_to_slot_or_del(challenge, slot_r_hand)

	var/list/foundIDs = synd_mind.current.search_contents_for(/obj/item/weapon/card/id)
	if(foundIDs.len)
		for(var/obj/item/weapon/card/id/ID in foundIDs)
			ID.name = "lead agent card"
			ID.access += access_syndicate_leader
	else
		message_admins("Warning: Nuke Ops spawned without access to leave their spawn area!")

	if (nuke_code)
		var/obj/item/weapon/paper/P = new
		P.info = "The bananium authorization code is: <b>[nuke_code]</b>"
		P.name = "bananium bomb code"
		var/mob/living/carbon/human/H = synd_mind.current
		P.loc = H.loc
		H.equip_to_slot_or_del(P, slot_l_hand, 0)
		H.update_icons()
	else
		nuke_code = "code will be provided later"
	return


/datum/game_mode/clown_ops/forge_syndicate_objectives(datum/mind/syndicate)
	var/datum/objective/nuclear/clown/syndobj = new
	syndobj.owner = syndicate
	syndicate.objectives += syndobj


/datum/game_mode/clown_ops/greet_syndicate(datum/mind/syndicate, you_are=1)
	if (you_are)
		syndicate.current << "<span class='notice'>You are a [syndicate_name()] agent!</span>"
	var/obj_count = 1
	for(var/datum/objective/objective in syndicate.objectives)
		syndicate.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return

/datum/game_mode/clown_ops/equip_syndicate(mob/living/carbon/human/synd_mob)
	var/radio_freq = SYND_FREQ

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate/alt(synd_mob)
	R.set_frequency(radio_freq)
	R.freqlock = 1
	synd_mob.equip_to_slot_or_del(R, slot_ears)

	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(synd_mob), slot_w_uniform)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes/combat(synd_mob), slot_shoes)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(synd_mob), slot_wear_mask)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(synd_mob), slot_l_store)
	synd_mob.equip_to_slot_or_del(new /obj/item/toy/crayon/rainbow(synd_mob), slot_r_store)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(synd_mob), slot_gloves)

	var/obj/item/weapon/card/id/syndicate/ID = new /obj/item/weapon/card/id/syndicate(synd_mob)
	ID.access += access_theatre
	synd_mob.equip_to_slot_or_del(ID, slot_wear_id)

	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/clown(synd_mob), slot_back)

	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/toy/pistol/riot(synd_mob), slot_belt)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(synd_mob.back), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(synd_mob, 100/*super potency*/), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/stamp/clown(synd_mob), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/spray/waterflower(synd_mob), slot_in_backpack)

	synd_mob.dna.add_mutation(CLOWNMUT)//can't be a clown without being clumsy :).

	var/obj/item/device/radio/uplink/U = new /obj/item/device/radio/uplink(synd_mob)
	U.hidden_uplink.uplink_owner="[synd_mob.key]"
	U.hidden_uplink.uses = 20
	synd_mob.equip_to_slot_or_del(U, slot_in_backpack)

	var/obj/item/weapon/implant/weapons_auth/W = new/obj/item/weapon/implant/weapons_auth(synd_mob)
	W.implant(synd_mob)
	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive(synd_mob)
	E.implant(synd_mob)
	synd_mob.faction |= "syndicate"
	synd_mob.faction |= "clown"
	synd_mob.update_icons()
	return 1


/datum/game_mode/clown_ops/check_win()
	if (nukes_left == 0)
		return 1
	return ..()

/datum/game_mode/clown_ops/declare_completion()
	var/disk_rescued = 1
	for(var/obj/item/weapon/disk/nuclear/D in world)
		if(!D.onCentcom())
			disk_rescued = 0
			break
	var/crew_evacuated = (SSshuttle.emergency.mode >= SHUTTLE_ENDGAME)
	//var/operatives_are_dead = is_operatives_are_dead()


	//nukes_left
	//station_was_nuked
	//derp //Used for tracking if the syndies actually haul the nuke to the station	//no
	//herp //Used for tracking if the syndies got the shuttle off of the z-level	//NO, DON'T FUCKING NAME VARS LIKE THIS

	if(!disk_rescued &&  station_was_nuked && !syndies_didnt_escape)
		feedback_set_details("round_end_result","win - syndicate nuke")
		world << "<FONT size = 3><B>Clown Syndicate Major Victory!</B></FONT>"
		world << "<B>[syndicate_name()] operatives have destroyed [station_name()]!</B>"

	else if (!disk_rescued &&  station_was_nuked && syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - syndicate nuke - did not evacuate in time")
		world << "<FONT size = 3><B>Total Annihilation</B></FONT>"
		world << "<B>[syndicate_name()] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked && nuke_off_station && !syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station")
		world << "<FONT size = 3><B>Crew Minor Victory</B></FONT>"
		world << "<B>[syndicate_name()] operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked && nuke_off_station && syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station - did not evacuate in time")
		world << "<FONT size = 3><B>[syndicate_name()] operatives have earned Darwin Award!</B></FONT>"
		world << "<B>[syndicate_name()] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if ((disk_rescued || SSshuttle.emergency.mode < SHUTTLE_ENDGAME) && are_operatives_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk secured - syndi team dead")
		world << "<FONT size = 3><B>Crew Major Victory!</B></FONT>"
		world << "<B>The Research Staff has saved the disc and killed the [syndicate_name()] Operatives</B>"

	else if ( disk_rescued )
		feedback_set_details("round_end_result","loss - evacuation - disk secured")
		world << "<FONT size = 3><B>Crew Major Victory</B></FONT>"
		world << "<B>The Research Staff has saved the disc and stopped the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued && are_operatives_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk not secured")
		world << "<FONT size = 3><B>Clown Syndicate Minor Victory!</B></FONT>"
		world << "<B>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued &&  crew_evacuated)
		feedback_set_details("round_end_result","halfwin - detonation averted")
		world << "<FONT size = 3><B>Clown Syndicate Minor Victory!</B></FONT>"
		world << "<B>[syndicate_name()] operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !crew_evacuated)
		feedback_set_details("round_end_result","halfwin - interrupted")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>Round was mysteriously interrupted!</B>"

	..()
	return


/datum/game_mode/proc/auto_declare_completion_clown_ops()
	if( clown_syndicates.len || (ticker && istype(ticker.mode,/datum/game_mode/clown_ops)) )
		var/text = "<br><FONT size=3><B>The clown syndicate operatives were:</B></FONT>"

		var/purchases = ""
		var/TC_uses = 0

		for(var/datum/mind/syndicate in clown_syndicates)

			text += "<br><b>[syndicate.key]</b> was <b>[syndicate.name]</b> ("
			if(syndicate.current)
				if(syndicate.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(syndicate.current.real_name != syndicate.name)
					text += " as <b>[syndicate.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"

			for(var/obj/item/device/uplink/H in world_uplinks)
				if(H && H.uplink_owner && H.uplink_owner==syndicate.key)
					TC_uses += H.used_TC
					purchases += H.purchase_log

		text += "<br>"

		text += "(Clown Syndicates used [TC_uses] TC) [purchases]"

		if(TC_uses==0 && station_was_nuked && !are_operatives_dead())
			text += "<BIG><IMG CLASS=icon SRC=\ref['icons/BadAss.dmi'] ICONSTATE='badass'></BIG>"

		world << text
	return 1


/datum/game_mode/clown_ops/proc/nukelastname(mob/M) //--All praise goes to NEO|Phyte, all blame goes to DH, and it was Cindi-Kate's idea. Also praise Urist for copypasta ho.
	var/randomname = pick(last_names)
	var/newname = copytext(sanitize(input(M,"HONK! You are the nuke operative [pick(title_list)]. Please choose a last name for your clown clan.", "Name change",randomname)),1,MAX_NAME_LEN)

	if (!newname)
		newname = randomname

	else
		if (newname == "Unknown" || newname == "floor" || newname == "wall" || newname == "rwall" || newname == "_")
			M << "That name is reserved."
			return nukelastname(M)

	return capitalize(newname)

/datum/game_mode/clown_ops/proc/NukeNameAssign(lastname,list/syndicates)
	for(var/datum/mind/synd_mind in syndicates)
		var/mob/living/carbon/human/H = synd_mind.current
		synd_mind.name = H.dna.species.random_name(H.gender,0,lastname)
		synd_mind.current.real_name = synd_mind.name
	return


//Leaving this here for now. HONK!
/datum/objective/nuclear/clown
	explanation_text = "Destroy the station with the bananium bomb."
	martyr_compatible = 1