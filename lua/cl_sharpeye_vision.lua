////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Vision                                     //
////////////////////////////////////////////////
local sharpeye = sharpeye

function sharpeye:IsCrosshairEnabled()
	return self:GetVar("core_crosshair") > 0
end

function sharpeye:IsOverlayEnabled()
	return self:GetVar("core_overlay") > 0
end

function sharpeye:HudSmooth( fCurrent, fTarget, fSmooth )
	return fCurrent + (fTarget - fCurrent) * math.Clamp( fSmooth * FrameTime() * 25 , 0 , 1 )
end

function sharpeye:SetDrawColorFromVar( sVar )
	return surface.SetDrawColor(
		self:GetVarColorVariadic( sVar )
	)
end

function sharpeye:GetCrosshairStaticSize()
	return self:GetVar("xhair_staticsize") / 8 * 48
end

function sharpeye:GetCrosshairDynamicSize()
	return self:GetVar("xhair_dynamicsize") / 8.0 * 4
end

function sharpeye:GetCrosshairShadowSize()
	return self:GetVar("xhair_shadowsize") / 8.0 * 8
end

function sharpeye:GetCrosshairFocusSize()
	return self:GetVar("xhair_focussize") / 8.0 * 4
end

function sharpeye:GetCrosshairFocusShadowSize()
	return self:GetVar("xhair_focusshadowsize") / 8.0 * 4
end

function sharpeye:GetCrosshairFocusSpin()
	return self:GetVar("xhair_focusspin") / 4.0 * 0.1
end

function sharpeye:GetCrosshairFocusAngle()
	return self:GetVar("xhair_focusangle") * 11.25
end

function sharpeye.HUDShouldDraw( sName )
	if not sharpeye:IsEnabled() then return end
	if sharpeye:IsCrosshairEnabled() and sName == "CHudCrosshair" then
		return false
	end
	
end

