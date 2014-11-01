io.stdout:setvbuf("no")

local principal = require "principal"
local scale = 1.4

tocart = function (elevation,angle)
	local radius = 1 - (elevation / 90)
	angle = math.rad(angle)
	return radius * math.cos(angle), radius * math.sin(angle)
end

local states = {
	EL = {0,0,0};
	AZ = {0,0,0,0};
	FR = {0,0,0,0,0,0,0,0,0};
	RADIOSTATE = "manual";
	ROTORSTATE = "manual";
	LOGO = 0;
}

love.load = function ()
	ra = love.thread.newThread("radio.lua")
	radio = love.thread.newChannel()
	ra:start(radio)

	--Inicia el programa de rotor y genera una conexion para comunicarse con el mismo
	ro = love.thread.newThread("rotor.lua")
	rotor = love.thread.newChannel()
	ro:start(rotor)

	love.window.setMode(580 * scale,315 * scale)
	love.window.setTitle("Risem")
	love.window.setIcon(love.image.newImageData("assets/logo.png"))
	
	logo = love.graphics.newImage("assets/logo.png")
	risem = love.graphics.newImage("assets/risem.png")
	arial = love.graphics.newFont("assets/arialbd.ttf",12 * scale)
	little = love.graphics.newFont("assets/arial.ttf",11 * scale)
end
local conv = function (val)
	return string.format("%03d.%01d",math.floor(val),val % 1 * 10)
end
love.update = function (dt)
	if states.LOGO >= 10 then 
		print "THIS IS A SECRET MESSAGE"
		states.LOGO = 0 
	end
	if states.RADIOSTATE == "gpredict" then
		local frequency, radi
		while radio:getCount() > 0 do
			radi = radio:pop()
		end
		if radi then 
			frequency = tonumber(radi)
			frz = string.format("%09d",frequency)
			for i=1,#frz do
				states.FR[i] = tonumber(frz:sub(i,i))
			end
		end
	end
	if states.ROTORSTATE == "gpredict" then
		local azimuth, elevation, roto
		while rotor:getCount() > 0 do
			roto = rotor:pop()
		end
		if roto then 
			elevation = tonumber(roto:sub(1,roto:find(",") - 1)) or 0
			azimuth = tonumber(roto:sub(roto:find(",") + 1)) or 0
			local azz = conv(azimuth)
			local elz = conv(elevation)
			local j,k = 1,1
			for i=1, 5 do
				states.AZ[j] = tonumber(azz:sub(i,i))
				if i ~= 5 then states.EL[k] = tonumber(elz:sub(i,i)) end
				if i ~= 3 then k = k + 1 end
				if i ~= 4 then j = j + 1 end
			end
		end
	end
end

love.draw = function ()
	principal.draw(scale,states)
end

love.mousepressed = function (x,y,b)
	principal.mousepressed(x,y,b,scale,states)
end

function love.threaderror(thread, errorstr)
	--Imprime los errores de los programas Radio y Rotor si algo falla
	print("Thread error!\n"..errorstr)
end