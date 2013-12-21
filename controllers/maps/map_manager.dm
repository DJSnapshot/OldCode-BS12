var/MapManager/map_manager = new

MapManager
	var/list/loaded_areas
	var/list/level_map
	var/log_file
	var/static/quote = "\""
	var/static/map_directory = "maps/loader/"
	var/static/map_type = "drm" //Dungeon Runtime Map

	New()
		//Set up the logging file,
		//	prep the list of areas with the "open space" area
		//	and set up the area map stuff.
		log_file = file("maploader_debug.txt")
		log_file << "Map Manager Started."

		loaded_areas = list(locate(world.area))

	proc/HandleFrameExit(var/obj/thing, var/Frame/frame)

	proc/Load(var/file_name)
		if(!(copytext(file_name, length(file_name) - 2) in list(map_type, "dmm")))
			log_file << "\tError: Invalid file type - [file_name]"
			return FALSE

		if(copytext(file_name, 1, length(map_directory) + 1) != map_directory)
			var/list/file_path = text2list(file_name, "/")
			var/in_file = file(file_name)
			file_name = file_path[file_path.len]
			if(fexists("[map_directory][file_name]"))
				fdel("[map_directory][file_name]")
			var/out_file = file("[map_directory][file_name]")
			out_file << file2text(in_file)

		var/file_type = copytext(file_name, length(file_name) - 2)
		file_name = copytext(file_name, 1, length(file_name) - 3)
		if(file_type == "dmm")
			CompileMap(file_name)

		world.maxz++
		LoadMap(new /savefile("[map_directory][file_name].[map_type]"), 1, 1, 1, 0)