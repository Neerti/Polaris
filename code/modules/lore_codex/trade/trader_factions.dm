var/list/all_trading_factions = list(
	TSC_NT		= new /datum/trader_faction/nanotrasen(),
	TSC_HEPH	= new /datum/trader_faction/hephaestus(),
	TSC_VM		= new /datum/trader_faction/vey_med(),
	TSC_ZH		= new /datum/trader_faction/zeng_hu(),
	TSC_WT		= new /datum/trader_faction/ward_takahashi(),
	TSC_BC		= new /datum/trader_faction/bishop(),
	TSC_MORPH	= new /datum/trader_faction/morpheus(),
	TSC_XION	= new /datum/trader_faction/xion(),
	TSC_GIL		= new /datum/trader_faction/gilthari(),
	TSC_AETHER	= new /datum/trader_faction/aether(),
	TSC_FOCAL	= new /datum/trader_faction/focal_point(),
	TSC_GRAYSON	= new /datum/trader_faction/grayson()
	)

/datum/trader_faction
	var/name = "default"
	var/desc = "A large blurb about the faction here."
	var/reputation_desc = "A list of things the faction likes or dislikes."
	var/reputation = 0	// How much the faction as a whole likes or dislikes the station.
	var/default_reputation = 0 // Roundstart rep.
	var/list/trader_types = list()

/datum/trader_faction/New()
	..()
	reputation = default_reputation

/datum/trader_faction/proc/adjust_reputation(amount)
	reputation = between(-100, reputation + amount, 100)

/proc/modify_trader_reputation(var/faction_name, var/amount)
	if(!faction_name in all_trading_factions)
		message_admins("Error: modify_reputation() was given an incorrect faction name, which was [faction_name].")

	var/datum/trader_faction/faction = all_trading_factions[faction_name]
	faction.adjust_reputation(amount)


// Guns and weapons.
/datum/trader_faction/hephaestus
	name = "Hephaestus Industries"

// Medical things.
/datum/trader_faction/vey_med
	name = "Vey-Medical"
	default_reputation = -25 // Competitor to NT.

// Medicine.
/datum/trader_faction/zeng_hu
	name = "Zeng-Hu Pharmaceuticals"
	default_reputation = -45 // Bitter rival.

// Computers.
/datum/trader_faction/ward_takahashi
	name = "Ward Takahashi"
	default_reputation = -15 // Somewhat competes with NT.

// Fancy prosthetics.
/datum/trader_faction/bishop
	name = "Bishop Cybernetics"

// Less fancy prosethetics and snark.
/datum/trader_faction/morpheus
	name = "Morpheus Cyberkinetics"

// Mining stuff.
/datum/trader_faction/xion
	name = "Xion Manufacturing Group"

// Luxury and booze.
/datum/trader_faction/gilthari
	name = "Gilthari Exports"

// Atmospherics.
/datum/trader_faction/aether
	name = "Aether Atmospherics & Recycling"



// Disaster relief and maybe surplus gear.
/datum/trader_faction/sifgov
	name = "Sif Governmental Authority"