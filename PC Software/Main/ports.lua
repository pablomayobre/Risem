local roundrect = require "roundrect"
local anim = require "anim"

local text = "Puertos"
local hover = {
	c = false,
}
local pushed = 0
local col = 0
local ahsd = true
local optheight = 30
local acceptpressed = false

Option = {}

local up = love.graphics.newMesh{
	{0,5,0,0,255,255,255},
	{8,5,0,0,255,255,255},
	{4,0,0,0,255,255,255}
}
local down = love.graphics.newMesh{
	{0,0,0,0,255,255,255},
	{8,0,0,0,255,255,255},
	{4,5,0,0,255,255,255}
}
btn = {
	x = 0;
	y = 0;
	w = 100;
	h = 35;
}

local padx = 15
local pady = 8
local pu = 0
local h = btn.h

local ports = {
	update = function (dt)
		anim.update(dt)
		s,p = 0,0
		x,y = love.mouse.getPosition()
		if hover.c then
			if hover.j then
				local sumar = h - hover.h
				hover.h = h
				hover.y = hover.y + sumar
				hover.ty = hover.ty + sumar
			end
			if x > hover.tx or x < hover.x or y < hover.y or y > hover.ty then
				hover.c = false
				if sh then
					sh = false
					pushed = 0
					col = 0
				end
				hover.j = false
			end
		end
		if ahsd then 
			h = math.floor(h + (btn.h-h)*dt*4)
		else 
			h = math.ceil(h + (5 + btn.h + #Option * 30 - h)*dt*8)
		end
	end,
	draw = function ()
		love.graphics.setColor(255,255,255,col)
		roundrect("fill",btn.x,btn.y + pu,btn.w,h,6,6,15)
		love.graphics.setColor(255,255,255,255)
		roundrect("line",btn.x,btn.y + pu,btn.w,h,6,6,15)
		love.graphics.printf(text,btn.x + padx,btn.y + pady + pu,btn.w,"left")
		love.graphics.print("Puerto:",btn.x - arial:getWidth("Puerto:    "),btn.y + pady)
		love.graphics.setColor(200,200,200)
		if not (h <= 35) then
			love.graphics.line(btn.x,btn.y + btn.h,btn.x + btn.w,btn.y + btn.h)
			love.graphics.draw(up,btn.x + btn.w - padx,btn.y + pady + 7)
			if hover.j then
				love.graphics.setColor(255,255,255,128)
				if hover.op == 7 then
					roundrect("fill",hover.x,hover.y,hover.tx - hover.x,hover.ty - hover.y,6,6,3)
				elseif hover.op == 1 then
					love.graphics.rectangle("fill",hover.x,hover.y - 5,hover.tx - hover.x,hover.ty - hover.y + 5)
				else
					love.graphics.rectangle("fill",hover.x,hover.y,hover.tx-hover.x,hover.ty-hover.y)
				end
			end
			love.graphics.setScissor(btn.x,btn.y + btn.h,btn.w,h - btn.h)
			options(h-btn.h)
			love.graphics.setScissor()
		else
			love.graphics.draw(down,btn.x + btn.w - padx,btn.y + pady + 7)
		end
		if acceptpressed then
			love.graphics.setColor(255,255,255,128)
		else
			love.graphics.setColor(255,255,255,0)
		end
		roundrect("fill",btn.x + btn.w + 10,btn.y,btn.w,btn.h,6,6)
		if text == "Puertos" then
			love.graphics.setColor(255,255,255,128)
		else
			love.graphics.setColor(255,255,255,255)
		end
		roundrect("line",btn.x + btn.w + 10,btn.y,btn.w,btn.h,6,6)
		love.graphics.printf("Aceptar",btn.x + btn.w + 10,btn.y + pady,btn.w,"center")
		if #Option < 1 then
			anim.draw(btn.x + btn.w*2 + 20,btn.y)
		end
		if StartupError then
			love.graphics.setColor(255,0,0,255)
			love.graphics.printf(StartupError,0,btn.y + btn.h + 10,love.window.getWidth(),"center")
		end
	end,
	mousepressed = function (b,x,y)
		if b == "l" then
			if x > btn.x + btn.w + 10 and x < btn.x + btn.w*2 + 10 then
			if y > btn.y and y < btn.y + btn.h and text ~= "Puertos" then
				func.connect(nil,text)
			end
			end
			if x > btn.x and x < btn.w + btn.x then 
				if y > btn.y and y < btn.y + btn.h and #Option >= 1 then
					hover = {
						c = true,
						x = btn.x,
						y = btn.y,
						ty = btn.y + btn.h,
						tx = btn.x + btn.w,
					}
					sh = true
					pushed = 2
					col = 128
				else
					for i = 1, #Option do
						y1 = btn.y + h - optheight * i
						y2 = btn.y + h - optheight * (i - 1)
						if y > y1 and y < y2 then
							hover = {
								c = true,
								x = btn.x,
								y = y1,
								ty = y2,
								tx = btn.x + btn.w,
								h = h,
								j = true,
								op = #Option - (i-1)
							}
						end
					end
				end
			end
		end
	end,
	mousereleased = function (b,x,y)
		if b == "l" then
			if hover.c then
				if x < hover.tx and x > hover.x and y > hover.y and y < hover.ty then
					hover.c = false
					if sh then
						sh = false
						pushed = 0
						col = 0
						ahsd = not ahsd
					end
					if hover.j then
						text = Option[hover.op]
						ahsd = not ahsd
					end
					hover.j = false
				end
			end
		end
	end
}

options = function (si)
	love.graphics.push()
	love.graphics.translate(btn.x,btn.y + btn.h -(#Option * 30 + 5-si))
		love.graphics.setColor(255,255,255,255)
		for i = 1 , #Option do
			love.graphics.printf(Option[i],padx,pady + 30 * (i-1),btn.w,"left")
		end
		love.graphics.setColor(200,200,200)
	love.graphics.pop()
end

return ports