var/list/available_traders = list()

/hook/startup/proc/populate_trader_list()
	available_traders += new /datum/trader/permanent/centcom/minerals()
	available_traders += new /datum/trader/permanent/centcom/security()
	available_traders += new /datum/trader/permanent/centcom/engineering()

/obj/machinery/computer/trade
	name = "trade console"
	desc = "Used by the Cargo staff to buy and sell things on behalf of the station."
	icon_screen = "supply"
	light_color = "#b88b2e"
	req_access = list(access_cargo)
	circuit = /obj/item/weapon/circuitboard/supplycomp //todo
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	var/obj/machinery/trade_teleporter/tele = null
	var/datum/money_account/cargo_account = null
	var/datum/trader/current_trader = null
	var/list/trade_log = list()
	var/teleporter_search_range = 8 // Mappers can increase if needed if cargo ever gets remapped.
	var/selling_modifier = 1
	var/buying_modifier = 1

/obj/machinery/computer/trade/New()
	..()
	transaction_devices += src // Global reference list to be properly set up by /proc/setup_economy()
	spawn(2 SECONDS)
		find_teleporter()
		if(!cargo_account)
			cargo_account = department_accounts["Cargo"]

/obj/machinery/computer/trade/proc/find_teleporter()
	if(tele) // Drop the current teleporter's computer link if one exists.
		tele.computer = null
		tele = null

	// Now find a new teleporter.
	var/list/nearby_things = range(teleporter_search_range)
	for(var/obj/machinery/trade_teleporter/new_tele in nearby_things)
		if(new_tele)
			tele = new_tele
			break

	if(tele)
		tele.computer = src

/obj/machinery/computer/trade/proc/send_items()
	if(tele)
		spawn(0)
			tele.send_items()

/obj/machinery/computer/trade/proc/spend_money(amount)
	if(!cargo_account)
		return FALSE
	if(cargo_account.suspended)
		return FALSE
	if(cargo_account.money < amount)
		return FALSE // Can't afford.
	cargo_account.money -= amount
	return TRUE

/obj/machinery/computer/trade/proc/test_trader()
	current_trader = new /datum/trader/smuggler()

/obj/machinery/computer/trade/proc/test_trader2()
	current_trader = new /datum/trader/permanent/centcom/minerals()

/obj/machinery/computer/trade/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/trade/attack_hand(mob/user)
	if(..())
		return 1
	interact(user)

/obj/machinery/computer/trade/interact(mob/user)
	var/dat = "<h2>[using_map.station_name] Trading Console</h2>"
	if(cargo_account)
		dat += "Current funds: [cargo_account.money]þ ([cargo_account.owner_name])<br>"
	else
		dat += "Error!  Cannot connect to Cargo account.<br>"

	if(!tele)
		dat += "Error: No telepad found!  <a href='?src=\ref[src];find_tele=1'>Scan for Telepad</a><br>"

	else
		dat += "<A href='?src=\ref[src];close_trader=1'>Trader Selection</A><br>"
		if(current_trader)
			dat += "<hr>"
			dat += "<h3>Trading with [current_trader.name]</h3>"
			dat += "Speaking with [current_trader.trader_name][current_trader.faction ? ", representing [current_trader.faction.name]" : ", an independant merchant"].<br>"
			dat += "They have a budget of [current_trader.budget]þ.<br>"
			dat += "[current_trader.get_opinion_text()] ([current_trader.opinion])<br>"
			dat += "<br>"
			// Station buying.
			if(current_trader.inventory.len)
				dat += "[current_trader.trader_name] is selling the following; (Prices modified to [current_trader.get_selling_price(100, src)]%)<br>"
				for(var/atom/movable/AM in current_trader.inventory)
					dat += "\The [AM], for [current_trader.get_selling_price(current_trader.inventory[AM], src)]þ. \
					[AM.get_item_cost() ? "(market price: [AM.get_item_cost()]þ )" : ""]"
					dat += "<a href='?src=\ref[src];buy=\ref[AM]'>Buy</a><br>"
				dat += "<br>"
			// Station selling.
			if(current_trader.desired_items.len)
				dat += "[current_trader.trader_name] is willing to buy the following;<br>"
				for(var/thing in current_trader.desired_items)
					var/atom/temp = thing
					dat += "[initial(temp.name)], for [current_trader.desired_items[thing]]þ.<br>"
				dat += "<br>"
			dat += "<a href='?src=\ref[src];negotiate=1'>Negotiate Prices</a> Buying: [buying_modifier*100]% | Selling: [selling_modifier*100]%<br>"
			dat += "<a href='?src=\ref[src];teleport=1'>Activate Telepad</a><br>"
			dat += "<hr>"
		else
			dat += "No vessels selected.  Please select a vender to engage in commerce.<br><br>"
			dat += "Available venders;<br>"
			for(var/datum/trader/trader in available_traders)
				dat += "[trader.name], [trader.faction ? "of [trader.faction]" : "independant"]  ([trader.class]).  <a href='?src=\ref[src];new_trader=\ref[trader]'>Contact</a><br>"
			dat += "<br>"

		dat += "<br>"

	dat += "<A href='?src=\ref[src];refresh=1'>Refresh console</A><br>"
	user << browse(dat, "window=trade;size=500x800")
	onclose(user, "trade")

/obj/machinery/computer/trade/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["teleport"])
		send_items()
	else if(href_list["find_tele"])
		find_teleporter()
	else if(href_list["new_trader"])
		var/datum/trader/new_trader = locate(href_list["new_trader"])
		if(new_trader)
			current_trader = new_trader
	else if(href_list["close_trader"])
		current_trader = null
	else if(href_list["buy"])
		var/atom/movable/AM = locate(href_list["buy"])
		if(AM && current_trader)
			var/choice = alert(usr, "Are you sure you wish to buy \a [AM]?", "Confirm Purchase", "No", "Yes")
			if(choice == "Yes")
				current_trader.sell(AM, src)

	else if(href_list["negotiate"])
		var/choice = alert(usr, "Would you like to adjust our buying or selling offers? \n\
		Asking to pay less or sell for more than the price offered by the trader may adversely affect relations, \
		while doing the opposite may make them like us more. \n\
		Traders can also refuse deals which are clearly terrible for them, so procede with care.", "Price Negotiation", "Buying", "Selling", "Cancel")
		if(choice == "Buying")
			buying_modifier = input(usr, "How much should we scale our purchasing offers?  \
			This is expressed as a percentage, with 100% being the default.", "Buying Offers", buying_modifier * 100) as num
			buying_modifier = round(buying_modifier, 1)
			buying_modifier = between(0, buying_modifier / 100, 100)
		if(choice == "Selling")
			selling_modifier = input(usr, "How much should we scale our selling offers?  \
			This is expressed as a percentage, with 100% being the default.", "Selling Offers", selling_modifier * 100) as num
			selling_modifier = round(selling_modifier, 1)
			selling_modifier = between(0, selling_modifier / 100, 100)
	interact(usr)