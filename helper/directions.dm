var/list/cardinal = list(NORTH, SOUTH, EAST, WEST, UP, DOWN)
var/list/all_dirs = list(\
	NORTH, SOUTH, EAST, NORTHEAST, SOUTHEAST, WEST, NORTHWEST, SOUTHWEST,\
	UP, NORTH|UP, SOUTH|UP, EAST|UP, NORTHEAST|UP, SOUTHEAST|UP, WEST|UP, NORTHWEST|UP, SOUTHWEST|UP,\
	DOWN, NORTH|DOWN, SOUTH|DOWN, EAST|DOWN, NORTHEAST|DOWN, SOUTHEAST|DOWN, WEST|DOWN, NORTHWEST|DOWN, SOUTHWEST|DOWN)
var/list/moore_neighborhood = list(NORTH, SOUTH, EAST, NORTHEAST, SOUTHEAST, WEST, NORTHWEST, SOUTHWEST)
var/list/directional_bitfield_lookup_table = list(\
	list(\
		NORTH,\
		SOUTH,\
		EAST,\
		WEST,\
		UP,\
		DOWN),\
	list(\
		SOUTH,\
		NORTH,\
		WEST,\
		EAST,\
		UP,\
		DOWN),\
	list(\
		EAST,\
		WEST,\
		SOUTH,\
		NORTH,\
		UP,\
		DOWN),\
	list(\
		WEST,\
		EAST,\
		NORTH,\
		SOUTH,\
		UP,\
		DOWN),\
	list(\
		UP,\
		DOWN,\
		EAST,\
		WEST,\
		SOUTH,\
		NORTH),\
	list(\
		DOWN,\
		UP,\
		EAST,\
		WEST,\
		NORTH,\
		SOUTH))

proc/TurnBitfield(var/direction_field, var/new_direction)
	if(new_direction == NORTH || direction_field == ALLDIR)
		return direction_field

	var/lookup_index = cardinal.Find(new_direction)

	if(!lookup_index || !isnum(direction_field))
		return

	. = 0

	for(var/base_index in 1 to cardinal.len)
		if(direction_field & cardinal[base_index])
			. |= directional_bitfield_lookup_table[lookup_index][base_index]

proc/ReverseDir(dir)
	.  = (dir & NORTH) ? SOUTH : 0
	. |= (dir & SOUTH) ? NORTH : 0
	. |= (dir & EAST) ? WEST : 0
	. |= (dir & WEST) ? EAST : 0
	. |= (dir & UP) ? DOWN : 0
	. |= (dir & DOWN) ? UP : 0

/proc/GetDir(var/atom/ref, var/atom/target)
	target = GetTurf(target)
	ref = GetTurf(ref)
	if (!ref || !target || ref == target)
		return 0
	return get_dir(ref, target) | (target.z > ref.z ? DOWN : 0) | (target.z < ref.z ? UP : 0)