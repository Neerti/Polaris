/************
* Employers *
************/

/datum/category_group/backstory/employer
	name = "Employer"
	desc = "Determines who your character is currently working for."
	effects = "Has a major effect on what roles your character will be able to be."
	category_item_type = /datum/category_item/backstory/employer
	default_value = TSC_NT // NT is default since its an NT station.

/datum/category_item/backstory/employer
	var/economic_modifier = 1.0 // Modifies how much money you start with.

/datum/category_item/backstory/employer/nanotrasen
	name = TSC_NT
	desc = "NanoTrasen is one of the foremost research and development companies in SolGov space. Originally focused on consumer products, \
	their swift move into the field of Phoron has lead to them being the foremost experts on the substance and its uses. In the modern day, \
	NanoTrasen prides itself on being an early adopter to as many new technologies as possible, often offering the newest products to their \
	employees.\
	<br><br>\
	In an effort to combat complaints about being \"guinea pigs\", Nanotrasen also offers one of the most comprehensive medical \
	plans in SolGov space, up to and including cloning and therapy."
	effects = "Can play as most roles on the facility, including Command. Adds records and manifest entry if not already included."
	sort_order = 1
	important = TRUE

/datum/category_item/backstory/employer/unemployed
	name = "Unemployed"
	effects = "Start with much less money."
	economic_modifier = 0.25
	sort_order = 2

/datum/category_item/backstory/employer/freelancer
	name = "Independant Freelancer"
	desc = "Freelancers may be on their own, or part of a smaller contracting service not bound by the grasp of a Trans-Stellar."
	effects = "Can join as a contractor for various roles. Adds records and manifest entry if not already included, when joining as a contractor."
	sort_order = 3

/datum/category_item/backstory/employer/pcrc
	name = TSC_PCRC
	desc = "PCRC is the softer, PR-friendlier version of Stealth Assault Enterpises (SAARE), specializing in defense and security ops. PCRC is a favorite \
	for those with more money than troops, such as certain colonial governments and other TSCs. Competition with SAARE is fairly \
	low, as PCRC enjoys its reputation because SAARE exists.\
	<br><br>\
	PCRC is also known for corporate bodyguarding and other low-risk security operations."
	effects = "Can join as a contractor for Security (Sec. Officer, specifically). Adds records and manifest entry if not already included, when joining as a contractor."
	sort_order = 4

/datum/category_item/backstory/employer/aether_atmospherics
	name = TSC_AETHER
	desc = "Aether has found its niche in bulk gas collection and supply. They conduct atmospheric mining of gas giants and \
	sell the products to space colonies throughout the galaxy and to the various low-grade terraforming operations on Sol’s \
	garden worlds.\
	<br><br>\
	Aether is headquartered on Titan, and the success of this home-grown TSC gives hope to many Titaners who want increased self-reliance for Titan."
	effects = "Can join as a contractor for Engineering (Atmospherics, specifically). Adds records and manifest entry if not already included, when joining as a contractor."
	sort_order = 5

/datum/category_item/backstory/employer/grayson
	name = TSC_GRAYSON
	desc = "Grayson is the largest bulk parts supplier in SolGov space, with significant secondary interests in mining. \
	While unable to obtain total market dominance owing to the ease of setting up competing operations, Grayson’s vertical \
	integration of the market gives them a competitive edge, frequently building factories on the same asteroids they mine \
	out.\
	<br><br>\
	Many other TSCs have Grayson parts at the beginning of their chain of supply."
	effects = "Can join as a contractor for Supply (Mining, specifically). Adds records and manifest entry if not already included, when joining as a contractor."
	sort_order = 6

/datum/category_item/backstory/employer/bishop
	name = TSC_BC
	desc = "Bishop’s focus is on high-class, stylish cybernetics. A favorite among transhumanists \
	(and a bête noire for bioconservatives), Bishop manufactures not only prostheses but also brain \
	augmentation, synthetic organ replacements, and odds and ends like implanted wrist-watches. Their \
	business model tends towards smaller, boutique operations, giving it a reputation for high price \
	and luxury, with Bishop cyberware often rivaling Vey-Med’s for cost.\
	<br><br>\
	Bishop’s reputation for catering towards the interests of human augmentation enthusiasts \
	instead of positronics have earned it ire from the Positronic Rights Group and puts it in \
	ideological (but not economic) competition with Morpheus Cyberkinetics."
	effects = "Can join as a contractor for Research (Robotics, specifically). Adds records and manifest entry if not already included, when joining as a contractor."
	sort_order = 7

