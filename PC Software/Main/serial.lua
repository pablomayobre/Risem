local quit = ...

require "love.timer"
require "love.system"
require "love.filesystem"

local socket = require "socket"
local functions = require "functions"

serial = socket.tcp()

serial:settimeout(10)

TX = love.thread.getChannel("receive")
RX = love.thread.getChannel("transmit")

local OPEN = true

connected = false
giveup = false

local start = love.timer.getTime()
local firsttime = true

local tryconnect = true

while OPEN do

	if not connected and not giveup then
		local n = serial:connect("127.0.0.1",2009)
		if n then
			connected = true
			functions.transmit.getports()
		elseif tryconnect then
			path = string.gsub(love.filesystem.getWorkingDirectory(),"/", "\\")
			os.execute('cd "'..path..'" & start risemUSB.exe')
			love.timer.sleep(8) --More waiting time means less chance of more flashy windows
		else
			TX:push "[E] ERROR: Incapaz de conectarse al Servicio Serie"
			giveup = true	
		end
	end

	while RX:getCount() > 0 do
		msg = RX:pop()
		if msg then
			if msg[1] == "reload" then
				giveup = false
				break
			elseif not connected then
				TX:push "[E] ERROR: No conectado al Servicio Serie"
			else
				functions.transmit[msg[1]](msg)
			end
		end
	end

	local ready = false
	while connected and not ready do
		serial:send "20"
		ready = true
		local msg, err, par = serial:receive()
		msg = functions.err(msg,err,par)
		if msg then
			msg = msg:gsub("^%s+", "")
			msg = msg:gsub("%s+$", "")
			if msg ~= "" then
				if functions.receive[msg:sub(1,2)] then
					functions.receive[msg:sub(1,2)](msg:sub(3),functions.receive)
				end
			end
		end
	end
	
	if quit:pop() == "EXIT" then
		if connected then
			love.timer.sleep(0.8)
			serial:settimeout(3)
			serial:send "30"
			love.timer.sleep(0.8)
		end
		OPEN = false
	end
end

TX:push "Thread closed"