local ttt = 0
local current = 0
local color = function (val)
	love.graphics.setColor(255,255,255,255*((7-val)/7)*0.7)
end
local circles = {
	function (s)
		love.graphics.circle("fill",18*s/2,8*s/2,2*s)
		love.graphics.circle("line",18*s/2,8*s/2,2*s)
	end,
	function (s)
		love.graphics.circle("fill",33*s/2,15*s/2,2*s)
		love.graphics.circle("line",33*s/2,15*s/2,2*s)
	end,
	function (s)
		love.graphics.circle("fill",36*s/2,31*s/2,2*s)
		love.graphics.circle("line",36*s/2,31*s/2,2*s)
	end,
	function (s) 
		love.graphics.circle("fill",26*s/2,43*s/2,2*s) 
		love.graphics.circle("line",26*s/2,43*s/2,2*s) 
	end,
	function (s) 
		love.graphics.circle("fill",10*s/2,43*s/2,2*s) 
		love.graphics.circle("line",10*s/2,43*s/2,2*s) 
	end,
	function (s) 
		love.graphics.circle("fill",0*s/2,31*s/2,2*s) 
		love.graphics.circle("line",0*s/2,31*s/2,2*s) 
	end,
	function (s) 
		love.graphics.circle("fill",4*s/2,15*s/2,2*s) 
		love.graphics.circle("line",4*s/2,15*s/2,2*s) 
	end,
}
local f = {
	update = function (dt)
		ttt = ttt + dt
		
		current = math.floor(ttt * 7)
	end,
	draw = function (x,y)
		love.graphics.push()
		love.graphics.translate(x,y)
		for i = 1, 7 do
			color((current + i) % 7)
			circles[i](1.4)
		end
		love.graphics.pop()
	end
}

return f