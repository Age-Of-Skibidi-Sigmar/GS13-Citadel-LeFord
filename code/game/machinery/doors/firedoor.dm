#define CONSTRUCTION_COMPLETE 0 //No construction done - functioning as normal
#define CONSTRUCTION_PANEL_OPEN 1 //Maintenance panel is open, still functioning
#define CONSTRUCTION_WIRES_EXPOSED 2 //Cover plate is removed, wires are available
#define CONSTRUCTION_GUTTED 3 //Wires are removed, circuit ready to remove
#define CONSTRUCTION_NOCIRCUIT 4 //Circuit board removed, can safely weld apart

/obj/machinery/door/firedoor
	name = "firelock"
	desc = "Apply crowbar."
	icon = 'icons/obj/doors/Doorfireglass.dmi'
	icon_state = "door_open"
	opacity = FALSE
	density = FALSE
	max_integrity = 300
	resistance_flags = FIRE_PROOF
	heat_proof = TRUE
	glass = TRUE
	sub_door = TRUE
	explosion_block = 1
	safe = FALSE
	layer = BELOW_OPEN_DOOR_LAYER
	closingLayer = CLOSED_FIREDOOR_LAYER
	assemblytype = /obj/structure/firelock_frame
	armor = list(MELEE = 30, BULLET = 30, LASER = 20, ENERGY = 20, BOMB = 10, BIO = 100, RAD = 100, FIRE = 95, ACID = 70)
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN
	air_tight = TRUE
	attack_hand_is_action = TRUE
	attack_hand_speed = CLICK_CD_MELEE
	can_open_with_hands = FALSE
	var/emergency_close_timer = 0
	var/nextstate = null
	var/boltslocked = TRUE
	var/list/affecting_areas

/obj/machinery/door/firedoor/Initialize(mapload)
	. = ..()
	CalculateAffectingAreas()
	UpdateAdjacencyFlags()


/obj/machinery/door/firedoor/examine(mob/user)
	. = ..()
	if(!density)
		. += "<span class='notice'>It is open, but could be <b>pried</b> closed.</span>"
	else if(!welded)
		. += "<span class='notice'>It is closed, but could be <i>pried</i> open. Deconstruction would require it to be <b>welded</b> shut.</span>"
	else if(boltslocked)
		. += "<span class='notice'>It is <i>welded</i> shut. The floor bolts have been locked by <b>screws</b>.</span>"
	else
		. += "<span class='notice'>The bolt locks have been <i>unscrewed</i>, but the bolts themselves are still <b>wrenched</b> to the floor.</span>"

/obj/machinery/door/firedoor/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	if (isnull(held_item))
		if (density)
			LAZYSET(context[SCREENTIP_CONTEXT_LMB], INTENT_ANY, "Knock")
			return CONTEXTUAL_SCREENTIP_SET
		else
			return .

	switch (held_item.tool_behaviour)
		if (TOOL_CROWBAR)
			if(!welded)
				LAZYSET(context[SCREENTIP_CONTEXT_LMB], INTENT_ANY, (density ? "Open" : "Close"))
				return CONTEXTUAL_SCREENTIP_SET
		if (TOOL_WELDER)
			LAZYSET(context[SCREENTIP_CONTEXT_LMB], INTENT_ANY, (welded ? "Unweld shut" : "Weld shut"))
			return CONTEXTUAL_SCREENTIP_SET
		if (TOOL_WRENCH)
			if (welded && !boltslocked)
				LAZYSET(context[SCREENTIP_CONTEXT_LMB], INTENT_ANY, "Unfasten bolts")
				return CONTEXTUAL_SCREENTIP_SET
		if (TOOL_SCREWDRIVER)
			if (welded)
				LAZYSET(context[SCREENTIP_CONTEXT_LMB], INTENT_ANY, (boltslocked ? "Unlock bolts" : "Lock bolts"))
				return CONTEXTUAL_SCREENTIP_SET
	return .

/obj/machinery/door/firedoor/proc/CalculateAffectingAreas()
	remove_from_areas()
	affecting_areas = get_adjacent_open_areas(src) | get_base_area(src)
	for(var/I in affecting_areas)
		var/area/A = I
		LAZYADD(A.firedoors, src)

