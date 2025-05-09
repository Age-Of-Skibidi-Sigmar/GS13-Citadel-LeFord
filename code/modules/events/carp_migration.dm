/datum/round_event_control/carp_migration
	name = "Carp Migration"
	typepath = /datum/round_event/carp_migration
	weight = 15
	min_players = 5 //GS13 - tweaked player count, earlier start and max occurences, to fit lowpop better
	earliest_start = 20 MINUTES
	max_occurrences = 4
	category = EVENT_CATEGORY_ENTITIES
	description = "Summons a school of space carp."

/datum/round_event_control/carp_migration/New()
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CARP_INFESTATION))
		weight *= 3
		max_occurrences *= 2
		earliest_start *= 0.5

/datum/round_event/carp_migration
	announce_when	= 3
	start_when = 50
	var/hasAnnounced = FALSE

/datum/round_event/carp_migration/setup()
	start_when = rand(40, 60)

/datum/round_event/carp_migration/announce(fake)
	if(prob(50))
		priority_announce("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")
	else
		print_command_report("Unknown biological entities have been detected near [station_name()], you may wish to break out arms.", "Biological entities")


/datum/round_event/carp_migration/start()
	var/mob/living/simple_animal/hostile/carp/fish
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		if(prob(95))
			fish = new (C.loc)
		else
			fish = new /mob/living/simple_animal/hostile/carp/megacarp(C.loc)
			fishannounce(fish) //Prefer to announce the megacarps over the regular fishies
	fishannounce(fish)

/datum/round_event/carp_migration/proc/fishannounce(atom/fish)
	if (!hasAnnounced)
		announce_to_ghosts(fish) //Only anounce the first fish
		hasAnnounced = TRUE
