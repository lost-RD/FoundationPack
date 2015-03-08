if configuration.debug then

require 'lovedebug'

end

function love.load()

	print([[FoundationPack v0.2
Compiled on 2014/11/12 by lost_RD of the LOVE2D.org forums
Thread: https://love2d.org/forums/viewtopic.php?f=5&t=79113

This pack claims no copyright over any code in the modules folder.
All modules are copyright to their respective owners.
]])

	require 'foundation-loader'

	-- PROBE
	print("--- Initialising profilers ---")
    drawProfiler = PROBE.new(60)
    updateProfiler = PROBE.new(60)
	print("--- Profilers initialised ---")

	-- begin user input --
	print("--- Executing foundation.load() ---")
	foundation.load()
	print("--- foundation.load() executed ---")
	-- end user input --

	-- PROBE
    drawProfiler:hookAll(_G, 'draw', {love, foundation})
    updateProfiler:hookAll(_G, 'update', {love, foundation})
    drawProfiler:enable(true)
    updateProfiler:enable(true)

end

function love.update(dt)
	updateProfiler:startCycle()

    Controllers.pre_update(dt)

	-- begin user input --

	foundation.update(dt)

	-- end user input --

    Controllers.post_update(dt)

	updateProfiler:endCycle()
end

function love.draw()
	drawProfiler:startCycle()

	-- begin user input --

	foundation.draw()

	-- end user input --

	drawProfiler:endCycle()

	if foundation.showProfilers then
	    drawProfiler:draw(50, 50, 150, 500, "DRAW CYCLE")
		updateProfiler:draw(love.window.getWidth()-200, 50, 150, 500, "UPDATE CYCLE")
	end
end

function love.mousepressed(x,y,button)
    Controllers.mousePressed(x,y,button)
end
function love.mousereleased(x,y,button)
    Controllers.mouseReleased(x,y,button)
end

function love.keypressed(key,isrepeat)
    Controllers.keyPressed(key)
end
function love.keyreleased(key,isrepeat)
    Controllers.keyReleased(key)
end

function love.joystickpressed(joystick,key)
    Controllers.joystickPressed(joystick,key)
end
function love.joystickreleased(joystick,key)
    Controllers.joystickReleased(joystick,key)
end