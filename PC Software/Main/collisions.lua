local chu = function (st)
	if st == "gpredict" then
		return "manual"
	elseif st == "manual" then
		return "gpredict"
	end
end
local collisions = {
	ROTOR = function (x,y,states)
		if x > 70 and y > 41 and x < 134 and y < 62 then
			states.ROTORSTATE = chu(states.ROTORSTATE)
		end
	end,
	RADIO = function (x,y,states)
		if x > 209 and y > 41 and x < 273 and y < 62 then
			states.RADIOSTATE = chu(states.RADIOSTATE)
		end
	end,
	ARROWSAZ = function (x,y,states)
		if states.ROTORSTATE == "manual" then
			if y > 88 and y < 100 then
				local total = tonumber(table.concat(states.AZ))/10
				if total < 360 then
					if x > 32 and x < 55 then
						if total + 100 <= 360 then
							states.AZ[1] = states.AZ[1] + 1
						end
					elseif x > 69 and x < 92 then
						if total + 10 <= 360 then
							states.AZ[2] = states.AZ[2] + 1
						end					
					elseif x > 106 and x < 129 then
						if total + 1 <= 360 then
							states.AZ[3] = states.AZ[3] + 1
						end	
					elseif x > 157 and x < 180 then
						if total + .1 <= 360 then
							states.AZ[4] = states.AZ[4] + 1
						end	
					end
					if states.AZ[4] > 9 then
						states.AZ[4] = 0
						states.AZ[3] = states.AZ[3] + 1
					end
					if states.AZ[3] > 9 then
						states.AZ[3] = 0
						states.AZ[2] = states.AZ[2] + 1
					end
					if states.AZ[2] > 9 then
						states.AZ[2] = 0
						states.AZ[1] = states.AZ[1] + 1
					end
				end
			elseif y > 156 and y < 168 then
				local total = tonumber(table.concat(states.AZ))/10
				if total > 0 then
					if x > 32 and x < 55 then
						if total - 100 >= 0 then
							states.AZ[1] = states.AZ[1] - 1
						end
					elseif x > 69 and x < 92 then
						if total - 10 >= 0 then
							states.AZ[2] = states.AZ[2] - 1
						end					
					elseif x > 106 and x < 129 then
						if total - 1 >= 0 then
							states.AZ[3] = states.AZ[3] - 1
						end	
					elseif x > 157 and x < 180 then
						if total - .1 >= 0 then
							states.AZ[4] = states.AZ[4] - 1
						end	
					end
					if states.AZ[4] < 0 then
						states.AZ[4] = 9
						states.AZ[3] = states.AZ[3] - 1
					end
					if states.AZ[3] < 0 then
						states.AZ[3] = 9
						states.AZ[2] = states.AZ[2] - 1
					end
					if states.AZ[2] < 0 then
						states.AZ[2] = 9
						states.AZ[1] = states.AZ[1] - 1
					end
				end
			end
		end
	end,
	ARROWSEL = function (x,y,states)
		if states.ROTORSTATE == "manual" then
			if y > 88 and y < 100 then
				local total = tonumber(table.concat(states.EL))/10
				if total < 90 then
					if x > 263 and x < 286 then
						if total + 10 <= 90 then
							states.EL[1] = states.EL[1] + 1
						end
					elseif x > 300 and x < 323 then
						if total + 1 <= 90 then
							states.EL[2] = states.EL[2] + 1
						end					
					elseif x > 351 and x < 374 then
						if total + .1 <= 90 then
							states.EL[3] = states.EL[3] + 1
						end	
					end
					if states.EL[3] > 9 then
						states.EL[3] = 0
						states.EL[2] = states.EL[2] + 1
					end
					if states.EL[2] > 9 then
						states.EL[2] = 0
						states.EL[1] = states.EL[1] + 1
					end
				end
			elseif y > 156 and y < 168 then
				local total = tonumber(table.concat(states.EL))/10
				if total > 0 then
					if x > 263 and x < 286 then
						if total - 10 >= 0 then
							states.EL[1] = states.EL[1] - 1
						end
					elseif x > 300 and x < 323 then
						if total - 1 >= 0 then
							states.EL[2] = states.EL[2] - 1
						end					
					elseif x > 351 and x < 374 then
						if total - .1 >= 0 then
							states.EL[3] = states.EL[3] - 1
						end	
					end
					if states.EL[3] < 0 then
						states.EL[3] = 9
						states.EL[2] = states.EL[2] - 1
					end
					if states.EL[2] < 0 then
						states.EL[2] = 9
						states.EL[1] = states.EL[1] - 1
					end
				end
			end
		end
	end,
	ARROWSFRUP = function (x,y,states)
		if states.RADIOSTATE == "manual" then
			if y > 205 and y < 217 then
				local total = tonumber(table.concat(states.FR))
				if total < 999999999 then
					if x > 32 and x < 55 then
						if total + 100000000 <= 999999999 then
							states.FR[1] = states.FR[1] + 1
						end	
					elseif x > 69 and x < 92 then
						if total + 10000000 <= 999999999 then
							states.FR[2] = states.FR[2] + 1
						end	
					elseif x > 106 and x < 129 then
						if total + 1000000 <= 999999999 then
							states.FR[3] = states.FR[3] + 1
						end	
					elseif x > 143 and x < 166 then
						if total + 100000 <= 999999999 then
							states.FR[4] = states.FR[4] + 1
						end	
					elseif x > 180 and x < 203 then
						if total + 10000 <= 999999999 then
							states.FR[5] = states.FR[5] + 1
						end	
					elseif x > 217 and x < 240 then
						if total + 1000 <= 999999999 then
							states.FR[6] = states.FR[6] + 1
						end	
					elseif x > 254 and x < 277 then
						if total + 100 <= 999999999 then
							states.FR[7] = states.FR[7] + 1
						end	
					elseif x > 291 and x < 314 then
						if total + 10 <= 999999999 then
							states.FR[8] = states.FR[8] + 1
						end	
					elseif x > 328 and x < 351 then
						if total + 1 <= 999999999 then
							states.FR[9] = states.FR[9] + 1
						end	
					end
					
					if states.FR[9] > 9 then
						states.FR[9] = 0
						states.FR[8] = states.FR[8] + 1
					end
					if states.FR[8] > 9 then
						states.FR[8] = 0
						states.FR[7] = states.FR[7] + 1
					end
					if states.FR[7] > 9 then
						states.FR[7] = 0
						states.FR[6] = states.FR[6] + 1
					end
					if states.FR[6] > 9 then
						states.FR[6] = 0
						states.FR[5] = states.FR[5] + 1
					end
					if states.FR[6] > 9 then
						states.FR[6] = 0
						states.FR[5] = states.FR[5] + 1
					end
					if states.FR[5] > 9 then
						states.FR[5] = 0
						states.FR[4] = states.FR[4] + 1
					end
					if states.FR[4] > 9 then
						states.FR[4] = 0
						states.FR[3] = states.FR[3] + 1
					end
					if states.FR[3] > 9 then
						states.FR[3] = 0
						states.FR[2] = states.FR[2] + 1
					end
					if states.FR[2] > 9 then
						states.FR[2] = 0
						states.FR[1] = states.FR[1] + 1
					end
					
				end
			end
		end
	end,
	ARROWSFRDOWN = function (x,y,states)
		if states.RADIOSTATE == "manual" then
			if y > 273 and y < 285 then
				local total = tonumber(table.concat(states.FR))
				if total > 0 then
					if x > 32 and x < 55 then
						if total - 100000000 >= 0 then
							states.FR[1] = states.FR[1] - 1
						end
					elseif x > 69 and x < 92 then
						if total - 10000000 >= 0 then
							states.FR[2] = states.FR[2] - 1
						end
					elseif x > 106 and x < 129 then
						if total - 1000000 >= 0 then
							states.FR[3] = states.FR[3] - 1
						end
					elseif x > 143 and x < 166 then
						if total - 100000 >= 0 then
							states.FR[4] = states.FR[4] - 1
						end
					elseif x > 180 and x < 203 then
						if total - 10000 >= 0 then
							states.FR[5] = states.FR[5] - 1
						end
					elseif x > 217 and x < 240 then
						if total - 1000 >= 0 then
							states.FR[6] = states.FR[6] - 1
						end
					elseif x > 254 and x < 277 then
						if total - 100 >= 0 then
							states.FR[7] = states.FR[7] - 1
						end	
					elseif x > 291 and x < 314 then
						if total - 10 >= 0 then
							states.FR[8] = states.FR[8] - 1
						end	
					elseif x > 328 and x < 351 then
						if total - 1 >= 0 then
							states.FR[9] = states.FR[9] - 1
						end	
					end
					
					if states.FR[9] < 0 then
						states.FR[9] = 9
						states.FR[8] = states.FR[8] - 1
					end
					if states.FR[8] < 0 then
						states.FR[8] = 9
						states.FR[7] = states.FR[7] - 1
					end
					if states.FR[7] < 0 then
						states.FR[7] = 9
						states.FR[6] = states.FR[6] - 1
					end
					if states.FR[6] < 0 then
						states.FR[6] = 9
						states.FR[5] = states.FR[5] - 1
					end
					if states.FR[6] < 0 then
						states.FR[6] = 9
						states.FR[5] = states.FR[5] - 1
					end
					if states.FR[5] < 0 then
						states.FR[5] = 9
						states.FR[4] = states.FR[4] - 1
					end
					if states.FR[4] < 0 then
						states.FR[4] = 9
						states.FR[3] = states.FR[3] - 1
					end
					if states.FR[3] < 0 then
						states.FR[3] = 9
						states.FR[2] = states.FR[2] - 1
					end
					if states.FR[2] < 0 then
						states.FR[2] = 9
						states.FR[1] = states.FR[1] - 1
					end
				end
			end
		end
	end,
	LOGO = function (x,y,states)
		local siz = 413*0.25
		if x > 446 and x < 446 + siz and y > 190 and y < 190 + siz then
			states.LOGO = states.LOGO + 1
		else
			states.LOGO = 0
		end
	end
}

return collisions