/datum/category_item/backstory/employer/morpheus
	name = TSC_MORPH
	desc = "The only large corporation run by positronic intelligences, Morpheus caters almost exclusively to their sensibilities and needs. \
	A product of the synthetic colony of Shelf, Morpheus eschews traditional advertising to keep their prices low and relied on word of \
	mouth among positronics to reach their current economic dominance. Morpheus in exchange lobbies heavily for positronic rights, \
	sponsors positronics through their Jans-Fhriede test, and tends to other positronic concerns to earn them the good-will of the \
	positronics, and the ire of those who wish to exploit them.\
	<br><br>\
	Morpheus is also known for a deeply sarcastic sense of humor, in part inspired by their Mercurial leanings."
	effects = "Can join as a contractor for Research (Robotics, specifically). Adds records and manifest entry if not already included, when joining as a contractor."
	sort_order = 8

/datum/category_item/backstory/employer/morpheus/test_for_invalidity(var/datum/category_item/player_setup_item/general/background/setup)
	var/beepboop = setup.get_FBP_type()
	if(!(beepboop in list(PREF_FBP_POSI, PREF_FBP_SOFTWARE)))
		return "Morpheus only employs Positronics, or owns Drones."
	return ..()

/datum/category_item/backstory/employer/einstein_engines
	name = TSC_EE
	desc = "Einstein is an old company that has survived through rampant respecialization. In the age of phoron-powered \
	exotic engines and ubiquitous solar power, Einstein makes its living through the sale of engine designs for power \
	sources it has no access to and emergency fission or hydrocarbon power supplies. Accusations of corporate espionage \
	against research-heavy corporations like NanoTrasen and its chief rival Focal Point are probably unfounded. "
	effects = "Can join as a contractor for Engineering (Engineer, specifically). Adds records and manifest entry if not already included, when joining as a contractor."
	sort_order = 9

/datum/category_item/backstory/employer/focal_point
	name = TSC_FOCAL
	desc = "Focal Point casts a wide net over the various markets relating to electrical power. Primarily catering towards \
	the developing market, they supply both electrical power itself (using a massive fleet of FTL-equipped solar arrays) and \
	the generators, APC control chips, and other amenities that help ensure loyal clientele."
	effects = "Can join as a contractor for Engineering (Engineer, specifically). Adds records and manifest entry if not already included, when joining as a contractor."
	sort_order = 10

/datum/category_item/backstory/employer/oculum_broadcast
	name = TSC_OCULUM
	desc = "Oculum owns approximately 30% of Sol-wide news networks, including microblogging aggregate sites, \
	network and comedy news, and even old-fashioned newspapers. Staunchly apolitical, they specialize in delivering \
	the most popular news available-- which means telling people what they already want to hear.\
	<br><br>\
	Oculum is a specialist in branding, and most people don't know that the reactionary Daedalus Dispatch newsletter \
	and the radically transhuman Liquid Steel webcrawler are controlled by the same organization."
	effects = "Can join as a contractor for Civilian (Journalist, specifically). Adds records and manifest entry if not already included, when joining as a contractor."
	sort_order = 11

/datum/category_item/backstory/employer/major_bills
	name = TSC_MAJOR
	desc = "The most popular courier service and starliner, Major Bill’s is an unassuming corporation whose \
	greatest asset is their low cost and brand recognition. Major Bill’s is known, perhaps unfavorably, \
	for its mascot, Major Bill, a cartoonish military figure that spouts quotable slogans.\
	<br><br>\
	Their motto is \"With Major Bill's, you won't pay major bills!\", \
	an earworm much of the galaxy longs to forget."
	effects = "Can join as a contractor for Supply (Cargo, specifically). Adds records and manifest entry if not already included, when joining as a contractor."
	sort_order = 12

/datum/category_item/backstory/employer/major_bills/display()
	var/list/dat = list()
	dat += "<div style=\"font-family:'Comic Sans MS'\">"
	dat += "<center><h2>[name]</h2><hr>"
	dat += "[desc]"
	dat += "<font color='0000AA'><i>([effects])</i></font>"
	dat += "</div>"
	return dat.Join("<br>")

