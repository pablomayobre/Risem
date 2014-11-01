local lg = love.graphics
local round = require "roundrect"

local numbers = lg.newImage("assets/numbers.png")
local config = lg.newImage("assets/config.png")
local help = lg.newImage("assets/help.png")
local comma = lg.newImage("assets/comma.png")
local degrees = lg.newImage("assets/degrees.png")
local hertz = lg.newImage("assets/hertz.png")

local w,h = numbers:getDimensions()
local quad = {}

for i=0, 9 do
	quad[i] = lg.newQuad(20 + i*160, 20, 150, 200,w,h)
end

local controlButtons
do
	local line = {
		gpredict = {97,125,229,255},
		manual = {255,103,40,255}
	}
	local back = {
		gpredict = {116,75,232,255},
		manual = {255,145,72,255}
	}
	local msg = {
		gpredict = "GPredict",
		manual = "Manual"
	}
	controlButtons = function (x,y,state,scale)
		if not line[state] then return end
		lg.setColor(back[state])
		round("fill",x * scale,y * scale,64 * scale,21 * scale,3 * scale,3 * scale)
		lg.setColor(line[state])
		lg.setLineWidth(2 * scale)
		round("line",x * scale,y * scale,64 * scale,21 * scale,3 * scale,3 * scale)
		lg.setColor(255,255,255,255)
		lg.printf(msg[state],x * scale,(y+4) * scale,64 * scale,"center")
	end
end
local arrow = function (t,x,y,scale)
	x = x + 2 * scale
	if t == "up" then
		love.graphics.polygon("fill",x * scale,(y+12) * scale,(x+23) * scale,(y+12) * scale,(x+11.5) * scale,y * scale)
	elseif t == "down" then
		love.graphics.polygon("fill",x * scale,y * scale,(x+23) * scale,y * scale,(x+11.5) * scale,(y+12) * scale)
	end
end

local collisions = require "collisions"

