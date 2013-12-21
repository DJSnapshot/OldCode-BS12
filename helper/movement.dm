/proc/GetStep(var/atom/atom, var/direction)
	if(!direction)
		return

	atom = GetTurf(atom)
	if(!atom)
		return

	atom = get_step(atom, direction & ~(DOWN|UP))
	direction = direction & ~(NORTH|SOUTH|EAST|WEST)

	if(direction & UP)
		atom = locate(atom.x, atom.y, atom.z - 1)
	if(direction & DOWN)
		atom = locate(atom.x, atom.y, atom.z + 1)

	return atom