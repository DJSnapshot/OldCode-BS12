/atom
	layer = TURF_LAYER
	var/level = LEVEL_FLOOR

	var/properties = STANDARD_PROPERTIES
	var/clothing_flags = 0
	var/pass_flags = 0
	var/status = 0
	var/mass = 1		//Kilograms
	var/volume = 1		//m^3

	var/proper_invisibility = 0

	var/list/fingerprints
	var/tmp/list/fingerprintshidden
	var/tmp/fingerprintslast
	var/list/blood_DNA

	var/tmp/last_bumped = 0

	var/tmp/list/anchoring

	///Chemistry.
//	var/datum/reagents/reagents

	var/tmp/effect/multiz/above_effect
	var/tmp/effect/multiz/below_effect

	Initialise()
		. = ..()
		if(!.)
			return

		invisibility = proper_invisibility
	//	if(reagents && !istype(reagents))
	//		reagents = new(src, reagents)

	Terminate()
		. = ..()
		if(!.)
			return

		for(var/atom/movable/thing in contents)
			thing.Terminate()

		if(above_effect)
			above_effect.GCDel()
		if(below_effect)
			below_effect.GCDel()

	//Delete via garbage collector.
	proc/GCDel()
		Terminate()
		for(var/atom/movable/thing in contents)
			thing.Move(null)
		contents.Cut()

	//Handles changes in direction.
	proc/Dir(new_dir)
		dir = new_dir
		UpdateIcon()

	proc/Bumped(var/atom/movable/impactor)

	//For this, call ..() after you have edited the icon stuff.
	//Handles multi-z image stuff.
	proc/UpdateIcon()
	proc/UpdateMultiZ()

	proc/SetIcon(var/icon/new_icon, var/new_icon_state)
		if(istype(new_icon))
			icon = new_icon

			if(istext(new_icon_state))
				icon_state = new_icon_state

			UpdateIcon()

	proc/SetIconState(var/new_icon_state)
		if(istext(new_icon_state))
			icon_state = new_icon_state
			UpdateIcon()

	//Set the invisibility to not-quite-totally-incabale-of-being-seen if it should be hidden.
	proc/Hide(var/turf_level)
		//special handling for special bullshit.
		if(!level)
			return

		if(turf_level > level && !CheckStatus(HIDDEN))
			SetStatus(HIDDEN)
			invisibility = 100
		else if(turf_level <= level && CheckStatus(HIDDEN))
			SetStatus(HIDDEN, 0)
			invisibility = proper_invisibility

	proc/CanPass(atom/movable/mover, turf/target, air_group = 0)
		return !density

	proc/HasEntered(atom/movable/AM)
	proc/HasProximity(atom/movable/AM)



