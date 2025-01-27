/*
Regenerative extracts:
	Work like a legion regenerative core.
	Has a unique additional effect.
*/
/obj/item/slimecross/regenerative
	name = "regenerative extract"
	desc = "It's filled with a milky substance, and pulses like a heartbeat."
	effect = "regenerative"
	icon_state = "regenerative"

/obj/item/slimecross/regenerative/proc/core_effect(mob/living/carbon/human/target, mob/user)
	return
/obj/item/slimecross/regenerative/proc/core_effect_before(mob/living/carbon/human/target, mob/user)
	return

/obj/item/slimecross/regenerative/pre_attack(atom/A, mob/living/user, params, attackchain_flags, damage_multiplier)
	if(isliving(A))
		var/mob/living/M = A
		if(M.stat == DEAD)
			to_chat(user, "<span class='warning'>[src] will not work on the dead!</span>")
			return TRUE //returning TRUE preemptively ends the attack chain and thus doesn't call afterattack, this is noteworthy for below as well
		//inform the target that they're about to have a regenerative extract used on them
		if(M != user) //targeting someone else
			M.visible_message("<span class='notice'>[user] readies [src], holding it steady near [M] and guiding it to the center of [M.ru_ego()] mass...</span>",
				"<span class='notice'>[user] readies [src], holding it steady near you and guiding it to the center of your mass...</span>")
			if(!do_after(user, 50, target = M)) //5 seconds
				return TRUE
		else //targeting self
			M.visible_message("<span class='notice'>[user] readies [src], holding it steady near [user.ru_na()]self and guiding it to the center of [user.ru_ego()] mass...</span>",
				"<span class='notice'>You ready [src], holding it steady near you and guiding it to the center of your mass...</span>")
			if(!do_after(user, 10, target = M)) //1 second
				return TRUE
		. = ..()
	else
		. = ..()

/obj/item/slimecross/regenerative/afterattack(atom/target,mob/user,prox)
	. = ..()
	if(!prox || !isliving(target))
		return
	var/mob/living/M = target
	if(M.stat == DEAD)
		to_chat(user, "<span class='warning'>[M] died before you could apply [src]!</span>")
		return
	if(M != user)
		user.visible_message("<span class='notice'>[user] crushes the [src] over [M], the milky goo quickly regenerating all of [M.ru_ego()] injuries!</span>",
			"<span class='notice'>You squeeze the [src], and it bursts over [M], the milky goo regenerating [M.ru_ego()] injuries.</span>")
	else
		user.visible_message("<span class='notice'>[user] crushes the [src] over [user.ru_na()]self, the milky goo quickly regenerating all of [user.ru_ego()] injuries!</span>",
			"<span class='notice'>You squeeze the [src], and it bursts in your hand, splashing you with milky goo which quickly regenerates your injuries!</span>")
	core_effect_before(M, user)
	var/new_disgust_level = 0
	if(iscarbon(M)) //simpler mobs don't have a disgust variable and we need to grab that.
		var/mob/living/carbon/C = M
		new_disgust_level = C.disgust + DISGUST_LEVEL_GROSS
	M.revive(full_heal = 1)
	M.set_disgust(new_disgust_level)
	core_effect(M, user)
	playsound(target, 'sound/effects/splat.ogg', 40, 1)
	//warn receivers of the extract about the disgust if they're carbon, making it clear that the regenerative extract is causing this.
	if(iscarbon(M))
		var/obj/item/organ/stomach/S = M.getorganslot(ORGAN_SLOT_STOMACH) //for getting the stummy name
		switch(new_disgust_level)
			if(0 to DISGUST_LEVEL_GROSS)
				to_chat(M,"<span class='warning'>While you recovered from [src], you feel a little nauseous.</span>")
			if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
				to_chat(M,"<span class='warning'>While you recovered from [src], you feel quite queasy.</span>")
			if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
				to_chat(M,"<span class='warning'>While you recovered from [src], you feel like you're about to vomit!</span>")
			if(DISGUST_LEVEL_DISGUSTED to INFINITY)
				to_chat(M,"<span class='userdanger'>You feel absolutely sick. Maybe you should lay off the regenerative extracts until your [(S ? S.name : "stomach")] settles!</span>")
	qdel(src)

/obj/item/slimecross/regenerative/grey
	colour = "grey" //Has no bonus effect.

/obj/item/slimecross/regenerative/orange
	colour = "orange"

