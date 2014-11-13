--[[
Copyright (c) 2014 Martin Felis <martin@fysx.org>
https://bitbucket.org/MartinFelis/loveplot/src

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
--]]

local loveplot = {}
loveplot._URL = 'https://bitbucket.org/MartinFelis/loveplot'

function loveplot.new(count)
	local plot = {
		background_color = { 64, 64, 64, 128 },
		border_color = { 200, 200, 200, 255 },

		count = count,
		range_switch_damping = 0.1,  -- used for automatic zooming, takes values in the range of [0.,1.]

		current_index = 1,
		values = {},

		prev_y_range = {-1., 1.},
		line_points = {},
	}

	for i=1,count do 
		table.insert (plot.values, 0.)
	end

	function plot:nextValue (value)
		self.values[self.current_index] = value
		self.current_index = (self.current_index) % self.count + 1
	end

	function plot:setValueLimits (min, max)
		self.prev_y_range = {min, max}
		self.y_limits = {min, max}
	end

	function plot:draw (x, y, width, height) 
		love.graphics.setColor (unpack(self.background_color))
		love.graphics.rectangle ("fill", x, y, width, height)

		local function plot_stencil () 
			love.graphics.rectangle("fill", x, y, width, height)
		end
		
		love.graphics.setStencil (plot_stencil)

		local x0 = x
		local x1 = x + width
		local dx = width / (self.count - 1)
		local y0 = y
		local y1 = y + height

		local y_min = self.values[1]
		local y_max = self.values[1]
		local y_range = y_max - y_min

		if self.y_limits then
			y_min = self.y_limits[1]
			y_max = self.y_limits[2]
			y_range = y_max - y_min
		else
			for i=1,self.count do
				y_min = math.min(y_min, self.values[i])
				y_max = math.max(y_max, self.values[i])
			end

			y_range = y_max - y_min
			y_min = y_min - 0.1 * y_range
			y_max = y_max + 0.1 * y_range
			y_range = y_max - y_min
		end

		if self.range_switch_damping ~= 0. then
			y_min = self.range_switch_damping * y_min + (1. - self.range_switch_damping) * self.prev_y_range[1]
			y_max = self.range_switch_damping * y_max + (1. - self.range_switch_damping) * self.prev_y_range[2]
			y_range = y_max - y_min
			self.prev_y_range = {y_min, y_max}
		end

		love.graphics.setColor (255, 0, 0, 255)
		for i=1,self.count do
			local index_0 = (self.current_index + self.count + i - 2) % self.count + 1
			local index_1 = (index_0) % self.count + 1

			self.line_points[2 * i + 1] = x0 + (i - 1) * dx
			self.line_points[2 * i + 2] = y1 - height * ((self.values[index_0] - y_min) / y_range )
		end
		love.graphics.setLineStyle("rough")
		love.graphics.line (unpack(self.line_points))

		love.graphics.setColor (255, 255, 255, 255)
		local font = love.graphics.getFont()
		local min_str = string.format ("%3.2f", y_min)
		local max_str = string.format ("%3.2f", y_max)

		-- print smaller values and add a k to the bound string
		if math.abs (y_min) > 1000 then
			min_str = string.format ("%3.2fk", y_min / 1000.)
		end
		if math.abs (y_max) > 1000 then
			max_str = string.format ("%3.2fk", y_max / 1000.)
		end
		local min_width = font:getWidth (min_str)
		local max_width = font:getWidth (max_str)
		local font_height = font:getHeight()

		love.graphics.print (max_str, x0 + width * 0.01, y0)
		love.graphics.print (min_str, x0 + width * 0.01, y1 - font_height)

		if self.title then
			local title_width = font:getWidth (self.title)
			love.graphics.print (self.title, x0 + width * 0.5 - title_width * 0.5, y0)
		end

		love.graphics.setStencil ()

		love.graphics.setColor (unpack(self.border_color))
		love.graphics.rectangle ("line", x, y, width, height)
	end

	return plot
end

return loveplot
