/proc/GetArea(var/atom/movable/O)
	if(isarea(O))
		return O

	if(isturf(O))
		return O:loc

	if(!istype(O) || !O.loc)
		return

	var/turf/turf = GetTurf(O)
	return turf.loc

/proc/GetFrame(var/atom/movable/atom)
	var/area/area = GetArea(atom)
	if(!istype(area))
		return
	return area.frame

/proc/GetTurf(var/atom/movable/atom)
	if(isturf(atom))
		return atom

	if(!istype(atom) || !atom.loc)
		return null

	return atom.locs[1]