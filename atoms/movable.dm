/atom/movable
	layer = OBJ_LAYER

	var/atom/anchored

	//Density information
	//Blocks everything except INCORPOREAL
	var/tmp/current_density
	var/directional_density
	//Blocks airflow or PASSGRILLE
	//	Air flows through it, anything else that can may as well be air.
	var/tmp/current_group_border
	var/directional_group_border
	//Blocks everything without PASSMOB
	var/tmp/current_mob_border
	var/directional_mob_border
	//Blocks everything without PASSGLASS
	var/tmp/current_glass
	var/directional_glass_border
	//Blocks anything without PASSTABLE
	var/tmp/current_table
	var/directional_table_border

	var/tmp/inertia_x = 0
	var/tmp/inertia_y = 0
	var/tmp/inertia_z = 0
	var/tmp/last_move_dir = NORTH
	var/tmp/last_move_time = 0
	var/tmp/move_speed = 1
	var/tmp/moved_recently = 0

	var/tmp/mob/pulledby

	Initialise()
		. = ..()
		if(!.)
			return

		if(density)
			directional_density = ALLDIR

		Dir(dir, 0)

		if(loc)
			loc.Entered(src, null)

	//		if(istype(loc, /turf))
	//			UpdateMultiZ(loc:status)

		if(anchored)
			Anchor(anchored)

	Terminate()
		. = ..()
		if(!.)
			return

		if(anchored)
			DeAnchor(FALSE)

	Del()
		Move(null)
		. = ..()

	GCDel()
		. = ..()
		Move(null)

	Move(new_loc, direction, step_x, step_y)

		last_move_dir = direction
		move_speed = world.timeofday - last_move_time
		last_move_time = world.timeofday

		if(initialised)
			Dir(direction)
			return ..()

		if(!new_loc)
			loc.Exited(src, new_loc)
			loc = null
			return 1

		return 0

	Dir(new_dir, var/update = 1)
		var/needing_update = 0

		if(directional_density)
			current_density = TurnBitfield(directional_density, new_dir)
			needing_update |= INCORPOREAL
		if(directional_group_border)
			current_group_border = TurnBitfield(directional_group_border, new_dir)
			needing_update |= PASSGRILLE
		if(directional_mob_border)
			current_mob_border = TurnBitfield(directional_mob_border, new_dir)
			needing_update |= PASSMOB
		if(directional_glass_border)
			current_glass = TurnBitfield(directional_glass_border, new_dir)
			needing_update |= PASSGLASS
		if(directional_table_border)
			current_table = TurnBitfield(directional_table_border, new_dir)
			needing_update |= PASSTABLE

		if(needing_update && update && isturf(loc))
			for(var/turf/turf in locs)
				turf.UpdateDensity(needing_update)

		return ..()

	//This should be used rarely enough I have no issue doing it like this.
	SetProperty()
		var/atom/old_loc = loc
		Move(null)
		. = ..()
		Move(old_loc)

	proc/Anchor(var/atom/target)
		if(!istype(target))
			return

		anchored = target
		if(!target.anchoring)
			target.anchoring = list()
		target.anchoring.Add(src)

	proc/DeAnchor(remove_link = TRUE)
		if(anchored && anchored.anchoring)
			anchored.anchoring.Remove(src)
		if(remove_link)
			anchored = null

	Bump(var/atom/obstacle, recurse = 0)
		/*if(thrown)
			ThrowImpact(obstacle)
			thrown = 0 */

		last_bumped = world.time

		if (obstacle && recurse)
			if(istype(obstacle, /atom/movable))
				obstacle:Bump(src)
			else
				obstacle.Bumped(src)
		return ..()

	Bumped(obstacle)
		return Bump(obstacle)

	UpdateMultiZ(var/directions = 0)
		//If the turf we are on does not need update, let's not waste the cycles.
		if(!initialised || !istype(loc, /turf))
			return

		world << "[src] - [directions]"

		if(directions & ADJACENT_BELOW)
			if(!above_effect)
				above_effect = new
				above_effect.Bind(src, ABOVE)

			if(!above_effect.Move(locate(x, y, z + 1)))
				world << above_effect.Move(null)
		else if(above_effect)
			above_effect.Move(null)

		if(directions & ADJACENT_ABOVE)
			if(!below_effect)
				below_effect = new
				below_effect.Bind(src, BELOW)

			if(!below_effect.Move(locate(x, y, z - 1)))
				world << below_effect.Move(null)
		else
			world << below_effect.Move(null)

	UpdateIcon()
		//If the turf we are on does not need update, let's not waste the cycles.
		if(!initialised || !istype(loc, /turf))
			return

		var/needs_update = 0
		for(var/turf/turf in locs)
			if(turf.CheckStatus(ADJACENT_ABOVE) || turf.CheckStatus(ADJACENT_BELOW))
				needs_update = 1
				break

		if(!needs_update)
			return

		if(below_effect)
			below_effect.Update()


		if(above_effect)
			above_effect.Update()