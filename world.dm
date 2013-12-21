/*
	These are simple defaults for your project.
 */

world
	fps = 25		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default
	view = 7		// show up to 7 tiles outward from center (15x15 view)

	mob = /mob/test
	area = /Frame
	turf = /turf

	New()
		. = ..()

		master_controller = new
		master_controller.Initialise()