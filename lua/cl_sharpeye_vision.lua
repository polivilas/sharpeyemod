////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Vision                                     //
////////////////////////////////////////////////

function sharpeye.IsCrosshairEnabled()
	return (sharpeye.GetVarNumber("sharpeye_core_crosshair") > 0)
end

function sharpeye.HudSmooth( fCurrent, fTarget, fSmooth )
	return fCurrent + (fTarget - fCurrent) * math.Clamp( fSmooth * FrameTime() * 25 , 0 , 1 )
end

function sharpeye.SetDrawColorFromVar( sVar )
	return surface.SetDrawColor(
		sharpeye.GetVarNumber(sVar .. "_r"),
		sharpeye.GetVarNumber(sVar .. "_g"),
		sharpeye.GetVarNumber(sVar .. "_b"),
		sharpeye.GetVarNumber(sVar .. "_a")
	)
end

function sharpeye.GetCrosshairStaticSize()
	return (sharpeye.GetVarNumber("sharpeye_xhair_staticsize") / 8) * 48
end

function sharpeye.GetCrosshairDynamicSize()
	return (sharpeye.GetVarNumber("sharpeye_xhair_dynamicsize") / 8.0) * 4
end

function sharpeye.HUDPaint()
	if not sharpeye.IsEnabled() then return end
	
	if sharpeye.IsCrosshairEnabled() then
		if not sharpeye_dat.crosshair then
			sharpeye_dat.crosshair = {}
			sharpeye_dat.crosshair.ch_x = ScrW() * 0.5
			sharpeye_dat.crosshair.ch_y = ScrH() * 0.5
			
			sharpeye_dat.crosshair.tg_x = ScrW() * 0.5
			sharpeye_dat.crosshair.tg_y = ScrH() * 0.5
			
			sharpeye_dat.crosshair.speed = 0.5
			--sharpeye_dat.crosshair.focus = 0.1
			
			--sharpeye_dat.crosshair.staticsize = 48
			--sharpeye_dat.crosshair.dynamicsize = 48 * 0.07 * 1.2
			
			sharpeye_dat.crosshair.shape = {}
			for k,matPath in pairs(sharpeye_dat.crosshairshapes) do
				sharpeye_dat.crosshair.shape[k] = surface.GetTextureID( matPath )
			end
			
		end
		
		-- Smooth before calculating.
		sharpeye_dat.crosshair.ch_x = sharpeye.HudSmooth(sharpeye_dat.crosshair.ch_x, sharpeye_dat.crosshair.tg_x, sharpeye_dat.crosshair.speed)
		sharpeye_dat.crosshair.ch_y = sharpeye.HudSmooth(sharpeye_dat.crosshair.ch_y, sharpeye_dat.crosshair.tg_y, sharpeye_dat.crosshair.speed)
		
		-- Displaying
		local staticSize = sharpeye.GetCrosshairStaticSize()
		local dynamicSize = sharpeye.GetCrosshairDynamicSize()
		
		sharpeye.SetDrawColorFromVar( "sharpeye_xhair_color" )
		
		if staticSize > 0 then
			surface.SetTexture(sharpeye_dat.crosshair.shape[1])
			surface.DrawTexturedRectRotated(ScrW() * 0.5, ScrH() * 0.5, staticSize, staticSize, 0)
		end

		if not sharpeye.IsInVehicle() and LocalPlayer():Alive() and (dynamicSize > 0) then
			surface.SetTexture(sharpeye_dat.crosshair.shape[2])
			surface.DrawTexturedRectRotated(sharpeye_dat.crosshair.ch_x, sharpeye_dat.crosshair.ch_y, dynamicSize, dynamicSize, 0)
		end
		
		-- Calculating
		sharpeye_dat.crosshair.traceLineData = utilx.GetPlayerTrace( LocalPlayer(), LocalPlayer():GetCursorAimVector() )
		sharpeye_dat.crosshair.traceLineRes = util.TraceLine( sharpeye_dat.crosshair.traceLineData )
		
		sharpeye_dat.crosshair.scrpos = sharpeye_dat.crosshair.traceLineRes.HitPos:ToScreen()
		sharpeye_dat.crosshair.tg_x = sharpeye_dat.crosshair.scrpos.x
		sharpeye_dat.crosshair.tg_y = sharpeye_dat.crosshair.scrpos.y
	
	end

end
