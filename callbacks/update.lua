dt = love.timer.getDelta( )

coil.update(dt)
flux.update(dt)
FPSplot.update(foundation.showFPSplot, 1/dt)

if Controllers.isPressed('lurker_update') then
	updateProfiler:endCycle()
	print("Lurker is scanning for modified files")
	lurker.scan()
	print("Scan completed")
	updateProfiler:startCycle()
end