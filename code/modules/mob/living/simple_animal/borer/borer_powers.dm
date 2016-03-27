/mob/living/simple_animal/borer/verb/infect_victim()
	set name = "Infect"
	set category = "Borer"
	set desc = "Infect a adjacent human being"

	if(victim)
		src << "<span class='boldnotice'>You already have a host! leave this one if you want a new one.</span>"

	if(stat == DEAD)
		return

	var/list/choices = list()
	for(var/mob/living/carbon/H in view(1,src))
		if(H!=src && Adjacent(H))
			choices += H

	var/mob/living/carbon/human/H = input(src,"Who do you wish to infect?") in null|choices
	if(!H) return

	if(H.borer)
		src << "<span class='usernotice'>[victim] is already infected!</span>"
		return

	if(CanInfect(H))
		src << "<span class='boldnotice'>You slither up [H] and begin probing at their ear canal...</span>"
		src.layer = MOB_LAYER
		if(!do_after(src,30))
			src << "<span class='boldnotice'>As [H] moves away, you are dislodged and fall to the ground.</span>"
			return

		if(!H || !src) return

		Infect(H)

/mob/living/simple_animal/borer/proc/CanInfect(var/mob/living/carbon/human/H)
	if(!Adjacent(H))
		return 0

	if(stat != CONSCIOUS)
		src << "<span class='boldnotice'>I must be conscious to do this...</span>"
		return 0

	if(H.stat == DEAD)
		src << "<span class='boldnotice'>This subject does not have a strong enough life energy...</span>"
		return 0
	return 1

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Borer"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!victim)
		src << "<span class='boldnotice'>You are not inside a host body.</span>"
		return

	if(stat != CONSCIOUS)
		src << "<span class='boldnotice'>You cannot secrete chemicals in your current state.</span>"

	if(docile)
		src << "<span class='boldnotice'>You are feeling far too docile to do that.</span>"
		return

	/*if(chemicals < 50)
		src << "<span class='boldnotice'>You don't have enough chemicals!</span>"
		return*/

	var content = ""
	content += "<p>Chemicals: [chemicals]</p>"
	content += "<p>Influence: [influence]%</p>"

	content += "<table>"

	for(var/datum in typesof(/datum/borer_chem))
		var/datum/borer_chem/C = new datum()
		if(C.chemname && C.needed_influence < influence)
			content += "<tr><td><a class='chem-select' href='?_src_=\ref[src];src=\ref[src];borer_use_chem=[C.chemname]'>[C.chemname] ([C.chemuse])</a><p>[C.chem_desc]</p></td></tr>"

	content += "</table>"

	var/html = {"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
		<html>
		<head>
			<title>Borer Chemicals</title>
			<link rel='stylesheet' type='text/css' href='icons.css'>
			<link rel='stylesheet' type='text/css' href='shared.css'>
			<style type='text/css'>

			body {
				padding: 10;
				margin: 0;
				font-size: 12px;
				color: #ffffff;
				line-height: 170%;
				font-family: Verdana, Geneva, sans-serif;
				background: #272727 url(uiBackground.png) 50% 0 repeat-x;
				overflow-x: hidden;
			}

			a, a:link, a:visited, a:active, .link, .linkOn, .linkOff, .selected, .disabled {
				color: #ffffff;
				text-decoration: none;
				background: #40628a;
				border: 1px solid #161616;
				padding: 2px 2px 2px 2px;
				margin: 2px 2px 2px 2px;
				cursor:default;
				display: inline-block;
			}

			a:hover, .linkActive:hover {
				background: #507aac;
				cursor: pointer;
			}

			img {
				border: 0px;
			}

			p {
				padding: 4px;
				margin: 0px;
			}

			h1, h2, h3, h4, h5, h6 {
				margin: 0;
				padding: 16px 0 8px 0;
				color: #517087;
				clear: both;
			}

			h1 {
				font-size: 15px;
			}

			h2 {
				font-size: 14px;
			}

			h3 {
				font-size: 13px;
			}

			h4 {
				font-size: 12px;
			}

			#header {
				margin: 3px;
				padding: 0px;
			}

			table {
				width: 570px;
				margin: 10px;
			}

			td {
				border: solid 1px #000;
				width: 560px;
			}

			.chem-select {
				width: 560px;
				margin: 5px;
				text-align: center;
			}

			.enabled {
				background-color: #0a0;
			}

			.disabled {
				background-color: #a00;
			}

			.shown {
				display: block;
			}

			.hidden {
				display: none;
			}
			</style>

			<script src="libraries.min.js"></script>
			<script type='text/javascript'>
				function reload() {
					jQuery.support.cors = true;
					/*$.ajax({
						dataType: 'json',
						url: 'byond://?_src_=\ref[src];src=\ref[src];borer_reload=1',
						success: function(data) {
							$('body').append('data: '+data);
						}
					});*/

					/*var jqxhr = $.getJSON( 'byond://?_src_=\ref[src];src=\ref[src];borer_reload=1', function() {
					  $('body').append( '<p>success</p>' );
					})
					  .done(function() {
					    $('body').append( '<p>second success</p>' );
					  })
					  .fail(function() {
					    $('body').append( '<p>error</p>' );
					  })
					  .always(function() {
					    $('body').append( '<p>complete</p>' );
					  })
					  .done(function( json ) {
					    $('body').append( '<p>JSON Data: ' + (json) + '</p>' );
					  })
					  .fail(function( jqxhr, textStatus, error ) {
					    $('body').append( '<p>Request Failed: ' + textStatus + ', ' + error + '</p>' );
					    $('body').append( '<p>Request Failed: ' + textStatus + ', ' + (jqxhr.responseJSON) + '</p>' );
					  });*/
				}

				function autoReload() {
					setTimeout(autoReload, 2000);
					reload();
				}

				$(function() {
					autoReload();
				});
			</script>
		</head>
		<body scroll='yes'><div id='content'>
		<h1 id='header'>Borer Chemicals</h1>
		<br />

		[content]

		</div></body></html>"}

	usr << browse(null, "window=ViewBorerChems;size=600x800")
	usr << browse(html, "window=ViewBorerChems;size=600x800")






