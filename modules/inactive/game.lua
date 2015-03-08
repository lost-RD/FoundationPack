print("requiring game.lua")

local Game = assert(class('Game'):include(Stateful), "failed to load game.lua")

print("Game loaded")

--debug music
TEsound.sound=true
TEsound.music=true

function Game:initialize()
	-- menu ressources
	self:gotoState('Loading', 'MainMenu', require( 'subclass/menuressources' ), _menu_ )
	print("Game initialised")
end

-- Include the methods available in all states here

-- prints output in the console
-- If you are on windows you will need to activate it first, see
--   https://love2d.org/wiki/Config_Files
-- for details (you have to set t.console to true)
function Game:log(...)
  print(...)
end

function Game:exit()
  self:log("Goodbye!")
  love.event.push('quit')
end

function Game:draw()
end

function Game:update(dt)
	-- update music/sound
	TEsound.cleanup()
end

-- by default, exit when pressing 'escape'
function Game:keypressed(key, isrepeat)
	print( key )
	if key == 'escape' then
		self:exit()
	end
end

function Game:keyreleased(key, isrepeat)
end

function Game:mousepressed(x,y,button)
end

function Game:mousereleased(x,y,button)
end

function Game:quit()
end

return Game
