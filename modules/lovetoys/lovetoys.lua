local lovetoys = {
  _URL         = 'https://github.com/lovetoys/lovetoys',
  _LICENSE     = [[The MIT License (MIT)

Copyright (c) 2013-2014 Arne Beer and Rafael Epplee

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]

}

-- Getting folder that contains engine
--local folderOfThisFile = (...):match("(.-)[^%/]+$")
local folderOfThisFile = "modules/lovetoys/"

-- Requiring class
lovetoys.class = require(folderOfThisFile .. "src/class")

lovetoys.events = {}

-- Requiring all Events
lovetoys.events.componentAdded = require(folderOfThisFile .. "src/events.componentAdded")
lovetoys.events.componentRemoved = require(folderOfThisFile .. "src/events.componentRemoved")

-- Requiring the lovetoys
lovetoys.entity = require(folderOfThisFile .. "src/entity")
lovetoys.engine = require(folderOfThisFile .. "src/engine")
lovetoys.system = require(folderOfThisFile .. "src/system")
lovetoys.eventManager = require(folderOfThisFile .. "src/eventManager")
lovetoys.component = require(folderOfThisFile .. "src/component")

print("[lovetoys] loaded")

return lovetoys