/*
	var/chemname = input("Select a chemical to secrete.", "Chemicals") as null|anything in chemnames

	if(!chemname)
		return

	var/datum/borer_chem/chem
	for(var/datum in typesof(/datum/borer_chem))
		var/datum/borer_chem/C = new datum()
		if(C.chemname == chemname)
			chem = C

	if(!chem || !victim || controlling || !src || stat)
		return

	if(!istype(chem, /datum/borer_chem))
		return

	if(chemicals < chem.chemuse)
		src << "<span class='boldnotice'>You need [chem.chemuse] chemicals stored to use this chemical!</span>"
		return

	src << "<span class='userdanger'>You squirt a measure of [chem.chemname] from your reservoirs into [victim]'s bloodstream.</span>"
	victim.reagents.add_reagent(chem.chemname, chem.quantity)
	chemicals -= chem.chemuse
	influence += chem.influence_change
	if(influence > 100)
		influence = 100
	if(influence < 0)
		influence = 0
	log_game("[src]/([src.ckey]) has injected [chemname] into their host [victim]/([victim.ckey])")
	*/

	return

/mob/living/simple_animal/borer/verb/hide()
	set category = "Borer"
	set name = "Hide"
	set desc = "Become invisible to the common eye."

	if(victim)
		src << "<span class='boldnotice'>You cannot do this whilst you are infecting a host</span>"

	if(src.stat != CONSCIOUS)
		return

	if (src.layer != TURF_LAYER+0.2)
		src.layer = TURF_LAYER+0.2
		src.visible_message("<span class='name'>[src] scurries to the ground!</span>", \
						"<span class='noticealien'>You are now hiding.</span>")
	else
		src.layer = MOB_LAYER
		src.visible_message("[src] slowly peaks up from the ground...", \
					"<span class='noticealien'>You stop hiding.</span>")

