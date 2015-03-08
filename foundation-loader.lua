-- Module Loader for LOVE2D game development framework
-- Developed by lost_RD for FoundationPack

--[[

The MIT License (MIT)

Copyright (c) 2014 lost_RD

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

function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

function loadModules(dir, level)
	print("[foundation-loader] modules directory = "..dir..", level = "..level)
	local modules = love.filesystem.getDirectoryItems(dir)

	for i, file in pairs(modules) do
		--print(i,file)
	end

	for iter,file in pairs(modules) do
		filename = file:split(".")
		name, ext = unpack(filename)
		if ext == "lua" then
			_G[name] = require(dir..'.'..name)
			print(name)
			print(" -"..assert(loadstring('return '..name..'._URL or '..name..'.__URL')()).."") --> URL
		else
			if love.filesystem.isDirectory(dir.."/"..file) then
				if not ((file == "inactive") or (level > 0)) then
					print("[foundation-loader] loading modules from folder: "..file)
					loadModules("modules/"..file, level+1)
				else
				    --do
				end
			else
				if level == 0 then
					print("[foundation-loader] "..file.." is not a valid module")
				end
			end
		end
	end
end

function loadChunks(dir)
	local files = love.filesystem.getDirectoryItems(dir)
	chunks = {}
	for iter,file in pairs(files) do
		print("callbacks: "..file.." found")
	end
	for iter,file in pairs(files) do
		filename = file:split(".")
		name, ext = unpack(filename)
		if ext == "lua" then
			print("callbacks: loading "..name.." callback...")
			--assert(loadstring('chunks.'..name..' = assert(loadfile("'..dir..'/'..file..'")())')())
			_G["foundation"][name] = assert(loadfile(dir.."/"..file), "callbacks: failed to load "..file)
			print("callbacks: "..name.." callback loaded")
		else
			if love.filesystem.isDirectory(file) then
				print("callbacks: "..file.." is a directory")
			else
				print("callbacks: "..file.." is not a lua file")
			end
		end
	end
	return chunks
end

print("--- Loading modules ---")
loadModules("modules", 0)
print("--- Modules loaded ---")
print("--- Loading callbacks ---")
foundation = {}
loadChunks("callbacks")
print("--- Callbacks loaded ---")