/datum
	var/tmp/initialised

	New(loc, var/list/__mapload)
		if(master_controller && master_controller.initialised && !__mapload)
			Initialise()

		if(islist(__mapload))
			for(var/variable in __mapload)
				if(variable in vars)
					vars[variable] = __mapload[variable]

		. = ..()

	proc/Initialise()
		if(!initialised)
			initialised = 1
			return 1
		return 0

	proc/Terminate()
		if(initialised)
			initialised = 0
			return 1
		return 0

	proc/GetState()
		if(initialised)
			return null

		. = list()
		for(var/variable in vars - list("key", "overlays", "underlays", "tag", "invisibility"))
			if(issaved(vars[variable]) && vars[variable] != initial(vars[variable]))
				if(istype(vars[variable], /datum))
					var/datum/contained_datum = vars[variable]
					.[variable] = contained_datum.GetState()
				else
					.[variable] = vars[variable]