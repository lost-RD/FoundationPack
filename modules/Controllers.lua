-- Controllers.lua v0.1
-- A Lua/Löve lib by Félix Dumenil that handles and simplify buttons/axe events.

--[[
	Functions you need to know:
		Controllers.init(controls_table)
			"control_table" being the table that contains all of your
			buttons/axes. It's formatted like this : 
			{
				name_of_button={
					type="button",
					per_player=false,
					default={"control1","control2","control3"}}
				},
				name_of_axis={
					type="axis",
					per_player=false,
					inverted=false, -- Invert the axis. Obvious
					limit=false, -- Should the axis stay in the [-1;1] range?
					exclusive="all", -- Can be: 
						-- "all" : No matter what's the last keypress
						-- "controller" : If the last key press was on a
						--    keyboard & mouse combo, or a controller, then this
						--    axis will only count binds made on a
						--    keyboard & mouse combo, or a controller.
						-- "press" : If the last key press was on a keyboard, a
						--    mouse, or a controller, this axis will only count
						--    the binds on a keyboard, a mouse, or a controller.
					default={"control1","control2","control3"}}
				}
			}
			The controls's binds can be : 
			buttons : kb_[key], gpb_[key], jpb_[id], mb_[key]
			          keyboard, gamepad,   joystick, mouse
			axes = jpa_[axis], gpa_[axis], md_[x/y],    mp_[x/y]
			       joystick,   gamepad,    mouse-delta, mouse position
			Note that you can also use buttons for axes, and axes for buttons,
			if you add "_+" or "_-" behind the bind. Ex: kb_return_+, gpa_rt_- 

		Controllers.pre_update(dt)
		Controllers.post_update(dt)

		Controllers.mousePressed([x,y,]button)
		Controllers.mouseReleased([x,y,]button)
		Controllers.keyPressed(key[,unicode])
		Controllers.keyReleased(key[,unicode])
		Controllers.joystickPressed(joystick,key)
		Controllers.joystickReleased(joystick,key)
	Functions you want to know:
		Controllers.setCallbacks(callback_table)
		Controllers.isDown(button[,player]) => Is the button down
		Controllers.isPressed(button[,player]) => If the button was pressed
		this frame
		Controllers.isReleased(button[,player]) => If the button was released
		this frame
		Controllers.nbPressed(button[,player]) => How much was the button
			pressed this frame
		Controllers.nbReleased(button[,player]) => How much was the button
			released this frame
		Controllers.getAxis(axis[,player]) => The value of the axis. Can be outta
			bounds if controls_table[axis].limit ~= true.
	Functions you can know:
		Controllers.getMouseOrigin() => x,y
		Controllers.setMouseOrigin(x,y)
		Controllers.getGrabMouse() => bool
		Controllers.setGrabMouse(bool)
			Simply do a "love.mouse.setPosition(mouse_origin.x*love.graphics.getWidth(),mouse_origin.y*love.graphics.getHeight())" each frame if enabled. Useful when using md_[x/y]
		Controllers.getMouseSensitivity() => sensitivity
		Controllers.setMouseSensitivity(sensitivity)
		    md_[x/y] and mp_[x/y] are multiplied by that mouse sensitivity
		    factor. Default is 0.02.
		Controllers.getButtonBinds(button,player) => list of binds
		Controllers.setButtonBinds(button,player,list_binds)
		Controllers.getButtonList(player) => list of buttons(the names you gave
			them in controls_table) that are appliquable to X player. nil for
			"global" player(So for stuff without per_player set to true)

]]

local Controllers = {}
Controllers._URL = 'https://github.com/Felix-Du/Controllers.lua'
Controllers = setmetatable(Controllers,Controllers)

