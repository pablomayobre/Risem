tohex = function (num)
	if not type(num) == "number" then error("Number expected got "..type(num)) end
	local out = ""
	local a = string.format("%X",num)
	for i=a:len(), 1, -1 do
		local s = a:sub(i,i)
		if s == "x" or s == "" then s = "0" end
		local val = string.format("%c",tonumber("0x0"..s)*2+33)
		out = val..out
	end
	if out:len()%2 == 1 then out = "!"..out end
	return out
end

todec = function (str)
	if not type(str) == "string" then error("String expected got "..type(str)) end
	local out = "0x"
	for i=1, str:len() do
		local a = string.format("%x",(string.byte(str:sub(i,i)) - 33)/2)
		out = out..a
	end
	return tonumber(out,16)
end