/obj/machinery/door/firedoor/proc/UpdateAdjacencyFlags()
	var/turf/T = get_turf(src)
	if(flags_1 & ON_BORDER_1)
		for(var/t in T.atmos_adjacent_turfs)
			if(get_dir(loc, t) == dir)
				var/turf/open/T2 = t
				if(T2 in T.atmos_adjacent_turfs)
					T.atmos_adjacent_turfs[T2] |= ATMOS_ADJACENT_FIRELOCK
				if(T in T2.atmos_adjacent_turfs)
					T2.atmos_adjacent_turfs[T] |= ATMOS_ADJACENT_FIRELOCK
	else
		for(var/t in T.atmos_adjacent_turfs)
			var/turf/open/T2 = t
			if(T2 in T.atmos_adjacent_turfs)
				T.atmos_adjacent_turfs[T2] |= ATMOS_ADJACENT_FIRELOCK
			if(T in T2.atmos_adjacent_turfs)
				T2.atmos_adjacent_turfs[T] |= ATMOS_ADJACENT_FIRELOCK

/obj/machinery/door/firedoor/closed
	icon_state = "door_closed"
	opacity = TRUE
	density = TRUE

//see also turf/AfterChange for adjacency shennanigans

/obj/machinery/door/firedoor/proc/remove_from_areas()
	if(affecting_areas)
		for(var/I in affecting_areas)
			var/area/A = I
			LAZYREMOVE(A.firedoors, src)

/obj/machinery/door/firedoor/Destroy()
	remove_from_areas()
	affecting_areas.Cut()
	return ..()

/obj/machinery/door/firedoor/Bumped(atom/movable/AM)
	if(panel_open || operating || welded)
		return
	return FALSE

/obj/machinery/door/firedoor/power_change()
	if(powered(power_channel))
		machine_stat &= ~NOPOWER
		INVOKE_ASYNC(src, PROC_REF(latetoggle))
	else
		machine_stat |= NOPOWER

/obj/machinery/door/firedoor/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	if(operating || !density)
		return

	user.visible_message("[user] bangs on \the [src].",
						 "You bang on \the [src].")
	playsound(loc, 'sound/effects/glassknock.ogg', 10, FALSE, frequency = 32000)

/obj/machinery/door/firedoor/attackby(obj/item/C, mob/user, params)
	add_fingerprint(user)
	if(operating)
		return

	if(welded)
		if(C.tool_behaviour == TOOL_WRENCH)
			if(boltslocked)
				to_chat(user, "<span class='notice'>There are screws locking the bolts in place!</span>")
				return
			C.play_tool_sound(src)
			user.visible_message("<span class='notice'>[user] starts undoing [src]'s bolts...</span>", \
								 "<span class='notice'>You start unfastening [src]'s floor bolts...</span>")
			if(!C.use_tool(src, user, 50))
				return
			playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] unfastens [src]'s bolts.</span>", \
								 "<span class='notice'>You undo [src]'s floor bolts.</span>")
			deconstruct(TRUE)
			return
		if(C.tool_behaviour == TOOL_SCREWDRIVER)
			user.visible_message("<span class='notice'>[user] [boltslocked ? "unlocks" : "locks"] [src]'s bolts.</span>", \
								 "<span class='notice'>You [boltslocked ? "unlock" : "lock"] [src]'s floor bolts.</span>")
			C.play_tool_sound(src)
			boltslocked = !boltslocked
			return

	return ..()

/obj/machinery/door/firedoor/try_to_activate_door(mob/user)
	return

/obj/machinery/door/firedoor/try_to_weld(obj/item/W, mob/user)
	if(!W.tool_behaviour == TOOL_WELDER)
		return
	if(!W.tool_start_check(user, amount=0))
		return
	user.visible_message("<span class='notice'>[user] starts [welded ? "unwelding" : "welding"] [src].</span>", "<span class='notice'>You start welding [src].</span>")
	if(W.use_tool(src, user, 40, volume=50))
		welded = !welded
		to_chat(user, "<span class='danger'>[user] [welded?"welds":"unwelds"] [src].</span>", "<span class='notice'>You [welded ? "weld" : "unweld"] [src].</span>")
		update_icon()