function Controllers.init(controls_table)
	--[[
		type controls:
		buttons : kb_[key],gpb_[key],jpb_[id],mb_[key]
		axes = jpa_[axis],gpa_[axis],md_[x/y],mp_[x/y]
		]]
	--[[ controls_table = {
		["control_name"] = {
			type="button",
			per_player=false,
			default={"control1","control2","control3"}}
	}
		["other_control"] = {
			type="axis",
			per_player=true,
			inverted=true,
			limit=false, -- Should the axis stay in the [-1;1] range?
			exclusive="all",
			default={"control1","control2","control3"}}
	}
		"exclusive" values:
		- all : kb, mouse or joystick
		- press kb/mouse/joystick
		- controller kb & mouse/joystick
	]]
	Controllers.controllertype = {
		kb = "keyboard",
		mb = "keyboard", -- Mouse buttons is considered as "keyboard". Weird, uh?
		-- "keyboard" is actually "mouse & keyboard",
		md = "keyboard",
		mp = "keyboard",

		gpb = "joystick",
		gpa = "joystick",
		jpb = "joystick",
		jpa = "joystick"
	}
	Controllers.presstype = {
		kb = "keyboard",
		mb = "mouse",
		md = "mouse",
		mp = "mouse",

		gpb = "joystick",
		gpa = "joystick",
		jpb = "joystick",
		jpa = "joystick"
	}

	Controllers.controls_table = controls_table
	Controllers.buttons_down = {}
	Controllers.buttons_down['global'] = {}
	Controllers.keys_cache = {}
	Controllers.controls_bind = {}
	Controllers.controls_bind['global'] = {}

	for c_id,control in pairs(Controllers.controls_table) do
		if not control.exclusive then
			control.exclusive = "all"
		end
		if not control.per_player then
			Controllers.controls_bind['global'][c_id] = {}
			if control.type == "button" then
				Controllers.buttons_down['global'][c_id] = {down=false, pressed=0, released=0}
			end
		end
	end
	Controllers:init_binds('global')
	Controllers.players = {}
	Controllers.callbacks = {}
	Controllers.last_presstype = "keyboard"
	Controllers.last_controllertype = "keyboard"

	Controllers.mouse_sensitivity = 0.02
	Controllers.mouse_position = {love.mouse.getPosition()}
	Controllers.mouse_origin = {.5,.5}
	Controllers.mouse_delta = {0,0}
	Controllers.grab_mouse = false
end

Controllers.__call = Controllers.init

function Controllers.setPlayer(player,type_controller,id_controller)
	assert(player ~= nil,("\"player\" arg shouldn't be nil"):format(type(player)))
	type_controller = type_controller or "all"
	assert(type(type_controller)=="string",("\"type_controller\" arg must be a string or nil/false, and not a %s"):format(type(type_controller)))
	assert(type(id_controller)=="number" or id_controller == nil or id_controller == "all",
		("\"id_controller\" arg must be a number, nil/false, or \"all\", and not a %s"):format(type(id_controller)))
	id_controller = id_controller or "all"
	Controllers.players[player] = {
			type = type_controller,
			id = id_controller,
			joystick = nil,
			connected = true
		}
	if type_controller == "joystick" and type(id_controller)=="number" then
		for _,joystick in ipairs(love.joystick.getJoysticks()) do
			if joystick:getID() == id_controller then
				Controllers.players[player].joystick = joystick
				Controllers.players[player].connected = joystick:isConnected()
				break
			end
		end
	end
	if Controllers.players[player].connected then
		if Controllers.callbacks['player_connected'] then
			Controllers.callbacks['player_connected'](player)
		end
	else
		if Controllers.callbacks['player_disconnected'] then
			Controllers.callbacks['player_disconnected'](player)
		end
	end
	Controllers.buttons_down[player] = {}
	for c_id,control in pairs(Controllers.controls_table) do
		if control.per_player then
			if control.type == "button" then
				Controllers.buttons_down[player][c_id] = {down=false, pressed=false, released=false}
			end
		end
	end
	Controllers:init_binds(player)
end

function Controllers.isDown(button,player)
	assert(type(button)=="string",("\"button\" arg must be a string, and not a %s"):format(type(button)))
	assert(Controllers.controls_table[button],("%s don't exist!"):format(button))
	assert(Controllers.controls_table[button].type == "button",("%s is not a button!"):format(button))
	player = player or "global"
	assert(Controllers.controls_bind[player],("Player \"%s\" don't exist! (Tip: use Controllers.setPlayer to create it!)"):format(player))
	return Controllers.buttons_down[player][button].down
end

function Controllers.isPressed(button,player)
	local nbpressed = Controllers.nbPressed(button,player)
	return nbpressed > 0
end

