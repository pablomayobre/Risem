io.stdout:setvbuf("no")

local principal = require "principal"
local ports = require "ports"
require "conversion"
local scale = 1.4

tocart = function (elevation,angle)
	local radius = 1 - (elevation / 90)
	angle = math.rad(angle)
	return radius * math.cos(angle), radius * math.sin(angle)
end

startup = true

local states = {
	EL = {0,0,0};
	AZ = {0,0,0,0};
	FR = {0,0,0,0,0,0,0,0,0};
	RADIOSTATE = "manual";
	ROTORSTATE = "manual";
	LOGO = 0;
}

func = require "func"

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
	
	thread = love.thread.newThread("serial.lua")
	transmit = love.thread.getChannel("transmit")
	receive = love.thread.getChannel("receive")

	quit = love.thread.newChannel()
	thread:start(quit)

	channels = {tx = transmit,rx = receive}
	
	btn.x = (love.graphics.getWidth() - btn.w)/2
	btn.y = (love.graphics.getHeight() - 100 - btn.h)/2
end
local conv = function (val)
	return string.format("%03d.%01d",math.floor(val),val % 1 * 10)
end
local time = 0
love.update = function (dt)
	while receive:getCount() > 0 do
		local msg = receive:pop()
		if msg then
			if type(msg) == "table" then
				if msg[1] == "ports" then
					Option = {}
					for k,v in ipairs(msg) do
						if k ~= 1 then
							Option[#Option + 1] = v
						end
					end
				end
			else
				if msg:match("%[RX%](.*)") then
					--Received something from the PIC YEAH!
					print(msg:match("%[RX%](.*)"))
				elseif msg:match("%[E%](.*)") then
					StartupError = msg:match("%[E%](.*)")
					--Oh no! Errors!
					print(msg:match("%[E%](.*)"))
				else
					if msg == "State = open" then
						startup = false
					elseif msg == "DISCONNECTED" then
						startup = true
					end
					print(msg)
					--A Serial message (Maybe a TX or innecessary data... at least to the user)
				end
			end
		end
	end
	if startup then
		ports.update(dt)
	else
		time = time + dt
		if time > 3 and somethingchanged then
			func.send("","AZ:"..tostring(tonumber(table.concat(states.AZ))/10))
			func.send("","EL:"..tostring(tonumber(table.concat(states.EL))/10))
			local val = tohex(tonumber("0x"..table.concat(states.FR),16))
			func.send("","FQ:"..val)
			print(string.format("%x",todec(val)))
			somethingchanged = false
			time = 0
		end
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
end

love.draw = function ()
	principal.draw(scale,states)
	if startup then
		love.graphics.setColor(0,0,0,200)
		love.graphics.rectangle("fill",0,0,love.window.getWidth(), love.window.getHeight())
		ports.draw()
	end
end

love.mousepressed = function (x,y,b)
	if startup then
		ports.mousepressed(b,x,y)
	else
		principal.mousepressed(x,y,b,scale,states)
	end
end

love.mousereleased = function (x,y,b)
	if startup then
		ports.mousereleased(b,x,y)
	end
end

function love.threaderror(thread, errorstr)
	--Imprime los errores de los programas Radio y Rotor si algo falla
	print("Thread error!\n"..errorstr)
end

function love.quit ()
	func.close()
	quit:push("EXIT")
	thread:wait()
end