/obj/machinery/door/firedoor/try_to_crowbar(obj/item/I, mob/user)
	if(welded || operating)
		return

	if(density)
		if(is_holding_pressure())
			// tell the user that this is a bad idea, and have a do_after as well
			to_chat(user, "<span class='warning'>As you begin crowbarring \the [src] a gush of air blows in your face... maybe you should reconsider?</span>")
			if(!do_after(user, 1.5 SECONDS, src)) // give them a few seconds to reconsider their decision.
				return
			log_game("[key_name_admin(user)] has opened a firelock with a pressure difference at [AREACOORD(loc)]") // there bibby I made it logged just for you. Enjoy.
			// since we have high-pressure-ness, close all other firedoors on the tile
			whack_a_mole()
		if(welded || operating || !density)
			return // in case things changed during our do_after
		emergency_close_timer = world.time + 60 // prevent it from instaclosing again if in space
		open()
	else
		close()

/obj/machinery/door/firedoor/proc/allow_hand_open(mob/user)
	var/area/A = get_area(src)
	if(A && A.fire)
		return FALSE
	return !is_holding_pressure()

/obj/machinery/door/firedoor/attack_ai(mob/user)
	add_fingerprint(user)
	if(welded || operating || machine_stat & NOPOWER)
		return TRUE
	if(density)
		open()
	else
		close()
	return TRUE

/obj/machinery/door/firedoor/attack_robot(mob/user)
	return attack_ai(user)

/obj/machinery/door/firedoor/attack_alien(mob/user)
	add_fingerprint(user)
	if(welded)
		to_chat(user, "<span class='warning'>[src] refuses to budge!</span>")
		return
	open()

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)

/obj/machinery/door/firedoor/update_icon()
	cut_overlays()
	if(density)
		icon_state = "door_closed"
		if(welded)
			add_overlay("welded")
	else
		icon_state = "door_open"
		if(welded)
			add_overlay("welded_open")

/obj/machinery/door/firedoor/open()
	. = ..()
	latetoggle()

/obj/machinery/door/firedoor/close()
	. = ..()
	latetoggle()

/obj/machinery/door/firedoor/proc/whack_a_mole(reconsider_immediately = FALSE)
	set waitfor = 0
	for(var/cdir in GLOB.cardinals)
		if((flags_1 & ON_BORDER_1) && cdir != dir)
			continue
		whack_a_mole_part(get_step(src, cdir), reconsider_immediately)
	if(flags_1 & ON_BORDER_1)
		whack_a_mole_part(get_turf(src), reconsider_immediately)

/obj/machinery/door/firedoor/proc/whack_a_mole_part(turf/start_point, reconsider_immediately)
	set waitfor = 0
	var/list/doors_to_close = list()
	var/list/turfs = list()
	turfs[start_point] = 1
	for(var/i = 1; (i <= turfs.len && i <= 11); i++) // check up to 11 turfs.
		var/turf/open/T = turfs[i]
		if(istype(T, /turf/open/space))
			return -1
		for(var/T2 in T.atmos_adjacent_turfs)
			if(turfs[T2])
				continue
			var/is_cut_by_unopen_door = FALSE
			for(var/obj/machinery/door/firedoor/FD in T2)
				if((FD.flags_1 & ON_BORDER_1) && get_dir(T2, T) != FD.dir)
					continue
				if(FD.operating || FD == src || FD.welded || FD.density)
					continue
				doors_to_close += FD
				is_cut_by_unopen_door = TRUE

			for(var/obj/machinery/door/firedoor/FD in T)
				if((FD.flags_1 & ON_BORDER_1) && get_dir(T, T2) != FD.dir)
					continue
				if(FD.operating || FD == src || FD.welded || FD.density)
					continue
				doors_to_close += FD
				is_cut_by_unopen_door= TRUE
			if(!is_cut_by_unopen_door)
				turfs[T2] = 1
	if(turfs.len > 10)
		return // too big, don't bother
	for(var/obj/machinery/door/firedoor/FD in doors_to_close)
		FD.emergency_pressure_stop(FALSE)
		if(reconsider_immediately)
			var/turf/open/T = FD.loc
			if(istype(T))
				T.ImmediateCalculateAdjacentTurfs()

/obj/machinery/door/firedoor/proc/emergency_pressure_stop(consider_timer = TRUE)
	set waitfor = 0
	if(density || operating || welded)
		return
	if(world.time >= emergency_close_timer || !consider_timer)
		close()

/obj/machinery/door/firedoor/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/structure/firelock_frame/F = new assemblytype(get_turf(src))
		if(disassembled)
			F.constructionStep = CONSTRUCTION_PANEL_OPEN
		else
			F.constructionStep = CONSTRUCTION_WIRES_EXPOSED
			F.obj_integrity = F.max_integrity * 0.5
		F.update_icon()
	qdel(src)


