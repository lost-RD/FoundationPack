Controllers.lua
===============

A Lua/Löve lib by Félix Dumenil that handles and simplify buttons/axe events.
Cool features : 
 - A simple API.
 - Using buttons for axes, and axes for buttons.
 - Multiple players support.
 - Optionals callbacks!
 - Mouse locking.

Requirements : 
 - Löve 0.9.x
 - A computer.
 - Nothing else.

Quick Tutorial
--------------

1. Import the library :  
	```
	Controllers = require('controllers')
	```
2. Initialize the library, and give it your list of bind-ables buttons and axes :  
	```
	function love.load()
	    Controllers.init({
		 menu_up = {type="button", default={'kb_up','gpb_dpup','gpa_lefty_-'}}
		,menu_down = {type="button", default={'kb_down','gpb_dpdown','gpa_lefty_+'}}
		,menu_select = {type="button", default={'kb_return','gpb_a'}}
		,menu_back = {type="button", default={'kb_escape','gpb_b'}}

		,game_jump = {type="button", per_player=true, default={'kb_ ','gpb_a'}}
		,game_walk = {type="axis", exclusive="press", per_player=true, default={'kb_left_-','kb_right_+','gpa_leftx'}}
		})
	end
	```
3. Place the others needed callbacks where they need to go :
	```
	function love.update(dt)
		Controllers.pre_update(dt)
		-- Your updating code here
		Controllers.post_update(dt)
	end
	function love.mousepressed(x,y,button)
		Controllers.mousePressed(x,y,button)
	end
	function love.mousereleased(x,y,button)
		Controllers.mouseReleased(x,y,button)
	end
	
	function love.keypressed(key,unicode)
		Controllers.keyPressed(key)
	end
	function love.keyreleased(key,unicode)
		Controllers.keyReleased(key)
	end
	
	function love.joystickpressed(joystick,key)
		Controllers.joystickPressed(joystick,key)
	end
	function love.joystickreleased(joystick,key)
		Controllers.joystickReleased(joystick,key)
	end

	```
4. Optionally add some players
	```
	function love.load()
	    Controllers.init({
		 menu_up = {type="button", default={'kb_up','gpb_dpup','gpa_lefty_-'}}
		,menu_down = {type="button", default={'kb_down','gpb_dpdown','gpa_lefty_+'}}
		,menu_select = {type="button", default={'kb_return','kb_ ','gpb_a'}}
		,menu_back = {type="button", default={'kb_escape','gpb_start'}}

		,game_jump = {type="button", per_player=true, default={'kb_ ','gpb_a'}}
		,game_walk = {type="axis", exclusive="press", per_player=true, default={'kb_left_-','kb_right_+','gpa_leftx'}}
		})
		Controllers.setPlayer('player_1','joystick',1)
	end
	```
5. Have fun!
	```
	function love.update(dt)
		Controllers.pre_update(dt)

		if pause then
			for i=1, Controllers.isPressed('menu_up') do
				menu_select = menu_select - 1
			end
			for i=1, Controllers.isPressed('menu_down') do
				menu_select = menu_select + 1
			end
		end

		if Controllers.isPressed('menu_back') then
			pause = not pause
		end

		if Controllers.isDown('game_jump','player_1') and player:onGround() then
			player:jump()
		end
		player.speedx = Controllers.getAxis('game_walk','player_1') * player.walk_speed

		Controllers.post_update(dt)
	end
	```
