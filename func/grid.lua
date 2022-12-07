Grid = Object:extend()

local sweep_i = {0,1,0,-1}
local sweep_j = {1,0,-1,0}
local layer_idx = {1,2,3}

function Grid:new()
	self.scale = 2.0

	self.current_cell = 0 -- cell being collided by the mouse (only one cell at the time)
	self.x0 = math.ceil(wind_w/2) -- 50 -- position en x de la première cell
	self.y0 = 50 -- position en y de la première cell
	self.cells = {} -- list of cells
	
	level = {}
	level.tilemap = 'assets/maps/arena' -- !careful when moving the files!
	self.map = require(level.tilemap)
	self.map.tileset = self.map.tilesets[1] -- simplifier le code
	self.map.image = love.graphics.newImage('assets/maps/'..self.map.tileset.image)
	self.Nx = self.map.layers[1].width -- nombre de cells en x
	self.Ny = self.map.layers[1].height -- nombre de cells en y
	self.dx = self.scale * self.map.tilewidth
	self.dy = self.scale * self.map.tileheight

	self:initQuad()

	-- build the mesh
	for l = 1, #layer_idx do
		layer = self.map.layers[l]
		for i = 1, self.Nx do
			local x_init = self.x0 - (i-1) * math.ceil(self.dx/2)
			local y_init = self.y0 + (i-1) * math.ceil(self.dy/2)

			for j = 1, self.Ny do
				local x = x_init + (j-1) * math.ceil(self.dx/2)
				local y = y_init + (j-1) * math.ceil(self.dy/2)
				local idx = self:ij_to_index(i,j)
				local id = layer.data[idx]

				table.insert(self.cells, Cell(x, y, self.dx, self.dy, #self.cells+1,i,j,l))

				if id ~= 0 then
					self.cells[#self.cells].filled = true
					if self.map.tileset.tiles[id].properties.traversable == false then
						self.cells[#self.cells].traversable = false
					end
					if self.map.tileset.tiles[id].properties.stairs == true then
						self.cells[#self.cells].stairs = true
					end
				end
			end
		end
	end

	-- find each cell's neighbors
	for index, cell in pairs(self.cells) do

		for i = 1, #sweep_i do
			local i_neighbor = cell.i + sweep_i[i]
			local j_neighbor = cell.j + sweep_j[i]
			local idx = self:ijl_to_index(i_neighbor, j_neighbor, cell.l)

			if i_neighbor <= self.Nx and i_neighbor >= 1 and
			   j_neighbor <= self.Ny and j_neighbor >= 1 then
				
				if self.cells[idx].traversable then
					table.insert(cell.neighbors, idx)
				end

				-- find the neigh
				if cell.stairs then
					local idx_lower = self:ijl_to_index(i_neighbor+1, j_neighbor+1, cell.l-1)
					if idx_lower < #self.cells and self.cells[idx_lower].traversable then
						table.insert(cell.neighbors, idx_lower)
					end
				end

				-- find stairs in the above layer
				if cell.l < #layer_idx then
					local idx_upper = self:ijl_to_index(i_neighbor-1, j_neighbor-1, cell.l+1)
					if self.cells[idx_upper].stairs then
						table.insert(cell.neighbors, idx_upper)
					end
				end
			end
		end
	end
end


function Grid:update()
	-- current cell is the cell that is on the top layer
	local layer_max = 1
	for idx, cell in pairs(self.cells) do
		if cell.filled then
			cell:update()
			if cell.collision then
				if cell.l >= layer_max then
					layer_max = cell.l
					self.current_cell = idx
				end
			end
		end
	end
end


function Grid:draw()
	-- draw the tilemap
	for l = 1,#layer_idx do
		layer = self.map.layers[l]
		for i = 1, self.Nx do

			local x_init = self.x0 - (i-1) * math.ceil(self.dx/2)
			local y_init = self.y0 + (i-1) * math.ceil(self.dy/2)

			for j = 1, self.Ny do
				local idx = self:ij_to_index(i,j)
				local tile_idx = layer.data[idx]
				if tile_idx ~= 0 then
					local quad = self.map.quads[tile_idx]

					local x = x_init + (j-1) * math.ceil(self.dx/2) - self.dx
					local y = y_init + (j-1) * math.ceil(self.dy/2) - self.dy/2

					love.graphics.draw(self.map.image, quad, x, y, 0, self.scale,self.scale)
				end
			end
		end
	end
end


function Grid:initQuad()
	self.map.quads = {} -- initialisation des quads
	for j = 0, self.map.tileset.imageheight/self.map.tileset.tileheight - 1 do
		for i = 0, self.map.tileset.imagewidth/self.map.tileset.tilewidth - 1 do
			local quad = love.graphics.newQuad(i*self.map.tileset.tilewidth, 
											   j*self.map.tileset.tileheight, 
											   self.map.tileset.tilewidth,
											   self.map.tileset.tileheight,
											   self.map.tileset.imagewidth,
											   self.map.tileset.imageheight)
			table.insert(self.map.quads, quad)
		end
	end
end


function Grid:ij_to_index(i,j)
	return j + (i-1)*self.Nx
end


function Grid:ijl_to_index(i,j,l)
	return j + (i-1) * self.Nx + (l-1)*self.Nx*self.Ny
end


function Grid:index_to_ijl(index)
	l = math.ceil(index / (self.Nx*self.Ny))
	i = math.ceil((index - (l-1)*self.Nx*self.Ny) / self.Nx)
	j = index - (l-1)*self.Nx*self.Ny - (i-1)*self.Nx

	return i,j,l
end