/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Borer"
	set name = "Paralyze Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	if(world.time - used_dominate < 150)
		src << "<span class='boldnotice'>You cannot use that ability again so soon.</span>"
		return

	if(victim)
		src << "<span class='boldnotice'>You cannot do that from within a host body.</span>"
		return

	if(src.stat != CONSCIOUS)
		src << "<span class='boldnotice'>You cannot do that in your current state.</span>"
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat == CONSCIOUS)
			choices += C

	if(world.time - used_dominate < dominate_cooldown)
		src << "<span class='boldnotice'>You cannot use that ability again so soon.</span>"
		return

	var/mob/living/carbon/M = input(src,"Who do you wish to dominate?") in null|choices


	if(!M || !src) return
	if(!Adjacent(M)) return

	if(M.borer)
		src << "<span class='boldnotice'>You cannot paralyze someone who is already infected!</span>"
		return

	src.layer = MOB_LAYER

	src << "<span class='warning'>You focus your psychic lance on [M] and freeze their limbs with a wave of terrible dread.</span>"
	M << "<span class='userdanger'>You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing.</span>"
	M.Stun(4)

	used_dominate = world.time

/mob/living/simple_animal/borer/verb/release_victim()
	set category = "Borer"
	set name = "Release Host"
	set desc = "Slither out of your host."

	if(!victim)
		src << "<span class='userdanger'>You are not inside a host body.</span>"
		return

	if(stat != CONSCIOUS)
		src << "<span class='userdanger'>You cannot leave your host in your current state.</span>"

	if(!victim || !src) return

	if(leaving)
		leaving = 0
		src << "<span class='userdanger'>You decide against leaving your host.</span>"
		return

	src << "<span class='userdanger'>You begin disconnecting from [victim]'s synapses and prodding at their internal ear canal.</span>"

	if(victim.stat != DEAD)
		host << "<span class='userdanger'>An odd, uncomfortable pressure begins to build inside your skull, behind your ear...</span>"

	leaving = 1

	spawn(100)

		if(!victim || !src) return
		if(!leaving) return
		if(controlling) return

		if(src.stat != CONSCIOUS)
			src << "<span class='userdanger'>You cannot release your host in your current state.</span>"
			return

		src << "<span class='userdanger'>You wiggle out of [victim]'s ear and plop to the ground.</span>"
		if(victim.mind)
			host << "<span class='danger'>Something slimy wiggles out of your ear and plops to the ground!</span>"
			host << "<span class='danger'>As though waking from a dream, you shake off the insidious mind control of the brain worm. Your thoughts are your own again.</span>"

		leave_victim()


