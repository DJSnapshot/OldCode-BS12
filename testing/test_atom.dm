mob/test
	icon = 'icons/testing.dmi'
	icon_state = "mob"

	Bump(var/atom/movable/atom)
		src << "Bumped [atom] - [atom == src]"
		. = ..()

	verb/move_to_start()
		Move(locate(2, 2, 1))

	verb/move_to_end()
		Move(locate(2,2,2))