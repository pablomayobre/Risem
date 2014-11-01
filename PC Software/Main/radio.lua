--Radio--
channel = ... --Establece una conexion con el programa principal
socket = require("socket") --Inclute la libreria para comunicaciones TCP/IP
radio = assert(socket.bind("localhost", 4532)) --Genera un servidor en la direccion "localhost" y el puerto 4532

radio:settimeout(0) --Setea el tiempo maximo de espera a 0 para no trabar el programa

tabl = { --En esta tabla se encuentran las funciones para cada comando que envia el Gpredict
	F = function (line,tran) --Comando F
		frequency = tonumber(line) --Setea la frecuencia al valor enviado por el Gpredict
		return "RPRT 0\n"
	end,
	f = function (line,tran) --Comando f
		return frequency.."\n" --Envia la frecuencia actual al Gpredict
	end,	
	q = function (line,tran) --Comando q
		return "RPRT 0\n" --Este comando es llamado por Gpredict para cerrar la conexion. Sin embargo no se encontraba documentado
					--Por ende enviamos el valor de aceptacion como si no hubiese ningun error.
	end,
}
--Pre seteado de variables a 0
oldfrquency = 0
frquency = 0
open = true

--Bucle infinito que contiene el programa
while open do
	--Aceptamos cualquier transmision nueva o conservamos la anterior
	transmitter = radio:accept() or transmitter
	--Si hay alguna conexion
	if transmitter then
		--Revisamos si el Gpredict realizo algun envio de informacion
		local line, err = transmitter:receive()
		--Si no hubo ningun error (Como por ejemplo que se haya acabado el tiempo)
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
	if oldfrequency ~= frequency then
		oldfrequency = frequency
		channel:push(frequency)
	end
end