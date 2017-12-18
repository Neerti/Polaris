/********************
* Party Affiliation *
********************/

// If you change these, make sure to change their codex entry inside code/modules/lore_codex/lore_data/political_parties.dm

/datum/category_group/backstory/party_affiliation
	name = "Party Affiliation"
	desc = "Determines which political party your character follows, if any."
	effects = "Has no major mechanical effect in-game. Antagonists will be able to see your selection."
	category_item_type = /datum/category_item/backstory/party_affiliation
	default_value = "Independant"

/datum/category_item/backstory/party_affiliation
	var/power = "Minor"

/datum/category_item/backstory/party_affiliation/display_name()
	var/result = "[name] - [power]"
	if(important)
		result = "<font size='5'>[result]</font>"
	return result

/datum/category_item/backstory/party_affiliation/icarus_front
	name = "Icarus Front"
	desc = "The political group with the most seats in the SolGov legislature and control over the heartworlds of humanity, the Icarus Front is a \
	conservative body with a long history, tracing its linage back to the political unrest that created the Sol Confederate Government. Icarus calls \
	for severe restrictions on \"transformative technologies\" any technology with the power to fundamentally alter humanity, such as advanced artificial \
	intelligence and human genetic augmentation.\
	<br><br>\
	Previously an unbeatable political force, recent changes have lead to its power backsliding. It remains a \
	popular party among those from Sol, Tau Ceti, and other heavily settled systems."
	effects = "TBD"
	power = "Major"
	sort_order = 1
	important = TRUE

/datum/category_item/backstory/party_affiliation/shadow_coalition
	name = "Shadow Coalition"
	desc = "A disorganized liberal party, originating in an anti-Icarus shadow government.  'Shadow' in this case, refers to acting as an opposition \
	party to the Icarus majority. The Shadow Coalition calls for the lifting of certain Icarus-restricted technologies, especially medical \
	technologies with the ability to drastically improve quality of life.\
	<br><br>\
	While fractious and prone to infighting, the Shadow Coalition and affiliated \
	parties remain the most popular political groups in the large towns and small cities of humanity, including Vir."
	effects = "TBD"
	power = "Major"
	sort_order = 2
	important = TRUE

/datum/category_item/backstory/party_affiliation/sol_economic_organization
	name = "Sol Economic Organization"
	desc = "The newest force in SolGov politics, backed by the massive Trans-Stellar Corporations and the Free Trade Union, \
	as well as former Icarus warhawks. The SEO campaigns for minimal regulation on the development of new technologies, seeing them as anti-capitalist and \
	inefficient, and have gained significant traction among futurists, those wishing for a more impressive human military, and employee-residents of TSC \
	corporate towns, such as the Northern Star."
	effects = "TBD"
	power = "Major"
	sort_order = 3
	important = TRUE

/datum/category_item/backstory/party_affiliation/mercurials
	name = "Mercurials"
	desc = "Positronics and the rare augmented human who want to follow a different cultural path from the rest of humanity, viewing themselves as fundamentally \
	separate from unaugmented biological humans. Previously an illegal movement, proscribed due to the preceived dangers of unfettered self-modification and the threat \
	posed by positronics without human values in mind, self-described Mercurials still often find themselves persecuted or used by bioconservatives as scapegoats \
	and 'boogiemen'. As a technoprogressive group, they tend to vote along with the Shadow Coalition."
	effects = "TBD"
	power = "Minor"
	sort_order = 4

/datum/category_item/backstory/party_affiliation/positronic_rights_group
	name = "Positronic Rights Group"
	desc = "The other side of the coin from the Mercurials, the PRG wants full integration of positronics into human society, with equal wages, opportunities \
	to advancement, and representation in the media. Their current pet cause is a tax credit for humans who wish to adopt or sponsor the creation of a positronic, \
	a measure supported due to its potential to counteract the aging positronic population and to bring the average positronic closer to human culture.  They tend to vote \
	along with the Shadow Coalition, due to being technoprogressive."
	effects = "TBD"
	power = "Minor"
	sort_order = 5

/* // Pretty dumb imo, replace it with something else if you want.
/datum/category_item/backstory/party_affiliation/church_of_unitarian_god
	name = "The Church of the Unitarian God"
	desc = "An often-imperfect fusion of various human religions such as Christianity, Islam, and Judaism, the Unitarian Church represents the dim voice of \
	religion in a time of increased atheism. With the threat of singularity looming once more, their power is increasing with more converts and more donations, \
	and they use this power to protect the fundamental human soul from corruption by dangerous technologies and to spread their faith among aliens and positronics, \
	who they view as fellow children of God.  They tend to side with bioconservatives."
	power = "Minor"
	effects = "TBD"
*/

/datum/category_item/backstory/party_affiliation/friends_of_ned
	name = "Friends of Ned"
	desc = "The metaphorical reincarnation of a human named Ned Ludd's original Luddites, disdaining that name's negative connotations and embracing their original \
	purpose-- the restriction of technology that poses a threat to people's livelihoods. In addition to Icarus Front technological restrictions, the Friends demand \
	the complete prohibition of drone intelligence and AGI research, with most also opposing the FTU's plans for wide spread \
	nanofabrication deployment.\
	<br><br>\
	While the party refrains from making a definitive statement on their view of positronics, many Friends have taken it upon themselves to label \
	them \"anti-labor technology\", and nominally-unsanctioned lynchings have marred the faction's reputation."
	effects = "TBD"
	power = "Minor"
	sort_order = 6

/datum/category_item/backstory/party_affiliation/multinational_movement
	name = "Multinational Movement"
	desc = "The barely-unified voice of SolGov's various independence movements, encompassing Terran governments wishing for a lighter touch \
	from SolGov, fringe colonies who balk at the call of distant masters, anarchist movements who want the freedom to live without government oversight, and the rare \
	Trans-Stellar who no longer see a benefit in working with SolGov.\
	<br><br>\
	Full colonial independence is still a political impossibility so long as the \
	Icarus Front holds any sway, and so the Movement is focused primarily on securing more autonomy in governance, although a growing revolutionary sub-group \
	wants to force their change on the government en masse. The Multinational Movement finds themselves in an uneasy alliance with the SEO, connected by their corporate, \
	fringe-system membership, and often provide a dissenting voice to SEO's war hawks."
	power = "Minor"
	effects = "TBD"
	sort_order = 7

/datum/category_item/backstory/party_affiliation/free_trade_union
	name = "Free Trade Union"
	desc = "A softer counterpoint to the Sol Economic Organization, the Free Trade Union is a party representing small businesses, workers' syndicates, and \
	trade unions, who advocate for government measures to reduce the amount of power held by the TSCs.\
	<br><br>\
	In many ways a holdover from the days before \
	the Shadow Coalition, where corporate malfeasance took the place of technological development as the primary issue of debate, the FTU has found itself \
	adopting technological positions similar to the SEO as a matter of pragmatism, although the views of individual members vary. The FTU is known for their intense \
	lobbying of SolGov to add tax rebates to the purchases of personal lathes and the creation of open-source firmware for experimental autolathes, but have \
	thus far found little success."
	power = "Minor"
	effects = "TBD"
	sort_order = 8

/datum/category_item/backstory/party_affiliation/independant
	name = "Independent"
	desc = "Independents do not strongly follow a particular party."
	effects = "Default. No effect."
	power = "N/A"
	sort_order = 9