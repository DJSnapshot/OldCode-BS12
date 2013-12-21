/atom
	proc/CheckProperty(var/bitflag)
		if(!isnum(bitflag))
			return 0
		return properties & bitflag

	proc/SetProperty(var/bitflag, var/set_as = 1)
		if(!isnum(bitflag))
			return 0
		if(set_as)
			properties |= bitflag
		else
			properties &= ~bitflag

	proc/ToggleProperty(var/bitflag)
		SetProperty(bitflag, !CheckProperty(bitflag))

	proc/CheckStatus(var/bitflag)
		if(!isnum(bitflag))
			return 0
		return status & bitflag

	proc/SetStatus(var/bitflag, var/set_as = 1)
		if(!isnum(bitflag))
			return 0
		if(set_as)
			status |= bitflag
		else
			status &= ~bitflag

	proc/ToggleStatus(var/bitflag)
		SetStatus(bitflag, !CheckStatus(bitflag))

	proc/CheckPassFlag(var/bitflag)
		if(!isnum(bitflag))
			return 0
		return pass_flags & bitflag

	proc/SetPassFlag(var/bitflag, var/set_as = 1)
		if(!isnum(bitflag))
			return 0
		if(set_as)
			pass_flags |= bitflag
		else
			pass_flags &= ~bitflag

	proc/TogglePassFlag(var/bitflag)
		SetPassFlag(bitflag, !CheckPassFlag(bitflag))

	proc/CheckClothingFlag(var/bitflag)
		if(!isnum(bitflag))
			return 0
		return clothing_flags & bitflag

	proc/SetClothingFlag(var/bitflag, var/set_as = 1)
		if(!isnum(bitflag))
			return 0
		if(set_as)
			clothing_flags |= bitflag
		else
			clothing_flags &= ~bitflag

	proc/ToggleClothingFlag(var/bitflag)
		SetClothingFlag(bitflag, !CheckClothingFlag(bitflag))