/obj/machinery/door/firedoor/proc/latetoggle()
	if(operating || machine_stat & NOPOWER || !nextstate)
		return
	switch(nextstate)
		if(FIREDOOR_OPEN)
			nextstate = null
			open()
		if(FIREDOOR_CLOSED)
			nextstate = null
			close()

/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	flags_1 = ON_BORDER_1|DEFAULT_RICOCHET_1
	CanAtmosPass = ATMOS_PASS_PROC

/obj/machinery/door/firedoor/border_only/closed
	icon_state = "door_closed"
	opacity = TRUE
	density = TRUE

/obj/machinery/door/firedoor/border_only/close()
	if(density)
		return TRUE
	if(operating || welded)
		return
	var/turf/T1 = get_turf(src)
	var/turf/T2 = get_step(T1, dir)
	for(var/mob/living/M in T1)
		if(M.stat == CONSCIOUS && M.pulling && M.pulling.loc == T2 && !M.pulling.anchored && M.pulling.move_resist <= M.move_force)
			var/mob/living/M2 = M.pulling
			if(!istype(M2) || !M2.buckled || !M2.buckled.buckle_prevents_pull)
				to_chat(M, "<span class='notice'>You pull [M.pulling] through [src] right as it closes</span>")
				M.pulling.forceMove(T1)
				M.start_pulling(M2)

	for(var/mob/living/M in T2)
		if(M.stat == CONSCIOUS && M.pulling && M.pulling.loc == T1 && !M.pulling.anchored && M.pulling.move_resist <= M.move_force)
			var/mob/living/M2 = M.pulling
			if(!istype(M2) || !M2.buckled || !M2.buckled.buckle_prevents_pull)
				to_chat(M, "<span class='notice'>You pull [M.pulling] through [src] right as it closes</span>")
				M.pulling.forceMove(T2)
				M.start_pulling(M2)
	. = ..()

/obj/machinery/door/firedoor/border_only/allow_hand_open(mob/user)
	var/area/A = get_area(src)
	if((!A || !A.fire) && !is_holding_pressure())
		return TRUE
	whack_a_mole(TRUE) // WOOP WOOP SIDE EFFECTS
	var/turf/T = loc
	var/turf/T2 = get_step(T, dir)
	if(!T || !T2)
		return
	var/status1 = check_door_side(T)
	var/status2 = check_door_side(T2)
	if((status1 == 1 && status2 == -1) || (status1 == -1 && status2 == 1))
		to_chat(user, "<span class='warning'>Access denied. Try closing another firedoor to minimize decompression, or using a crowbar.</span>")
		return FALSE
	return TRUE

/obj/machinery/door/firedoor/border_only/proc/check_door_side(turf/open/start_point)
	var/list/turfs = list()
	turfs[start_point] = 1
	for(var/i = 1; (i <= turfs.len && i <= 11); i++) // check up to 11 turfs.
		var/turf/open/T = turfs[i]
		if(istype(T, /turf/open/space))
			return -1
		for(var/T2 in T.atmos_adjacent_turfs)
			turfs[T2] = 1
	if(turfs.len <= 10)
		return FALSE // not big enough to matter
	return start_point.air.return_pressure() < 20 ? -1 : 1

/obj/machinery/door/firedoor/border_only/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!(get_dir(loc, target) == dir)) //Make sure looking at appropriate border
		return TRUE

/obj/machinery/door/firedoor/border_only/CanAStarPass(obj/item/card/id/ID, to_dir)
	return !density || (dir != to_dir)

/obj/machinery/door/firedoor/border_only/CheckExit(atom/movable/mover as mob|obj, turf/target)
	if(get_dir(loc, target) == dir)
		return !density
	return TRUE

/obj/machinery/door/firedoor/border_only/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return TRUE

/obj/machinery/door/firedoor/heavy
	name = "heavy firelock"
	icon = 'icons/obj/doors/Doorfire.dmi'
	glass = FALSE
	explosion_block = 2
	assemblytype = /obj/structure/firelock_frame/heavy
	max_integrity = 550

/obj/machinery/door/firedoor/window
	name = "window shutter"
	icon = 'icons/obj/doors/doorfirewindow.dmi'
	desc = "A second window that slides in when the original window is broken, designed to protect against hull breaches. Truly a work of genius by GT engineers." //GS13 - NT to GT
	glass = TRUE
	explosion_block = 0
	max_integrity = 50
	resistance_flags = 0 // not fireproof
	heat_proof = FALSE

