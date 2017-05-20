/*
	New Trader System!

	This is the replacement for Cargo's shuttle and general ordering of stuff.  Instead of a big central place (presumably CentCom)
	holding a bunch of stuff they're willing to give away with cargo points, the colony does business with various nearby (or distant)
	ships or bases, each carrying different items and wanting other items, and it's up to the Cargo department to ensure that a profit
	is made while still getting the colony whatever they need.

	Instead of magic cargo points, each merchant is going to want thalers, so the computer that the Cargo staff will be using will
	be linked to the Cargo department's account, which is there for Cargo to spend for supplies, or to invest in for future wealth.

	In Cargo, instead of a cargo shuttle, items are teleported to and from imaginary space ships.  This is because rewriting the
	shuttle to work with the new system would be most unpleasent.  Instead, Cargo gets a fancy teleporter pad that can send
	and receive items.

	Cargo will know of ships that are nearby that they can trade, as well as ships expected to arrive in the near future.
	Some merchants can also be called in order to buy specific things (at a significant markup if they weren't already coming).

	Command is able to enter 'contracts' with other places, in order to produce specific items for payment or other awards.

	Different types of spaceships may arrive at the Northern Star, wanting things like fuel, food, booze, medical supplies, or
	other things, and they may be associated by different groups, from Trans-Stellars to independants to maybe even traders spawned
	by random event.
*/

/datum/trader
	var/name = "a space ship"		// What the ship will identify as on the commerce computer.
	var/class = "general"			// Discriptor of what kind of goods the merchant will sell.
	var/trader_name = "John Doe"	// Name for the actual merchant.
	var/datum/trader_faction/faction = null // The faction associated with the trader, which determines what things they sell, what they want, how they talk, etc.
	var/budget = 2000				// How much cash the merchant is willing to part with when paying for station goods.  Semi-random
	var/opinion = 0					// How much this specific trader likes or dislikes the station. Postives are good, negatives are bad, and 0 is neutral.
	var/trade_opinion_gain_ratio = 200	// Determines how fast the trader gains opinion for doing fair deals.  By default, for every 200 thaler traded, 1 opinion is gained.
	var/list/inventory = list() 	// Assoc list of things the merchant is willing to sell.
	var/list/desired_items = list()	// Things the merchant will be willing to buy from the station.
	var/obj/cargo_hold/cargo = null	// Obj which will act as a temporary storage for things sent to the ship.  This can be destroyed with explosives, which will end badly for everyone.
	var/obj/machinery/computer/trade/trade_computer = null // Trade computer they're currently talking through.
	var/list/conversation = list()	// Assoc list of what the trader will say.  E.g. list("Greetings" = "Hello to you as well.").

	// Conversational vars.
	var/greet_message = null			// Message said when the trader arrives for the first time.
	var/farewell_message = null			// Message said when the trader leaves.
	var/buying_message = null			// Note this is when the trader is buying, IE the station is the seller.
	var/selling_message = null			// Same as above, this is when the station is buying and the trader is selling.
	var/cannot_afford_message = null	// Said when the trader cannot buy the offered item.
	var/unwanted_items_message = null	// Said when receiving items the trader does not want.

	var/hostile_messages = list()
	var/unfriendly_messages = list()
	var/neutral_messages = list()
	var/friendly_messages = list()
	var/happy_messages = list()


/obj/cargo_hold
	name = "cargo hold"
	desc = "How are you reading this?"

/datum/trader/permanent


/datum/trader/testing
//	desired_items = list(/obj/item/ = 150)

/datum/trader/New()
	cargo = new(null)

	assign_trader_name()

	var/list/new_inventory = list()
	for(var/thing in inventory)
		var/atom/movable/AM = new thing(null)
		new_inventory[AM] = inventory[thing]
	inventory = new_inventory

	assign_faction()
	..()

/datum/trader/Destroy()
	faction = null
	qdel(cargo)
	for(var/atom/movable/AM in inventory)
		qdel(AM)
	..()

/datum/trader/proc/assign_faction()
	if(faction && istext(faction))
		faction = all_trading_factions[faction]
		if(faction)
			opinion = faction.reputation

// Gives a random name.  Override for special names (e.g. Vey-Med and Skrell names)
/datum/trader/proc/assign_trader_name()
	trader_name = random_name(pick(MALE, FEMALE))

/datum/trader/proc/modify_opinion(amount)
	opinion = between(-100, round(opinion + amount, 0.01), 100)
	if(faction) // The faction gets 30% of the opinion shift.
		faction.adjust_reputation(round(amount * 0.3, 0.01))

/datum/trader/proc/get_opinion()
	return opinion

/datum/trader/proc/get_opinion_text()
	switch(opinion)
		if(-INFINITY to -70)
			return "<font color='red'><b>[trader_name] wants nothing to do with you.</b></font>"
		if(-70 to -50)
			return "<font color='red'><b>[trader_name] would rather not discuss business with you.</b></font>"
		if(-50 to -30)
			return "<font color='red'>[trader_name] dislikes you.</font>"
		if(-30 to -10)
			return "<font color='red'>[trader_name] is slightly disappointed at you.</font>"
		if(-10 to 10)
			return "[trader_name] feels neutral towards you."
		if(10 to 30)
			return "<font color='green'>[trader_name] feels you are agreeable.</font>"
		if(30 to 50)
			return "<font color='green'>[trader_name] is pleased with you.</font>"
		if(50 to 80)
			return "<font color='green'><b>[trader_name] is happy from trading with you.</b></font>"
		if(80 to INFINITY)
			return "<font color='green'><b>[trader_name] feels you are an excellent business partner.</b></font>"

