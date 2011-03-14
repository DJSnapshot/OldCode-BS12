/obj/machinery/router
	networking = 1
	icon = 'computer.dmi'
	icon_state = "console"
	density = 1
	anchored = 1

var/global/first_free_address_range = 1
/obj/machinery/router/var/address_range
/obj/machinery/router/var/list/connected[255]
/obj/machinery/router/var/mob/console_user
/obj/machinery/router/var/datum/os/OS

/obj/machinery/router/New()
	address_range = first_free_address_range
	address = address_range << 8
	address |= 1

	first_free_address_range += 1

/obj/machinery/router/New()
	..()
	OS = new(src)
	// find things that aren't connected currently
	for(var/obj/machinery/M in orange(15,src)) if(M.networking && !M.address)
		connect(M)
/obj/machinery/router/Del()
	for(var/obj/machinery/M in connected)
		disconnect(M)
	..()

/obj/machinery/router/process()
	if(console_user)
		if(!(console_user in range(1,src)) || winget(console_user, "console", "is-visible") == "false")
			console_user.hide_console()
	if(OS)
		for(var/mob/A in OS.owner)
			if(!(A in range(1,src)) || winget(A, "console", "is-visible") == "false")
				A.hide_console()

/obj/machinery/router/proc/connect(var/obj/machinery/M)
	if(M.address) return
	var/i = 1
	NewIP:
	i+=1
	if(i > 100)
		M.address = 0
		return
	// shift the address range to the left by 3 bytes
	M.address = address_range << 8
	M.address |= rand(2, 255)

	if(connected[M.address % 256]) goto NewIP

	connected[M.address % 256] = M

/obj/machinery/router/proc/disconnect(var/obj/machinery/M)
	if(!M.address) return

	connected[M.address % 256] = null
	M.address = 0

/obj/machinery/router/call_function(var/datum/function/F)
	if(F.name == "who")
		var/tp = /obj
		if(F.arg1 == "apc")
			tp = /obj/machinery/power/apc
		else if(F.arg1 == "airlock")
			tp = /obj/machinery/door/airlock
		else if(F.arg1 == "status_display")
			tp = /obj/machinery/status_display
		else if(F.arg1 == "alarm")
			tp = /obj/machinery/alarm
		else if(F.arg1 == "router")
			tp = /obj/machinery/router

		var/datum/function/R = new()
		R.name = "response"
		R.arg1 = ""
		for(var/obj/M in connected) if(istype(M,tp))
			R.arg1 += "[ip2text(M:address)]\t[M.name]\n"
		for(var/obj/machinery/router/Ro in world) if(istype(Ro,tp))
			R.arg1 += "[ip2text(Ro.address)]\tRouter\n"
		R.source_id = address
		R.destination_id = F.source_id
		receive_packet(src, R)
	if(F.name == "response")
		OS.receive_message(F.arg1)

/obj/machinery/router/receive_packet(var/obj/machinery/sender, var/datum/function/P)
	if(P.destination_id == src.address)
		call_function(P)
		return

	// shift 3 bytes to the right to get the address range
	var/router = P.destination_id >> 8
	// if the destination is connected to this router, send to the destination
	if(router == src.address_range)
		for(var/obj/M in connected) if(M:address == P.destination_id)
			M:receive_packet(src, P)
	// otherwise, send to the router connected to the destination
	else
		for(var/obj/machinery/router/R in world) if(R.address_range == router)
			R.receive_packet(src, P)


/obj/machinery/computer/console/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

obj/machinery/router/attack_hand(mob/user as mob)
	user.display_console(src)