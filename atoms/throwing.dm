
	proc/HitCheck(var/speed)
		if(thrown)
			for(var/atom/A in GetTurf(src))
				if(A == src)
					continue

				if(istype(A,/mob/living))
					if(A:lying)
						continue
					ThrowImpact(A, speed)
					if(thrown == 1)
						thrown = 0

				if(isobj(A))
					if(A.density && !A.throwpass)	// **TODO: Better behaviour for windows which are dense, but shouldn't always stop movement
						ThrowImpact(A, speed)
						thrown = 0

	proc/ThrowAt(atom/target, range, speed)
		if(!target || !src)
			return 0
		//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

		thrown = 1

		if(usr && HULK in usr.mutations)
			thrown = 2 // really strong throw!

		var/dist_x = abs(target.x - src.x)
		var/dist_y = abs(target.y - src.y)

		var/dx
		if (target.x > src.x)
			dx = EAST
		else
			dx = WEST

		var/dy
		if (target.y > src.y)
			dy = NORTH
		else
			dy = SOUTH
		var/dist_travelled = 0
		var/dist_since_sleep = 0
		var/area/a = GetArea(loc)
		if(dist_x > dist_y)
			var/error = dist_x/2 - dist_y

			while(src && target &&((((src.x < target.x && dx == EAST) || (src.x > target.x && dx == WEST)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/unsimulated/space)) && src.thrown && istype(src.loc, /turf))
				// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
				if(error < 0)
					var/atom/step = get_step(src, dy)
					if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
						break
					Move(step)
					HitCheck(speed)
					error += dist_x
					dist_travelled++
					dist_since_sleep++
					if(dist_since_sleep >= speed)
						dist_since_sleep = 0
						sleep(1)
				else
					var/atom/step = get_step(src, dx)
					if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
						break
					Move(step)
					HitCheck(speed)
					error -= dist_y
					dist_travelled++
					dist_since_sleep++
					if(dist_since_sleep >= speed)
						dist_since_sleep = 0
						sleep(1)
				a = GetArea(src.loc)
		else
			var/error = dist_y/2 - dist_x
			while(src && target &&((((src.y < target.y && dy == NORTH) || (src.y > target.y && dy == SOUTH)) && dist_travelled < range) || (a.has_gravity == 0)  || istype(src.loc, /turf/unsimulated/space)) && src.thrown && istype(src.loc, /turf))
				// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
				if(error < 0)
					var/atom/step = get_step(src, dx)
					if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
						break
					Move(step)
					HitCheck(speed)
					error += dist_y
					dist_travelled++
					dist_since_sleep++
					if(dist_since_sleep >= speed)
						dist_since_sleep = 0
						sleep(1)
				else
					var/atom/step = get_step(src, dy)
					if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
						break
					Move(step)
					HitCheck(speed)
					error -= dist_x
					dist_travelled++
					dist_since_sleep++
					if(dist_since_sleep >= speed)
						dist_since_sleep = 0
						sleep(1)

				a = GetArea(src.loc)

		//done throwing, either because it hit something or it finished moving
		thrown = 0
		if(isobj(src))
			ThrowImpact(GetTurf(src),speed)



	proc/ThrowImpact(atom/hit_atom, var/speed)
		if(istype(hit_atom,/mob/living))
			var/mob/living/M = hit_atom
			M.hitby(src, speed)

		else if(isobj(hit_atom))
			var/obj/O = hit_atom
			if(!O.anchored)
				step(O, src.dir)
			O.hitby(src, speed)

		else if(isturf(hit_atom))
			var/turf/T = hit_atom
			if(T.density)
				spawn(2)
					step(src, turn(src.dir, 180))
				if(istype(src,/mob/living))
					var/mob/living/M = src
					M.take_organ_damage(20)