/datum/trader/proc/get_opinion_discounts()
	switch(opinion) // Below -70 is effectively infinite since most won't trade at that point.
		if(-INFINITY to -70)
			return 5.00 // +400%
		if(-70 to -50)
			return 3.00 // +200%
		if(-50 to -30)
			return 1.50 // +50%
		if(-30 to 30)
			return 1.00 // Base
		if(30 to 50)
			return 0.90 // -10%
		if(50 to 80)
			return 0.75 // -25%
		if(80 to INFINITY)
			return 0.50 // -50%

// This is called when the "ship" receives one or more objects via teleportation.
// It will buy as many things it receives as it can, assuming the things received were things the trader wanted.
// Unwanted or too expensive items are sent back to the telepad in a few seconds.
/datum/trader/proc/on_received_items(var/obj/machinery/trade_teleporter/tele)
	for(var/obj/O in cargo)
		for(var/desired_item in desired_items)
			if(ispath(O, desired_item))
				if(pay_money(desired_items[desired_item]))
					send_message("[buying_message] [O].")
					qdel(O) // Only delete if they can actually pay.
				else
					send_message("[cannot_afford_message] [O].")
				break

	sleep(3 SECONDS)
	// Send things we don't want back.
	var/list/unwanted_items = list()
	for(var/atom/movable/AM in cargo)
		unwanted_items += AM
		if(tele)
			tele.receive_item(AM)

	if(unwanted_items.len)
		send_message("[unwanted_items_message] [english_list(unwanted_items)].")

// Selling, from the trader's perspective.
/datum/trader/proc/get_selling_price(amount, var/obj/machinery/computer/trade/trade_computer)
	var/discount = get_opinion_discounts()
	return round(amount * discount * trade_computer.buying_modifier)

// Sells an instance of an item to the station.
/datum/trader/proc/sell(var/atom/movable/AM, var/obj/machinery/computer/trade/trade_computer)
	if(!trade_computer && !trade_computer.tele)
		return
	if(!AM in inventory) // Don't sell things we don't have.
		return

	var/price = get_selling_price(inventory[AM], trade_computer)
	if(trade_computer.spend_money(price))
		make_transaction_log(AM, trade_computer, amount = price, selling = TRUE)
		budget += price
		opinion_from_sell(AM, price)
		inventory.Remove(AM)
		trade_computer.tele.receive_item(package_item(AM))

// Permanent traders instantiate new instances of whatever they're selling, as opposed to having limited stock.
/datum/trader/permanent/sell(var/atom/movable/AM, var/obj/machinery/computer/trade/trade_computer)
	if(!trade_computer && !trade_computer.tele)
		return
	if(!AM in inventory) // Don't sell things we don't have.
		return

	var/price = get_selling_price(inventory[AM], trade_computer)
	if(trade_computer.spend_money(price))
		var/atom/movable/new_instance = new AM.type()
		make_transaction_log(AM, trade_computer, amount = price, selling = TRUE)
		budget += price
		opinion_from_sell(AM, price)
		trade_computer.tele.receive_item(package_item(new_instance))

// First argument is the item being bought/sold, second is the trade computer, third is the agreed upon price, and fourth is
// if AM was being bought or sold (from the trader's perspective).
/datum/trader/proc/make_transaction_log(var/atom/movable/AM, var/obj/machinery/computer/trade/trade_computer, var/amount, var/selling)
	//create a transaction log entry
	var/datum/transaction/T = new()
	T.target_name = trade_computer.cargo_account.owner_name
	T.purpose = "[selling ? "Bought" : "Sold"] \a [AM] from [src.name]."
	T.amount = amount
	T.source_terminal = "[station_name()] [trade_computer.name]"
	T.date = current_date_string
	T.time = stationtime2text()
	trade_computer.cargo_account.transaction_log.Add(T)

/datum/trader/proc/pay_money(var/amount)
	return

/datum/trader/proc/buy(var/atom/movable/AM, var/obj/machinery/computer/trade/trade_computer)
	return

/datum/trader/proc/send_message(var/message)
	return

/datum/trader/proc/opinion_from_sell(var/atom/movable/AM, var/price)
	var/base_price = inventory[AM]
	var/discounted_price = base_price * get_opinion_discounts()
	var/difference = price - discounted_price // Positive numbers mean the station undersold, negative means the trader got ripped off, 0 means it was 'fair'.
	if(difference >= 0) // Gain opinion for just trading, so long as the deal wasn't terrible for them.
		modify_opinion(price / trade_opinion_gain_ratio)
	// Lose opinion based on if the deal deviated from the offered price significantly.
	if(discounted_price != 0 && difference < 0)
		modify_opinion( (difference / discounted_price) * 200) // Each percent of difference reduces opinion by 2.
	// Gain opinion if the station was buying at a loss.
	if(difference > 0)
		modify_opinion(difference / trade_opinion_gain_ratio)

// Override if you need special packaging behaviour, such as lockboxes for guns.
/datum/trader/proc/package_item(var/atom/movable/AM)
	return AM