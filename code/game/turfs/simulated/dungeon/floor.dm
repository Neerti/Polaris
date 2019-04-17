// Special floor type for Point of Interests.

/turf/simulated/floor/dungeon
	block_tele = TRUE // Anti-cheese.

/turf/simulated/floor/dungeon/ex_act()
	return


// Visual subtypes

/turf/simulated/floor/dungeon/tiled
	icon = 'icons/turf/flooring/tiles.dmi'

/turf/simulated/floor/dungeon/tiled/dark
	name = "dark floor"
	icon_state = "dark"