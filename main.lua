Object = require 'lib/classic'
Camera = require 'lib/hump.camera'
Timer = require 'lib/hump.timer'
Vector = require 'lib/hump.vector'
Colors = require 'lib/colors' -- a place to store my favorite colors
require 'func/grid'
require 'func/explorer'
require 'func/cell'
require 'lib/misc'
love.graphics.setBackgroundColor(Colors.deepgrey) -- color matching my windows 10 theme :)
wind_w = 1400
wind_h = 750
love.graphics.setDefaultFilter('nearest','nearest') -- Pas de filtre pour les sprites
love.window.setMode(wind_w, wind_h)
love.window.setTitle('Tactical project')


function love.load()
	mousereleased = false

	grid = Grid()
	start = 57 -- index of the starting cell
	explorer = Explorer(start)
end


function love.update(dt)
	grid:update()
	explorer:update(grid)
end


function love.draw()
	grid:draw()
	explorer:draw(grid)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end










function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		mousereleased = true
	end
end