/obj/machinery/door/firedoor/window/allow_hand_open()
	return TRUE

/obj/item/electronics/firelock
	name = "firelock circuitry"
	custom_price = PRICE_CHEAP
	desc = "A circuit board used in construction of firelocks."
	icon_state = "mainboard"

/obj/structure/firelock_frame
	name = "firelock frame"
	desc = "A partially completed firelock."
	icon = 'icons/obj/doors/Doorfire.dmi'
	icon_state = "frame1"
	anchored = FALSE
	density = TRUE
	var/constructionStep = CONSTRUCTION_NOCIRCUIT
	var/reinforced = 0

/obj/structure/firelock_frame/examine(mob/user)
	. = ..()
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			. += "<span class='notice'>It is <i>unbolted</i> from the floor. A small <b>loosely connected</b> metal plate is covering the wires.</span>"
			if(!reinforced)
				. += "<span class='notice'>It could be reinforced with plasteel.</span>"
		if(CONSTRUCTION_WIRES_EXPOSED)
			. += "<span class='notice'>The maintenance plate has been <i>pried away</i>, and <b>wires</b> are trailing.</span>"
		if(CONSTRUCTION_GUTTED)
			. += "<span class='notice'>The maintenance panel is missing <i>wires</i> and the circuit board is <b>loosely connected</b>.</span>"
		if(CONSTRUCTION_NOCIRCUIT)
			. += "<span class='notice'>There are no <i>firelock electronics</i> in the frame. The frame could be <b>cut</b> apart.</span>"

/obj/structure/firelock_frame/update_icon_state()
	icon_state = "frame[constructionStep]"

