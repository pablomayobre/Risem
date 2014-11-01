--Rotor--
channel = ... --Establece una conexion con el programa principal
socket = require("socket") --Inclute la libreria para comunicaciones TCP/IP
rotor = assert(socket.bind("localhost", 4533)) --Genera un servidor en la direccion "localhost" y el puerto 4533

rotor:settimeout(0) --Setea el tiempo maximo de espera a 0 para no trabar el programa

arguments = function(text) --Esta funcion se encarga de tomar el dato recibido y descomponerlo en informacion util
	local delimiter = " "
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(text, delimiter, from)
	while delim_from do
		local st = string.sub(text, from , delim_from - 1)
		if st and not(st == "" or st == " ") then
			table.insert(result, st)
		end
		from = delim_to + 1
		delim_from, delim_to = string.find(text, delimiter, from )
	end
	table.insert(result, string.sub(text, from))
	return unpack(result)
end
tabl = { --En esta tabla se encuentran las funciones para cada comando que envia el Gpredict
	P = function (line,tran) --Comando P
		azimuth,elevation = arguments(line) --Setea el azimut y la elevacion a los valores recibidos
		return "RPRT 0\n" --Da un mensaje de aceptacion
	end,
	p = function (line,tran) --Comando p
		return azimuth.."\n"..elevation.."\n" --Les envia al Gpredict los valores actuales de Azimut y Elevacion
	end,	
	q = function (line,tran) --Comando q
		return "RPRT 0\n" --Este comando es llamado por Gpredict para cerrar la conexion. Sin embargo no se encontraba documentado
					--Por ende enviamos el valor de aceptacion como si no hubiese ningun error.
	end,		
}
--Pre seteado de variables a 0
azimuth,elevation = 0,0
oldazimuth, oldelevation = 0,0
open = true

--Bucle infinito que contiene el programa
while open do
	--Aceptamos cualquier transmision nueva o conservamos la anterior
	transmitter = rotor:accept() or transmitter
	--Si hay alguna conexion
	if transmitter then
		--Revisamos si el Gpredict realizo algun envio de informacion
		local line, err = transmitter:receive()
		if not err then
			--Procesamos el caracter
			local firstcharacter = line:sub(1,1)
			if firstcharacter then
				transmitter:send(tabl[firstcharacter](line:sub(2),transmitter))
			end
			--Si el Gpredict desea cerrarse, finalizamos la conexion
			if firstcharacter == "q" then
				transmitter:shutdown()
			end
		end
	end
	--Si los valores cambiaron, estos son enviado al programa principal
	if (oldazimuth ~= azimuth) or (oldelevation ~= elevation) then
		oldazimuth = azimuth
		oldelevation = elevation
		channel:push(elevation..","..azimuth)
	end
end
