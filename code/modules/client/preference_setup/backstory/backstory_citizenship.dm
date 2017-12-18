/**************
* Citizenship *
**************/

/datum/category_group/backstory/citizenship
	name = "Citizenship"
	desc = "Determines what nation your character is a citzen of."
	effects = "Some choices may provide a passport, work visa, or similar item as proof of citizenship."
	category_item_type = /datum/category_item/backstory/citizenship
	default_value = "Sif"

/datum/category_item/backstory/citizenship
	var/government = null
	var/system = null
	var/alliance = null

/datum/category_item/backstory/citizenship/display()
	var/list/dat = list()
	dat += "<center><h2>[name]</h2><hr>"
	dat += "<h4>Governing Body: [government]</h4>"
	dat += "<h4>Alliance: [alliance]</h4>"
	dat += "[desc]"
	dat += "<font color='0000AA'><i>([effects])</i></font>"
	return dat.Join("<br>")

/datum/category_item/backstory/citizenship/display_name()
	var/result = "[name], [system]"
	if(important)
		result = "<font size='5'>[result]</font>"
	return result

/datum/category_item/backstory/citizenship/solgov
	alliance = "Solar Confederate Government"

/datum/category_item/backstory/citizenship/solgov/sif
	name = "Sif"
	government = "Vir Governmental Authority"
	system = "Vir"
	alliance = "Solar Confederate Government"
	desc = "Sif is a terrestrial planet in the Vir system. It is somewhat earth-like, in that it has oceans, a breathable atmosphere, \
	a magnetic field, weather, and similar gravity to Earth. It is currently the capital planet of Vir. Its center of government is the \
	equatorial city and site of first settlement, New Reykjavik.\
	<br><br>\
	The aptly named Vir Governmental Authority is the sole governing administration for the Vir system, based out of New Reykjavik on Sif. \
	It is a representative democratic government, and a fully recognised member of the Confederation."
	effects = "No effect."
	sort_order = 1


/datum/category_item/backstory/citizenship/solgov/earth
	name = "Earth"
	government = "Various SolGov Nation-States"
	system = "Sol"
	desc = "Earth is the birthplace of mankind and remains the true heart of economic, cultural, and political \
	influence - the pearl of both the Sol System and Humanity as a whole."
	effects = "Join with a Sol passport."
	sort_order = 2

/datum/category_item/backstory/citizenship/solgov/mars
	name = "Mars"
	government = "TBD"
	system = "Sol"
	desc = "Mars is the metropolitan industrial powerhouse of the Sol System and one of the oldest human colonies. \
	While the red planet itself was never terraformed, human life bustles in the billions in domed cities, underground \
	facilities, and megastructures scraping the sky."
	effects = "Join with a Sol passport."
	sort_order = 3


/datum/category_item/backstory/citizenship/solgov/binma
	name = "Binma"
	government = "United Binmasian Conglomerate"
	desc = "Thought needs to go write one."
	system = "Tau Ceti"
	effects = "Join with a Tau Ceti passport."
	sort_order = 4


/datum/category_item/backstory/citizenship/solgov/kishar
	name = "Kishar"
	government = "Various SolGov Nation-States"
	system = "Alpha Centauri"
	desc = "Kishar is the oldest planetary colony outside of the Sol system. A dusty planet with a thin atmosphere orbiting at spitting \
	distance of the dim red dwarf Proxima Centauri, Kishar is a fairly inhospitable world by modern standards. However, as the closest \
	exoplanet to Sol, Kishar was the site of a major colonization effort in 2140's. These colonies, populated with the most desperate \
	refugees from Earth, became the source of the population that now covers the surface of Kishar in airtight domes.\
	<br><br>\
	Kishar, like many core worlds, has a high concentration of SolGov member states per square inch of habitable space. \
	Most nations control three to five domes and the minor settlements in between, though individual city-states and larger, \
	more decentralized nations do occur. Most of these are parliamentary or presidential republics, but a significant number \
	of direct democracies also exist. "
	effects = "Join with a Alpha Centauri passport."
	sort_order = 5

