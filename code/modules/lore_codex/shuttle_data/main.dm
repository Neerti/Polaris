// Essentially an in-game reference for how the shuttle mechanics work.

/datum/lore/codex/category/main_shuttle // The top-level categories for the shuttle owner's manual
	name = "Index"
	data = "Welcome. You, or your employer, are now the proud owner of a spacecraft produced by Wulf Aeronautics.\
	<br><br>\
	Contained inside this manual are instructions on how to use, maintain, repair, and refit your spacecraft."
	children = list(
		/datum/lore/codex/page/shuttle_speeds,
		/datum/lore/codex/page/shuttle_mount_points,
		/datum/lore/codex/page/shuttle_components,
		/datum/lore/codex/page/shuttle_component_thrusters,
		/datum/lore/codex/page/shuttle_component_ftl,
		/datum/lore/codex/page/shuttle_component_capacitor,
		/datum/lore/codex/page/shuttle_component_hull_augment,
		/datum/lore/codex/page/shuttle_component_engine_augment,
		/datum/lore/codex/page/shuttle_component_electronic_augment,
		/datum/lore/codex/page/shuttle_repair
		)

/datum/lore/codex/page/shuttle_speeds
	name = "Piloting - Engine Throttle Settings"
	data = "This shuttle, like most others, contains controls for the propulsion systems. These can be accessed at the \
	main console in the cockpit. The shuttle has three preconfigured settings for throttle control; 'Slow', 'Normal', \
	and 'Hyper'.\
	<br><br>\
	Slow will reduce thrust output by approximately 50%. Running at reduced levels is somewhat more energy efficent than \
	running at full power would be, and it may also be safer to do so in certain situations that require fine control. \
	The Autopilot (if included with your model) is locked to running at this level, unless special hardware is installed \
	(sold seperately).\
	<br><br>\
	Normal is the standard setting, and will produce the full amount of thrust from the propulsion systems installed on \
	the shuttle. It should be suitable for most purposes when the shuttle is crewed with a qualified pilot.\
	<br><br>\
	Hyper is a dangerous setting that should only be used in emergencies. It bypasses the safety systems in the ship \
	in order to deliver the maximum possible power to the engines. Propulsion output can reach approximately 200%, \
	however the shuttle will be damaged with even brief use. Energy demand will also spike, and flying can be \
	more hazardous in certain situations, particularly those that demand precision. Finally, it will void the \
	warranty on your spacecraft (if applicable)."

/datum/lore/codex/page/shuttle_mount_points
	name = "Refitting - Mount Points"
	data = "Your ship includes various components, most of which are required for the ship to function, such as \
	propulsion systems. These systems are mounted onto the vessel directly at specific locations called \
	mount points. Mount points are static and integral to the core of the ship, and cannot be moved. \
	Mount point connectors are modular, meaning that one component can be exchanged for another similar \
	component, without any retrofitting required. A wrench or similar tool can be used to mount or \
	unmount a component from the mount point.\
	<br><br>\
	Note that mount points are specific to a type of component. You cannot attach a hull augmentation to a thruster \
	mount point, for example."

/datum/lore/codex/page/shuttle_components
	name = "Maintenance - Components (Basic)"
	data = "The shuttle is made up of various components, attached to mount points all over the vessel. \
	Each component has a specific purpose, which will be elaborated in specific sections of this manual. \
	Components can suffer damage from many sources ranging from meteorite impacts, to EM interferance, to \
	attrition from regular use.\
	<br><br>\
	Regular maintenance will ensure that your craft will continue functioning \
	for a very long time. Ignoring accumulating damage on components can cause internal faults to appear, \
	which make the component be less effective. Faults that are not attended to can worsen, causing the \
	component to become dangerous to operate, become inoperable, or even become permanently nonfunctional."

/datum/lore/codex/page/shuttle_component_thrusters
	name = "Maintenance - Thrusters"
	data = "Propulsion systems, commonly called 'thrusters', are required for a craft to move, or to stay \
	in the air when in an atmosphere.. They are attached onto the ship with external thruster mount points. \
	Thrusters require energy in order to propel the ship in a given direction, which is sourced directly from \
	another component called an Energy Capacitor. A large number of different models for thrusters exist, each with \
	their own benefits and drawbacks. Thrusters are generally the biggest victims to attrition.\
	<br><br>\
	A minor fault with a thruster will cause it to be less performant than it otherwise would, but still draw \
	the same amount of energy.\
	<br><br>\
	A major fault will make the thruster barely work at all, or fail entirely. If all thrusters fail or \
	otherwise reach a low enough threshold to be unable to support the shuttle, it may crash, if in a gravity well.\
	<br><br>\
	A critical fault will permanently render the thruster nonfunctional."

