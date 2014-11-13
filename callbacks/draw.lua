if foundation.showFPSplot then
    FPSplot:draw(250, 50, 300, 200)
end

textDebug:draw(250, 300)
textShowProfilers:draw(250, 350)	
textLurker:draw(250, 410)

if not foundation.showFPSplot or not foundation.showProfilers then
	textJKlol:draw(250,500)
end