/datum/category_item/backstory/citizenship/solgov/anshar
	name = "Anshar"
	government = TSC_XION // This probably needs a look-over.
	system = "Alpha Centauri"
	desc = "Anshar is a young, geologically active moon with a powerful magnetosphere. Its magnetosphere is responsible for protecting Kishar \
	from the fierce solar wind of Proxima Centauri, but its huge size and close orbit also causes the dust storms that have worn the \
	planet's surface to nothing.  Anshar hosts most of the industry of the Kishar-Anshar orbital system, being much richer in metal than its host planet. \
	The relationship between the Anshari and the Kishari is close and economically symbiotic.\
	<br><br>\
	The habitats of Anshar were originally controlled by Kishari national interests, but over time were acquired by the Anshar Mining Corporation, \
	which after a merger in 2469 became a part of Xion Manufacturing Group. Management by Xion has seen a significant increase of productivity, \
	and a significant decrease of living standards."
	effects = "Join with a TBD."
	sort_order = 6

/datum/category_item/backstory/citizenship/solgov/heaven
	name = "Heaven"
	government = "Citizen's Republic of Heaven"
	system = "Alpha Centauri"
	desc = "Heaven is a massive habitation complex consisting of two large counter-rotating cylindrical habitats, seven co-rotating torii, \
	and dozens of smaller 'tin can' habitats and mining colonies. It is the oldest extrasolar colony and the one of the largest human orbital \
	habitation complexes."
	effects = "Join with a TBD."
	sort_order = 7


/datum/category_item/backstory/citizenship/solgov/brinkburn
	name = "Brinkburn"
	government = "TBD"
	system = "Nyx"
	desc = "A martian-like planet, Brinkburn is small and dry, yet is hot enough to be habitable and supports a slowly growing population of nearly 38'000, \
	some 98% of whom are human. It is encircled by a dense ring system, theorized to be the debris of a broken primordial moon, which makes it relatively unsafe \
	to enter or exit orbit - although the rings are heavily trafficked and prospected regardless."
	effects = "Join with a Nyx passport."
	sort_order = 8

/datum/category_item/backstory/citizenship/solgov/yulcite
	name = "Yulcite"
	government = "TBD"
	system = "Nyx"
	desc = "A superearth near the outer edge of the habitable zone with a slowly outward-trending orbit, Yulcite sports a surface gravity of 1.3G and a \
	balmy average day temperature of -11C. It has been a hotbed of xenoarcheology for decades, following the discovery of the remains of a pre-space \
	native civilization, now over 8.3 million years dead."
	effects = "Join with a Nyx passport."
	sort_order = 9

/datum/category_item/backstory/citizenship/solgov/sophia
	name = "Sophia"
	government = "TBD"
	system = "El"
	desc = "Orbiting the dull red star of El, Sophia would have been strip-mined and forgotten like Sol's Main Belt, were it not for the fact \
	that it was the first discovered site of Singularitarian activity. Because of its crucial role in the production of the positronic brain, \
	Sophia became a burgeoning startup city and an important cultural site. \
	<br><br>\
	Sophia also controls the rest of its system, although as its host star is a dull red dwarf and the only planet dusty and mineral-poor, \
	very few people actually live in this space. Sophia is a full member of SolGov and tends to vote overwhelmingly with the Positronic Rights Group."
	effects = "Join with a El passport."
	sort_order = 10

/datum/category_item/backstory/citizenship/solgov/nisp
	name = "Nisp"
	government = "Gendaran Assembly, Nisp Planetary Council, and Kessan Republic"
	system = "Kess-Gendar"
	desc = "A tropical garden super-earth, Nisp features an impressive ring system extending from 2 planetary radii to around 4.5 planetary radii. \
	With a planetary average temperature of around 31.5 C, photosynthetic organisms maintain photosynthesis year-round over much of the planet's \
	surface.\
	<br><br>\
	The surface pressure is 2.5 atmospheres, and due to concentrations of nitrous oxide, respirators are required for long-term exposure \
	to the native environment, with temperature-control suits often used as well. Due to Rayleigh scattering, the sky looks a greenish-turquoise, \
	as shorter wavelengths are scattered out by the thicker atmosphere."
	effects = "Join with a Kessan Confederation passport."
	sort_order = 11