/obj/item/slimecross/regenerative/orange/core_effect_before(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>The [src] boils over!</span>")
	for(var/turf/turf in range(1,target))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)

/obj/item/slimecross/regenerative/purple
	colour = "purple"

/obj/item/slimecross/regenerative/purple/core_effect(mob/living/target, mob/user)
	target.reagents.add_reagent(/datum/reagent/medicine/regen_jelly,10)

/obj/item/slimecross/regenerative/blue
	colour = "blue"

/obj/item/slimecross/regenerative/blue/core_effect(mob/living/target, mob/user)
	if(isturf(target.loc))
		var/turf/open/T = get_turf(target)
		T.MakeSlippery(TURF_WET_WATER, min_wet_time = 10, wet_time_to_add = 5)
		target.visible_message("<span class='warning'>The milky goo in the extract gets all over the floor!</span>")

/obj/item/slimecross/regenerative/metal
	colour = "metal"

/obj/item/slimecross/regenerative/metal/core_effect(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>The milky goo hardens and reshapes itself, encasing [target]!</span>")
	var/obj/structure/closet/C = new /obj/structure/closet(target.loc)
	C.name = "slimy closet"
	C.desc = "Looking closer, it seems to be made of a sort of solid, opaque, metal-like goo."
	target.forceMove(C)

/obj/item/slimecross/regenerative/yellow
	colour = "yellow"

/obj/item/slimecross/regenerative/yellow/core_effect(mob/living/target, mob/user)
	var/list/batteries = list()
	for(var/obj/item/stock_parts/cell/C in target.GetAllContents())
		if(C.charge < C.maxcharge)
			batteries += C
	if(batteries.len)
		var/obj/item/stock_parts/cell/ToCharge = pick(batteries)
		ToCharge.charge = ToCharge.maxcharge
		to_chat(target, "<span class='notice'>You feel a strange electrical pulse, and one of your electrical items was recharged.</span>")

/obj/item/slimecross/regenerative/darkpurple
	colour = "dark purple"

/obj/item/slimecross/regenerative/darkpurple/core_effect(mob/living/target, mob/user)
	var/equipped = 0
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/purple(null), ITEM_SLOT_FEET)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(null), ITEM_SLOT_ICLOTHING)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/purple(null), ITEM_SLOT_GLOVES)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/head/soft/purple(null), ITEM_SLOT_HEAD)
	if(equipped > 0)
		target.visible_message("<span class='notice'>The milky goo congeals into clothing!</span>")

/obj/item/slimecross/regenerative/darkblue
	colour = "dark blue"

