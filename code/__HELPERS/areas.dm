#define BP_MAX_ROOM_SIZE 300

//GS13 EDIT - makes it a list so that it'd actually protect all those areas from outages
GLOBAL_LIST_INIT(typecache_powerfailure_safe_areas, typecacheof(list(/area/engineering/main, \
															    /area/engineering/supermatter, \
															    /area/engineering/atmospherics_engine, \
															    /area/ai_monitored/turret_protected/ai)))
// GS13 END EDIT

//Repopulates sortedAreas list
/proc/repopulate_sorted_areas()
	GLOB.sortedAreas = list()

	for(var/area/A in world)
		GLOB.sortedAreas.Add(A)

	sortTim(GLOB.sortedAreas, GLOBAL_PROC_REF(cmp_name_asc))

/area/proc/addSorted()
	GLOB.sortedAreas.Add(src)
	sortTim(GLOB.sortedAreas, GLOBAL_PROC_REF(cmp_name_asc))

//Takes: Area type as a text string from a variable.
//Returns: Instance for the area in the world.
/proc/get_area_instance_from_text(areatext)
	if(istext(areatext))
		areatext = text2path(areatext)
	return GLOB.areas_by_type[areatext]

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/get_areas(areatype, subtypes=TRUE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null

	var/list/areas = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/V in GLOB.sortedAreas)
			var/area/A = V
			if(cache[A.type])
				areas += V
	else
		for(var/V in GLOB.sortedAreas)
			var/area/A = V
			if(A.type == areatype)
				areas += V
	return areas

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(areatype, target_z = 0, subtypes=FALSE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(islist(areatype))
		var/list/turfs = list()
		for(var/A in areatype)
			turfs += get_area_turfs(A)
		return turfs
	else if(!ispath(areatype))
		return null

	var/list/turfs = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/V in GLOB.sortedAreas)
			var/area/A = V
			if(!cache[A.type])
				continue
			for(var/turf/T in A)
				if(target_z == 0 || target_z == T.z)
					turfs += T
	else
		for(var/V in GLOB.sortedAreas)
			var/area/A = V
			if(A.type != areatype)
				continue
			for(var/turf/T in A)
				if(target_z == 0 || target_z == T.z)
					turfs += T
	return turfs
// Gets an atmos isolated contained space
// Returns an associative list of turf|dirs pairs
// The dirs are connected turfs in the same space
// break_if_found is a typecache of turf/area types to return false if found
// Please keep this proc type agnostic. If you need to restrict it do it elsewhere or add an arg.
/proc/detect_room(turf/origin, list/break_if_found, max_size=INFINITY)
	if(origin.blocks_air)
		return list(origin)

	. = list()
	var/list/checked_turfs = list()
	var/list/found_turfs = list(origin)
	while(found_turfs.len)
		var/turf/sourceT = found_turfs[1]
		found_turfs.Cut(1, 2)
		var/dir_flags = checked_turfs[sourceT]
		for(var/dir in GLOB.alldirs)
			if(length(.) > max_size)
				return
			if(dir_flags & dir) // This means we've checked this dir before, probably from the other turf
				continue
			var/turf/checkT = get_step(sourceT, dir)
			if(!checkT)
				continue
			checked_turfs[sourceT] |= dir
			checked_turfs[checkT] |= turn(dir, 180)
			.[sourceT] |= dir
			.[checkT] |= turn(dir, 180)
			if(break_if_found[checkT.type] || break_if_found[checkT.loc.type])
				return FALSE
			var/static/list/cardinal_cache = list("[NORTH]"=TRUE, "[EAST]"=TRUE, "[SOUTH]"=TRUE, "[WEST]"=TRUE)
			if(!cardinal_cache["[dir]"] || checkT.blocks_air || !TURFS_CAN_SHARE(sourceT, checkT))
				continue
			found_turfs += checkT // Since checkT is connected, add it to the list to be processed

