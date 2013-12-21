#define RL_MAX_SIZE 7
#define RL_LIGHT_LAYER 10

turf
	var/tmp/colour_red = 0
	var/tmp/colour_blue = 0
	var/tmp/colour_green = 0
	var/tmp/raw_colour_red = 255
	var/tmp/raw_colour_blue = 255
	var/tmp/raw_colour_green = 255

	UpdateLight()

	/*
		if (!RL_LightOverlay)
			RL_LightOverlay = new /obj/lightoverlay(src)
		var/turf
			e = get_step(src, EAST)
			se = get_step(src, SOUTHEAST)
			s = get_step(src, SOUTH)
		RL_LightOverlay.overlays.Cut()
		RL_LightOverlay.overlays.Add("g[s.RL_LightG][se.RL_LightG][RL_LightG][e.RL_LightG]", "b[s.RL_LightB][se.RL_LightB][RL_LightB][e.RL_LightB]")
		RL_LightOverlay.icon_state = "r[s.RL_LightR][se.RL_LightR][RL_LightR][e.RL_LightR]"
*/
atom
	proc
		RL_SetOpacity(newopacity) // TODO: queue opacity changes
			if (opacity == newopacity)
				return
			opacity = newopacity
			for (var/obj/light/L in view(src, RL_MAX_SIZE))
				L.Move(L.loc, L.dir) // hack: update

obj/light
	var
		ColorR = 1
		ColorG = 1
		ColorB = 1
		Size = 2
		list/affected = list()

	proc
		SetColor(r, g, b)
			for (var/turf/T in affected)
				var/falloff = affected[T]
				T.RL_LightRawR -= falloff*ColorR
				T.RL_LightRawG -= falloff*ColorG
				T.RL_LightRawB -= falloff*ColorB
			ColorR = r
			ColorG = g
			ColorB = b
			for (var/turf/T in affected)
				var/falloff = affected[T]
				T.RL_LightRawR += falloff*ColorR
				T.RL_LightRawG += falloff*ColorG
				T.RL_LightRawB += falloff*ColorB
				T.RL_LightR = round(min(T.RL_LightRawR*6, 6), 1)
				T.RL_LightG = round(min(T.RL_LightRawG*6, 6), 1)
				T.RL_LightB = round(min(T.RL_LightRawB*6, 6), 1)

			for (var/turf/T in view(src, Size+1))
				T.RL_UpdateLight()

		SetSize(size)
			if (size > RL_MAX_SIZE)
				CRASH("Light is too big")
			Size = size
			if (loc)
				SetPos(loc, dir)

		SetPos(l, di)
			loc = l
			dir = di

			for (var/turf/T in affected)
				var/falloff = affected[T]
				T.RL_LightRawR -= falloff*ColorR
				T.RL_LightRawG -= falloff*ColorG
				T.RL_LightRawB -= falloff*ColorB
				T.RL_ShouldUpdate = 1

			var/list/oldaffected = affected
			affected = list()
			var/list/v = view(src, Size+1)
			for (var/turf/T in v)
				if (!T.RL_ApplyLight)
					continue
				T.RL_ShouldUpdate = 1
				var/xo = T.x-src.x - 0.5
				var/yo = T.y-src.y + 0.5

				if (T.opacity)
					var/turf
						w = get_step(T, WEST)
						nw = get_step(T, NORTHWEST)
						n = get_step(T, NORTH)
					if ((!(w in v) || w.opacity) && (!(nw in v) || nw.opacity) && (!(n in v) || n.opacity))
						continue

				if (di & (SOUTH|NORTH))
					if (abs(xo) > abs(yo))
						continue
					else if (((di & SOUTH) ? -yo : yo) <= 0)
						continue
				else if (di & (EAST|WEST))
					if (abs(xo) < abs(yo))
						continue
					else if (((di & WEST) ? -xo : xo) <= 0)
						continue

				var/falloff = max(Size-sqrt(xo**2 + yo**2), 0)/12
				T.RL_LightRawR += falloff*ColorR
				T.RL_LightRawG += falloff*ColorG
				T.RL_LightRawB += falloff*ColorB
				affected[T] = falloff

			for (var/turf/T in v)
				if (T.RL_ShouldUpdate)
					T.RL_LightR = round(min(T.RL_LightRawR*6, 6), 1)
					T.RL_LightG = round(min(T.RL_LightRawG*6, 6), 1)
					T.RL_LightB = round(min(T.RL_LightRawB*6, 6), 1)
					T.RL_ShouldUpdate = 0
			for (var/turf/T in oldaffected)
				if (T.RL_ShouldUpdate)
					T.RL_LightR = round(min(T.RL_LightRawR*6, 6), 1)
					T.RL_LightG = round(min(T.RL_LightRawG*6, 6), 1)
					T.RL_LightB = round(min(T.RL_LightRawB*6, 6), 1)
			for (var/turf/T in v)
				if (T.RL_ApplyLight)
					T.RL_UpdateLight()
			for (var/turf/T in oldaffected)
				if (T.RL_ShouldUpdate)
					T.RL_UpdateLight()
					T.RL_ShouldUpdate = 0