/mob/living/simple_animal/borer/verb/jumpstart()
	set category = "Borer"
	set name = "Jumpstart Host"
	set desc = "Brings your host back from the dead."

	if(!victim)
		src << "<span class='boldnotice'>You need a host to be able to use this.</span>"
		return

	if(docile)
		src << "<span class='boldnotice'>You are feeling too docile to use this!</span>"
		return

	if(chemicals < 250)
		src << "<span class='boldnotice'>You need 250 chems to use this!</span>"
		return

	chemicals -= 250

	if(victim.stat == DEAD)
		dead_mob_list -= victim
		living_mob_list += victim
	victim.tod = null
	victim.setToxLoss(0)
	victim.setOxyLoss(0)
	victim.setCloneLoss(0)
	victim.SetParalysis(0)
	victim.SetStunned(0)
	victim.SetWeakened(0)
	victim.radiation = 0
	victim.heal_overall_damage(victim.getBruteLoss(), victim.getFireLoss())
	victim.reagents.clear_reagents()
	if(istype(victim,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = victim
		H.restore_blood()
		H.remove_all_embedded_objects()
	victim.update_canmove()
	victim.med_hud_set_status()
	victim.med_hud_set_health()
	victim.stat = CONSCIOUS
	log_game("[src]/([src.ckey]) has revived [victim]/([victim.ckey]")

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Borer"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!victim)
		src << "<span class='boldnotice'>You are not inside a host body.</span>"
		return

	if(src.stat != CONSCIOUS)
		src << "You cannot do that in your current state."
		return

	if(docile)
		src << "<span class='boldnotice'>You are feeling far too docile to do that.</span>"
		return

	if(world.time - used_control < control_cooldown)
		src << "<span class='boldnotice'>Its too soon to use that again!</span>"
		return

	if(influence < 50)
		src << "<span class='boldnotice'>You need atleast 50% influence to do this!</span>"
		return

	src << "<span class='danger'>You begin delicately adjusting your connection to the host brain...</span>"

	spawn(100+(victim.brainloss*5))

		if(!victim || !src || controlling)
			return
		else


			log_game("[src]/([src.ckey]) assumed control of [victim]/([victim.ckey] with borer powers.")
			src << "<span class='boldnotice'>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</span>"
			victim << "<span class='userdanger'>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</span>"

			// host -> brain
			var/h2b_id = victim.computer_id
			var/h2b_ip= victim.lastKnownIP
			victim.computer_id = null
			victim.lastKnownIP = null

			qdel(host_brain)
			host_brain = new(src)

			host_brain.ckey = victim.ckey

			host_brain.name = victim.name

			if(victim.mind)
				host_brain.mind = victim.mind

			if(!host_brain.computer_id)
				host_brain.computer_id = h2b_id

			if(!host_brain.lastKnownIP)
				host_brain.lastKnownIP = h2b_ip

			// self -> host
			var/s2h_id = src.computer_id
			var/s2h_ip= src.lastKnownIP
			src.computer_id = null
			src.lastKnownIP = null

			victim.ckey = src.ckey
			victim.mind = src.mind

			if(!victim.computer_id)
				victim.computer_id = s2h_id

			if(!victim.lastKnownIP)
				victim.lastKnownIP = s2h_ip

			controlling = 1

			victim.verbs += /mob/living/carbon/proc/release_control
			victim.verbs += /mob/living/carbon/proc/spawn_larvae

			victim.med_hud_set_status()

			victim.cansuicide = 0

/mob/living/simple_animal/borer/verb/punish()
	set category = "Borer"
	set name = "Punish"
	set desc = "Punish your victim"

	if(!victim)
		src << "<span class='boldnotice'>You are not inside a host body.</span>"
		return

	if(src.stat != CONSCIOUS)
		src << "You cannot do that in your current state."
		return

	if(docile)
		src << "<span class='boldnotice'>You are feeling far too docile to do that.</span>"
		return

	if(chemicals < 75)
		src << "<span class='boldnotice'>You need 75 chems to punish your host.</span>"
		return

	var/punishment = input("Select a punishment:.", "Punish") as null|anything in list("Blindness","Deafness","Stun")

	if(!punishment)
		return

	if(chemicals < 75)
		src << "<span class='boldnotice'>You need 75 chems to punish your host.</span>"
		return

	switch(punishment) //Hardcoding this stuff.
		if("Blindness")
			victim.eye_blind = 20
		if("Deafness")
			victim.ear_deaf = 20
		if("Stun")
			victim.Weaken(10)

	log_game("[src]/([src.ckey]) punished [victim]/([victim.ckey] with [punishment]")

	chemicals -= 75

	influence -= 15
	if(influence < 0)
		influence = 0

mob/living/carbon/proc/release_control()

	set category = "Borer"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	if(borer && borer.host_brain)
		if(alert(src, "Sure you want to give up your control so soon?", "Confirm", "Yes", "No") != "Yes")
			return
		src << "<span class='danger'>You withdraw your probosci, releasing control of [borer.host_brain]</span>"

		borer.detatch()

		verbs -= /mob/living/carbon/proc/release_control
		verbs -= /mob/living/carbon/proc/spawn_larvae

/mob/living/carbon/proc/spawn_larvae()
	set category = "Borer"
	set name = "Reproduce"
	set desc = "Vomit out your younglings."

	if(istype(src, /mob/living/carbon/brain))
		src << "<span class='usernotice'>You need a mouth to be able to do this.</span>"
		return
	if(!borer)
		return

	if(borer.chemicals >= 100)
		var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)
		for(var/client/C in candidates)
			if(jobban_check_mob(C.mob, "borer") || !(C.prefs.toggles & MIDROUND_ANTAG))
				candidates -= C
		if(!candidates.len)
			src << "<span class='usernotice'>Our reproduction system seems to have failed... Perhaps we should try again some other time?</span>"
			return
		var/client/C = pick(candidates)

		borer.chemicals -= 100

		new /obj/effect/decal/cleanable/vomit(get_turf(src))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)

		var/mob/living/simple_animal/borer/newborer = new(get_turf(src))
		newborer.transfer_personality(C)
		visible_message("<span class='userdanger'>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</span>")
		log_game("[src]/([src.ckey]) has spawned a new borer via reproducing.")
	else
		src << "<span class='boldnotice'>You do not have enough chemicals stored to reproduce.</span>"
		return