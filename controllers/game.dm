var/controller/game/master_controller

controller/game
	var/movement_disabled = 0

	Initialise()
		. = ..()
		if(!.)
			return

		for(var/turf/turf in world)
			turf.Initialise()
			turf.gravity_z = 1

		for(var/atom/thing in world)
			thing.Initialise()