/obj/item/slimecross/regenerative/darkblue/core_effect(mob/living/target, mob/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/fireproofed = FALSE
	if(H.get_item_by_slot(ITEM_SLOT_OCLOTHING))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		fireproof(C)
	if(H.get_item_by_slot(ITEM_SLOT_HEAD))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(ITEM_SLOT_HEAD)
		fireproof(C)
	if(fireproofed)
		target.visible_message("<span class='notice'>Some of [target]'s clothing gets coated in the goo, and turns blue!</span>")

/obj/item/slimecross/regenerative/darkblue/proc/fireproof(obj/item/clothing/C)
	C.name = "fireproofed [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	C.heat_protection = C.body_parts_covered
	C.resistance_flags |= FIRE_PROOF

/obj/item/slimecross/regenerative/silver
	colour = "silver"

/obj/item/slimecross/regenerative/silver/core_effect(mob/living/target, mob/user)
	target.set_nutrition(NUTRITION_LEVEL_FULL - 1)
	target.set_thirst(THIRST_LEVEL_VERY_QUENCHED - 1)
	to_chat(target, "<span class='notice'>You feel satiated.</span>")

/obj/item/slimecross/regenerative/bluespace
	colour = "bluespace"
	var/turf/open/T

/obj/item/slimecross/regenerative/bluespace/core_effect(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>[src] disappears in a shower of sparks!</span>","<span class='danger'>The milky goo teleports you somewhere it remembers!</span>")
	do_sparks(5,FALSE,target)
	target.forceMove(T)
	do_sparks(5,FALSE,target)

/obj/item/slimecross/regenerative/bluespace/Initialize(mapload)
	. = ..()
	T = get_turf(src)

/obj/item/slimecross/regenerative/sepia
	colour = "sepia"

/obj/item/slimecross/regenerative/sepia/core_effect_before(mob/living/target, mob/user)
	to_chat(target, "<span class=notice>You try to forget how you feel.</span>")
	target.AddComponent(/datum/component/dejavu)

/obj/item/slimecross/regenerative/cerulean
	colour = "cerulean"

/obj/item/slimecross/regenerative/cerulean/core_effect(mob/living/target, mob/user)
	src.forceMove(user.loc)
	var/obj/item/slimecross/X = new /obj/item/slimecross/regenerative(user.loc)
	X.name = name
	X.desc = desc
	user.put_in_active_hand(X)
	to_chat(user, "<span class='notice'>Some of the milky goo congeals in your hand!</span>")

/obj/item/slimecross/regenerative/pyrite
	colour = "pyrite"

/obj/item/slimecross/regenerative/pyrite/core_effect(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>The milky goo coating [target] leaves [target.ru_na()] a different color!</span>")
	target.add_atom_colour(rgb(rand(0,255),rand(0,255),rand(0,255)),WASHABLE_COLOUR_PRIORITY)

/obj/item/slimecross/regenerative/red
	colour = "red"

/obj/item/slimecross/regenerative/red/core_effect(mob/living/target, mob/user)
	to_chat(target, "<span class='notice'>You feel... <i>faster.</i></span>")
	target.reagents.add_reagent(/datum/reagent/medicine/ephedrine,3)

/obj/item/slimecross/regenerative/green
	colour = "green"

/obj/item/slimecross/regenerative/green/core_effect(mob/living/target, mob/user)
	if(isslime(target))
		target.visible_message("<span class='warning'>The [target] suddenly changes color!</span>")
		var/mob/living/simple_animal/slime/S = target
		S.random_colour()
	if(isjellyperson(target))
		target.reagents.add_reagent(/datum/reagent/slime_toxin,5)


/obj/item/slimecross/regenerative/pink
	colour = "pink"

/obj/item/slimecross/regenerative/pink/core_effect(mob/living/target, mob/user)
	to_chat(target, "<span class='notice'>You feel more calm.</span>")
	target.reagents.add_reagent(/datum/reagent/drug/krokodil,4)

/obj/item/slimecross/regenerative/gold
	colour = "gold"

/obj/item/slimecross/regenerative/gold/core_effect(mob/living/target, mob/user)
	var/obj/item/coin/C = new /obj/effect/spawner/lootdrop/coin(target.loc)
	playsound(C, 'sound/items/coinflip.ogg', 50, 1)
	target.put_in_hand(C)

/obj/item/slimecross/regenerative/oil
	colour = "oil"

/obj/item/slimecross/regenerative/oil/core_effect(mob/living/target, mob/user)
	playsound(src, 'sound/weapons/flash.ogg', 100, 1)
	for(var/mob/living/L in view(user,7))
		L.flash_act()

/obj/item/slimecross/regenerative/black
	colour = "black"

/obj/item/slimecross/regenerative/black/core_effect_before(mob/living/target, mob/user)
	var/dummytype = target.type
	var/mob/living/dummy = new dummytype(target.loc)
	to_chat(target, "<span class='notice'>The milky goo flows from your skin, forming an imperfect copy of you.</span>")
	if(iscarbon(target))
		var/mob/living/carbon/T = target
		var/mob/living/carbon/D = dummy
		T.dna.transfer_identity(D)
		D.updateappearance(mutcolor_update=1)
		D.real_name = T.real_name
	dummy.adjustBruteLoss(target.getBruteLoss())
	dummy.adjustFireLoss(target.getFireLoss())
	dummy.adjustToxLoss(target.getToxLoss())
	dummy.adjustOxyLoss(200)

/obj/item/slimecross/regenerative/lightpink
	colour = "light pink"

/obj/item/slimecross/regenerative/lightpink/core_effect(mob/living/target, mob/user)
	if(!isliving(user))
		return
	if(target == user)
		return
	var/mob/living/U = user
	U.revive(full_heal = 1)
	to_chat(U, "<span class='notice'>Some of the milky goo sprays onto you, as well!</span>")

/obj/item/slimecross/regenerative/adamantine
	colour = "adamantine"

/obj/item/slimecross/regenerative/adamantine/core_effect(mob/living/target, mob/user) //WIP - Find out why this doesn't work.
	target.apply_status_effect(STATUS_EFFECT_SLIMESKIN)

/obj/item/slimecross/regenerative/rainbow
	colour = "rainbow"

/obj/item/slimecross/regenerative/rainbow/core_effect(mob/living/target, mob/user)
	target.apply_status_effect(STATUS_EFFECT_RAINBOWPROTECTION)
