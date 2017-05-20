// This is used to send and receive objects from "spaceships".

/obj/machinery/trade_teleporter
	name = "trade tele-pad"
	desc = "This machine is a teleporter, that sends cargo between here and nearby vessels.  It is controled \
	remotely by a trading computer.  It cannot send individuals, which is probably a good thing."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "trade_tele"
	idle_power_usage = 1000
	active_power_usage = 10000
	anchored = TRUE
	var/obj/machinery/computer/trade/computer = null
	var/busy = FALSE

/obj/machinery/trade_teleporter/proc/sending_effect()
	flick("trade_tele_send", src)
	playsound(src, 'sound/weapons/emitter2.ogg', 50, 1)

/obj/machinery/trade_teleporter/proc/receiving_effect()
	playsound(src, 'sound/weapons/emitter2.ogg', 50, 1)

// When the pad receives something.  Can be an object instance or a type.  If it's a type, it's spawned immediately.
/obj/machinery/trade_teleporter/proc/receive_item(var/incoming_thing)
	if(istype(incoming_thing, /atom/movable)) // Is the thing an actual instance?
		var/atom/movable/AM = incoming_thing
		AM.forceMove(get_turf(src))
	else // Probably a type instead.
		new incoming_thing(get_turf(src))
	receiving_effect()

/obj/machinery/trade_teleporter/proc/send_items()
	if(!computer)
		return
	if(!computer.current_trader)
		return
	if(busy)
		return

	busy = TRUE
	sending_effect()
	sleep(5) // Wait for the icon and sound.
	for(var/obj/O in get_turf(src))
		if(O.anchored)
			continue
		O.forceMove(computer.current_trader.cargo)
	computer.current_trader.on_received_items(src)
	sleep(5 SECONDS)
	busy = FALSE