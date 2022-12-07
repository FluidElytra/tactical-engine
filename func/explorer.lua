Explorer = Object:extend()

local debug_mode = false
local complete = false
-- local sweep_i = {-1,0,1,1,1,0,-1,-1}
-- local sweep_j = {1,1,1,0,-1,-1,-1,0}
local sweep_i = {0,1,0,-1}
local sweep_j = {1,0,-1,0}

function Explorer:new(start)
	--[[
	DESCRIPTION: initialize the explorer with it start point and its destination
	PARAMETERS:
		start <int>
			index of the start cell
		stop <int>
			index of the stop cell
	--]]

	self.position = start
	self.previous_position = start
	self.stop = start -- index of the cell to reach
	self.path = {} -- table of the indexes of cells to travel through
	self.previous_path = {}
	self.state = 'idle' -- finite state machine
	self.reachable = true -- if the explorer can reach its destination
	self.i, self.j, self.l = grid:index_to_ijl(self.position) -- locate the explorer on the grid
	self.minigrid = {}
	self.range = 5
end


function Explorer:update(grid)
	--[[
	DESCRIPTION: computes explorer's position and computes the path if needed
	PARAMETERS:
		grid <object grid>
			the grid where the cell information is stored
	--]]

	self.i, self.j, self.l = grid:index_to_ijl(self.position) -- locate the explorer on the grid

	if self.state == 'idle' then
		self.minigrid = {} -- reset the accessible cells
		grid.cells[self.position].traversable = false

		if grid.current_cell == self.position and mousereleased then
			self.state = 'travel_plan'
			mousereleased = false
		end


	elseif self.state == 'travel_plan' then
		grid.cells[self.position].traversable = true

		-- right click: cancels selection and travel plan
		if love.mouse.isDown(2) then
			self.state = 'idle'
		end

		-- find cells in range
		if #self.minigrid == 0 then
			for idx, cell in pairs(grid.cells) do
				if cell.filled then
					if self:distance(cell.i, cell.j) <= self.range then
						local path, reachable = self:pathfinding(grid, self.position, cell.index)
						if reachable and #path <= self.range then
							table.insert(self.minigrid, cell.index)
						end
					end
				end
			end
		end

		-- plan travel with A* pathfinding
		if grid.current_cell ~= 0 then
			if grid.cells[grid.current_cell].traversable then
				self.stop = grid.current_cell
			end
		end

		self.path, self.reachable = self:pathfinding(grid, self.position, self.stop)

		if self.reachable and exist_in(self.stop,self.minigrid) then
			self.previous_position = self.stop
			self.previous_path = self.path
		else
			self.stop = self.previous_position
			self.path = self.previous_path
		end

		-- left click: selects destination and update position
		if mousereleased then
			self.state = 'travel'
			mousereleased = false
		end


	elseif self.state == 'travel' then
		self.minigrid = {} -- reset the accessible cells
		self.position = self.stop -- update position
		self.path = {}
		self.state = 'idle' -- close the loop


	elseif self.state == 'action_menu' then
	elseif self.state == 'attack' then
	end

end


function Explorer:draw(grid)
	--[[
	DESCRIPTION: draw the explorer and its path toward its destination
	PARAMETERS:
		grid <object grid>
			the grid where the cell information is stored
	--]]

	if self.state == 'idle' then
		emphasize(self.position, Colors.white, 'D')

	elseif self.state == 'travel_plan' then
		-- draw available cell for movement
		if #self.minigrid > 0 then
			for idx, value in pairs(self.minigrid) do
				emphasize(value,Colors.lightgreen,'')
			end
		end

		-- color the departure
		emphasize(self.position, Colors.white, 'D')

		-- color the arrival
		emphasize(self.stop, Colors.white, 'A')

		-- plot the path
		love.graphics.setColor(Colors.pink)
		love.graphics.setLineWidth(5)
		for i = 2, #self.path do
			x_1 = grid.cells[self.path[i-1]].points[0].x - grid.dx/2
			y_1 = grid.cells[self.path[i-1]].points[0].y
			x_2 = grid.cells[self.path[i]].points[0].x - grid.dx/2
			y_2 = grid.cells[self.path[i]].points[0].y

			love.graphics.line(x_1 , y_1,
							   x_2 , y_2)
		end
		love.graphics.setLineWidth(1)
		love.graphics.setColor(Colors.white)

	elseif self.state == 'travel' then
	elseif self.state == 'action_menu' then
	elseif self.state == 'attack' then
	end

