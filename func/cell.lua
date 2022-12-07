Cell = Object:extend()


function Cell:new(x, y, dx, dy, index, i_index, j_index, l_index)
	self.points = {}
	self.points[0] = Vector(x,y)
	self.points[1] = Vector(x-dx/2,y-dy/2)
	self.points[2] = Vector(x-dx,y)
	self.points[3] = Vector(x-dx/2,y+dy/2)

	self.index = index
	self.i = i_index
	self.j = j_index
	self.l = l_index
	self.neighbors = {}
	self.collision = false
	self.traversable = true
	self.stairs = false
	self.filled = false
	self.color = Colors.white
end

function Cell:draw(grid)
	love.graphics.setCanvas(base_canvas)
		love.graphics.setColor(self.color)
		-- love.graphics.polygon('line', self.points[0].x, self.points[0].y, self.points[1].x, self.points[1].y, self.points[2].x, self.points[2].y, self.points[3].x, self.points[3].y)
		if self.filled and self.l == 2 then
			love.graphics.print(self.index, self.points[0].x-grid.dx/2-7, self.points[0].y-7)
		end
	love.graphics.setCanvas()

	love.graphics.setCanvas(highlight_canvas)
		if self.collision == true then
			love.graphics.setColor(self.color)
			love.graphics.setLineWidth(5)
			love.graphics.polygon('line', self.points[0].x, self.points[0].y, self.points[1].x, self.points[1].y, self.points[2].x, self.points[2].y, self.points[3].x, self.points[3].y)
			love.graphics.setLineWidth(1)
		end
		love.graphics.setColor(self.color)
	love.graphics.setCanvas()
	
end

function Cell:update()
	self.collision = false
	self:collide()
end

function Cell:collide()
	x, y = love.mouse.getPosition() -- get mouse location

	for current_idx, current_point in pairs(self.points) do
		next_idx = current_idx + 1
		
		if next_idx == #self.points+1 then
			next_idx = 0
		end
		next_point = self.points[next_idx]

		if (((current_point.y >= y and next_point.y < y) or (current_point.y < y and next_point.y >= y)) and (x < (next_point.x-current_point.x)*(y-current_point.y) / (next_point.y-current_point.y)+current_point.x)) then
			self.collision = not self.collision
		end
	end
end