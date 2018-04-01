#define Z_LEVEL_FIRST_MAJOR_BILLS				1

/datum/map/major_bills
	name = "Bill's Shuttle #451"
	full_name = "MBTV Bill's Shuttle #451"
	path = "major_bills"

	lobby_icon = 'icons/misc/title.dmi'
	lobby_screens = list("major_bills")

	zlevel_datum_type = /datum/map_z_level/major_bills

	station_name  = "Bill's Shuttle #451"
	station_short = "Bill's Shuttle"
	dock_name     = "New Reykjavik, Sif"
	boss_name     = "Major Bill"
	boss_short    = "Bill"
	company_name  = "Major Bill's Transportation"
	company_short = "MB"
	starsys_name  = "Vir"

	shuttle_docked_message = "Major Bills will fly to the %dock_name% in approximately %ETD%. Please practice quoting The Slogan for when we arrive."
	shuttle_leaving_dock = "Major Bills's Shuttle is now in FTL, without major bills! Estimated %ETA% until the shuttle arrives at %dock_name%."
	shuttle_called_message = "%dock_name% is in need of Major Bill's affordable shipping prices. We will begin FTL prep in approximately %ETA%."
	shuttle_recall_message = "Major Bill is disappointed that we are not going anywhere yet."
	emergency_shuttle_docked_message = "I'm not really sure why an 'Emergency Shuttle' is needed, when clearly Major Bill's Shuttle is clearly superior, as such, we are \
	now that shuttle. We will jump in %ETD%."
	emergency_shuttle_leaving_dock = "Major Bills Shuttle is better than that other shuttle we turned away. We will arrive and use our Slogan at %dock_name% in %ETA%."
	emergency_shuttle_called_message = "Major Bill is disappointed that something terrible is happening and you're wanting to call it quits. Please reconsider."
	emergency_shuttle_recall_message = "Major Bill is happy that you came to your senses. Please resume Slogan practice."

	allowed_jobs = list(/datum/job/private_bill)

/datum/map_z_level/major_bills/first
	z = Z_LEVEL_FIRST_MAJOR_BILLS
	name = "The Only Floor You Will Need(TM)"
	flags = MAP_LEVEL_STATION|MAP_LEVEL_CONTACT|MAP_LEVEL_PLAYER
	transit_chance = 100