end


function Explorer:pathfinding(grid, start, arrival)
	--[[
	DESCRIPTION: finds the shortest path between the start and arrival points
	PARAMETERS:
		grid <object grid>
			the grid where the cell information is stored
		start <int>
			index of the cell the explorer starts its path
		arrival <int>
			index of the cell the explorer has to travel to
	--]]

	-- initialization
	reachable = true
	start_i, start_j = grid.cells[start].i, grid.cells[start].j
	arrival_i, arrival_j = grid.cells[arrival].i, grid.cells[arrival].j

	self.closed = {}
	self.closed.index = {}
	self.closed.parent = {}

	self.open = {} -- index and cost
	self.open.F_cost = {}
	self.open.H_cost = {}
	self.open.index = {}
	self.open.parent = {}

	self.open.index[1] = grid.cells[start].index
	self.open.F_cost[1] = 0
	self.open.H_cost[1] = 0
	self.open.parent[1] = 0

	local complete = false
	local min_dist = 15

	while not complete do
		-- find the cell with the smallest F and H values
		key, value = min(self.open.F_cost)

		if key == nil then
			complete = true
			self.closed = {}
			self.closed.index = {start}
			self.closed.parent = {start}
			break
		end

		-- convert index to i, j coordinates
		current_index = self.open.index[key]

		current_i, current_j = grid.cells[current_index].i, grid.cells[current_index].j
		
		-- add current to the closed list
		table.insert(self.closed.index, current_index)
		table.insert(self.closed.parent, self.open.parent[key])

		-- remove current cell from the open list
		table.remove(self.open.index, key)
		table.remove(self.open.F_cost, key)
		table.remove(self.open.H_cost, key)
		table.remove(self.open.parent, key)

		-- stop criteria
		if current_index == arrival then
			complete = true
		end

		-- open neighbor cells
		for k = 1, #grid.cells[current_index].neighbors do
			index = grid.cells[current_index].neighbors[k]
			cell = grid.cells[index]
			i = cell.i
			j = cell.j

			if i <= grid.Nx and i >= 1 and j <= grid.Ny and j >= 1 then -- check if the cell is in the grid
				if not exist_in(index, self.closed.index) and not exist_in(index, self.open.index) and cell.traversable and cell.filled then
					local G_cost = math.sqrt((i - start_i)^2 + (j - start_j)^2)*10 -- compute distance from start
					local H_cost = math.sqrt((i - arrival_i)^2 + (j - arrival_j)^2)*10 -- compute distance from stop
					local F_cost = G_cost + H_cost
					table.insert(self.open.index, index)
					table.insert(self.open.H_cost, H_cost)
					table.insert(self.open.F_cost, G_cost + H_cost)
					table.insert(self.open.parent, current_index)
				end
			end
		end
	end

	-- reconstruct the path
	path = {}

	if #self.closed.index > 1 then
		-- when the explorer can reach its destination
		local current = arrival
		path[1] = current

		while current ~= start do
			found, key = key_of(current, self.closed.index)
			if found then
				current = self.closed.parent[key]
				table.insert(path, current)
			end
		end
	else
		-- when the explorer cannot reach its destination
		if start ~= arrival then
			path[1] = start
			reachable = false
		end
		
	end



	return path, reachable
end



function emphasize(index, color, text)
	--[[
	DESCRIPTION: colors the cell at a given index and display information
	PARAMETERS:
		index <int>
			index of the cell to color
		color <table>
			4-items array coding for the color
		text <str>
			string or number to display in the cell
	--]]

	cell = grid.cells[index]
	love.graphics.setColor(color)

	love.graphics.circle('fill', cell.points[0].x-grid.dx/2,cell.points[0].y, 10)
	love.graphics.setColor(Colors.white)
	-- love.graphics.print(text, cell.points[0].x+grid.dx/2-7, cell.points[0].y-7)
	love.graphics.setColor(Colors.white)
end


function Explorer:distance(i,j)
	dist = math.sqrt((self.i-i)^2 + (self.j-j)^2)
	return dist
end