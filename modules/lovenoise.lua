-- ... shameless library info copy from kikito :P
local lovenoise = {
	_VERSION     = 'v0.2.0',
    _DESCRIPTION = 'Noise Library for LOVE',
    _URL         = 'https://github.com/icrawler/lovenoise',
    _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2014 Phoenix Enero

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- local references
local MAXVAL = 2 ^ 16
local random = love.math.random
local max = math.max
local min = math.min

return_modules = function()

    -- CONSTANTS
    local MAXVAL = 2 ^ 16

    -- LOCAL REFERENCES
    local random = love.math.random
    local max = math.max
    local min = math.min

    -- Require needed fails
    local class = require('modules.middleclass')
    local return_presets = function()

        -- local references
        local lnoise = love.math.noise -- Can be modified for other frameworks
        local abs = function(a) return a < 0 and -a or a end
        local max = math.max
        local min = math.min

        -- util functions
        local function clamp01(v)
            return (v > 1 and 1 or v) < 0 and 0 or v
        end

        -- [[ Fractal Noise ]] --

        -- 1D
        local function fractal1(x, n, a, f)
            if n == 1 then return lnoise(x)*2-1 end
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                val = val + (lnoise(x*cf)*2-1)*ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v
        end

        -- 2D
        local function fractal2(x, y, n, a, f)
            if n == 1 then return lnoise(x, y)*2-1 end
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                val = val + (lnoise(x*cf, y*cf)*2-1)*ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v
        end

        -- 3D
        local function fractal3(x, y, z, n, a, f)
            if n == 1 then return lnoise(x, y, z)*2-1 end
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                val = val + (lnoise(x*cf, y*cf, z*cf)*2-1)*ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v
        end

        -- 4D
        local function fractal4(x, y, z, w, n, a, f)
            if n == 1 then return lnoise(x, y, z, w)*2-1 end
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                val = val + (lnoise(x*cf, y*cf, z*cf, w*cf)*2-1)*ca
                v = v + ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v
        end

        -- Main function
        local function fractal(pos, seed, frequency, n, a, f)
            local l = #pos
            local s = frequency
            if l == 1 then
                return
                fractal1(pos[1]*s+seed, n, a, f)
            elseif l == 2 then
                return
                fractal2(pos[1]*s+seed, pos[2]*s-seed, n, a, f)
            elseif l == 3 then
                return
                fractal3(pos[1]*s+seed, pos[2]*s-seed, pos[3]*s+seed, n, a, f)
            elseif l == 4 then
                return
                fractal4(pos[1]*s-seed, pos[2]*s+seed, pos[3]*s-seed, pos[4]*s+seed, n, a, f)
            end
            return nil
        end

        -- simplex noise
        local function simplex(pos, seed, frequency)
            local l = #pos
            local s = frequency
            if l == 1 then
                return
                lnoise(pos[1]*s+seed)*2-1
            elseif l == 2 then
                return
                lnoise(pos[1]*s+seed, pos[2]*s-seed)*2-1
            elseif l == 3 then
                return
                lnoise(pos[1]*s+seed, pos[2]*s-seed, pos[3]*s+seed)*2-1
            elseif l == 4 then
                return
                lnoise(pos[1]*s-seed, pos[2]*s+seed, pos[3]*s-seed, pos[4]*s+seed)*2-1
            end
        end

        -- ridged multifractal noise
        local function ridged1(x, n, a, f)
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                local s = (1-abs(lnoise(x*cf)*2-1))
                val = val + s*s*ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v*2-1
        end

        local function ridged2(x, y, n, a, f)
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                local s = (1-abs(lnoise(x*cf, y*cf)*2-1))
                val = val + s*s*ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v*2-1
        end

        local function ridged3(x, y, z, n, a, f)
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                local s = (1-abs(lnoise(x*cf, y*cf, z*cf)*2-1))
                val = val + s*s*ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v*2-1
        end

        local function ridged4(x, y, z, w, n, a, f)
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                local s = (1-abs(lnoise(x*cf, y*cf, z*cf, w*cf)*2-1))
                val = val + s*s*ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v*2-1
        end

        local function ridgedMulti(pos, seed, frequency, n, a, f)
            local l = #pos
            local s = frequency
            if l == 1 then
                return
                ridged1(pos[1]*s+seed, n, a, f)
            elseif l == 2 then
                return
                ridged2(pos[1]*s+seed, pos[2]*s-seed, n, a, f)
            elseif l == 3 then
                return
                ridged3(pos[1]*s+seed, pos[2]*s-seed, pos[3]*s+seed, n, a, f)
            elseif l == 4 then
                return
                ridged4(pos[1]*s-seed, pos[2]*s+seed, pos[3]*s-seed, pos[4]*s+seed, n, a, f)
            end
            return nil
        end

        -- billow noise
        local function billow1(x, n, a, f)
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                local s = abs(lnoise(x*cf)*2-1)
                val = val + s*ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v*2-1
        end

        local function billow2(x, y, n, a, f)
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                local s = abs(lnoise(x*cf, y*cf)*2-1)
                val = val + s*ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v*2-1
        end

        local function billow3(x, y, z, n, a, f)
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                local s = abs(lnoise(x*cf, y*cf, z*cf)*2-1)
                val = val + s*ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v*2-1
        end

        local function billow4(x, y, z, w, n, a, f)
            local ca = 1
            local cf = 1
            local val = 0
            local v = 0
            for _=1, n do
                local s = abs(lnoise(x*cf, y*cf, z*cf, w*cf)*2-1)
                val = val + s*ca
                v = v + ca
                ca = ca * a
                cf = cf * f
            end
            return val/v*2-1
        end

        local function billow(pos, seed, frequency, n, a, f)
            local l = #pos
            local s = frequency
            if l == 1 then
                return
                billow1(pos[1]*s+seed, n, a, f)
            elseif l == 2 then
                return
                billow2(pos[1]*s+seed, pos[2]*s-seed, n, a, f)
            elseif l == 3 then
                return
                billow3(pos[1]*s+seed, pos[2]*s-seed, pos[3]*s+seed, n, a, f)
            elseif l == 4 then
                return
                billow4(pos[1]*s-seed, pos[2]*s+seed, pos[3]*s-seed, pos[4]*s+seed, n, a, f)
            end
            return nil
        end

        return {fractal = fractal, simplex = simplex, ridgedMulti = ridgedMulti,
                billow = billow}

    end

    presets = return_presets()

    -- [[ Module Abstract Class ]] --

    local Module = class('LoveNoise.Module')

    function Module:initialize() self.sources = nil end

    -- Adds a source module at an index. Indices are one-based
    function Module:addSource(index, source)
        if not self.sources then self.sources={} end
        self.sources[index] = source
    end

    function Module:getValue(...)
        return -1
    end

    -- [[ end ]] --

    -- [[ NoiseModule superclass ]]--

    local NoiseModule = class("LoveNoise.NoiseModule")

        -- Initializes a module
        function NoiseModule:initialize(seed, frequency)
            self.seed = seed or 42
            self.frequency = frequency or 1
        end

        -- Sets the seed for the module
        function NoiseModule:setSeed(seed)
            self.seed=seed
            return self
        end

        -- Sets the frequency for the module
        function NoiseModule:setFrequency(frequency)
            self.frequency=frequency
            return self
        end

        -- Gets the value of a coherent-noise function at a certain position
        function NoiseModule:getValue(...)
            return -1
        end

    -- [[ end ]] --

    -- [[ Fractal Noise Module ]] --
    -- Inherits from NoiseModule

    local Fractal = class('LoveNoise.Generator.Fractal', NoiseModule)

        -- Initializes a Fractal module
        -- Args:
        --  * octaves - number of octaves or levels of detail
        --  * lacunarity - how quickly the frequencies increases for each octave
        --  * persistence - how quickly the amplitudes diminish for each octave
        --  * seed - a value that changes the output of a noise function
        function Fractal:initialize( octaves,
                                     lacunarity,
                                     persistence,
                                     seed,
                                     frequency )
            NoiseModule.initialize(self, seed, frequency)
            self.octaves = octaves or 1
            self.lacunarity = lacunarity or 2
            self.persistence = persistence or 0.5

        end

        -- Sets the number of octaves
        function Fractal:setOctaves(octaves)
            self.octaves=octaves or 1
            return self
        end

        -- Sets the lacunarity value
        function Fractal:setLacunarity(lacunarity)
            self.lacunarity=lacunarity
            return self
        end

        -- Sets the persistence value
        function Fractal:setPersistence(persistence)
            self.persistence=persistence
            return self
        end

        function Fractal:getValue(...)
            return presets.fractal( {...},
                                    self.seed,
                                    self.frequency,
                                    self.octaves,
                                    self.persistence,
                                    self.lacunarity )
        end

    -- [[ end ]] --

    -- [[ Ridged-Multifractal Noise Module ]] --
    -- Inherits from Fractal

    local RidgedMulti = class('LoveNoise.Generator.RidgedMulti', Fractal)

        function RidgedMulti:getValue(...)
            return presets.ridgedMulti( {...},
                                        self.seed,
                                        self.frequency,
                                        self.octaves,
                                        self.persistence,
                                        self.lacunarity )
        end

    -- [[ end ]] --

    -- [[ Billow Noise Module ]] --
    -- Inherits from Fractal

    local Billow = class('LoveNoise.Generator.Billow', Fractal)

        function Billow:getValue(...)
            return presets.billow( {...},
                                   self.seed,
                                   self.frequency,
                                   self.octaves,
                                   self.persistence,
                                   self.lacunarity )
        end

    -- [[ Simplex Noise Module (internal implemntation) ]] --
    -- inherits from NoiseModule

    local Simplex = class('LoveNoise.Generator.Simplex', NoiseModule)

        function Simplex:getValue(...)
            return presets.simplex( {...},
                                    self.seed,
                                    self.frequency)
        end

    -- [[ end ]] --

    -- [[ Add Module ]] --
    -- Inherits from Module

    local Add = class('LoveNoise.Combiner.Add', Module)

    -- Initializes an Add module with sources source1 and source2
    function Add:initialize(source1, source2)
        self.sources = {source1, source2}
    end

    -- Gets the combined value of the two sources
    function Add:getValue(...)
        return self.sources[1]:getValue(...) + self.sources[2]:getValue(...)
    end

    -- [[ end ]] --

    -- [[ Max Module ]] --
    -- Inherits from Module

    local Max = class('LoveNoise.Combiner.Max', Module)

    -- Initializes a Max module with sources source1 and source2
    function Max:initialize(source1, source2)
        self.sources = {source1, source2}
    end

    -- Gets the maximum value of the two sources
    function Max:getValue(...)
        return max(self.sources[1]:getValue(...), self.sources[2]:getValue(...))
    end

    -- [[ end ]] --

    -- [[ Min Module ]] --
    -- Inherits from Module

    local Min = class('LoveNoise.Combiner.Min', Module)

    -- Initializes a Min module with sources source1 and source2
    function Min:initialize(source1, source2)
        self.sources = {source1, source2}
    end

    -- Gets the minimum value of the two sources
    function Min:getValue(...)
        return min(self.sources[1]:getValue(...), self.sources[2]:getValue(...))
    end

    -- [[ end ]] --

    -- [[ Multiply Module ]] --
    -- Inherits from Module

    local Multiply = class('LoveNoise.Combiner.Multiply', Module)

    -- Initializes a Multiply module with sources source1 and source2
    function Multiply:initialize(source1, source2)
        self.sources = {source1, source2}
    end

    -- Gets the multiplied value of the two sources
    function Multiply:getValue(...)
        return self.sources[1]:getValue(...) * self.sources[2]:getValue(...)
    end

    -- [[ end ]] --

    -- [[ Power Module ]] --
    -- Inherits from Module

    local Power = class('LoveNoise.Combiner.Power', Module)

    -- Initializes a Power module with sources source1 and source2
    function Power:initialize(source1, source2)
        self.sources = {source1, source2}
    end

    -- Gets the value of the first source raised by the value of the second source
    function Power:getValue(...)
        return self.sources[1]:getValue(...) ^ self.sources[2]:getValue(...)
    end

    -- [[ end ]] --


    -- [[ Invert Module ]] --
    -- Inherits from Module

    local Invert = class('LoveNoise.Modifier.Invert', Module)

    -- Initializes a Power module with sources source1 and source2
    function Invert:initialize(source)
        self.sources = {source1}
    end

    -- Gets the value of the source inverted
    function Invert:getValue(...)
        return -self.sources[1]:getValue(...)
    end



    -- Return a table containing all modules
    return {
                -- Generator Modules
                Fractal=Fractal,
                RidgedMulti=RidgedMulti,
                Simplex=Simplex,
                Billow=Billow,

                -- Combiner Modules
                Add=Add,
                Max=Max,
                Min=Min,
                Multiply=Multiply,
                Power=Power,

                -- Modifier Modules
                Invert=Invert
            }

end

lovenoise.modules = return_modules()

-- Returns the maximum number of octaves for a given
-- persistence and amount of detail
function lovenoise.findOctaveLimit(persistence, aod)
    if a >= 1 then return -1 end
    return math.ceil(math.log(1/d)/math.log(a))
end

-- end--
return lovenoise