/turf/open/floor
	//NOTE: Floor code has been refactored, many procs were removed and refactored
	//- you should use istype() if you want to find out whether a floor has a certain type
	//- floor_tile is now a path, and not a tile obj
	name = "floor"
	icon = 'GainStation13/icons/turf/floors.dmi' //GS13 change (so our floors are used instead)
	baseturfs = /turf/open/floor/plating
	dirt_buildup_allowed = TRUE

	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	flags_1 = NO_SCREENTIPS_1

	/// Minimum explosion power to break tile
	var/explosion_power_break_tile = EXPLOSION_POWER_FLOOR_TILE_BREAK
	/// Minimum explosion power to break turf
	var/explosion_power_break_turf = EXPLOSION_POWER_FLOOR_TURF_BREAK
	//// Minimum explosion power to scrape away the floor
	var/explosion_power_turf_scrape = EXPLOSION_POWER_FLOOR_TURF_SCRAPE
	//// Shielded turfs are completely protected from anything under this
	var/explosion_power_protect_shielded = EXPLOSION_POWER_FLOOR_SHIELDED_IMMUNITY
	/// Starting from here, there's a chance for this to break
	var/explosion_power_minimum_chance_break = EXPLOSION_POWER_FLOOR_MINIMUM_TURF_BREAK
	/// Starting from here, +20% chance to break turf.
	var/explosion_power_break_turf_bonus = EXPLOSION_POWER_FLOOR_TURF_BREAK_BONUS

	var/icon_regular_floor = "floor" //used to remember what icon the tile should have by default
	var/icon_plating = "plating"
	thermal_conductivity = 0.04
	heat_capacity = 10000
	intact = 1
	var/broken = 0
	var/burnt = 0
	var/floor_tile = null //tile that this floor drops
	var/list/broken_states
	var/list/burnt_states

	tiled_dirt = TRUE

/turf/open/floor/Initialize(mapload)
	if (!broken_states)
		broken_states = typelist("broken_states", list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5"))
	else
		broken_states = typelist("broken_states", broken_states)
	burnt_states = typelist("burnt_states", burnt_states)
	if(!broken && broken_states && (icon_state in broken_states))
		broken = TRUE
	if(!burnt && burnt_states && (icon_state in burnt_states))
		burnt = TRUE
	. = ..()
	//This is so damaged or burnt tiles or platings don't get remembered as the default tile
	var/static/list/icons_to_ignore_at_floor_init = list("foam_plating", "plating","light_on","light_on_flicker1","light_on_flicker2",
					"light_on_clicker3","light_on_clicker4","light_on_clicker5",
					"light_on_broken","light_off","wall_thermite","grass", "sand",
					"asteroid","asteroid_dug",
					"asteroid0","asteroid1","asteroid2","asteroid3","asteroid4",
					"asteroid5","asteroid6","asteroid7","asteroid8","asteroid9","asteroid10","asteroid11","asteroid12",
					"basalt","basalt_dug",
					"basalt0","basalt1","basalt2","basalt3","basalt4",
					"basalt5","basalt6","basalt7","basalt8","basalt9","basalt10","basalt11","basalt12",
					"oldburning","light-on-r","light-on-y","light-on-g","light-on-b", "wood", "carpetsymbol", "carpetstar",
					"carpetcorner", "carpetside", "carpet", "arcade", "ironsand1", "ironsand2", "ironsand3", "ironsand4", "ironsand5",
					"ironsand6", "ironsand7", "ironsand8", "ironsand9", "ironsand10", "ironsand11",
					"ironsand12", "ironsand13", "ironsand14", "ironsand15",
					"snow", "snow0", "snow1", "snow2", "snow3", "snow4", "snow5", "snow6", "snow7", "snow8", "snow9", "snow10", "snow11", "snow12", "snow-ice", "snow_dug",
					"unsmooth", "smooth", "1-i", "2-i", "3-i", "4-i", "1-n", "2-n", "3-s", "4-s", "1-w", "2-e", "3-w", "4-e", "1-nw", "2-ne", "3-sw", "4-se", "1-f", "2-f", "3-f", "4-f")
	if(broken || burnt || (icon_state in icons_to_ignore_at_floor_init)) //so damaged/burned tiles or plating icons aren't saved as the default
		icon_regular_floor = "floor"
	else
		icon_regular_floor = icon_state
	if(mapload && prob(66)) // 2/3 instead of 1/3 (default)
		MakeDirty()

/turf/open/floor/ex_act(severity, target, origin)
	var/shielded = is_shielded()
	..()
	if(severity != 1 && shielded && target != src)
		return
	if(target == src)
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return
	if(target != null)
		severity = 3

	switch(severity)
		if(1)
			ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
		if(2)
			switch(pick(1,2;75,3))
				if(1)
					if(!length(baseturfs) || !ispath(baseturfs[baseturfs.len-1], /turf/open/floor))
						ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
						ReplaceWithLattice()
					else
						ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
					if(prob(33))
						new /obj/item/stack/sheet/metal(src)
				if(2)
					ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
				if(3)
					if(prob(80))
						ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					else
						break_tile()
					hotspot_expose(1000,CELL_VOLUME)
					if(prob(33))
						new /obj/item/stack/sheet/metal(src)
		if(3)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)

