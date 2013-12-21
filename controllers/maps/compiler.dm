MapData
	parent_type = /obj
	invisibility = 101

	var/vessel_type = "station" as text
	var/make = "independent" as text
	var/model = "unknown" as text

MapManager/proc/CompileMap(var/map_name as text)
	log_file << "\tCompiling map: [map_name].dmm -> [map_name].[map_type]"
	var/start_time = world.timeofday
	if(!fexists("[map_directory][map_name].dmm"))
		log_file << "\t\tError: File does not exist."
		return FALSE

	//Now that we have completed the sanity checks, let's load the file and
	//	begin parsing it.
	var/source_file = file("[map_directory][map_name].dmm")
	var/savefile/destination_file = new ("[map_directory][map_name].[map_type]")
	var/checksum = md5(source_file)

	//Check if we need to compile.
	if(destination_file.dir.Find("checksum") && destination_file["checksum"] == checksum)
		log_file << "\tCompleted.  Map has already been compiled."
		return TRUE

	var/file_contents = file2text(source_file)
	if(!length(file_contents))
		log_file << "\t\tError: File is empty."

	//Holds the location where the definitions end and the map begins
	var/definition_end = findtext(file_contents, "\n\n")

	//Semi-formatted lists of the models and z-levels
	var/list/all_models = text2list(copytext(file_contents, 1, definition_end), "\n")
	var/list/all_levels = text2list(copytext(file_contents, definition_end + 2), "\n\n")
	if(!all_models || !all_models.len || !all_levels || !all_levels.len)
		log_file << "\t\tError: File is malformed."
		return FALSE

	var/list/turf_models = list()
	var/token_length
	var/list/map_data

	for(var/model in all_models)
		//Separate the model into the key and the contents.
		//	e.g. "aaa" = (/turf/unsimulated/space,/frame)
		//	becomes list("aaa" = "/turf/unsimulated/space,/frame")
		var/seperator = findtext(model, " = ")
		var/model_token = copytext(model, 2, seperator - 1)
		var/model_contents = copytext(model, seperator + 4, length(model))

		if(!token_length)
			token_length = length(model_token)

		var/list/parsed_model = ParseModel(model_contents)
		if(!map_data && islist(parsed_model))
			for(var/index in 1 to parsed_model.len)
				if(ispath(parsed_model[index][1], /MapData))
					map_data = parsed_model[index][2]

		turf_models[model_token] = parsed_model

	var/list/encoded_map = list()
	var/x_dimension
	var/y_dimension
	var/z_dimension = 0

	//Begin encoding the map.
	for(var/level in all_levels)
		//First, we split the level into a list with each entry being a slice of
		//	the level along the x-axis.
		level = copytext(level, findtext(level, "{\"\n") + 3, findtext(level, "\n\"}"))
		if(!level)
			break
		var/list/split_level = text2list(level, "\n")

		//Handle dimension measurements.
		z_dimension++
		if(!x_dimension)
			x_dimension = length(split_level[1])/token_length
			y_dimension = split_level.len
			if(x_dimension != round(x_dimension))
				log_file << "\t\tError: x-dimension not integer! [length(split_level[1])] v.s. [token_length]"
				return FALSE

		//Then, begin loading the models into the list.
		for(var/y_index in y_dimension to 1 step -1)
			for(var/x_index in 1 to ((x_dimension - 1) * token_length) + 1 step token_length)
				encoded_map[++encoded_map.len] = turf_models[copytext(split_level[y_index], x_index, x_index + token_length)]

	destination_file["checksum"] << checksum
	destination_file["map"] << encoded_map
	destination_file["x"] << x_dimension
	destination_file["y"] << y_dimension
	destination_file["z"] << z_dimension
	if(map_data)
		destination_file["mass"] << map_data["mass"]
		destination_file["make"] << map_data["make"]
		destination_file["model"] << map_data["model"]
		destination_file["type"] << map_data["vessel_type"]

	log_file << "\tCompile completed, [(world.timeofday - start_time)/10] seconds."
	return TRUE

MapManager/proc/ParseModel(var/model_text)
	var/list/result = list()

	var/list/text_strings = list()
	var/index = 0
	while(findtext(model_text, quote))
		/*Loop: Stores quoted portions of text in text_strings, and replaces them with an
				index to that list.
				- Each iteration represents one quoted section of text.
				*/

		index++
		//Add the next section of quoted text to the list
		var/first_quote = findtext(model_text, quote)
		var/second_quote = findtext(model_text, quote, first_quote + 1)
		var/quoted_chunk = copytext(model_text, first_quote + 1, second_quote)
		text_strings += quoted_chunk
		//Then remove the quoted section.
		model_text = copytext(model_text, 1, first_quote) + "~[index]" + copytext(model_text, second_quote + 1)

	var/list/objects = text2list(model_text, ",/")
	for(var/object in objects)
		var/variable_seperator = findtext(object, "{")
		var/path = text2path(copytext(object, 1, variable_seperator))

		//Let's let the maploader handle this.
		if(!path || path == world.area || path == world.turf)
			continue

		if(variable_seperator)
			var/list/variables = list()
			for(var/variable in text2list(copytext(object, variable_seperator + 1, length(object)), "; "))
				variables.Add(ParseVars(variable, text_strings))

			if(!ispath(path, /area))
				result[++result.len] = list(path, variables)
			else
				result[++result.len] = list(path, list2params(variables))

		else
			result[++result.len] = list(path, null)
	if(result.len)
		return result


MapManager/proc/ParseVars(var/list/entry, var/list/strings)
	var/split_point = findtext(entry, " = ")
	var/entry_name

	//Associative
	//the entry_name thing is to shut up the compiler.
	//It thinks the variable is not being used.
	if(split_point && !entry_name)
		var/destring = findtext(entry, "~", 1, split_point)
		if(destring)
			entry_name = strings[text2num(copytext(entry, destring, split_point))]
		else
			entry_name = copytext(entry, 1, split_point)
		entry = copytext(entry, split_point + 3)

	if(findtext(entry, "list("))
		entry = list()
		for(var/variable in text2list(copytext(entry, 6, length(entry)), ", "))
			entry.Add(ParseVars(variable, strings))

	else if(findtext(entry, "~"))//Check for strings
		while(findtext(entry,"~"))
			var/reference_index = copytext(entry, findtext(entry, "~") + 1)
			entry = strings[text2num(reference_index)]

	//Check for numbers
	else if(isnum(text2num(entry)))
		entry = text2num(entry)

	//Check for file
	else if(copytext(entry,1,2) == "'")
		if(copytext(entry, length(entry) - 3, length(entry)) == "dmi")
			entry = icon(copytext(entry, 2, length(entry)))
		else
			entry = file(copytext(entry, 2, length(entry)))

	if(split_point)
		var/list/new_list = list()
		new_list[entry_name] = entry
		return new_list
	else
		return entry