/datum/category_item/backstory/citizenship/independant
	alliance = "Independant"
	effects = "Join with a SolGov Work Visa."

/datum/category_item/backstory/citizenship/independant/shelf
	name = "Shelf"
	government = "Shelf Board of Directors"
	system = "Almach Rim"
	desc = "Shelf is the ever-moving birthplace and headquarters of Morpheus Cyberkinetics. Originally only a handful of positronics in a single \
	out-of-date transport shuttle, Shelf has grown over the years into the single largest flotilla in human space, composed of upwards of seventeen \
	hundred ships. The atmosphere in most ships is an unbreathable. Most of the ships can be interfaced with by a positronic brain or slightly \
	modified MMI, and some residents spend more of their time in control of their ship than in control of their own bodies.\
	<br><br>\
	Shelf is controlled by a Board of Directors, most of whom are also on the Board for Morpheus. The creation of new positronic brains within \
	the flotilla is discouraged, with most of its population immigrating from elsewhere, usually positronics dissatisfied with being treated as \
	second-class citizens. Shelf instead focuses its resources on improving the lives of its existing populace, as a galaxy leader in leisure \
	time and lifestyle satisfaction. Drone experimentation is fairly common in Shelf, though they do still technically follow EIO regulations, \
	despite existing outside of SolGov's jurisdiction. Shelf's leaders find it unwise to annoy one's neighbors."
	sort_order = 12

/datum/category_item/backstory/citizenship/independant/shelf/test_for_invalidity(var/datum/category_item/player_setup_item/general/background/setup)
	var/beepboop = setup.is_FBP()
	if(!beepboop)
		return "Shelf cannot be inhabitied by non-synthetics due to its environment."
	return ..()

/datum/category_item/backstory/citizenship/independant/eutopia
	name = "Eutopia"
	government = "No formal government"
	system = "Smith"
	desc = "Eutopia is a secessionist state-like organization founded on anarcho-capitalist free market principles and philosophical Objectivism. \
	Created during the 2400's by a collection of corporate interests, secessionists, and the wealthy, Eutopia has profited from its status as a \
	tax haven and a place free from many of SolGov's more restrictive laws.\
	<br><br>\
	Eutopia doesn't have a formal government, but as part of a concession made with SolGov to support their continuing independence all residents are \
	obligated to buy in to the Eutopian Foreign Relations Board, a privately traded corporation that oversees technological development. \
	The EFRB maintains their hold on the system by owning and operating the main spaceport, and are renowned for their discretion. Their \
	reports prevent SolGov from acusing the Eutopians of Five Points violations and invading their space, allowing their vast free market \
	to play out with only mild interference."
	sort_order = 13

/datum/category_item/backstory/citizenship/independant/natuna
	name = "Natuna Bhumi Barisal"
	government = "No central government"
	system = "Natuna Bhumi Barisal"
	desc = "Natuna Bhumi Barisal is an independent colony on the border of Human and Skrell space. The colony seceded in the early 25th century \
	in protest of restrictions on Human-Skrell migration, and became the first to allow humans and Skrell to live alongside one another outside \
	of in official roles. It became instrumental in the lifting of immigration restrictions between the two governments. Today, the colony \
	remains under embargo by most nations on good terms with the Skrell, and has become something of a hub for Ue-Katish pirates.\
	<br><br>\
	Natuna Bhumi Barisal lacks a formal centralized government, with settlements in the system remaining almost entirely autonomous. \
	Most human-run townships hold local elections for peacekeepers and spokespeople, with the exact power these individuals hold \
	varying from place to place, while even the Ue-Katish Skrell maintain a rigid hierarchical structure within their communities \
	with clear roles set out for each member. In both cases troublemakers are often dealt with harshly by vigilante justice. \
	A group of planetary spokespeople are elected from the population of the largest settlement of Natuna Bhumi Barisal on a \
	five-year basis. Voluntary representatives from other communities are welcomed to advise on matters of planetary and \
	international importance. While the spokespeople have final say, it is often in their best interest to represent popular opinion. "
	sort_order = 14

