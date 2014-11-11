demand = function ()
	serial:settimeout(nil)
	local msg, err, par = serial:receive()
	serial:settimeout(0)
	return msg, err, par
end
local reverse = function (t,l)
	local b
	for k,v in pairs(t) do
		if v == l then
			b = k
			break
		end
	end
	return b
end
-- http://wiki.interfaceware.com/534.html
local function string_split(s, d)
	local t = {}
	local i = 0
	local f
	local match = '(.-)' .. d .. '()'
	if string.find(s, d) == nil then
		return {s}
	end
	for sub, j in string.gmatch(s, match) do
		i = i + 1
		t[i] = sub
		f = j
	end
	if i ~= 0 then
		t[i+1] = string.sub(s, f)
	end
	return t
end

local baudrate = {
	["300"] = "00";
	["600"] = "01";
	["1200"] = "02";
	["2400"] = "03";
	["4800"] = "04";
	["9600"] = "05";
	["14400"] = "06";
	["19200"] = "07";
	["38400"] = "08";
	["57600"] = "09";
	["115200"] = "10"
}
local databits = {
	["7"] = "0";
	["8"] = "1";
}
local stopbits = {
	["1"] = "0";
	["1.5"] = "1";
	["2"] = "2";
}
local parity = {
	["none"] = "0";
	["even"] = "1";
	["mark"] = "2";
	["odd"] = "3";
	["space"] = "4";
}
local handshake = {
	["none"] = "0";
	["soft"] = "1";
	["hard"] = "2";
	["hardsoft"] = "3";
}

local functions = {}

functions.err = function (msg, err, par)
	if not msg then
		if err == "timeout" then
			TX:push "[E] ERROR: La comunicacion con el servicio tardo mucho tiempo"
		elseif err == "closed" then
			TX:push "[E] ERROR: Se cerro el servicio serie"
			connected = false
		else
			TX:push ("[E] ERROR: "..err)
		end
	else
		return msg
	end
end

functions.transmit = {
	getports = function () 
		if connected then
			serial:send("11\r\n")
			love.timer.sleep(0.3)
		else
			TX:push "[E] ERROR: No conectado al servicio"
		end
	end,
	connect = function (arg)
		if connected then
			if arg[2] then
				print(arg[2])
				serial:send("01"..arg[2].."\r\n")
				love.timer.sleep(0.3)
			end
			serial:send("07\r\n")
			love.timer.sleep(0.3)
			serial:send("17\r\n")
			love.timer.sleep(0.3)
		else
			TX:push "[E] ERROR: No conectado al servicio"
		end
	end,
	config = function (arg)
		if connected then
			if type(arg) == "table" then
				if arg.baud and baudrate(arg.baud) then
					serial:send("02"..baudrate(arg.baud).."\r\n")
					love.timer.sleep(0.3)
				end
				if arg.data and databits(arg.data) then
					serial:send("03"..databits(arg.data).."\r\n")
					love.timer.sleep(0.3)
				end
				if arg.stop and stopbits(arg.stop) then
					serial:send("04"..stopbits(arg.stop).."\r\n")
					love.timer.sleep(0.3)
				end
				if arg.parity and parity(arg.parity) then
					serial:send("05"..parity(arg.parity).."\r\n")
					love.timer.sleep(0.3)
				end
				if arg.handshake and handshake(arg.handshake) then
					serial:send("06"..handshake(arg.handshake).."\r\n")
					love.timer.sleep(0.3)
				end
			elseif type(arg[2]) == "string" and arg == "default" then
				serial:send("09".."\r\n")
				love.timer.sleep(0.3)
			else
				TX:push "[E] ERROR: El argumento pasado como configuracion es erroneo"
			end
			serial:send("19".."\r\n")
			love.timer.sleep(0.3)
		else
			TX:push "[E] ERROR: No conectado al servicio"
		end
	end,
	send = function (arg)
		if connected then
			serial:send("10"..arg[2].."\r\n")
			love.timer.sleep(0.3)
		else
			TX:push "[E] ERROR: No conectado al servicio"
		end
	end,
	close = function ()
		if connected then
			serial:send("08".."\r\n")
			love.timer.sleep(0.3)
		else
			TX:push "[E] ERROR: No conectado al servicio"
		end
	end,
}

functions.receive = {
	["01"] = function (msg)
		TX:push ("Port = "..msg)
	end;
	["07"] = function (msg)
		TX:push "CONNECTED"
	end;
	["08"] = function (msg)
		TX:push "DISCONNECTED"
	end;
	["10"] = function (msg)
		TX:push ("[TX] "..msg)
	end;
	["31"] = function (msg)
		TX:push("[E] "..msg)
	end;
	["11"] = function (msg)
		if msg and msg ~= "" then
			local t = string_split(msg,",")
			TX:push{"ports",unpack(t)}
			--for k,v in ipairs(t) do
				--TX:push("  - "..v)
			--end
		end
	end;	
	["12"] = function (msg)
		TX:push("Baudrate = "..reverse(baudrate,msg))
	end;
	["13"] = function (msg)
		TX:push("Data bits = "..reverse(databits,msg))
	end;
	["14"] = function (msg)
		TX:push("Stop bits = "..reverse(stopbits,msg))
	end;
	["15"] = function (msg)
		TX:push("Parity = "..reverse(parity,msg))
	end;
	["16"] = function (msg)
		TX:push("Handshake = "..reverse(handshake,msg))
	end;
	["17"] = function (msg)
		TX:push("State = "..(msg == "0" and "closed" or "open"))
	end;
	["18"] = function (msg)
		TX:push("There are "..msg.." bytes in the reading buffer")
	end;
	["19"] = function (msg,f)
		TX:push("Current configuration:")
		TX:push("Port = "..msg:sub(12))
		f["12"](msg:sub(1,2))
		f["13"](msg:sub(4,1))
		f["14"](msg:sub(6,1))
		f["15"](msg:sub(8,1))
		f["16"](msg:sub(10,1))
	end;
	["20"] = function (msg)
		if msg and msg ~= "" then
			TX:push("[RX] "..msg)
		end
	end
}

return functions