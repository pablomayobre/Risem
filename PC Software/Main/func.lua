local concatenator = " "

local func = {
	--This is a list of variables for better coding
	none = "none",
	even = "even",
	odd = "odd",
	mark = "mark",
	space = "space",
	soft = "soft",
	hard = "hard",
	hardsoft = "hardsoft";

	getports = function ()
		channels.tx:push{"getports"}
	end,
	
	reload = function ()
		channels.tx:push{"reload"}
	end,
	
	connect = function (env, args)
		channels.tx:push{"connect",args}
	end,
	
	config = function (env, args)
		if args == "default" then
			channels.tx:push{"config","default"}
		elseif args == "help" then
			return [[Config command options:
				baud (baudrate)  = 300, 600, 1200, 2400, 4800, 9600...
				data (data bits) = 7, 8
				stop (stop bits) = 1, 1.5, 2
				parity           = none, even, odd, mark, space
				handshake        = none, soft, hard, hardsoft]]
		else
			if type(args) == "table" then args = table.concat(args, " ; ") end
			args = "return { "..args.." }"
			local f = loadstring(args)
			setfenv(f,env)
			local result = f()
			result[1] = config
			channels.tx:push(result)
		end
	end,
	
	send = function (concat, args)
		if type(args) == "table" then 
			args = table.concat(args, concat()) --Concat is a function that returns the concatenator string
		end
		channels.tx:push{"send",args}
	end,
	
	close = function ()
		channels.tx:push{"close"}
	end,
	
	concat = function (args)
		if args == nil then
			return concatenator
		else
			concatenator = args
		end
	end,
	
	reload = function (args)
		channels.tx:push{"reload"}
	end
}

return func