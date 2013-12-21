#define DMM_IGNORE_AREAS 1
#define DMM_IGNORE_TURFS 2
#define DMM_IGNORE_OBJS 4
#define DMM_IGNORE_NPCS 8
#define DMM_IGNORE_PLAYERS 16
#define DMM_IGNORE_MOBS 24
MapManager/proc/SaveMap(var/Frame/frame, var/savefile/savefile, var/flags)
	var/list/map = list()
	for(var/z in frame.z_pos to frame.z_pos + frame.z_size - 1)
		for(var/y in frame.y_pos to frame.y_pos + frame.y_size - 1)
			for(var/x in frame.x_pos to frame.x_pos + frame.x_size - 1)
				map[++map.len] = MakeModel(locate(x,y,z), flags)

	savefile["x"] = frame.x_size
	savefile["y"] = frame.y_size
	savefile["z"] = frame.z_size
	savefile["map"] = map
	return TRUE

MapManager/proc/MakeModel(var/turf/turf as turf, var/flags)//turf turf turf
	var/list/objects = turf.contents
	if(!(flags & DMM_IGNORE_TURFS))
		objects = turf + objects

	var/list/results = list()
	for(var/atom/thing in objects)
		if(istype(thing, /obj) && flags & DMM_IGNORE_OBJS)
			continue

		if(istype(thing, /mob))
			if(flags & DMM_IGNORE_MOBS)
				continue
			if(flags & DMM_IGNORE_NPCS && !thing:ckey)
				continue
			if(flags & DMM_IGNORE_PLAYERS && thing:ckey)
				continue

		var/list/variables = list()
		for(var/variable in thing.vars)
			if(issaved(thing.vars[variable]) && thing.vars[variable] != initial(thing.vars[variable]))
				variables[variable] = thing.vars[variable]

		if(variables.len)
			results[++results.len] = list(thing.type, null)
		else
			results[++results.len] = list(thing.type, variables)

	if(!(flags & DMM_IGNORE_AREAS) && !istype(turf.loc, /Frame))
		var/list/area_vars = list()
		for(var/variable in turf.loc.vars)
			if(issaved(turf.loc.vars[variable]) && turf.loc.vars[variable] != initial(turf.loc.vars[variable]))
				area_vars[variable] = turf.loc.vars[variable]
		if(area_vars.len)
			results[++results.len] = list(turf.loc, null)
		else
			results[++results.len] = list(turf.loc, area_vars)

	return results