/turf/open/floor/wave_ex_act(power, datum/wave_explosion/explosion, dir)
	var/shielded = is_shielded()
	. = ..()
	if(shielded)
		if(power < explosion_power_protect_shielded)
			return
		else
			power -= explosion_power_protect_shielded
	hotspot_expose(1000, CELL_VOLUME)
	if(power < explosion_power_break_tile)
		return
	if(power < explosion_power_minimum_chance_break)
		if(prob(33 + ((explosion_power_break_turf - power) / (explosion_power_break_turf - explosion_power_break_tile))))
			break_tile()
		return
	if((power < explosion_power_turf_scrape) && ((power >= explosion_power_break_turf) || prob((1 - ((explosion_power_break_turf - power) / (explosion_power_break_turf - explosion_power_minimum_chance_break))) * 100 + ((power > explosion_power_break_turf_bonus)? 20 : 0))))
		switch(pick(1, 2;75, 3))
			if(1)
				if(!length(baseturfs) || !ispath(baseturfs[baseturfs.len-1], /turf/open/floor))
					ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					ReplaceWithLattice()
				else
					ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
				if(prob(33))
					new /obj/item/stack/sheet/metal(src)
				return
			if(2)
				ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
				return
			if(3)
				if(prob(80))
					ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					return
				else
					break_tile()
				hotspot_expose(1000,CELL_VOLUME)
				if(prob(33))
					new /obj/item/stack/sheet/metal(src)
	if(power >= explosion_power_turf_scrape)
		ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
		return

/turf/open/floor/is_shielded()
	for(var/obj/structure/A in contents)
		if(A.level == 3)
			return TRUE

/turf/open/floor/blob_act(obj/structure/blob/B)
	return

/turf/open/floor/attack_paw(mob/user)
	return attack_hand(user)

/turf/open/floor/proc/gets_drilled()
	return

/turf/open/floor/proc/break_tile_to_plating()
	var/turf/open/floor/plating/T = make_plating()
	if(!istype(T))
		return
	T.break_tile()

/turf/open/floor/proc/break_tile()
	if(broken)
		return
	icon_state = pick(broken_states)
	broken = 1

/turf/open/floor/burn_tile()
	if(broken || burnt)
		return
	if(burnt_states.len)
		icon_state = pick(burnt_states)
	else
		icon_state = pick(broken_states)
	burnt = 1

/turf/open/floor/proc/make_plating()
	for(var/obj/effect/decal/cleanable/C in src)
		if(C.wiped_by_floor_change)
			qdel(C)
	return ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/ChangeTurf(path, new_baseturf, flags)
	if(!isfloorturf(src))
		return ..() //fucking turfs switch the fucking src of the fucking running procs
	if(!ispath(path, /turf/open/floor))
		return ..()
	var/old_icon = icon_regular_floor
	var/old_dir = dir
	var/turf/open/floor/W = ..()
	//GS13 EDIT START
	if(!(W.type in subtypesof(/turf/open/floor/plasteel)))
		W.icon_regular_floor = old_icon
	//GS13 EDIT END
	W.setDir(old_dir)
	W.update_icon()
	return W

/turf/open/floor/attackby(obj/item/C, mob/user, params)
	if(!C || !user)
		return TRUE
	if(..())
		return TRUE
	if(intact && istype(C, /obj/item/stack/tile))
		try_replace_tile(C, user, params)
	return FALSE

/turf/open/floor/crowbar_act(mob/living/user, obj/item/I)
	return intact ? FORCE_BOOLEAN(pry_tile(I, user)) : FALSE