local principal = {
	mousepressed = function (x,y,b,scale,states)
		x = x/scale
		y = y/scale
		if b == "l" then
			for k,v in pairs(collisions) do
				collisions[k](x,y,states)
			end
		end
	end,
	draw = function (scale,states)
		local azimuth = tonumber(table.concat(states.AZ))/10
		local elevation = tonumber(table.concat(states.EL))/10
		
		local rotorx, rotory = tocart(elevation,azimuth - 90)
		lg.setFont(arial)
		lg.setBackgroundColor(245,245,245)
		--HEADER--
			lg.setColor(50,50,50,255)
			lg.rectangle("fill",0,0,580 * scale,32 * scale)
			--RISEM
			lg.setColor(255,255,255,255)
			lg.draw(risem,10 * scale,5 * scale,0,.25 * scale)
			--ICONS
			lg.draw(config,505 * scale,6 * scale,0,.25 * scale)
			lg.draw(help,543 * scale,6 * scale,0,.25 * scale)
		--POLAR CHART--
			lg.setColor(255,255,255,255)
			lg.rectangle("fill",432 * scale,51 * scale,131 * scale,131 * scale)
			lg.setColor(220,220,220,255)
			lg.rectangle("line",432 * scale,51 * scale,131 * scale,131 * scale)
			
			lg.push()
			lg.translate(497 * scale,116 * scale)
				lg.setFont(little)
				
				lg.setColor(150,150,150,255)
				lg.line(-55 * scale,0,55 * scale,0)
				lg.line(0,-55 * scale,0,55 * scale)
				lg.circle("line",0,0,50 * scale)
				lg.circle("line",0,0,33 * scale)
				lg.circle("line",0,0,16 * scale)
				
				lg.setColor(255,0,0,255)
				love.graphics.printf("N",-20 * scale,-66 * scale,40 * scale,"center")
				love.graphics.printf("S",-20 * scale,54 * scale,40 * scale,"center")
				love.graphics.printf("O",-64 * scale,-7 * scale,9 * scale,"center")
				love.graphics.printf("E",55 * scale,-7 * scale,9 * scale,"center")
				
				love.graphics.circle("fill",rotorx * 50 * scale, rotory * 50 * scale, 3 * scale)
				
				lg.setFont(arial)
			lg.pop()
		--CONTROL BUTTONS--
			lg.setColor(0,0,0,255)
			lg.print("ROTOR:",20 * scale,44 * scale)
			lg.print("RADIO:",164 * scale,44 * scale)
			controlButtons(70,41,states.ROTORSTATE,scale)
			controlButtons(209,41,states.RADIOSTATE,scale)
		--AZIMUTH CONTROL--
			--BORDER
				lg.setColor(150,150,150,255)
				lg.setLineWidth(1 * scale)
				round("line",15 * scale,75 * scale,205 * scale,105 * scale,3 * scale,3 * scale)
				lg.setColor(245,245,245,255)
				lg.rectangle("fill",26 * scale,71 * scale,41 * scale,9 * scale)
				lg.setColor(150,150,150,255)
				lg.printf("Azimut",26 * scale,67 * scale,41 * scale,"center")
			--NUMBERS
				lg.setColor(255,255,255,255)
				lg.draw(numbers,quad[states.AZ[1]],28 * scale,103 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.AZ[2]],65 * scale,103 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.AZ[3]],102 * scale,103 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.AZ[4]],153 * scale,103 * scale,0,.25 * scale)
				
				lg.draw(comma,140 * scale,147 * scale,0,.25 * scale)
				lg.draw(degrees,190 * scale,103 * scale,0,.25 * scale)
			--ARROWS
				if states.ROTORSTATE == "gpredict" then
					lg.setColor(150,150,150,255)
				else
					lg.setColor(0,0,0,255)
				end
				arrow("up",32,88,scale)
				arrow("up",69,88,scale)
				arrow("up",106,88,scale)
				arrow("up",157,88,scale)
				
				arrow("down",32,156,scale)
				arrow("down",69,156,scale)
				arrow("down",106,156,scale)
				arrow("down",157,156,scale)
		--ELEVATION CONTROL--
			--BORDER
				lg.setColor(150,150,150,255)
				lg.setLineWidth(1 * scale)
				round("line",246 * scale,75 * scale,168 * scale,105 * scale,3 * scale,3 * scale)
				lg.setColor(245,245,245,255)
				lg.rectangle("fill",257 * scale,71 * scale,55 * scale,9 * scale)
				lg.setColor(150,150,150,255)
				lg.printf("Elevacion",257 * scale,67 * scale,55 * scale,"center")
			--NUMBERS
				lg.setColor(255,255,255,255)
				lg.draw(numbers,quad[states.EL[1]],259 * scale,103 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.EL[2]],296 * scale,103 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.EL[3]],347 * scale,103 * scale,0,.25 * scale)
				
				lg.draw(comma,334 * scale,147 * scale,0,.25 * scale)
				lg.draw(degrees,384 * scale,103 * scale,0,.25 * scale)
			--ARROWS
				if states.ROTORSTATE == "gpredict" then
					lg.setColor(150,150,150,255)
				else
					lg.setColor(0,0,0,255)
				end
				arrow("up",263,88,scale)
				arrow("up",300,88,scale)
				arrow("up",351,88,scale)
				
				arrow("down",263,156,scale)
				arrow("down",300,156,scale)
				arrow("down",351,156,scale)
		--FREQUENCY CONTROL--
			--BORDER
				lg.setColor(150,150,150,255)
				lg.setLineWidth(1 * scale)
				round("line",15 * scale,192 * scale,399 * scale,105 * scale,3 * scale,3 * scale)
				lg.setColor(245,245,245,255)
				lg.rectangle("fill",26 * scale,188 * scale,65 * scale,9 * scale)
				lg.setColor(150,150,150,255)
				lg.printf("Frecuencia",26 * scale,184 * scale,65 * scale,"center")
			--NUMBERS
				lg.setColor(255,255,255,255)
				lg.draw(numbers,quad[states.FR[1]],28 * scale,220 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.FR[2]],65 * scale,220 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.FR[3]],102 * scale,220 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.FR[4]],139 * scale,220 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.FR[5]],176 * scale,220 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.FR[6]],213 * scale,220 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.FR[7]],250 * scale,220 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.FR[8]],287 * scale,220 * scale,0,.25 * scale)
				lg.draw(numbers,quad[states.FR[9]],324 * scale,220 * scale,0,.25 * scale)
				
				lg.draw(hertz,360 * scale,243 * scale,0,.25 * scale)
			--ARROWS
				if states.RADIOSTATE == "gpredict" then
					lg.setColor(150,150,150,255)
				else
					lg.setColor(0,0,0,255)
				end
				arrow("up",32,205,scale)
				arrow("up",69,205,scale)
				arrow("up",106,205,scale)
				arrow("up",143,205,scale)
				arrow("up",180,205,scale)
				arrow("up",217,205,scale)
				arrow("up",254,205,scale)
				arrow("up",291,205,scale)
				arrow("up",328,205,scale)
				
				arrow("down",32,273,scale)
				arrow("down",69,273,scale)
				arrow("down",106,273,scale)
				arrow("down",143,273,scale)
				arrow("down",180,273,scale)
				arrow("down",217,273,scale)
				arrow("down",254,273,scale)
				arrow("down",291,273,scale)
				arrow("down",328,273,scale)
		--LOGO--
			lg.setColor(255,255,255,255)
			lg.draw(logo,446 * scale,190 * scale,0,.25 * scale)
	end
}

return principal