/datum/category_item/backstory/employer/hephaestus
	name = TSC_HEPH
	desc = "Hephaestus Industries is the largest supplier of arms, ammunition, and small military vehicles in Sol space. \
	Hephaestus products have a reputation for reliability, and the corporation itself has a noted tendency to stay removed \
	from corporate politics.\
	<br><br>\
	They enforce their neutrality with the help of a fairly large asset-protection contingent \
	which prevents any contracting polities from using their own materiel against them. SolGov itself is one of Hephaestus’ \
	largest bulk contractors owing to the above factors."
	effects = "No effects."
	sort_order = 13

/datum/category_item/backstory/employer/vey_med
	name = TSC_VM
	desc = "Vey-Med is one of the newer TSCs on the block and is notable for being largely owned and operated by Skrell. \
	Despite the suspicion and prejudice leveled at them for their alien origin, Vey-Med has obtained market dominance in \
	the sale of medical equipment-- from surgical tools to large medical devices to the Oddyseus trauma response mecha and \
	everything in between.\
	<br><br>\
	Their equipment tends to be top-of-the-line, most obviously shown by their incredibly human-like \
	FBP designs. Vey’s rise to stardom came from their introduction of resurrective cloning, although in recent years they’ve \
	been forced to diversify as their patents expired and NanoTrasen-made medications became essential to modern cloning."
	effects = "No effects."
	sort_order = 14

/datum/category_item/backstory/employer/zeng_hu
	name = TSC_ZH
	desc = "Zeng-Hu is an old TSC, based in the Sol system. Until the discovery of Phoron, Zeng-Hu maintained a stranglehold on the market for \
	medications, and many household names are patented by Zeng-Hu-- Bicaridyne, Dylovene, Tricordrazine, all came from a Zeng-Hu medical \
	laboratory.\
	<br><br>\
	Zeng-Hu’s fortunes have been in decline as NanoTrasen’s near monopoly on phoron research cuts into their R&D and \
	Vey-Med’s superior medical equipment effectively decimated their own equipment interests. The three-way rivalry between \
	these companies for dominance in the medical field is well-known and a matter of constant economic speculation."
	effects = "No effects."
	sort_order = 15

/datum/category_item/backstory/employer/ward_takahashi
	name = TSC_WT
	desc = "Ward-Takahashi focuses on the sale of small consumer electronics, with its computers, communicators, and \
	even mid-class automobiles a fixture of many households. Less famously, Ward-Takahashi also supplies most of the \
	AI cores on which vital control systems are mounted, and it is this branch of their industry that has led to their \
	tertiary interest in the development and sale of high-grade AI systems.\
	<br><Br>\
	Ward-Takahashi’s economies of scale frequently steal market share from NanoTrasen’s high-price products, leading to a \
	bitter rivalry in the consumer electronics market."
	effects = "No effects."
	sort_order = 16

/datum/category_item/backstory/employer/xion
	name = TSC_XION
	desc = "Xion, quietly, controls most of the market for industrial equipment. Their portfolio includes mining exosuits, \
	factory equipment, rugged positronic chassis, and other pieces of equipment vital to the function of the economy. Xion \
	keeps its control of the market by leasing, not selling, their equipment, and through infamous and bloody patent protection \
	lawsuits. Xion are noted to be a favorite contractor for SolGov engineers, owing to their low cost and rugged design."
	effects = "No effects."
	sort_order = 17

// This one might get cut.
/datum/category_item/backstory/employer/gilthari
	name = TSC_GIL
	desc = "Gilthari is Sol’s premier supplier of luxury goods, specializing in extracting money from the rich and successful. \
	Their largest holdings are in gambling, but they maintain subsidiaries in everything from VR equipment to luxury watches. \
	Their holdings in mass media are a smaller but still important part of their empire. Gilthari is known for treating its \
	positronic employees very well, sparking a number of conspiracy theories.\
	<br><br>\
	The gorgeous FBP model that Gilthari provides them is a symbol of the corporation’s wealth and reach ludicrous prices \
	when available on the black market, with licit ownership of the chassis limited, by contract, to employees."
	effects = "Join with more funds."
	economic_modifier = 2.0
	sort_order = 18

/datum/category_item/backstory/employer/wulf_aeronautics
	name = TSC_WULF
	desc = "Wulf Aeronautics is the chief producer of transport and hauling spacecraft. A favorite contractor of SolGov, \
	Wulf manufactures most of their diplomatic and logistics craft, and does a brisk business with most other TSCs. \
	The quiet reliance of the economy on their craft has kept them out of the spotlight and uninvolved in other \
	corporations’ back-room dealings."
	effects = "No effects."
	sort_order = 19

