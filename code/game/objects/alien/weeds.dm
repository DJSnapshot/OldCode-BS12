/obj/alien/proc/process()
	return
/obj/alien/weeds/
	layer = 2
/obj/alien/weeds/New()
	if(istype(src.loc, /turf/space))
		del(src)
	var/obj/cable/C = locate() in src.loc
	if(C)
		del(C)
	var/obj/machinery/light/L = locate() in src.loc
	if(L)
		L.broken()
	updateicon()
/obj/alien/weeds/process()
	var/turf/T = src.loc
	var/obj/alien/weeds/north = locate() in T.north
	var/obj/alien/weeds/west = locate() in T.west
	var/obj/alien/weeds/east = locate() in T.east
	var/obj/alien/weeds/south = locate() in T.south
	if(!north||!west||!east||!south)
		Life()
	else
		updateicon(0)
	spawn(50)
	src.process()
/obj/alien/weeds/proc/updateicon(var/spread = 1)
	var/turf/T = src.loc
	var/obj/alien/weeds/north = locate() in T.north
	var/obj/alien/weeds/west = locate() in T.west
	var/obj/alien/weeds/east = locate() in T.east
	var/obj/alien/weeds/south = locate() in T.south
	src.overlays = null
	var/dir
	var/num = 0
	if(!north)
		dir += "north"
		num++
	else if(spread)
		north.updateicon(0)
	if(!south)
		dir += "south"
		num++
	else if(spread)
		south.updateicon(0)
	if(!west)
		dir += "west"
		num++
	else if(spread)
		west.updateicon(0)
	if(!east)
		dir += "east"
		num++
	else if(spread)
		east.updateicon(0)
	if(!dir)
		icon_state = "creep_center"
	else
		icon_state = "creep_[dir]"
	return

/obj/alien/weeds/proc/Life()
	var/turf/U = src.loc
/*
	if (locate(/obj/movable, U))
		U = locate(/obj/movable, U)
		if(U.density == 1)
			del(src)
			return

Alien plants should do something if theres a lot of poison
	if(U.poison> 200000)
		src.health -= round(U.poison/200000)
		src.update()
		return
*/
	if (istype(U, /turf/space))
		del(src)
		return

	for(var/dirn in cardinal)
		var/turf/T = get_step(src, dirn)

		if (istype(T.loc, /area/arrival))
			continue

//		if (locate(/obj/movable, T)) // don't propogate into movables
//			continue

		var/cont = 0
		for(var/obj/O in T)
			if(O.density)
				if(istype(O,/obj/machinery/door))
					break
				else
					cont = 1
					break

		if(cont)
			continue

		var/obj/alien/weeds/B = new /obj/alien/weeds(U)
		B.icon_state = pick("creep_center")

		if(T.Enter(B,src) && !(locate(/obj/alien/weeds) in T))
			B.loc = T
			updateicon()
			spawn(80)
				if(B)
					B.Life()
			// open cell, so expand
		else
			var/obj/machinery/door/airlock/D = locate() in T
			if(D)
				world << "ATTEMPTING TO OPEN DOOR"
				if(D.density)
					D.forcedopen()
					D.locked = 1
				else
					world << "door already open"
				sleep(100)
				world << "Door opening"
				if(T.Enter(B,src) && !(locate(/obj/alien/weeds) in T))
					world << "spawned on door"
					B.loc = T
					B.Life()
					updateicon()
					return
				else
					del(B)
			del(B)
/obj/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(5))
				del(src)
				return
		else
	return
/*
/obj/alien/weeds/burn(fi_amount)
	if (fi_amount > 18000)
		spawn( 0 )
			del(src)
			return
		return 0
	return 1
*/