function Controllers.isReleased(button,player)
	local nbreleased = Controllers.nbReleased(button,player)
	return nbreleased > 0
end

function Controllers.nbPressed(button,player)
	assert(type(button)=="string",("\"button\" arg must be a string, and not a %s"):format(type(button)))
	assert(Controllers.controls_table[button],("%s don't exist!"):format(button))
	assert(Controllers.controls_table[button].type == "button",("%s is not a button!"):format(button))
	player = player or "global"
	assert(Controllers.controls_bind[player],("Player \"%s\" don't exist! (Tip: use Controllers.setPlayer to create it!)"):format(player))
	local nbpressed = Controllers.buttons_down[player][button].pressed
	return nbpressed
end

function Controllers.nbReleased(button,player)
	assert(type(button)=="string",("\"button\" arg must be a string, and not a %s"):format(type(button)))
	assert(Controllers.controls_table[button],("%s don't exist!"):format(button))
	assert(Controllers.controls_table[button].type == "button",("%s is not a button!"):format(button))
	player = player or "global"
	assert(Controllers.controls_bind[player],("Player \"%s\" don't exist! (Tip: use Controllers.setPlayer to create it!)"):format(player))
	local nbreleased = Controllers.buttons_down[player][button].released
	return nbreleased
end

function Controllers.getAxis(axis,player)
	assert(type(axis)=="string",("\"axis\" arg must be a string, and not a %s"):format(type(axis)))
	assert(Controllers.controls_table[axis],("%s don't exist!"):format(axis))
	assert(Controllers.controls_table[axis].type == "axis",("%s is not an axis!"):format(axis))
	player = player or "global"
	assert(Controllers.controls_bind[player],("Player \"%s\" don't exist! (Tip: use Controllers.setPlayer to create it!)"):format(player))
	local axis_value = 0
	local type_controller = "all"
	local id_controller = "all"
	if Controllers.controls_table[axis].per_player then
		assert(Controllers.players[player],"player "..tostring(player).." don't exist!")
		type_controller = Controllers.players[player].type
		id_controller = Controllers.players[player].id
	end
	for bind_id,bind in ipairs(Controllers.controls_bind[player][axis]) do
		local type_,key_name,others = Controllers:get_key(bind)
		if type_controller == "all" or Controllers.controllertype[type_] == type_controller then
			if Controllers.controls_table[axis].exclusive == "all" or
				(Controllers.controls_table[axis].exclusive == "press" and Controllers.last_presstype == Controllers.presstype[type_]) or
				(Controllers.controls_table[axis].exclusive == "controller" and Controllers.last_controllertype == Controllers.controllertype[type_]) then
				axis_value = axis_value + Controllers:get_axis(bind,controller_id)
			end
		end
	end
	if Controllers.controls_table[axis].limit then
		axis_value = math.max(-1,math.min(1,axis_value))
	end
	if Controllers.controls_table[axis].inverted then
		axis_value = -axis_value
	end
	return axis_value
end

function Controllers.isConnected(player)
	assert(Controllers.players[player],("Player \"%s\" don't exist! (Tip: use Controllers.setPlayer to create it!)"):format(player))
	return Controllers.players[player].connected
end

function Controllers.getButtonBinds(button,player)
	assert(type(button)=="string",("\"button\" arg must be a string, and not a %s"):format(type(button)))
	assert(Controllers.controls_table[button],("%s don't exist!"):format(button))
	player = player or "global"
	assert(Controllers.controls_bind[player],("Player \"%s\" don't exist! (Tip: use Controllers.setPlayer to create it!)"):format(player))
	return Controllers.controls_bind[player][button]
end

function Controllers.setButtonBinds(button,player,list_binds)
	assert(type(button)=="string",("\"button\" arg must be a string, and not a %s"):format(type(button)))
	assert(Controllers.controls_table[button],("%s don't exist!"):format(button))
	player = player or "global"
	assert(Controllers.controls_bind[player],("Player \"%s\" don't exist! (Tip: use Controllers.setPlayer to create it!)"):format(player))
	if list_binds == 'default' then
		Controllers:init_binds(player)
		return
	end
	assert(type(list_binds)=="table",("\"list_binds\" arg must be a table, and not a %s"):format(type(list_binds)))
	Controllers.controls_bind[player][button] = {unpack(list_binds)}
