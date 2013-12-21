effect
	parent_type = /atom/movable
	pass_flags = INCORPOREAL

	var/tmp/atom/parent_atom

	proc/Bind(var/atom/copied)
		if(!copied)
			return

		icon = copied.icon
		icon_state = copied.icon_state
		name = copied.name
		desc = copied.desc
		level = copied.level
		layer = copied.layer
		pixel_x = copied.pixel_x
		pixel_y = copied.pixel_y

		if(istype(copied, /effect))
			parent_atom = copied:parent_atom
		else
			parent_atom = copied

	Del()
		Terminate()
		return ..()

	Terminate()
		. = ..()
		if(!.)
			return

		parent_atom = null

effect/multiz
	var/tmp/relative_level

	Bind(var/atom/copied, var/zlevel)
		relative_level = zlevel

		if(istype(copied, /effect))
			parent_atom = copied:parent_atom
		else
			parent_atom = copied

		Update()

	UpdateIcon()
		return
	UpdateMultiZ()
		return

	proc/Update()
		if(icon != parent_atom.icon)
			icon = parent_atom.icon
		if(icon_state != parent_atom.icon_state)
			icon_state = parent_atom.icon_state

		name = parent_atom.name
		desc = parent_atom.desc
		layer = parent_atom.layer
		pixel_x = parent_atom.pixel_x
		color = parent_atom.color
		alpha = parent_atom.alpha
		invisibility = parent_atom.invisibility

		if(relative_level == ABOVE)
			pixel_y = parent_atom.pixel_y + 20
			mouse_opacity = 0
			layer += 100
			alpha = 100
		else
			pixel_y = parent_atom.pixel_y - 20
			layer -= 100