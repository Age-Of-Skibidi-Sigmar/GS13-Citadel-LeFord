//GS13: Shadow Wood

GLOBAL_LIST_INIT(shadoww_recipes, list ( \
		new/datum/stack_recipe("Shadow wood floor tile", /obj/item/stack/tile/shadoww, 1, 4, 20), \
		new/datum/stack_recipe("Shadow wood table frame", /obj/structure/table_frame/shadoww, 2, time = 10), \
		new/datum/stack_recipe("Shadow wood barricade", /obj/structure/barricade/shadoww, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
		null, \
		new/datum/stack_recipe("Shadow wood chair", /obj/structure/chair/shadoww, 3, time = 10, one_per_turf = TRUE, on_floor = TRUE), \
		null, \
		new/datum/stack_recipe("Shadow wood barricade", /obj/structure/barricade/shadoww, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
		null, \
		new/datum/stack_recipe("Dog bed", /obj/structure/bed/shadowwdogbed, 10, time = 10, one_per_turf = TRUE, on_floor = TRUE), \
		new/datum/stack_recipe("Dresser", /obj/structure/shadowwdresser, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE), \
		new/datum/stack_recipe("shadow wood crate", /obj/structure/closet/crate/shadoww, 6, time = 50, one_per_turf = TRUE, on_floor = TRUE),\
))


/obj/item/stack/sheet/mineral/shadoww
	name = "shadow wood"
	desc = "An purplish wood, it's nothing special besides its color."
	singular_name = "shadow wood plank"
	icon_state = "sheet-shadoww"
	item_state = "sheet-shadoww"
	icon = 'GainStation13/icons/obj/stack_objects.dmi'
	custom_materials = list(/datum/material/wood=MINERAL_MATERIAL_AMOUNT)
	sheettype = "shadoww"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 0)
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/mineral/shadoww
	novariants = TRUE
	grind_results = list(/datum/reagent/carbon = 20)
	walltype = /turf/closed/wall/mineral/shadoww

/obj/item/stack/sheet/mineral/shadoww/get_main_recipes()
	. = ..()
	. += GLOB.shadoww_recipes

/obj/item/stack/sheet/mineral/shadoww/fifty
	amount = 50

/obj/item/stack/sheet/mineral/shadoww/twenty
	amount = 20

/obj/item/stack/sheet/mineral/shadoww/ten
	amount = 10

/obj/item/stack/sheet/mineral/shadoww/five
	amount = 5

//GS13: Giant mushroom

GLOBAL_LIST_INIT(gmushroom_recipes, list ( \
		new/datum/stack_recipe("Mushroom floor tile", /obj/item/stack/tile/gmushroom, 1, 4, 20), \
		new/datum/stack_recipe("Mushroom table frame", /obj/structure/table_frame/gmushroom, 2, time = 10), \
		new/datum/stack_recipe("Mushroom barricade", /obj/structure/barricade/gmushroom, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
		null, \
		new/datum/stack_recipe("Mushroom chair", /obj/structure/chair/gmushroom, 3, time = 10, one_per_turf = TRUE, on_floor = TRUE), \
		null, \
		new/datum/stack_recipe("Mushroom barricade", /obj/structure/barricade/gmushroom, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
		null, \
		new/datum/stack_recipe("Dog bed", /obj/structure/bed/gmushroomdogbed, 10, time = 10, one_per_turf = TRUE, on_floor = TRUE), \
		new/datum/stack_recipe("Dresser", /obj/structure/gmushroomdresser, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE), \
		new/datum/stack_recipe("Mushroom crate", /obj/structure/closet/crate/gmushroom, 6, time = 50, one_per_turf = TRUE, on_floor = TRUE),\
		null, \
))

/obj/item/stack/sheet/mineral/gmushroom
	name = "mushroom 'wood'"
	desc = "A material similar to wood, except for being fireproof."
	singular_name = "mushroom plank"
	icon_state = "sheet-gmushroom"
	item_state = "sheet-gmushroom"
	icon = 'GainStation13/icons/obj/stack_objects.dmi'
	sheettype = "gmushroom"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 0)
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/mineral/gmushroom
	novariants = TRUE
	grind_results = list(/datum/reagent/carbon = 20)
	walltype = /turf/closed/wall/mineral/gmushroom

/obj/item/stack/sheet/mineral/gmushroom/get_main_recipes()
	. = ..()
	. += GLOB.gmushroom_recipes

/obj/item/stack/sheet/mineral/gmushroom/fifty
	amount = 50

/obj/item/stack/sheet/mineral/gmushroom/twenty
	amount = 20

/obj/item/stack/sheet/mineral/gmushroom/ten
	amount = 10

/obj/item/stack/sheet/mineral/gmushroom/five
	amount = 5

//GS13: Plaswood

GLOBAL_LIST_INIT(plaswood_recipes, list ( \
		new/datum/stack_recipe("Plaswood floor tile", /obj/item/stack/tile/plaswood, 1, 4, 20), \
		new/datum/stack_recipe("Plaswood table frame", /obj/structure/table_frame/plaswood, 2, time = 10), \
		null, \
		new/datum/stack_recipe("Plaswood chair", /obj/structure/chair/plaswood, 3, time = 10, one_per_turf = TRUE, on_floor = TRUE), \
		null, \
		new/datum/stack_recipe("Plaswood barricade", /obj/structure/barricade/plaswood, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
		null, \
		new/datum/stack_recipe("Dog bed", /obj/structure/bed/plaswooddogbed, 10, time = 10, one_per_turf = TRUE, on_floor = TRUE), \
		new/datum/stack_recipe("Dresser", /obj/structure/plaswooddresser, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE), \
		new/datum/stack_recipe("Plaswood crate", /obj/structure/closet/crate/plaswood, 6, time = 50, one_per_turf = TRUE, on_floor = TRUE),\
		null, \
))


/obj/item/stack/sheet/mineral/plaswood
	name = "plaswood"
	desc = "A type of resistant wood acquired from Plasma Trees. It amost looks like metal!"
	singular_name = "plaswood plank"
	icon_state = "sheet-plaswood"
	item_state = "sheet-plaswood"
	icon = 'GainStation13/icons/obj/stack_objects.dmi'
	sheettype = "plaswood"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 80)
	resistance_flags = FLAMMABLE | ACID_PROOF
	throwforce = 10
	merge_type = /obj/item/stack/sheet/mineral/plaswood
	novariants = TRUE
	grind_results = list(/datum/reagent/carbon = 20, /datum/reagent/toxin/plasma = 20)
	point_value = 23
	walltype = /turf/closed/wall/mineral/plaswood

/obj/item/stack/sheet/mineral/plaswood/get_main_recipes()
	. = ..()
	. += GLOB.plaswood_recipes

/obj/item/stack/sheet/mineral/plaswood/fifty
	amount = 50

/obj/item/stack/sheet/mineral/plaswood/twenty
	amount = 20

/obj/item/stack/sheet/mineral/plaswood/ten
	amount = 10

/obj/item/stack/sheet/mineral/plaswood/five
	amount = 5