/proc/create_area(mob/creator)
	// Passed into the above proc as list/break_if_found
	var/static/area_or_turf_fail_types = typecacheof(list(
		/turf/open/space,
		/area/shuttle,
		))
	// Ignore these areas and dont let people expand them. They can expand into them though
	var/static/blacklisted_areas = typecacheof(list(
		/area/space,
		))

	if(creator?.create_area_cooldown >= world.time)
		to_chat(creator, "<span class='warning'>You're trying to create a new area a little too fast.</span>")
		return
	creator.create_area_cooldown = world.time + 10

	var/list/turfs = detect_room(get_turf(creator), area_or_turf_fail_types, BP_MAX_ROOM_SIZE*2)
	if(!turfs)
		to_chat(creator, "<span class='warning'>The new area must be completely airtight and not a part of a shuttle.</span>")
		return
	if(turfs.len > BP_MAX_ROOM_SIZE)
		to_chat(creator, "<span class='warning'>The room you're in is too big. It is [turfs.len >= BP_MAX_ROOM_SIZE *2 ? "more than 100" : ((turfs.len / BP_MAX_ROOM_SIZE)-1)*100]% larger than allowed.</span>")
		return
	var/list/areas = list("New Area" = /area)
	for(var/i in 1 to turfs.len)
		var/area/place = get_area(turfs[i])
		if(blacklisted_areas[place.type])
			continue
		if(!place.requires_power || (place.area_flags & NOTELEPORT) || (place.area_flags & HIDDEN_AREA))
			continue // No expanding powerless rooms etc
		areas[place.name] = place
	var/area_choice = input(creator, "Choose an area to expand or make a new area.", "Area Expansion") as null|anything in areas
	area_choice = areas[area_choice]

	if(!area_choice)
		to_chat(creator, "<span class='warning'>No choice selected. The area remains undefined.</span>")
		return
	var/area/newA
	var/area/oldA = get_area(get_turf(creator))
	if(!isarea(area_choice))
		var/str = stripped_input(creator,"New area name:", "Blueprint Editing", "", MAX_NAME_LEN)
		if(!str || !length(str)) //cancel
			return
		if(length(str) > 50)
			to_chat(creator, "<span class='warning'>The given name is too long. The area remains undefined.</span>")
			return
		newA = new area_choice
		newA.setup(str)
		newA.set_dynamic_lighting()
		newA.has_gravity = oldA.has_gravity
	else
		newA = area_choice

	for(var/i in 1 to turfs.len)
		var/turf/thing = turfs[i]
		var/area/old_area = thing.loc
		newA.contents += thing
		thing.change_area(old_area, newA)

	newA.reg_in_areas_in_z()

	var/list/firedoors = oldA.firedoors
	for(var/door in firedoors)
		var/obj/machinery/door/firedoor/FD = door
		FD.CalculateAffectingAreas()

	to_chat(creator, "<span class='notice'>You have created a new area, named [newA.name]. It is now weather proof, and constructing an APC will allow it to be powered.</span>")
	return TRUE

/**
  * Returns the base area the target is located in if there is one.
  * Alternatively, returns the area as is.
  */
/proc/get_base_area(atom/target)
	var/area/A = get_area(target)
	if(A?.base_area)
		return A.base_area
	return A

/**
  * Returns either null, or a list containing every sub area associated with our base area.
  * If include_base is TRUE, the base area will also be added to the return list.
  */
/proc/get_sub_areas(atom/target, include_base = TRUE)
	var/area/A = get_area(target)
	if(!A)
		return
	. = list()
	if(A.base_area)
		A = A.base_area
	if(include_base)
		. += A
	if(A.sub_areas)
		. += A.sub_areas

/**
  * Proc used for purposes similar to get_areas_turfs(), but aimed to include associated areas.
  * Only accepts area instances and paths for the first arg, no text strings.
  * Returns a list of all turfs found in the sub areas (including the base's if include_base is TRUE)
  * and located in a z level matching target_z, or anywhere if target_z is 0
  */

/proc/get_sub_areas_turfs(area/A, target_z = 0, include_base = TRUE)
	var/list/contents = get_sub_areas_contents(A, include_base)
	. = list()
	for(var/turf/T in contents)
		if(target_z == 0 || target_z == T.z)
			. += T
/**
  * Simple proc that returns a sum of all contents from every sub area,
  * Think of the above but for all contents, not just turfs, and without target z.
  */

/proc/get_sub_areas_contents(area/A, include_base = TRUE)
	if(ispath(A))
		A = GLOB.areas_by_type[A]
	else
		A = get_area(A) //in case it's called on other atoms.
	if(!A)
		return
	if(A.base_area)
		A = A.base_area
	. = list(A.contents)
	for(var/i in A.sub_areas)
		. += A.sub_areas[i].contents

#undef BP_MAX_ROOM_SIZE