/datum/category_item/backstory/citizenship/independant/natuna/test_for_invalidity(var/datum/category_item/player_setup_item/general/background/setup)
	return "Natuna is currently under embargo by SolGov."


/datum/category_item/backstory/citizenship/independant/new_kyoto
	name = "New Kyoto"
	government = "The Imperial Cabinet"
	system = "Phact"
	desc = "New Kyoto is a Japanese cultural revivalist colony which seceded from SolGov during the Age of Secession. \
	The colony consists of one major populated planet in the Phact system, in addition to industrial and mining \
	operations on two smaller planets. The local government is inhospitable towards outside influence, and as \
	such Trans-Stellar Corporation presence is negligible.\
	<br><br>\
	The government of New Kyoto in its current state was formed to emulate that of Edo Period Japan, with the family of \
	the original colony's corporate president styling his family as \"Emperors\" for just over two hundred years. Currently, \
	the Emperor acts as a figurehead for an elected Prime Minister and Imperial Cabinet though this has changed several times \
	over the colony's short history. The government holds a strong policy of seclusion, with the primary intention of maintaining \
	a specific cultural stasis which exists as more of an amalgamation of several periods of Japanese history than the \"True Japan\" \
	that was proclaimed at its commencement. Once a member of the SolGov Colonial Assembly, the Emperor declared independence just \
	over one hundred years ago in order to reaffirm the colony's supposed self-sufficiency."
	sort_order = 15

/datum/category_item/backstory/citizenship/independant/casinis_reach
	name = "Casini's Reach"
	government = "No centralized government"
	system = "Casini's Reach"
	desc = "Casini’s Reach is an independent anarcho-communist colony on the edge of human space. While often considered a \
	singular colony by outsiders for the purposes of astropolitics, the system is in reality occupied by a large number of \
	individual communes united by a mutual defense pact in the name of security.\
	<br><br>\
	The system consists entirely of independent communes, with the only body resembling a government being the \
	Six Moon Pact, a defensive pact consisting of almost every commune in the system - though those who refuse to \
	align themselves find themselves effectively shielded from outsiders, who are usually unaware of the specifics \
	of local politics. The administration of individual communes varies, though usually major decisions are delegated \
	to voluntary or elected committees which will represent the needs of those they represent.\
	<br><br>\
	These positions are quite precarious, as it is usually quite straightforward for an individual \
	to be removed if those they represent feel they are not being properly spoken for. \
	Matters of system-wide importance, such as the administration of the transit network, \
	a commune believed to be violating the rights of its people, or inter-system politics \
	can at times take quite some time to resolve, and it is not unusual for serious matters to be acted upon by individual communities in the meantime."
	sort_order = 16

/datum/category_item/backstory/citizenship/independant/taron
	name = "Republic of Taron"
	government = "The Taron Presidency, Assembly and Senate"
	system = "Relan"
	desc = "The Republic of Taron seceded from SolGov during the Age of Secession and now occupies the main inhabited planet and its moon. \
	It shares the system of Relan with the Free Relan Federation.\
	<br><br>\
	Once prospering as the system capital under the ruthless domination of the Artemis Mineral Extraction corporation, \
	following the civil war with the Federation, Taron lost almost all of its extraplanetary resources and industry, \
	the majority of their income having come from mining in the system’s asteroid belts, resulting in a near total \
	economic crash. As habitats were forced to shut down, conditions worsened and martial law was enforced for a \
	period of ten years, during which quality of life only became worse. Overcrowding has resulted in bloated \
	rents, and combined with high import costs the planet sees far worse standard of living despite its nominally \
	higher than average level of development for a sub-habitable planet. Conditions have begun to improve quickly \
	following the establishment of a trade deal with SolGov in 2553, although it may be some years before the economy fully recovers."
	sort_order = 17

