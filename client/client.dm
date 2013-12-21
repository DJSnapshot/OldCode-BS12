client/verb/check_status()
	var/turf/location = GetTurf(mob)
	mob << {"[location]\n\tCan Fall = [location.DirectionalPass(DOWN, mob.pass_flags) ? "True" : "False"]\n\tDensity = [location.current_density]\n\tFlags = [location.status]\n\tUD = [location.status & ~(NORTH|SOUTH|EAST|WEST)]"}

client/verb/mob_status()
