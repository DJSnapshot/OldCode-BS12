turf/simulated/open_space
	name = "open space"
	desc = "You feel you should watch your step."

	icon_state = null
	intact = 0

	Initialise()
		. = ..()
		if(!.)
			return

		var/turf/below = locate(x, y, z + 1)
		if(!below || istype(below, /turf/unsimulated/space))
			return ChangeTurf(/turf/unsimulated/space)

		for(var/turf/turf in block(locate(x - 1, y - 1, z), locate(x + 1, y + 1, z + 1)))
			turf.SetStatus(ADJACENT_OPEN)

/*	Terminate()
		for(var/turf/turf in block(locate(x - 1, y - 1, z), locate(x + 1, y + 1, z + 1)))
			turf.Consider*/

	Entered(var/atom/movable/atom, var/atom/old_loc)
		. = ..()

		if(!initialised)
			return

		if(loc && loc:has_gravity)
			Fall(atom)