/datum/category_item/backstory/citizenship/independant/relan_federation
	name = "Free Relan Federation"
	government = "The System Assembly"
	system = "Relan"
	desc = "The Free Relan Federation shares the Relan system with the Republic of Taron, and is the result of \
	a split from the Republic in the early 26th century, and consists of the rest of the system outwith Taron \
	planetary orbit, primarily within the system’s two asteroid belts.\
	<br><br>\
	In part due to gaining control of most of the Republic’s former economic base after the civil war, average income is \
	relatively higher than on Taron, and standards of living are higher. Major economic downturn came about in 2530 with \
	the collapse of trade with SolGov, and the colony saw a marked decreased in quality of life as maintenance became an \
	issue on several stations and people were forced to relocate, resulting in overcrowding. Economic recovery in the last \
	decade has mainly focused on robotics, Relan being attractive due to its laxer restrictions on technology compared \
	to much of Solar space, with several manufacturing and robotics facilities since constructed, and the colony has \
	secured corporate investment from Morpheus Cyberkinetics. Mining exports have been a key sector as well, picking \
	up again after many years of being limited by SolGov’s trade restrictions on independent colonies."
	sort_order = 18


/datum/category_item/backstory/citizenship/skrell
	alliance = "N/A"
	effects = "Join with a SolGov Work Visa."

/datum/category_item/backstory/citizenship/skrell/test_for_invalidity(var/datum/category_item/player_setup_item/general/background/setup)
	if(setup.pref.species != "Skrell")
		return "Only Skrell may choose this option."
	return ..()


/datum/category_item/backstory/citizenship/tajara
	alliance = "Pearlshield Coalition"
	effects = "Join with a SolGov Work Visa."

/datum/category_item/backstory/citizenship/tajara/test_for_invalidity(var/datum/category_item/player_setup_item/general/background/setup)
	if(setup.pref.species != "Tajara")
		return "Only Tajarans may choose this option."
	return ..()

/datum/category_item/backstory/citizenship/tajara/rarkajar
	name = "Meralar"
	government = "TBD"
	system = "Rarkajar"
	desc = "\"Banded Pearl\" in Old Selem. The home planet of the Tajarans, a terrestrial oxygen planet on the outer edge of \
	the Goldilocks Zone, leading to lower surface temperatures. It is rich on resources to the point where it is theorized \
	that the planet was originally two and they smashed/merged together. Supporting this theory, Meralar possesses a \
	planetary ring of four to five layers, with no moon. The Meralar day is about 43 hours long.\
	<br><br>\
	The planet is sort of chilly. There's lots of ocean, and a \"tropical\" belt that's roughly terran temperate. This belt covers a band of \
	the south of the northern continent, and the northern coast of the southern continent (and a few islands and \
	atolls, of course). Between the two is the only always-liquid portion of the planet's oceans, and it is \
	heavily trafficked by traders and fishing ships. There is also an eastern continent that is relatively \
	unexplored due to hostile natives. Much of the northern and southern continents have subarctic climates, \
	and there are large polar ice caps at both poles."
	sort_order = 19


/datum/category_item/backstory/citizenship/unathi
	alliance = "Moghes Hegemony"
	effects = "Join with a SolGov Work Visa."

/datum/category_item/backstory/citizenship/unathi/test_for_invalidity(var/datum/category_item/player_setup_item/general/background/setup)
	if(setup.pref.species != "Unathi")
		return "Only Unathi may choose this option."
	return ..()

/datum/category_item/backstory/citizenship/unathi/rarkajar
	name = "Moghes"
	government = "TBD"
	system = "Uueoa-Esa"
	desc = "Moghes, in the Uueoa-Esa system, is the homeworld of the Unathi, and the capital of the Moghes Hegemony. \
	The average temperature on Moghes is a warm 23C. For the most part, the surface of Moghes is land, with massive \
	saltwater lakes and seas dotting the supercontinent's surface. The tropical band on Moghes is mostly hot, \
	rocky plains with occasional stretches of desert, while the temperate band is mostly swampland and savannas, \
	while the poles are mostly swampland. The Northernmost polar region is a relatively cold plain, with \
	very unusual life, as Moghes' moon Kharet is locked in orbit above this part of the planet."
	sort_order = 20
