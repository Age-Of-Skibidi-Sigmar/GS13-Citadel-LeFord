/datum/round_event_control/blob
	name = "Blob"
	typepath = /datum/round_event/ghost_role/blob
	weight = 10
	max_occurrences = 0 //GS13 - let's not

	earliest_start = 40 MINUTES
	min_players = 35
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns a new blob overmind."

/datum/round_event/ghost_role/blob
	announce_when	= -1
	role_name = "blob overmind"
	fakeable = TRUE

/datum/round_event/ghost_role/blob/announce(fake)
	if(prob(75))
		priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", "outbreak5", has_important_message = TRUE)
	else
		print_command_report("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "level 5 biohazard")

/datum/round_event/ghost_role/blob/spawn_role()
	if(!GLOB.blobstart.len)
		return MAP_ERROR
	var/list/candidates = get_candidates(ROLE_BLOB, null, ROLE_BLOB)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/new_blob = pick(candidates)
	var/mob/camera/blob/BC = new_blob.become_overmind()
	spawned_mobs += BC
	message_admins("[ADMIN_LOOKUPFLW(BC)] has been made into a blob overmind by an event.")
	log_game("[key_name(BC)] was spawned as a blob overmind by an event.")
	return SUCCESSFUL_SPAWN