/datum/lore/codex/page/shuttle_component_ftl
	name = "Maintenance - FTL Drive"
	data = "Included in your model of spacecraft is a highly advanced Faster Than Light Drive that enables \
	the vessel to be able to fly to most in-system locations in a reasonable amount of time.\
	The stock drive should be sufficent for relatively close in-system purposes such as Surface-to-Orbit or \
	moving between orbitals around the same planet. Interplanetary flight may benefit from an upgraded \
	FTL drive.\
	<br><br>\
	Please note that the vessel is not a starship and should not be used to cross between different \
	systems unassisted.\
	<br><br>\
	A minor fault with the FTL drive will cause travel times to increase.\
	<br><br>\
	A major fault will greatly increase the travel time, and has various risks for the shuttle and its crew while jumping.\
	<br><br>\
	A critical fault will not make the drive nonfunctional, but it will be difficult to control and be dangerous to use."

/datum/lore/codex/page/shuttle_component_capacitor
	name = "Maintenance - Energy Capacitor"
	data = "The capacitor is essentially a very dense battery for the shuttle. It stores energy that powers certain \
	important things on the ship, such as the engines, the FTL drive, life support, and other functions. The capacitor can \
	be recharged by docking at certain locations that have power. It can also be charged with special components that can \
	generate power, however these are generally rare and expensive.\
	<br><br>\
	A minor fault with the energy capacitor will cause energy to leak and be lost over time.\
	<br><br>\
	A major fault will cause more energy to be lost, emit sparks, and can cause a surge of power in other components \
	periodically, damaging them if unprotected..\
	<br><br>\
	A critical fault can emit arcing lightning around the component, posing great danger to crew onboard."

/datum/lore/codex/page/shuttle_component_hull_augment
	name = "Maintenance - Hull Augmentation"
	data = "On some vessels, there may be one or more mount points for a special type of component called \
	a hull augmentation, which provides a benefit to the ship's external structure. Hull augments generally don't \
	require power, and some can protect other components from external damage by absorbing the damage into itself \
	through the hull.\
	<br><br>\
	Several hull augmentations exist such as photovoltaics to collect energy while in space, improved aerodynamics \
	to improve speed and agility while in atmosphere, and reinforcing the hull to gain improved physical or energetic defense.\
	<br><br>\
	The effects of faults for hull augments is specific to each augment, however they tend to lead to a loss of \
	the augment's functionality when reaching critical, like most other components."

/datum/lore/codex/page/shuttle_component_engine_augment
	name = "Maintenance - Engine Augmentation"
	data = "On some vessels, there may be one or more mount points for a special type of component called \
	a engine augmentation, which provides a benefit to the ship's ability to move. They are typically used \
	to radically alter the specifications of the installed thrusters beyond what is normally possible.\
	<br><br>\
	Several engine augmentations exist such as promoting energy effiency, protecting against attrition, and \
	supercharging the engines with even more energy.\
	<br><br>\
	The effects of faults for hull augments is specific to each augment, however they tend to lead to a loss of \
	the augment's functionality when reaching critical, like most other components."

/datum/lore/codex/page/shuttle_component_electronic_augment
	name = "Maintenance - Electronic Augmentation"
	data = "On some vessels, there may be one or more mount points for a special type of component called \
	a electronic augmentation, which provides a highly specialized benefit to the ship's operations. The effects of each \
	vary greatly.\
	<br><br>\
	Several electronic augmentations exist such as a superior autopilot AI, internal surge protectors, and advanced sensors. \
	<br><br>\
	The effects of faults for hull augments is specific to each augment, however they tend to lead to a loss of \
	the augment's functionality when reaching critical, like most other components."

/datum/lore/codex/page/shuttle_repair
	name = "Maintenance - Repair"
	data = "From time to time, your craft might accumulate damage to itself, and will need to be repaired. \
	This section will tell you how to do just that.\
	<br><br>\
	The hull of the ship should not require any day to day repairs, as it is very durable. If the hull \
	is breached, please contact a qualified shipwright.\
	<br><br>\
	The windows of the shuttle can be repaired with a welding tool, if the windows are cracked. Shattered \
	windows will require a replacement, preferably with a durable transparent material.\
	<br><br>\
	Components attached to mount points can be damaged from regular use or from external events. Depending \
	on the extend of the damage, repairs can be relatively simple, complicated, or impossible. Generally, \
	the more well maintained a component is, and the earlier a problem is attended to, the easier it is to fix. \
	<br><br>\
	For repairing day to day repairs against attrition, simply unmount the component with a wrench or similar \
	tool, then use a welding tool on it. Afterwards, remount the component back into its mount point. \
	<br><br>\
	If a component is suffering from a fault, additional measures will need to be taken, depending on how \
	severe the fault is. To repair a fault, unmount the component, then use a screwdriver or similar \
	tool to loosen the maintenance panel. Afterwards, use a prying tool like a crowbar to remove the panel. \
	With internal access to the component, you should be able to spot the apparent issue, and resolve it \
	using common materials such as steel or plasteel sheets. Don't forget to close the panel when finished."