end

function Controllers.getButtonList(player)
	player = player or "global"
	assert(Controllers.controls_bind[player],("Player \"%s\" don't exist! (Tip: use Controllers.setPlayer to create it!)"):format(player))
	local bind_list = {}
	for c_id,bind_list in pairs(Controllers.controls_bind[player]) do
		table.insert(bind_list,c_id)
	end
	return bind_list
end

function Controllers.getMouseOrigin()
	return unpack(Controllers.mouse_origin)
end

function Controllers.setMouseOrigin(x,y)
	assert(type(x)=="number",("X must be a number, and not a %s"):format(type(x)))
	assert(type(y)=="number",("Y must be a number, and not a %s"):format(type(y)))
	assert(0 < x and x < 1,("X should be between 0 and 1 (Value : %s)"):format(x))
	assert(0 < y and y < 1,("Y should be between 0 and 1 (Value : %s)"):format(y))
	Controllers.mouse_origin = {x,y}
end

function Controllers.getMouseSensitivity()
	return Controllers.mouse_sensitivity
end

function Controllers.setMouseSensitivity(mouse_sensitivity)
	assert(type(mouse_sensitivity)=="number",("setMouseSensitivity's arg must be a number, and not a %s"):format(type(mouse_sensitivity)))
	Controllers.mouse_sensitivity = mouse_sensitivity
end

function Controllers.setGrabMouse(grab_mouse)
	assert(type(grab_mouse)=="boolean",("setGrabMouse's arg must be a boolean, and not a %s"):format(type(grab_mouse)))
	Controllers.grab_mouse = grab_mouse
end

function Controllers.getGrabMouse()
	return Controllers.grab_mouse
end

function Controllers.setCallbacks(callback_table)
	--[[Callbacks:
		pressed(button,player_name)
		released(button,player_name)
		pressed_any(key,controller_id)
		released_any(key,controller_id)
		player_connected(player)
		player_disconnected(player)
	]]

	assert(type(callback_table)=="table","The callback table should be, well, a table and not a "..type(callback_table)..".")
	Controllers.callbacks = callback_table
end

-- Callbacks needed

function Controllers.pre_update(dt)
	local new_mouse_x,new_mouse_y = love.mouse.getPosition()
	Controllers.mouse_delta[1] = new_mouse_x - Controllers.mouse_position[1]
	Controllers.mouse_delta[2] = new_mouse_y - Controllers.mouse_position[2]
	Controllers.mouse_position[1] = new_mouse_x
	Controllers.mouse_position[2] = new_mouse_y

	for player_name,player_buttons in pairs(Controllers.buttons_down) do
		for button,button_info in pairs(player_buttons) do
			local is_pressed = Controllers:is_button_down(button,player_name)

			if button_info.down ~= is_pressed then
				button_info.down = is_pressed
				if is_pressed then
					if button_info.pressed == 0 then
						button_info.pressed = 1
						if Controllers.callbacks.pressed then
							Controllers.callbacks.pressed(button,player_name)
						end
					end
				else
					if button_info.released == 0 then
						button_info.released = 1
						if Controllers.callbacks.released then
							Controllers.callbacks.released(button,player_name)
						end
					end
				end
			end
		end
	end
	for player_name,player in pairs(Controllers.players) do
		if player.joystick then
			local new_connected = player.joystick:isConnected()
			if player.connected ~= new_connected then
				player.connected = new_connected
				if new_connected then
					if Controllers.callbacks['player_connected'] then
						Controllers.callbacks['player_connected'](player)
					end
				else
					if Controllers.callbacks['player_disconnected'] then
						Controllers.callbacks['player_disconnected'](player)
					end
				end
			end
		end
	end
end

function Controllers.post_update(dt)
	for player_name,player_buttons in pairs(Controllers.buttons_down) do
		for button,button_info in pairs(player_buttons) do
			button_info.pressed = 0
			button_info.released = 0
		end
	end
	if Controllers.grab_mouse then
		love.mouse.setPosition(Controllers.mouse_origin[1]*love.graphics.getWidth(),Controllers.mouse_origin[2]*love.graphics.getHeight())
	end
end

function Controllers.mousePressed(x,y,button)
	if type(x)=="string" then button = x end
	Controllers:fake_press('mb_'..button)
