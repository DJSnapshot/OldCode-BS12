/turf
	icon = 'icons/turf.dmi'

	status = ADJACENT_ABOVE | ADJACENT_BELOW
	mouse_opacity = 0
	alpha = 100
	color = "#000000"

	//Blocks everything except INCORPOREAL
	var/tmp/current_density
	var/tmp/list/directional_density
	//Blocks airflow or PASSGRILLE
	//	Air flows through it, anything else that can may as well be air.
	var/tmp/current_group_border
	var/tmp/list/directional_group
	//Blocks everything without PASSMOB
	var/tmp/current_mob_border
	var/tmp/list/directional_mob
	//Blocks everything without PASSGLASS
	var/tmp/current_glass
	var/tmp/list/directional_glass
	//Blocks anything without PASSTABLE
	var/tmp/current_table
	var/tmp/list/directional_table

	var/tmp/list/special_objects

	var/tmp/list/proximity_sensing
	var/tmp/list/entry_sensing

	var/tmp/gravity_x = 0
	var/tmp/gravity_y = 0
	var/tmp/gravity_z = 0

	Initialise()
		. = ..()
		if(!.)
			return

		UpdateLight()

	//	for(var/atom/movable/AM in src)
	//		Entered(AM, src)

	Terminate()
		. = ..()
		if(!.)
			return

		alpha = initial(alpha)
		color = initial(color)

	GCDel()
		. = ..()
		del src

	proc/UpdateLight()

	Enter(var/atom/movable/mover, var/turf/old_turf)
		//prevent movement before initialisation
		if(!initialised)
			return 0

		if(mover.CheckPassFlag(INCORPOREAL))
			return 1

		if(master_controller.movement_disabled)
			usr << "\red Movement is admin-disabled." //This is to identify lag problems
			return 0

		//Used to handle directional densities.
		var/incoming_direction = GetDir(old_turf, src)
		var/outgoing_direction = ReverseDir(incoming_direction)

		//If something wants to move here from inside something, allow it if we are not dense.
		if (!mover || !istype(old_turf) || !(incoming_direction in cardinal))
			return !density

		//We are dense, so bump into us and call it a day.
		if(density)
			mover.Bump(src, 1)
			return 0

		//If something is blocking exit on that turf, bump into it and do not move.
		//Next, we run similar checks against the pass flags
		if(old_turf.current_group_border && !mover.CheckPassFlag(PASSGRILLE))
			if(old_turf.current_group_border & outgoing_direction)
				for(var/atom/movable/atom in old_turf.directional_group)
					if(atom.current_density & outgoing_direction)
						mover.Bump(atom, 1)
						return 0

		if(old_turf.current_table && !mover.CheckPassFlag(PASSTABLE))
			if(old_turf.current_table & outgoing_direction)
				for(var/atom/movable/atom in old_turf.directional_table)
					if(atom.current_density & outgoing_direction && mover != atom)
						mover.Bump(atom, 1)
						return 0

		if(old_turf.current_mob_border && !mover.CheckPassFlag(PASSMOB))
			if(old_turf.current_mob_border & outgoing_direction)
				for(var/atom/movable/atom in old_turf.directional_mob)
					if(atom.current_density & outgoing_direction && mover != atom)
						mover.Bump(atom, 1)
						return 0

		if(old_turf.current_glass && !mover.CheckPassFlag(PASSGLASS))
			if(old_turf.current_glass & outgoing_direction)
				for(var/atom/movable/atom in old_turf.directional_glass)
					if(atom.current_density & outgoing_direction && mover != atom)
						mover.Bump(atom, 1)
						return 0

		if(old_turf.current_density && old_turf.current_density & outgoing_direction)
			for(var/atom/movable/atom in old_turf.directional_density)
				if(atom.current_density & outgoing_direction && mover != atom)
					mover.Bump(atom, 1)
					return 0

		//Identical to above, but for things on this turf.
		if(current_group_border && !mover.CheckPassFlag(PASSGRILLE))
			if(current_group_border & incoming_direction)
				for(var/atom/movable/atom in directional_group)
					if(atom.current_density & incoming_direction && mover != atom)
						mover.Bump(atom, 1)
						return 0

		if(current_table && !mover.CheckPassFlag(PASSTABLE))
			if(current_table & incoming_direction)
				for(var/atom/movable/atom in directional_table)
					if(atom.current_density & incoming_direction && mover != atom)
						mover.Bump(atom, 1)
						return 0

		if(current_mob_border && !mover.CheckPassFlag(PASSMOB))
			if(current_mob_border & incoming_direction)
				for(var/atom/movable/atom in directional_mob)
					if(atom.current_density & incoming_direction && mover != atom)
						mover.Bump(atom, 1)
						return 0

		if(current_glass && !mover.CheckPassFlag(PASSGLASS))
			if(current_glass & incoming_direction)
				for(var/atom/movable/atom in directional_glass)
					if(atom.current_density & incoming_direction && mover != atom)
						mover.Bump(atom, 1)
						return 0

		if(current_density && current_density & incoming_direction)
			for(var/atom/movable/atom in directional_density)
				if(atom.current_density & incoming_direction && mover != atom)
					mover.Bump(atom, 1)
					return 0

		//Finally, we check to ensure nothing with special movement stuff fucks with us.
		if(special_objects)
			for(var/atom/obstacle in special_objects)
				if(!obstacle.CanPass(mover, src))
					mover.Bump(obstacle, 1)
					return 0

		return 1 //Nothing found to block so return success!


	Entered(var/atom/movable/atom, var/atom/old_loc)
		if(!initialised)
			return 0

		. = ..()

		var/check_multiz = 0

		if(atom.current_density)
			if(!current_density)
				current_density = 0
				directional_density = list()

			check_multiz = (atom.current_density & DOWN != current_density & DOWN || atom.current_density & UP  != current_density & UP)

			if(!directional_density.Find(atom))
				current_density |= atom.current_density
				directional_density += atom

		if(check_multiz)
			CheckMultiZ()

		if(atom.current_mob_border)
			if(!current_mob_border)
				current_mob_border = 0
				directional_mob = list()

			if(!directional_mob.Find(atom))
				current_mob_border |= atom.current_mob_border
				directional_mob += atom

		if(atom.current_group_border)
			if(!current_group_border)
				current_group_border = 0
				directional_group = list()

			if(!directional_group.Find(atom))
				current_group_border |= atom.current_group_border
				directional_group += atom

		if(atom.current_table)
			if(!current_table)
				current_table = 0
				directional_table = list()

			if(!directional_table.Find(atom))
				current_table |= atom.current_table
				directional_table += atom

		if(atom.current_glass)
			if(!current_glass)
				current_glass = list()
				directional_glass = list()

			if(!directional_glass.Find(atom))
				current_glass |= atom.current_glass
				directional_glass += atom

		if(entry_sensing)
			for(var/atom/sensitive in entry_sensing)
				sensitive.HasEntered(atom)

		if(proximity_sensing)
			for(var/atom/sensitive in proximity_sensing)
				sensitive.HasProximity(atom)

		if(atom.CheckProperty(SENSE_ENTRY))
			if(!entry_sensing)
				entry_sensing = list()
			entry_sensing |= atom

		if(atom.CheckProperty(SENSE_PROXIMITY))
			for(var/turf/turf in block(locate(x - 1, y - 1, z), locate(x + 1, y + 1, z)))
				turf.AddProximity(atom)

		if(atom.CheckProperty(SPECIAL_DENSITY))
			if(!special_objects)
				special_objects = list()
			special_objects |= atom

		if(CheckStatus(ADJACENT_ABOVE) || CheckStatus(ADJACENT_BELOW))
			atom.UpdateMultiZ(status)
		else if((atom.below_effect && atom.below_effect.loc) || (atom.above_effect && atom.above_effect.loc))
			atom.UpdateMultiZ()

		HandleInertia(atom)

	Exited(var/atom/movable/mover, var/atom/new_loc)
		if(!initialised)
			return 0

		var/density_to_update = 0
		var/object_location = 0

		if(directional_density)
			object_location = directional_density.Find(mover)
			if(object_location)
				directional_density.Cut(object_location, object_location + 1)
				density_to_update |= INCORPOREAL

		if(directional_group)
			object_location = directional_group.Find(mover)
			if(object_location)
				directional_group.Cut(object_location, object_location + 1)
				density_to_update |= PASSGRILLE

		if(directional_mob)
			object_location = directional_mob.Find(mover)
			if(object_location)
				directional_mob.Cut(object_location, object_location + 1)
				density_to_update |= PASSMOB

		if(directional_table)
			object_location = directional_table.Find(mover)
			if(object_location)
				directional_table.Cut(object_location, object_location + 1)
				density_to_update |= PASSTABLE

		if(directional_glass)
			object_location = directional_glass.Find(mover)
			if(object_location)
				directional_glass.Cut(object_location, object_location - 1)
				density_to_update |= PASSGLASS

		if(density_to_update)
			UpdateDensity(density_to_update)

		if(mover.CheckProperty(SENSE_ENTRY))
			entry_sensing -= mover
			if(!entry_sensing.len)
				entry_sensing = null

		if(mover.CheckProperty(SENSE_PROXIMITY))
			for(var/turf/turf in block(locate(x - 1, y - 1, z), locate(x + 1, y + 1, z)))
				turf.RemoveProximity(mover)

		if(mover.CheckProperty(SPECIAL_DENSITY))
			special_objects -= mover
			if(!special_objects.len)
				special_objects = null

		return ..()

	proc/UpdateDensity(var/fields)
		if(!initialised)
			return

		if(fields & INCORPOREAL)
			if(!directional_density.len)
				directional_density = null
				current_density = null
			else
				for(var/atom/movable/atom in directional_density)
					current_density |= atom.current_density
			CheckMultiZ()

		if(fields & PASSGRILLE)
			if(!directional_group.len)
				directional_group = null
				current_group_border = null
			else
				for(var/atom/movable/atom in directional_group)
					current_group_border |= atom.current_group_border

		if(fields & PASSMOB)
			if(!directional_mob.len)
				directional_mob = null
				current_mob_border = null
			else
				for(var/atom/movable/atom in directional_mob)
					current_mob_border |= atom.current_mob_border

		if(fields & PASSTABLE)
			if(!directional_table.len)
				directional_table = null
				current_table = null
			else
				for(var/atom/movable/atom in directional_table)
					current_table |= atom.current_table

		if(fields & PASSGLASS)
			if(!directional_glass.len)
				directional_glass = null
				current_glass = null
			else
				for(var/atom/movable/atom in directional_glass)
					current_glass |= atom.current_glass

	proc/AddProximity(var/atom/movable/mover)
		if(!initialised)
			return

		if(!proximity_sensing)
			proximity_sensing = list()
		proximity_sensing |= mover

	proc/RemoveProximity(var/atom/movable/mover)
		if(!initialised)
			return

		proximity_sensing -= mover
		if(!proximity_sensing.len)
			proximity_sensing = null

	proc/DirectionalPass(direction, bitflag = 0)
		if(bitflag & INCORPOREAL)
			return 1

		var/reversed_direction = ReverseDir(direction)
		var/turf/other_turf = GetStep(src, direction)
		if(!other_turf)
			return 0

		if(current_density & direction || other_turf.current_density & reversed_direction)
			return 0

		if(bitflag & PASSGRILLE && (current_group_border & direction || other_turf.current_group_border & reversed_direction))
			return 0

		if(bitflag & PASSTABLE && (current_table & direction || other_turf.current_table & reversed_direction))
			return 0

		if(bitflag & PASSMOB && (current_mob_border & direction || other_turf.current_mob_border & reversed_direction))
			return 0

		if(bitflag & PASSGLASS && (current_glass & direction || other_turf.current_glass & reversed_direction))
			return 0

		return 1

	proc/HandleInertia(var/atom/movable/atom)
		if(!atom)
			return

		HandleGravity(atom)

	proc/InertialDrift(atom/movable/A as mob|obj)

	proc/HandleGravity(var/atom/movable/atom)
		if(!gravity_z)
			return

		if(gravity_z < 0 && !CheckStatus(HAS_BELOW))
			return

		if(gravity_z > 0 && !CheckStatus(HAS_ABOVE))
			return

		spawn(1 / gravity_z)
			var/target_z = z + 1
			if(z < 0)
				target_z -= 2

			atom.Move(locate(x, y, target_z))

	proc/LevelUpdate()
		for(var/atom/O in src)
			O.Hide(level)

	proc/CheckMultiZ()
		if(DirectionalPass(UP) && !CheckStatus(HAS_ABOVE))
			var/turf/turf = locate(x, y, z - 1)
			SetStatus(HAS_ABOVE)
			turf.SetStatus(HAS_BELOW)

			for(var/turf/adjacent_turf in block(locate(x - 1, y - 1, z), locate(x + 1, y + 1, z)))
				adjacent_turf.SetStatus(ADJACENT_ABOVE)
			for(var/turf/adjacent_turf in block(locate(x - 1, y - 1, z - 1), locate(x + 1, y + 1, z - 1)))
				adjacent_turf.SetStatus(ADJACENT_BELOW)

			for(var/atom/movable/atom in src)
				HandleGravity(atom)

		else if(!DirectionalPass(UP) && CheckStatus(HAS_ABOVE))
			var/turf/turf = locate(x, y, z - 1)
			SetStatus(HAS_ABOVE, 0)
			turf.SetStatus(HAS_BELOW, 0)

			UpdateAdjacency(z - 1)


		if(DirectionalPass(DOWN) && !CheckStatus(HAS_BELOW))
			var/turf/turf = locate(x, y, z + 1)
			SetStatus(HAS_BELOW)
			turf.SetStatus(HAS_ABOVE)

			for(var/turf/adjacent_turf in block(locate(x - 1, y - 1, z + 1), locate(x + 1, y + 1, z + 1)))
				adjacent_turf.SetStatus(ADJACENT_ABOVE)
			for(var/turf/adjacent_turf in block(locate(x - 1, y - 1, z), locate(x + 1, y + 1, z)))
				adjacent_turf.SetStatus(ADJACENT_BELOW)

			for(var/atom/movable/atom in src)
				HandleGravity(atom)

		else if(!DirectionalPass(DOWN) && CheckStatus(HAS_BELOW))
			var/turf/turf = locate(x, y, z + 1)
			SetStatus(HAS_BELOW, 0)
			turf.SetStatus(HAS_ABOVE, 0)

			UpdateAdjacency()

	proc/UpdateAdjacency(var/considering_z = z)
		var/list/reconsidering_turfs = block(locate(x - 1, y - 1, considering_z), locate(x + 1, y + 1, considering_z ))

		for(var/turf/adjacent_turf in block(locate(x - 2, y - 2, considering_z), locate(x + 2, y + 2, considering_z)))
			if(adjacent_turf.CheckStatus(HAS_BELOW))
				reconsidering_turfs -= block(locate(adjacent_turf.x - 1, adjacent_turf.y - 1, considering_z), locate(adjacent_turf.x + 1, adjacent_turf.y + 1, considering_z))

		for(var/turf/unset_turf in reconsidering_turfs)
			var/turf/turf = locate(unset_turf.x, unset_turf.y, considering_z + 1)
			unset_turf.SetStatus(ADJACENT_BELOW, 0)
			turf.SetStatus(ADJACENT_ABOVE, 0)

	UpdateMultiZ(var/directions)
		//If the turf we are on does not need update, let's not waste the cycles.
		if(!initialised)
			return

		if(directions & ADJACENT_ABOVE)
			if(!above_effect)
				above_effect = new
				above_effect.Bind(src, ABOVE)

			above_effect.Move(locate(x, y, z - 1))
		else if(above_effect)
			above_effect.Move(null)

		if(directions & ADJACENT_BELOW)
			if(!below_effect)
				below_effect = new
				below_effect.Bind(src, BELOW)

			below_effect.Move(locate(x, y, z + 1))
		else
			below_effect.Move(null)

	UpdateIcon()
		//If the turf we are on does not need update, let's not waste the cycles.
		if(!initialised)
			return

		if(!(CheckStatus(ADJACENT_ABOVE) || CheckStatus(ADJACENT_BELOW)))
			return

		if(below_effect)
			below_effect.Update()


		if(above_effect)
			above_effect.Update()