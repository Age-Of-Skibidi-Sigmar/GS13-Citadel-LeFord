//Shadowwood tables
/obj/structure/table/shadoww
	name = "Shadow wood table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon = 'GainStation13/icons/obj/smooth_structures/shadoww_table.dmi'
	icon_state = "shadoww_table"
	frame = /obj/structure/table_frame/shadoww
	framestack = /obj/item/stack/sheet/mineral/shadoww
	buildstack = /obj/item/stack/sheet/mineral/shadoww
	resistance_flags = FLAMMABLE
	max_integrity = 70
	canSmoothWith = list(/obj/structure/table/shadoww,
		/obj/structure/table/shadoww/shadowwpoker)

/obj/structure/table/shadoww/shadowwpoker
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'GainStation13/icons/obj/smooth_structures/shadowwpoker_table.dmi'
	icon_state = "shadowwpoker_table"
	frame = /obj/structure/table_frame/shadoww
	buildstack = /obj/item/stack/tile/carpet

//Plaswood tables
/obj/structure/table/plaswood
	name = "plaswood table"
	desc = "An strong and grey wooden table."
	icon = 'GainStation13/icons/obj/smooth_structures/plaswood_table.dmi'
	icon_state = "plaswood_table"
	frame = /obj/structure/table_frame/plaswood
	framestack = /obj/item/stack/sheet/mineral/plaswood
	buildstack = /obj/item/stack/sheet/mineral/plaswood
	resistance_flags = FLAMMABLE
	max_integrity = 200
	integrity_failure = 50
	armor = list("melee" = 10, "bullet" = 30, "laser" = 30, "energy" = 100, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)
	canSmoothWith = list(/obj/structure/table/plaswood,
		/obj/structure/table/plaswood/plaswoodpoker)

/obj/structure/table/plaswood/plaswoodpoker
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'GainStation13/icons/obj/smooth_structures/plaswoodpoker_table.dmi'
	icon_state = "plaswoodpoker_table"
	frame = /obj/structure/table_frame/plaswood
	buildstack = /obj/item/stack/tile/carpet


//Mushroom tables
/obj/structure/table/gmushroom
	name = "Mushroom table"
	desc = "A pinkish table. And is fireproof!"
	icon = 'GainStation13/icons/obj/smooth_structures/gmushroom_table.dmi'
	icon_state = "gmushroom_table"
	frame = /obj/structure/table_frame/gmushroom
	framestack = /obj/item/stack/sheet/mineral/gmushroom
	buildstack = /obj/item/stack/sheet/mineral/gmushroom
	resistance_flags = FIRE_PROOF
	max_integrity = 70
	canSmoothWith = list(/obj/structure/table/gmushroom,
		/obj/structure/table/gmushroom/gmushroompoker)

/obj/structure/table/gmushroom/gmushroompoker
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'GainStation13/icons/obj/smooth_structures/gmushroompoker_table.dmi'
	icon_state = "gmushroompoker_table"
	frame = /obj/structure/table_frame/gmushroom
	buildstack = /obj/item/stack/tile/carpet