function sharpeye.HUDPaint()
	local self = sharpeye
	
	if not self:IsEnabled() then return end
	
	if self:IsCrosshairEnabled() then
		if not self.dat.crosshair then
			self.dat.crosshair = {}
			self.dat.crosshair.ch_x = ScrW() * 0.5
			self.dat.crosshair.ch_y = ScrH() * 0.5
			
			self.dat.crosshair.tg_x = ScrW() * 0.5
			self.dat.crosshair.tg_y = ScrH() * 0.5
			
			self.dat.crosshair.dbv_x = ScrW() * 0.5
			self.dat.crosshair.dbv_y = ScrH() * 0.5
			
			self.dat.crosshair.tdbv_x = ScrW() * 0.5
			self.dat.crosshair.tdbv_y = ScrH() * 0.5
			
			self.dat.crosshair.dist = -1
			self.dat.crosshair.tdist = -1
			
			self.dat.crosshair.speed = 0.5
			--self.dat.crosshair.focus = 0.1
			
			--self.dat.crosshair.staticsize = 48
			--self.dat.crosshair.dynamicsize = 48 * 0.07 * 1.2
			
			self.dat.crosshair.shape = {}
			for k,matPath in pairs(self.dat.crosshairshapes) do
				self.dat.crosshair.shape[k] = surface.GetTextureID( matPath )
			end
			
		end
		
		-- Smooth before calculating.
		self.dat.crosshair.ch_x = self:HudSmooth(self.dat.crosshair.ch_x, self.dat.crosshair.tg_x, self.dat.crosshair.speed)
		self.dat.crosshair.ch_y = self:HudSmooth(self.dat.crosshair.ch_y, self.dat.crosshair.tg_y, self.dat.crosshair.speed)
		
		self.dat.crosshair.dbv_x = self:HudSmooth(self.dat.crosshair.dbv_x, self.dat.crosshair.tdbv_x, self.dat.crosshair.speed)
		self.dat.crosshair.dbv_y = self:HudSmooth(self.dat.crosshair.dbv_y, self.dat.crosshair.tdbv_y, self.dat.crosshair.speed)
		
		self.dat.crosshair.dist = self:HudSmooth(self.dat.crosshair.dist, self.dat.crosshair.tdist, self.dat.crosshair.speed)
		
		-- Displaying
		local staticSize  = self:GetCrosshairStaticSize()
		local dynamicSize = self:GetCrosshairDynamicSize()
		local shadowSize  = self:GetCrosshairShadowSize()
		local focusSize   = self:GetCrosshairFocusSize()
		local focusShadowSize   = self:GetCrosshairFocusShadowSize()
		
		
		if staticSize > 0 then
			self:SetDrawColorFromVar( "xhair_color" )
			surface.SetTexture(self.dat.crosshair.shape[1])
			surface.DrawTexturedRectRotated(ScrW() * 0.5, ScrH() * 0.5, staticSize, staticSize, 0)
		end

		local hasDynamic = (dynamicSize > 0)
		local hasFocus   = (focusSize > 0)
		local focusSpin = hasFocus and (((self.dat.crosshair.dist > 192) and (self.dat.crosshair.dist - 192) or 0) * self:GetCrosshairFocusSpin() + self:GetCrosshairFocusAngle()) or 0
		if not self:IsInVehicle() and LocalPlayer():Alive() and (hasDynamic or hasFocus) then
			local rdist = (1024 - math.Clamp( self.dat.crosshair.dist, 192, 512 )) * 0.015
			local speSpell = self.dat.crosshair.dist < 0 and (1 + self.dat.crosshair.dist) or 1
			rdist = rdist * speSpell
			local drawFocus = hasFocus and (rdist > 0)
			
			self:SetDrawColorFromVar( "xhair_shadcolor" )
			if hasDynamic then
				surface.SetTexture(self.dat.crosshair.shape[3])
				surface.DrawTexturedRectRotated(self.dat.crosshair.ch_x, self.dat.crosshair.ch_y, shadowSize, shadowSize, 0)
			end
			
			if drawFocus then
				surface.SetTexture(self.dat.crosshair.shape[5])
				surface.DrawTexturedRectRotated(self.dat.crosshair.dbv_x, self.dat.crosshair.dbv_y, focusShadowSize*rdist, focusShadowSize*rdist, focusSpin)
			end
			
			self:SetDrawColorFromVar( "xhair_color" )
			if hasDynamic then
				surface.SetTexture(self.dat.crosshair.shape[2])
				surface.DrawTexturedRectRotated(self.dat.crosshair.ch_x, self.dat.crosshair.ch_y, dynamicSize, dynamicSize, 0)
			end
			
			if drawFocus then
				surface.SetTexture(self.dat.crosshair.shape[4])
				surface.DrawTexturedRectRotated(self.dat.crosshair.dbv_x, self.dat.crosshair.dbv_y, focusSize*rdist, focusSize*rdist, focusSpin)
			end
			
		end
		
		-- Calculating
		self.dat.crosshair.traceLineData = utilx.GetPlayerTrace( LocalPlayer(), vgui.IsHoveringWorld() and LocalPlayer():GetCursorAimVector() or LocalPlayer():GetAimVector() )
		
		self.dat.crosshair.traceLineData.mask = nil
		self.dat.crosshair.traceLineRes = util.TraceLine( self.dat.crosshair.traceLineData )
		
		self.dat.crosshair.scrpos = self.dat.crosshair.traceLineRes.HitPos:ToScreen()
		self.dat.crosshair.tg_x = math.Clamp( self.dat.crosshair.scrpos.x, -ScrW() * 4, ScrW() * 4)
		self.dat.crosshair.tg_y = math.Clamp( self.dat.crosshair.scrpos.y, -ScrH() * 4, ScrH() * 4)
		
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
			
			
					
			self.dat.crosshair.midpos = dbvorigin + (self.dat.crosshair.traceLineRes.HitPos - dbvorigin) * 0.8
			
			self.dat.crosshair.scrpos = self.dat.crosshair.midpos:ToScreen()
			self.dat.crosshair.tdbv_x = self.dat.crosshair.scrpos.x
			self.dat.crosshair.tdbv_y = self.dat.crosshair.scrpos.y
			self.dat.crosshair.tdist = sharpeye_focus:IsApproach() and -1 or self.dat.crosshair.traceLineRes.Fraction * 16384
		
		end
	
	end

end

function sharpeye.RenderScreenspaceEffects()
	if not sharpeye:IsEnabled() then return end
	if not sharpeye:IsOverlayEnabled() or not GAMEMODE:PostProcessPermitted( "material overlay" ) then return end

	DrawMaterialOverlay( sharpeye.dat.main_overlay, 0);
			
end