end

function Controllers.mouseReleased(x,y,button)
	if type(x)=="string" then button = x end
	Controllers:fake_release('mb_'..button)
end

function Controllers.keyPressed(key)
	Controllers:fake_press('kb_'..key)
end

function Controllers.keyReleased(key)
	Controllers:fake_release('kb_'..key)
end

function Controllers.joystickPressed(joy,key)
	local has_gamepad_key = false
	if joy:isGamepad() then
		for _,button in ipairs({'a','b','x','y','back','guide','start','leftstick','rightstick','leftshoulder','rightshoulder','dpup','dpdown','dpleft','dpright'}) do
			local type_,index,_direction = joy:getGamepadMapping(button)
			if type_ == "button" and index == key then
				Controllers:fake_press('gpb_'..button,joy:getID())
				has_gamepad_key = true
			end
		end
	end
	if not has_gamepad_key then
		Controllers:fake_press('jpb_'..key,joy:getID())
	end
end

function Controllers.joystickReleased(joy,key)
	local has_gamepad_key = false
	if joy:isGamepad() then
		for _,button in ipairs({'a','b','x','y','back','guide','start','leftstick','rightstick','leftshoulder','rightshoulder','dpup','dpdown','dpleft','dpright'}) do
			local type_,index,_direction = joy:getGamepadMapping(button)
			if type_ == "button" and index == key then
				Controllers:fake_release('gpb_'..button,joy:getID())
				has_gamepad_key = true
			end
		end
	end
	if not has_gamepad_key then
		Controllers:fake_release('jpb_'..key,joy:getID())
	end
end

-- Internal functions

function Controllers:init_binds(player)
	local is_player = player and (player ~= "global")
	self.controls_bind[player] = {}

	for c_id,control in pairs(self.controls_table) do
		if (not not control.per_player) == is_player then
			self.controls_bind[player][c_id] = {}
			for b_id,bind in ipairs(control.default) do
				self.controls_bind[player][c_id][b_id] = bind
			end
		end
	end
end

function Controllers:get_key(key)
	if not self.keys_cache[key] then
		local type_ = ""
		local key_name = ""
		local others
		if key:sub(3,3)=="_" then
			type_ = key:sub(1,2)
			key_name = key:sub(4)
		else
			type_ = key:sub(1,3)
			key_name = key:sub(5)
		end

		if (key_name:sub(-2,-1) == '_+' or key_name:sub(-2,-1) == '_-') and key_name:len()>2 then
			others = key_name:sub(-1,-1)
			key_name = key_name:sub(1,key_name:len()-2)
		end
		self.keys_cache[key] = {type_,key_name,others}
	end
	return unpack(self.keys_cache[key])
end

function Controllers:is_button_down(key,player)
	player = player or "global"
	assert(self.controls_table[key],tostring(key).." key isn't binded!")
	assert((not not self.controls_table[key].per_player) == (player ~= "global"),tostring(key).." key isn't called correctly!")
	assert(self.controls_table[key].type=="button", tostring(key).." key isn't a button!")
	local type_controller = "all"
	local id_controller = "all"
	if self.controls_table[key].per_player then
		assert(self.players[player],"player "..tostring(player).." don't exist!")
		type_controller = self.players[player].type
		id_controller = self.players[player].id
	end
	for bind_id,bind in ipairs(self.controls_bind[player][key]) do
		local type_,key_name,others = self:get_key(bind)
		if type_controller == "all" or self.controllertype[type_] == type_controller then
			if self:is_key_down(bind,controller_id) then
			 	return true
			end 
		end
	end
	return false
end

