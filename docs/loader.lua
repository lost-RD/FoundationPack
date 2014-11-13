local loader = require 'love-loader'

local images = {}
local sounds = {}

local finishedLoading = false

function love.load()
  loader.newImage(  images, 'rabbit', 'path/to/rabbit.png')
  loader.newSource( sounds, 'iiiik',  'path/to/iiik.ogg')
  loader.newSource( sounds, 'music',  'path/to/music.ogg', 'stream')

  loader.start(function()
    finishedLoading = true
  end)
end

function love.update(dt)
  if not finishedLoading then
    loader.update() -- You must do this on each iteration until all resources are loaded
  end
end

function love.draw()
  if finishedLoading then
    -- media contains the images and sounds. You can use them here safely now.
    love.graphics.draw(images.rabbit, 100, 200)
  else -- not finishedLoading
    local percent = 0
    if loader.resourceCount ~= 0 then percent = loader.loadedCount / loader.resourceCount end
    love.graphics.print(("Loading .. %d%%"):format(percent*100), 100, 100)
  end
end