/obj/structure/firelock_frame/attackby(obj/item/C, mob/user)
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			if(C.tool_behaviour == TOOL_CROWBAR)
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] starts prying something out from [src]...</span>", \
									 "<span class='notice'>You begin prying out the wire cover...</span>")
				if(!C.use_tool(src, user, 50))
					return
				if(constructionStep != CONSTRUCTION_PANEL_OPEN)
					return
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] pries out a metal plate from [src], exposing the wires.</span>", \
									 "<span class='notice'>You remove the cover plate from [src], exposing the wires.</span>")
				constructionStep = CONSTRUCTION_WIRES_EXPOSED
				update_icon()
				return
			if(C.tool_behaviour == TOOL_WRENCH)
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					to_chat(user, "<span class='warning'>There's already a firelock there.</span>")
					return
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] starts bolting down [src]...</span>", \
									 "<span class='notice'>You begin bolting [src]...</span>")
				if(!C.use_tool(src, user, 30))
					return
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					return
				user.visible_message("<span class='notice'>[user] finishes the firelock.</span>", \
									 "<span class='notice'>You finish the firelock.</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				if(reinforced)
					new /obj/machinery/door/firedoor/heavy(get_turf(src))
				else
					new /obj/machinery/door/firedoor(get_turf(src))
				qdel(src)
				return
			if(istype(C, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/P = C
				if(reinforced)
					to_chat(user, "<span class='warning'>[src] is already reinforced.</span>")
					return
				if(P.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need more plasteel to reinforce [src].</span>")
					return
				user.visible_message("<span class='notice'>[user] begins reinforcing [src]...</span>", \
									 "<span class='notice'>You begin reinforcing [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				if(do_after(user, 60, target = src))
					if(constructionStep != CONSTRUCTION_PANEL_OPEN || reinforced || P.get_amount() < 2 || !P)
						return
					user.visible_message("<span class='notice'>[user] reinforces [src].</span>", \
										 "<span class='notice'>You reinforce [src].</span>")
					playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
					P.use(2)
					reinforced = 1
				return

		if(CONSTRUCTION_WIRES_EXPOSED)
			if(C.tool_behaviour == TOOL_WIRECUTTER)
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] starts cutting the wires from [src]...</span>", \
									 "<span class='notice'>You begin removing [src]'s wires...</span>")
				if(!C.use_tool(src, user, 60))
					return
				if(constructionStep != CONSTRUCTION_WIRES_EXPOSED)
					return
				user.visible_message("<span class='notice'>[user] removes the wires from [src].</span>", \
									 "<span class='notice'>You remove the wiring from [src], exposing the circuit board.</span>")
				new/obj/item/stack/cable_coil(get_turf(src), 5)
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
			if(C.tool_behaviour == TOOL_CROWBAR)
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] starts prying a metal plate into [src]...</span>", \
									 "<span class='notice'>You begin prying the cover plate back onto [src]...</span>")
				if(!C.use_tool(src, user, 80))
					return
				if(constructionStep != CONSTRUCTION_WIRES_EXPOSED)
					return
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] pries the metal plate into [src].</span>", \
									 "<span class='notice'>You pry [src]'s cover plate into place, hiding the wires.</span>")
				constructionStep = CONSTRUCTION_PANEL_OPEN
				update_icon()
				return
		if(CONSTRUCTION_GUTTED)
			if(C.tool_behaviour == TOOL_CROWBAR)
				user.visible_message("<span class='notice'>[user] begins removing the circuit board from [src]...</span>", \
									 "<span class='notice'>You begin prying out the circuit board from [src]...</span>")
				if(!C.use_tool(src, user, 50, volume=50))
					return
				if(constructionStep != CONSTRUCTION_GUTTED)
					return
				user.visible_message("<span class='notice'>[user] removes [src]'s circuit board.</span>", \
									 "<span class='notice'>You remove the circuit board from [src].</span>")
				new /obj/item/electronics/firelock(drop_location())
				constructionStep = CONSTRUCTION_NOCIRCUIT
				update_icon()
				return
			if(istype(C, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/B = C
				if(B.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need more wires to add wiring to [src].</span>")
					return
				user.visible_message("<span class='notice'>[user] begins wiring [src]...</span>", \
									 "<span class='notice'>You begin adding wires to [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				if(do_after(user, 60, target = src))
					if(constructionStep != CONSTRUCTION_GUTTED || B.get_amount() < 5 || !B)
						return
					user.visible_message("<span class='notice'>[user] adds wires to [src].</span>", \
										 "<span class='notice'>You wire [src].</span>")
					playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
					constructionStep = CONSTRUCTION_WIRES_EXPOSED
					update_icon()
				return
		if(CONSTRUCTION_NOCIRCUIT)
			if(C.tool_behaviour == TOOL_WELDER)
				if(!C.tool_start_check(user, amount=1))
					return
				user.visible_message("<span class='notice'>[user] begins cutting apart [src]'s frame...</span>", \
									 "<span class='notice'>You begin slicing [src] apart...</span>")

				if(C.use_tool(src, user, 40, volume=50, amount=1))
					if(constructionStep != CONSTRUCTION_NOCIRCUIT)
						return
					user.visible_message("<span class='notice'>[user] cuts apart [src]!</span>", \
										 "<span class='notice'>You cut [src] into metal.</span>")
					var/turf/T = get_turf(src)
					new /obj/item/stack/sheet/metal(T, 3)
					if(reinforced)
						new /obj/item/stack/sheet/plasteel(T, 2)
					qdel(src)
				return
			if(istype(C, /obj/item/electronics/firelock))
				user.visible_message("<span class='notice'>[user] starts adding [C] to [src]...</span>", \
									 "<span class='notice'>You begin adding a circuit board to [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				if(!do_after(user, 40, target = src))
					return
				if(constructionStep != CONSTRUCTION_NOCIRCUIT)
					return
				qdel(C)
				user.visible_message("<span class='notice'>[user] adds a circuit to [src].</span>", \
									 "<span class='notice'>You insert and secure [C].</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
			if(istype(C, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/P = C
				if(!P.adapt_circuit(user, 30))
					return
				user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
				"<span class='notice'>You adapt a firelock circuit and slot it into the assembly.</span>")
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
	return ..()

/obj/structure/firelock_frame/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if((constructionStep == CONSTRUCTION_NOCIRCUIT) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
	return FALSE

/obj/structure/firelock_frame/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
			"<span class='notice'>You adapt a firelock circuit and slot it into the assembly.</span>")
			constructionStep = CONSTRUCTION_GUTTED
			update_icon()
			return TRUE
	return FALSE

/obj/structure/firelock_frame/heavy
	name = "heavy firelock frame"
	reinforced = TRUE

#undef CONSTRUCTION_COMPLETE
#undef CONSTRUCTION_PANEL_OPEN
#undef CONSTRUCTION_WIRES_EXPOSED
#undef CONSTRUCTION_GUTTED
#undef CONSTRUCTION_NOCIRCUIT