/turf/open/floor/proc/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type)
		return
	var/obj/item/CB = user.is_holding_tool_quality(TOOL_CROWBAR)
	if(!CB)
		return
	var/turf/open/floor/plating/P = pry_tile(CB, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

/turf/open/floor/proc/pry_tile(obj/item/I, mob/user, silent = FALSE)
	I.play_tool_sound(src, 80)
	return remove_tile(user, silent)

/turf/open/floor/proc/remove_tile(mob/user, silent = FALSE, make_tile = TRUE, forced = FALSE)
	if(broken || burnt)
		broken = 0
		burnt = 0
		if(user && !silent)
			to_chat(user, "<span class='notice'>You remove the broken plating.</span>")
	else
		if(user && !silent)
			to_chat(user, "<span class='notice'>You remove the floor tile.</span>")
		if(floor_tile && make_tile)
			spawn_tile()
	return make_plating()

/turf/open/floor/proc/spawn_tile()
	new floor_tile(src)

/turf/open/floor/singularity_pull(S, current_size)
	. = ..()
	switch(current_size)
		if(STAGE_THREE)
			if(floor_tile && prob(30))
				remove_tile()
		if(STAGE_FOUR)
			if(floor_tile && prob(50))
				remove_tile()
		if(STAGE_FIVE to INFINITY)
			if(floor_tile)
				if(prob(70))
					remove_tile()
			else if(prob(50) && (/turf/open/space in baseturfs))
				ReplaceWithLattice()

/turf/open/floor/narsie_act(force, ignore_mobs, probability = 20)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/floor/clockwork, flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/acid_melt()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			return list("mode" = RCD_FLOORWALL, "delay" = 20, "cost" = 16)
		if(RCD_AIRLOCK)
			if(the_rcd.airlock_glass)
				return list("mode" = RCD_AIRLOCK, "delay" = 50, "cost" = 20)
			else
				return list("mode" = RCD_AIRLOCK, "delay" = 50, "cost" = 16)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 33)
		if(RCD_WINDOWGRILLE)
			return list("mode" = RCD_WINDOWGRILLE, "delay" = 10, "cost" = 4)
		if(RCD_GIRDER)
			return list("mode" = RCD_GIRDER, "delay" = 20, "cost" = 10) //gs13 - girder mode
		if(RCD_MACHINE)
			return list("mode" = RCD_MACHINE, "delay" = 20, "cost" = 25)
		if(RCD_COMPUTER)
			return list("mode" = RCD_COMPUTER, "delay" = 20, "cost" = 25)
	return FALSE

/turf/open/floor/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, "<span class='notice'>You build a wall.</span>")
			PlaceOnTop(/turf/closed/wall)
			return TRUE
		if(RCD_AIRLOCK)
			if(locate(/obj/machinery/door/airlock) in src)
				return FALSE
			to_chat(user, "<span class='notice'>You build an airlock.</span>")
			var/obj/machinery/door/airlock/A = new the_rcd.airlock_type(src)

			A.setDir(the_rcd.airlock_dir) //GS13 - directional airlocks edit
			A.electronics = new/obj/item/electronics/airlock(A)

			if(the_rcd.conf_access)
				A.electronics.accesses = the_rcd.conf_access.Copy()
			A.electronics.one_access = the_rcd.use_one_access

			if(A.electronics.one_access)
				A.req_one_access = A.electronics.accesses
			else
				A.req_access = A.electronics.accesses
			A.autoclose = TRUE
			return TRUE
		if(RCD_DECONSTRUCT)
			if(!ScrapeAway(flags = CHANGETURF_INHERIT_AIR))
				return FALSE
			to_chat(user, "<span class='notice'>You deconstruct [src].</span>")
			return TRUE
		if(RCD_WINDOWGRILLE)
			if(locate(/obj/structure/grille) in src)
				return FALSE
			to_chat(user, "<span class='notice'>You construct the grille.</span>")
			var/obj/structure/grille/G = new(src)
			G.anchored = TRUE
			return TRUE
		if(RCD_GIRDER) //gs13 - girder mode
			if(locate(/obj/structure/girder) in src)
				return FALSE
			var/obj/structure/girder/R = new(src)
			R.anchored = TRUE
			return TRUE
		if(RCD_MACHINE)
			if(locate(/obj/structure/frame/machine) in src)
				return FALSE
			var/obj/structure/frame/machine/M = new(src)
			M.state = 2
			M.icon_state = "box_1"
			M.anchored = TRUE
			return TRUE
		if(RCD_COMPUTER)
			if(locate(/obj/structure/frame/computer) in src)
				return FALSE
			var/obj/structure/frame/computer/C = new(src)
			C.anchored = TRUE
			C.setDir(the_rcd.computer_dir)
			return TRUE

	return FALSE

/turf/open/floor/material
	name = "floor"
	icon_state = "materialfloor"
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/turf/open/floor/material/spawn_tile()
	for(var/i in custom_materials)
		var/datum/material/M = i
		new M.sheet_type(src, FLOOR(custom_materials[M] / MINERAL_MATERIAL_AMOUNT, 1))
