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

function sharpeye.GetCrosshairShadowSize()
	return (sharpeye.GetVarNumber("sharpeye_xhair_shadowsize") / 8.0) * 8
end

function sharpeye.GetCrosshairFocusSize()
	return (sharpeye.GetVarNumber("sharpeye_xhair_focussize") / 8.0) * 4
end

function sharpeye.GetCrosshairFocusShadowSize()
	return (sharpeye.GetVarNumber("sharpeye_xhair_focusshadowsize") / 8.0) * 4
end

function sharpeye.GetCrosshairFocusSpin()
	return (sharpeye.GetVarNumber("sharpeye_xhair_focusspin") / 4.0) * 0.1
end

function sharpeye.GetCrosshairFocusAngle()
	return sharpeye.GetVarNumber("sharpeye_xhair_focusangle") * 11.25
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
			
			sharpeye_dat.crosshair.dbv_x = ScrW() * 0.5
			sharpeye_dat.crosshair.dbv_y = ScrH() * 0.5
			
			sharpeye_dat.crosshair.tdbv_x = ScrW() * 0.5
			sharpeye_dat.crosshair.tdbv_y = ScrH() * 0.5
			
			sharpeye_dat.crosshair.dist = 0
			sharpeye_dat.crosshair.tdist = 0
			
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
		
		sharpeye_dat.crosshair.dbv_x = sharpeye.HudSmooth(sharpeye_dat.crosshair.dbv_x, sharpeye_dat.crosshair.tdbv_x, sharpeye_dat.crosshair.speed)
		sharpeye_dat.crosshair.dbv_y = sharpeye.HudSmooth(sharpeye_dat.crosshair.dbv_y, sharpeye_dat.crosshair.tdbv_y, sharpeye_dat.crosshair.speed)
		
		sharpeye_dat.crosshair.dist = sharpeye.HudSmooth(sharpeye_dat.crosshair.dist, sharpeye_dat.crosshair.tdist, sharpeye_dat.crosshair.speed)
		
		-- Displaying
		local staticSize  = sharpeye.GetCrosshairStaticSize()
		local dynamicSize = sharpeye.GetCrosshairDynamicSize()
		local shadowSize  = sharpeye.GetCrosshairShadowSize()
		local focusSize   = sharpeye.GetCrosshairFocusSize()
		local focusShadowSize   = sharpeye.GetCrosshairFocusShadowSize()
		
		if staticSize > 0 then
			sharpeye.SetDrawColorFromVar( "sharpeye_xhair_color" )
			surface.SetTexture(sharpeye_dat.crosshair.shape[1])
			surface.DrawTexturedRectRotated(ScrW() * 0.5, ScrH() * 0.5, staticSize, staticSize, 0)
		end

		local hasDynamic = (dynamicSize > 0)
		local hasFocus   = (focusSize > 0)
		local focusSpin = hasFocus and (sharpeye_dat.crosshair.dist * sharpeye.GetCrosshairFocusSpin() + sharpeye.GetCrosshairFocusAngle()) or 0
		if not sharpeye.IsInVehicle() and LocalPlayer():Alive() and (hasDynamic or hasFocus) then
			local rdist = (1024 - math.Clamp( sharpeye_dat.crosshair.dist, 192, 512 )) * 0.015
			local speSpell = sharpeye_dat.crosshair.dist < 0 and (1 + sharpeye_dat.crosshair.dist) or 1
			rdist = rdist * speSpell
			
			sharpeye.SetDrawColorFromVar( "sharpeye_xhair_shadcolor" )
			if hasDynamic then
				surface.SetTexture(sharpeye_dat.crosshair.shape[3])
				surface.DrawTexturedRectRotated(sharpeye_dat.crosshair.ch_x, sharpeye_dat.crosshair.ch_y, shadowSize, shadowSize, 0)
			end
			
			if hasFocus then
				surface.SetTexture(sharpeye_dat.crosshair.shape[5])
				surface.DrawTexturedRectRotated(sharpeye_dat.crosshair.dbv_x, sharpeye_dat.crosshair.dbv_y, focusShadowSize*rdist, focusShadowSize*rdist, focusSpin)
			end
			
			sharpeye.SetDrawColorFromVar( "sharpeye_xhair_color" )
			if hasDynamic then
				surface.SetTexture(sharpeye_dat.crosshair.shape[2])
				surface.DrawTexturedRectRotated(sharpeye_dat.crosshair.ch_x, sharpeye_dat.crosshair.ch_y, dynamicSize, dynamicSize, 0)
			end
			
			if hasFocus then
				surface.SetTexture(sharpeye_dat.crosshair.shape[4])
				surface.DrawTexturedRectRotated(sharpeye_dat.crosshair.dbv_x, sharpeye_dat.crosshair.dbv_y, focusSize*rdist, focusSize*rdist, focusSpin)
			end
			
		end
		
		-- Calculating
		sharpeye_dat.crosshair.traceLineData = utilx.GetPlayerTrace( LocalPlayer(), LocalPlayer():GetCursorAimVector() )
		
		
		sharpeye_dat.crosshair.traceLineData.mask = nil
		sharpeye_dat.crosshair.traceLineRes = util.TraceLine( sharpeye_dat.crosshair.traceLineData )
		
		sharpeye_dat.crosshair.scrpos = sharpeye_dat.crosshair.traceLineRes.HitPos:ToScreen()
		sharpeye_dat.crosshair.tg_x = sharpeye_dat.crosshair.scrpos.x
		sharpeye_dat.crosshair.tg_y = sharpeye_dat.crosshair.scrpos.y
		
		if sharpeye_focus:HasFocus() or sharpeye_focus:IsApproach() then
			local viewModel = LocalPlayer():GetViewModel()
			local dbvorigin
			if viewModel and LocalPlayer():GetActiveWeapon() ~= NULL then
				local attachmentID = viewModel:LookupAttachment("1")
				if attachmentID == 0 then attachmentID = viewModel:LookupAttachment("muzzle") end
				
				local attachData = viewModel:GetAttachment(attachmentID or 0)
				dbvorigin = attachData and attachData.Pos or nil
				
			end
			dbvorigin = dbvorigin or LocalPlayer():GetShootPos()
			
			
					
			sharpeye_dat.crosshair.midpos = dbvorigin + (sharpeye_dat.crosshair.traceLineRes.HitPos - dbvorigin) * 0.8
			
			sharpeye_dat.crosshair.scrpos = sharpeye_dat.crosshair.midpos:ToScreen()
			sharpeye_dat.crosshair.tdbv_x = sharpeye_dat.crosshair.scrpos.x
			sharpeye_dat.crosshair.tdbv_y = sharpeye_dat.crosshair.scrpos.y
			sharpeye_dat.crosshair.tdist = sharpeye_focus:IsApproach() and -1 or sharpeye_dat.crosshair.traceLineRes.Fraction * 16384
		
		end
	
	end

end
