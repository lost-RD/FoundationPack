-- babel
babel.init({ locale = "en-UK", locales_folders = { "resources/translations" } })

-- lurker
local lurker_scan_key = " "

-- controllers
Controllers.init({
    menu_up = {type="button", default={'kb_up','gpb_dpup','gpa_lefty_-'}},
    menu_down = {type="button", default={'kb_down','gpb_dpdown','gpa_lefty_+'}},
    menu_select = {type="button", default={'kb_return','gpb_a'}},
    menu_back = {type="button", default={'kb_escape','gpb_b'}},
    lurker_update = {type="button", default={'kb_'..lurker_scan_key}},
})
Controllers.setPlayer('player_1','keyboard',1)

-- loveplot
FPSplot = loveplot.new(100)
FPSplot.title = "Frames Per Second"
FPSplot.upperLimit = 30
FPSplot:setValueLimits(0,FPSplot.upperLimit)

function FPSplot.update(enabled, val)
	if enabled then
		FPSplot:nextValue(val)
		local max = FPSplot.upperLimit
		for key,val in pairs(FPSplot.values) do
			max = math.max(max,val)
		end
		FPSplot:setValueLimits(0,10*math.ceil(max/10))
	end
end

-- demo stuff
foundation.showFPSplot = true
foundation.showProfilers = true

textDebug = richtext.new{"Press SHIFT + F8 to show/hide the debug prompt", black = {255,255,255}}
textShowProfilers = richtext.new{[[Boolean toggle showFPSplot or showProfilers
in the debug prompt if you're looking for
something fun to do]], black = {255,255,255}}
textJKlol = richtext.new{"I lied, there's actually nothing fun to do here", black = {255,255,255}}
textLurker = richtext.new{"Press space to reload any files that \nhave been modified", black = {255,255,255}}

updateProfiler:hook(FPSplot, 'nextValue')