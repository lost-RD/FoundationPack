# LOVE plot - a simple plotting snippet

This is a simple plotting snippet that allows to plot values as graphs in
LÖVE.

Note: it clears the current stencil and also adjusts the current color.

# Usage

    myplot = newPlot (100)  --create plot which holds 100 values
		myplot.title            --set the title

		myplot:nextValue (dt)   --set the next value
		myplot:draw (x,y,w,h)   --draw the plot at specified position and size

# Example

     newPlot = require "loveplot"
     
     local myplot = newPlot (100)
     myplot.title = "FunkyRandomTitle"
     
     -- to use fixed range:
     --myplot:setValueLimits (-1.2, 1.2)
     
     function love.load()
     	math.randomseed (0)
     	for i=1,myplot.count do
     		myplot:nextValue (i)
     	end
     end
     
     function love.draw()
     	myplot:draw (10, 10, 300, 200)
     end
     
     local current = 0.
     
     function love.update(dt)
     	current = current + dt
     	if current < 3 then
     		myplot:nextValue (math.sin(current * 10.))
     	else
     		myplot:nextValue (math.sin(current * 10.) * 10.)
     	end
     end

# License

Some opensource license I guess zlib. See header of loveplot.lua for
details.