function Controllers:is_key_down(key,controller_id)
	local type_,key_name,others = self:get_key(key)
	if type_ == "kb" then
		assert(not others, "There shouldn't be an \"other\" field for keyboard!")
		assert(not controller_id, "There shouldn't be a controller_id for keyboard!")
		return love.keyboard.isDown(key_name)
	elseif type_ == "mb" then
		assert(not others, "There shouldn't be an \"other\" field for mouse button!")
		assert(not controller_id, "There shouldn't be a controller_id for mouse button!")
		return love.mouse.isDown(key_name)
	elseif type_ == "gpb" or type_ == "jpb" then
		assert(not others, "There shouldn't be an \"other\" field!")
		for _,joystick in ipairs(love.joystick.getJoysticks()) do
			if (not controller_id) or controller_id == "all" or joystick:getID() == controller_id then
				if type_ == "gpb" then
					if joystick:isGamepadDown(key_name) then
						return true
					end
				elseif type_ == "jpb" then
					if joystick:isDown(tonumber(key_name)) then
						return true
					end
				end
			end
		end
	else -- Axis I guess?
		assert(others, "There should be an \"other\" field for buttons-axis!")
		if others == "-" and self:get_axis(type_.."_"..key_name,controller_id) < -.5 then
			return true
		elseif others == "+" and self:get_axis(type_.."_"..key_name,controller_id) > .5 then
			return true
		end
	end
	return false
end

function Controllers:get_axis(key,controller_id)
	local type_,key_name,others = self:get_key(key)
	if type_ == "jpa" or type_ == "gpa" then -- Joystick axis
		local axis = 0
		assert(not others, "There shouldn't be an \"other\" field!")
		for _,joystick in ipairs(love.joystick.getJoysticks()) do
			if (not controller_id) or controller_id == "all" or joystick:getID() == controller_id then
				if type_ == "gpa" then
					 axis = axis + joystick:getGamepadAxis(key_name)
				elseif type_ == "jpa" then
					 axis = axis + joystick:getAxis(tonumber(key_name))
				end
			end
		end
		return axis
	elseif type_ == "md" or type_ == "mp" then -- Mouse
		if type_ == "md" then
			if key_name == "x" then
				return self.mouse_delta[1] * self.mouse_sensitivity
			elseif key_name == "y" then
				return self.mouse_delta[2] * self.mouse_sensitivity
			end
		elseif type_ == "mp" then
			if key_name == "x" then
				return (self.mouse_position[1]-self.mouse_origin[1]*love.graphics.getWidth()) * self.mouse_sensitivity
			elseif key_name == "y" then
				return (self.mouse_position[2]-self.mouse_origin[2]*love.graphics.getHeight()) * self.mouse_sensitivity
			end
		end
	else -- A button, I guess?
		assert(others, "There should be an \"other\" field for axis-buttons!")
		if self:is_key_down(type_.."_"..key_name,controller_id) then
			if others == "-" then
				return -1
			elseif others == "+" then
				return 1
			end
			error('bad \"other\" field')
		else
			return 0
		end
	end
end

function Controllers:fake_press(key,controller_id)
	if self.callbacks["pressed_any"] then
		if controller_id=="all" then controller_id = nil end
		self.callbacks["pressed_any"](key,controller_id)
	end
	controller_id = controller_id or "all"

	local type_,key_name,others = self:get_key(key)

	self.last_presstype = self.presstype[type_]
	self.last_controllertype = self.controllertype[type_]

	for player_name,player_buttons in pairs(self.controls_bind) do
		if controller_id == "all" or (not self.players[player_name])or (not self.players[player_name].joystick) or self.players[player_name].joystick:getID() == controller_id then
			for button,button_info in pairs(player_buttons) do
				for bind_id,bind in ipairs(button_info) do
					if bind == key then
						self.buttons_down[player_name][button].pressed = self.buttons_down[player_name][button].pressed + 1
						if self.callbacks.pressed then
							self.callbacks.pressed(button,player_name)
						end
					end
				end
			end
		end
	end
end

function Controllers:fake_release(key,controller_id)
	if self.callbacks["released_any"] then
		if controller_id=="all" then controller_id = nil end
		self.callbacks["released_any"](key,controller_id)
	end
	controller_id = controller_id or "all"

	for player_name,player_buttons in pairs(self.controls_bind) do
		if controller_id == "all" or (not self.players[player_name])or (not self.players[player_name].joystick) or self.players[player_name].joystick:getID() == controller_id then
			for button,button_info in pairs(player_buttons) do
				for bind_id,bind in ipairs(button_info) do
					if bind == key then
						self.buttons_down[player_name][button].released = self.buttons_down[player_name][button].released + 1
						if self.callbacks.released then
							self.callbacks.released(button,player_name)
						end
					end
				end
			end
		end
	end
end

return Controllers
