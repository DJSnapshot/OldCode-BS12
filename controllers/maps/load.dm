MapManager/proc/LoadMap(var/savefile/map_file, var/x = 1, var/y = 1, var/z = 1, var/buffer = 3 * world.view + 2)
	log_file << "\tBeginning Load: [map_file.name]"
	var/start_time = world.timeofday

	var/x_dimension = map_file["x"]
	var/y_dimension = map_file["y"]
	var/z_dimension = map_file["z"]
	var/list/map = map_file["map"]

	if(map.len != x_dimension * y_dimension * z_dimension)
		log_file << "\t\tMap incomplete, aborting."
		return "map incomplete"

	var/Frame/frame = new
	frame.x_pos = x
	frame.y_pos = y
	frame.z_pos = z
	frame.x_size = x_dimension
	frame.y_size = y_dimension
	frame.z_size = z_dimension
	frame.buffer = buffer

	map_file["mass"] >> frame.mass
	map_file["make"] >> frame.make
	map_file["model"] >> frame.model
	map_file["type"] >> frame.vessel_type

	var/list/areas = list()
	var/list/all_objects = list()

	for(var/map_position in 1 to map.len)
		var/turf/target = locate(x + (map_position - 1) % x_dimension,\
			y + ((map_position - 1) / x_dimension) % y_dimension,\
			z + ((map_position - 1) / (x_dimension * y_dimension)) % z_dimension)
		frame.contents.Add(target)

		if(!map[map_position])
			continue

		if(prob(1))
			sleep(1)
		var/list/turf = map[map_position]
		for(var/index in 1 to turf.len)
			var/object_type = turf[index][1]
			var/object_settings = turf[index][2]

			//Handle creation of areas, keeping them isolated to the frame
			if(ispath(object_type, /area))
				if(object_settings in areas)
					var/area/tarGetArea = areas[object_settings]
					tarGetArea.contents.Add(target)
				else
					var/area/new_area = new object_type(__mapload = object_settings)
					new_area.frame = frame
					new_area.contents.Add(target)
					all_objects.Add(new_area)
					areas[object_settings] = new_area

			//Make sure the object knows it is being loaded.
			if(!object_settings)
				object_settings = 1

			//Create the object and add it to the list.
			var/new_object = new object_type(target, __mapload = object_settings)
			all_objects.Add(new_object)

	log_file << "\tMap Load Complete, [(world.timeofday - start_time)/10] seconds."
	return all_objects

/*
MapManager/proc/AddBuffer(var/Frame/frame, var/buffer = 3 * world.world.view + 2)
	//Gather a mass of buffer turfs.
	//West side
	var/list/buffer_turfs = block(locate(frame.x_pos - buffer, frame.y_pos + frame.y_size + buffer - 1, frame.z_pos),\
		locate(frame.x_pos - 1, frame.y_pos - buffer, frame.z_pos + frame.z_size - 1))
	//East side
	buffer_turfs += block(locate(frame.x_pos + frame.x_size + buffer - 1, frame.y_pos + frame.y_size + buffer - 1, frame.z_pos),\
		locate(frame.x_pos + frame.x_size, frame.y_pos - buffer, frame.z_pos + frame.z_size - 1))
	//North
	buffer_turfs += block(locate(frame.x_pos, frame.y_pos + frame.y_size + buffer - 1, frame.z_pos),\
		locate(frame.x_pos + frame.x_size - 1, frame.y_pos - buffer, frame.z_pos + frame.z_size - 1))
	//South
	buffer_turfs += block(locate(frame.x_pos, frame.y_pos - buffer, frame.z_pos),\
		locate(frame.x_pos + frame.x_size - 1, frame.y_pos - 1, frame.z_pos + frame.z_size - 1))

	//Add them all to the frame
	for(var/turf/turf in buffer_turfs)
		var/turf/new_turf = new world.turf(turf)
		frame.contents.Add(new_turf)

	//Add teleport things.
	buffer_turfs = block(locate(frame.x_pos + (world.view + 1) - buffer, frame.y_pos + (world.view + 1) - buffer, frame.z_pos),\
			locate(frame.x_pos + (world.view + 1) - buffer, frame.y_pos + frame.y_size + buffer - (world.view + 1), frame.z_pos + frame.z_size - 1))
	buffer_turfs += block(locate(frame.x_pos + frame.x_size + buffer - (world.view + 1), frame.y_pos + (world.view + 1) - buffer, frame.z_pos),\
			locate(frame.x_pos + frame.x_size + buffer - (world.view + 1), frame.y_pos + frame.y_size + buffer - (world.view + 1), frame.z_pos + frame.z_size - 1))
	buffer_turfs += block(locate(frame.x_pos + (world.view + 1) - buffer, frame.y_pos + (world.view + 1) - buffer, frame.z_pos),\
			locate(frame.x_pos + frame.x_size + buffer - (world.view + 1), frame.y_pos + (world.view + 1) - buffer, frame.z_pos + frame.z_size - 1))
	buffer_turfs += block(locate(frame.x_pos + (world.view + 1) - buffer, frame.y_pos + frame.y_size + buffer - (world.view + 1), frame.z_pos),\
			locate(frame.x_pos + frame.x_size + buffer - (world.view + 1), frame.y_pos + frame.y_size + buffer - (world.view + 1), frame.z_pos + frame.z_size - 1))

	for(var/turf/turf in buffer_turfs)
		new /turf/teleport(turf)

	buffer_turfs = block(locate(frame.x_pos - buffer - 1, frame.y_pos - buffer - 1, frame.z_pos),\
			locate(frame.x_pos - buffer - 1, frame.y_pos + frame.y_size + buffer, frame.z_pos + frame.z_size - 1))
	buffer_turfs += block(locate(frame.x_pos + frame.x_size + buffer, frame.y_pos - buffer - 1, frame.z_pos),\
			locate(frame.x_pos + frame.x_size + buffer, frame.y_pos + frame.y_size + buffer, frame.z_pos + frame.z_size - 1))
	buffer_turfs += block(locate(frame.x_pos - buffer - 1, frame.y_pos - buffer - 1, frame.z_pos),\
			locate(frame.x_pos + frame.x_size + buffer, frame.y_pos - buffer - 1, frame.z_pos + frame.z_size - 1))
	buffer_turfs += block(locate(frame.x_pos - buffer - 1, frame.y_pos + frame.y_size + buffer, frame.z_pos),\
			locate(frame.x_pos + frame.x_size + buffer, frame.y_pos + frame.y_size + buffer, frame.z_pos + frame.z_size - 1))

	for(var/turf/turf in buffer_turfs)
		new /turf/block(turf) */