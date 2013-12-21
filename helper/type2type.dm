proc/text2list(var/string, var/separator = "\n")
	if(!istext(string) || !istext(separator))
		return

	. = list()
	var/last_index = 1
	var/current_index = 1
	var/separator_length = length(separator)

	while(TRUE)
		current_index = findtext(string, separator, last_index)
		. += copytext(string, last_index, current_index)

		if(!current_index)
			break

		last_index = current_index + separator_length