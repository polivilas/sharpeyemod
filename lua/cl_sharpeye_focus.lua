////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// ::Focus Extension Code                     //
////////////////////////////////////////////////
//
//  -- This code originates for the most of it from an external source.
//  It is a modification of an existing addon to work on SharpeYe.
//  Therefore, most of the code will actually look very similar to
//  the original work.
//
// Original author : Devenger, used with approval !
// Original addon  : Twitch Weaponry
//
////////////////////////////////////////////////

// ATTENTION PERSONNEL. sharpeye_focus USES METHODS.

function sharpeye.IsFocusEnabled()
	return (sharpeye.GetVarNumber("sharpeye_opt_focus") > 0)
end

function sharpeye.HookFocus()
	if sharpeye_dat.focus_hooked then return end
	hook.Add("CreateMove", "sharpeye_CreateMove", function(cmd) return sharpeye_focus:CreateMove(cmd) end)
	
	sharpeye_dat.focus_hooked = true
	
end

function sharpeye.UnhookFocus()
	if not sharpeye_dat.focus_hooked then return end
	hook.Remove("CreateMove", "sharpeye_CreateMove")
	
	sharpeye_dat.focus_hooked = false
	
end

///

function sharpeye_focus:ToggleFocus()
	if not self.__hasfocus then
		self:EnableFocus()
	else
		self:DisableFocus()
	end
	
end

function sharpeye_focus:EnableFocus()
	if self.__hasfocus then return end
	self.__hasfocus = true
	self.__raccor_x_quo = 0
	self.__bViewWasModified = true
	
end

function sharpeye_focus:DisableFocus()
	if not self.__hasfocus then return end
	self.__hasfocus = false
	self.__decotime = CurTime()
	
	if self.lockedViewAng then
		LocalPlayer():SetEyeAngles( self.lockedViewAng )
	end

end

function sharpeye_focus:HasFocus()
	return self.__hasfocus
	
end

function sharpeye_focus:SimilarizeAngles(ang1, ang2)
	if math.abs (ang1.y - ang2.y) > 180 then
		if ang1.y - ang2.y < 0 then
			ang1.y = ang1.y + 360
		else
			ang1.y = ang1.y - 360
		end
	end
end

//local VIEWMODEL_AIMPOS
//local VIEWMODEL_AIMANG
local VIEWMODEL_FLIP
//local VIEWMODEL_DEGREEOFZOOM
local VIEWMODEL_FOVTOSET
local VIEWMODEL_FOV
local VIEWMODEL_EDGEFOV
local VIEWMODEL_MOUSESENSITIVITY
local VIEWMODEL_ZOOMTIME
local VIEWMODEL_FCT_STATIONAIMON
--local FOV_DEFAULT

function sharpeye_focus:InitializeMessyVars()	
	VIEWMODEL_FOVTOSET     = GetConVarNumber("fov_desired") or 75
	VIEWMODEL_FOV          = VIEWMODEL_FOVTOSET + sharpeye.GetVar( "sharpeye_detail_focus_aimsim" ) * 3.0 -- Default is 5 so 15
	VIEWMODEL_MOUSESENSITIVITY = 1
	VIEWMODEL_ZOOMTIME    = 0.2
	
	-- Useful out of the whole
	VIEWMODEL_FLIP         = false
	
	self.allowedFromCentreX = sharpeye.GetVar( "sharpeye_detail_focus_anglex" )
	self.allowedFromCentreY = sharpeye.GetVar( "sharpeye_detail_focus_angley" )
	self.dispFromEdge       = sharpeye.GetVar( "sharpeye_detail_focus_backing" ) --Default is 5 so 5.
	self.handShiftX         = sharpeye.GetVar( "sharpeye_detail_focus_handshiftx" ) * 0.5 --Default is 5 so 2.5.
	self.smooth             = 1 - sharpeye.GetVar( "sharpeye_detail_focus_smoothing" ) * 0.9 --Default is 5 so 2.5.
end

// NOTE TO SELF : CLEANUP THIS SH--
function sharpeye_focus:EvaluateMessyVars()	
	/*VIEWMODEL_AIMPOS       = pl:GetActiveWeapon().ViewModelAimPos or Vector(0,0,0)
	VIEWMODEL_AIMANG       = nil
	VIEWMODEL_DEGREEOFZOOM = pl:GetActiveWeapon().DegreeOfZoom or 1
	VIEWMODEL_FOVTOSET     = pl:GetActiveWeapon().FOVToSet or GetConVarNumber("fov_desired") or 75
	VIEWMODEL_FOV          = pl:GetActiveWeapon().FOVToSet or 90
	VIEWMODEL_MOUSESENSITIVITY    = pl:GetActiveWeapon().MouseSensitivity or 1
	VIEWMODEL_ZOOMTIME    = 0.2*/
	
	//VIEWMODEL_AIMPOS       = pl:GetActiveWeapon().ViewModelAimPos or Vector(0,0,0)
	//VIEWMODEL_AIMANG       = nil
	//VIEWMODEL_DEGREEOFZOOM = pl:GetActiveWeapon().DegreeOfZoom or 0
	VIEWMODEL_FOVTOSET     = GetConVarNumber("fov_desired") or 75
	VIEWMODEL_FOV          = VIEWMODEL_FOVTOSET + sharpeye.GetVar( "sharpeye_detail_focus_aimsim" ) * 3.0 -- Default is 5 so 15
	VIEWMODEL_MOUSESENSITIVITY = 1
	VIEWMODEL_ZOOMTIME    = 0.4
	
	-- Useful out of the whole
	VIEWMODEL_FLIP         = LocalPlayer():GetActiveWeapon().ViewModelFlip or false
	//VIEWMODEL_FCT_STATIONAIMON    = true //GRD
	
	--FOV_DEFAULT = GetConVarNumber("fov_desired") or 75
	

	self.allowedFromCentreX = sharpeye.GetVar( "sharpeye_detail_focus_anglex" )
	self.allowedFromCentreY = sharpeye.GetVar( "sharpeye_detail_focus_angley" )
	self.dispFromEdge       = sharpeye.GetVar( "sharpeye_detail_focus_backing" ) --Default is 5 so 5.
	self.handShiftX         = sharpeye.GetVar( "sharpeye_detail_focus_handshiftx" ) * 0.5 --Default is 5 so 2.5.
	self.smooth             = 1 - (sharpeye.GetVar( "sharpeye_detail_focus_smoothing" ) * 0.1)*0.95 --Default is 5 so 2.5.
	
end

function sharpeye_focus:IsApproach()
	return (CurTime() - self.__decotime) < VIEWMODEL_ZOOMTIME
	
end

function sharpeye_focus:ApproachRatio()
	return 1 - (CurTime() - self.__decotime) / VIEWMODEL_ZOOMTIME
	
end

-- BlackOps' Legs addon compatibility test
function sharpeye_focus:GetBiaisViewAngles()
	if not sharpeye.IsEnabled()      then return nil end
	if not sharpeye.IsFocusEnabled() then return nil end
	if not self:HasFocus()       then return nil end
	
	return self.lockedViewAng or nil

end

function sharpeye_focus:AppendCalcView( view )
	if not sharpeye.IsFocusEnabled() then return end
	
	self:EvaluateMessyVars()
	if self:HasFocus() then

		self.__oriAngle.p = view.angles.p
		self.__oriAngle.y = view.angles.y
		self.__oriAngle.r = view.angles.r
		local angles = view.angles
		local usefulViewAng
		if self.lockedViewAng then
			self.computeViewAng = self.lockedViewAng - self.computeViewAng + angles
			usefulViewAng = self.computeViewAng
		else
			usefulViewAng = angles
			
		end
		view.angles = usefulViewAng
		
		local pl = LocalPlayer()
		
		self:SimilarizeAngles(angles, usefulViewAng)
		
		local fovratio = VIEWMODEL_FOVTOSET / VIEWMODEL_FOV
		angles = (angles * fovratio) + (usefulViewAng * (1 - fovratio))
		local diff_p = angles.p
		local diff_y = angles.y
		
		if VIEWMODEL_FLIP then
			angles.y = usefulViewAng.y + (usefulViewAng.y - angles.y)
		end
		if view.vm_angles then
			angles:RotateAroundAxis( angles:Right(), 	view.vm_angles.p - self.__oriAngle.p )
			angles:RotateAroundAxis( angles:Up(), 		view.vm_angles.y - self.__oriAngle.y ) 
			angles:RotateAroundAxis( angles:Forward(),  view.vm_angles.r - self.__oriAngle.r )
		end
		
		--if not self.__bViewWasModified and (CurTime() - self.__bViewWasModifiedTime) > self.__bViewWasModifiedDelay then
		if not self.__bViewWasModified then
			local ap,ay,ar = math.AngleDifference(angles.p, usefulViewAng.p), math.AngleDifference(angles.y, usefulViewAng.y), math.AngleDifference(angles.r, usefulViewAng.r)
			local dp,dy,dr = math.AngleDifference(self.__vm_angles_delta.p, ap), math.AngleDifference(self.__vm_angles_delta.y, ay), math.AngleDifference(self.__vm_angles_delta.r, ar)
		
			self.__vm_angles_delta.p = math.ApproachAngle( self.__vm_angles_delta.p, ap, dp*FrameTime()/0.03*self.smooth)
			self.__vm_angles_delta.y = math.ApproachAngle( self.__vm_angles_delta.y, ay, dy*FrameTime()/0.03*self.smooth)
			self.__vm_angles_delta.r = math.ApproachAngle( self.__vm_angles_delta.r, ar, dr*FrameTime()/0.03*self.smooth)
			
			self.__vm_angles.p = usefulViewAng.p + self.__vm_angles_delta.p
			self.__vm_angles.y = usefulViewAng.y + self.__vm_angles_delta.y
			self.__vm_angles.r = usefulViewAng.r + self.__vm_angles_delta.r
			
			/*self.__vm_angles.p = math.ApproachAngle( self.__vm_angles.p, angles.p, math.AngleDifference( self.__vm_angles.p, angles.p )*FrameTime()/0.03 )
			self.__vm_angles.y = math.ApproachAngle( self.__vm_angles.y, angles.y, math.AngleDifference( self.__vm_angles.y, angles.y )*FrameTime()/0.03 )
			self.__vm_angles.r = math.ApproachAngle( self.__vm_angles.r, angles.r, math.AngleDifference( self.__vm_angles.r, angles.r )*FrameTime()/0.03 )*/

		else		
			self.__bViewWasModified = false
			
			local ap,ay,ar = math.AngleDifference(angles.p, usefulViewAng.p), math.AngleDifference(angles.y, usefulViewAng.y), math.AngleDifference(angles.r, usefulViewAng.r)
		
			self.__vm_angles_delta.p = ap
			self.__vm_angles_delta.y = ay
			self.__vm_angles_delta.r = ar
			
			self.__vm_angles.p = angles.p
			self.__vm_angles.y = angles.y
			self.__vm_angles.r = angles.r
			
		end
		
		view.vm_angles.p = self.__vm_angles.p
		view.vm_angles.y = self.__vm_angles.y
		view.vm_angles.r = self.__vm_angles.r
		
		
		local pos = view.vm_origin or view.origin
		local Forward 	= angles:Forward()
		local Right 	= angles:Right()
		self.__raccor_x = (diff_y - usefulViewAng.y)/self.allowedFromCentreX
		self.__raccor_y = (diff_p - usefulViewAng.p)/self.allowedFromCentreY
		
		self.__diligent = math.Clamp(math.abs(self.__raccor_x) + math.abs(self.__raccor_y), 0, 1)
		
		self.__raccor_x_quo = self.__raccor_x_quo + (self.__raccor_x - self.__raccor_x_quo) * FrameTime()/0.03*self.smooth
		pos = pos - Forward * self.__diligent * self.dispFromEdge + Right * self.__raccor_x_quo * self.handShiftX * (VIEWMODEL_FLIP and -1 or 1)
		view.vm_origin = pos
		
		self.__y_ref = nil

	elseif self:IsApproach() then
		local ratio = self:ApproachRatio()
		local aratio = 1 - ratio
		
		if not self.__y_ref then
			self.__y_ref = view.vm_angles.y
		end
		local yAnglePatch = math.AngleDifference( self.__y_ref, view.vm_angles.y )
		self.__y_ref = view.vm_angles.y
		
		--if VIEWMODEL_FLIP then print("Flipped models unsupported") end
		if view.vm_angles then
			self.__vm_angles.y = self.__vm_angles.y - yAnglePatch
			
			--self.__vm_angles.p = math.ApproachAngle( self.__vm_angles.p, view.vm_angles.p, aratio*3 )
			--self.__vm_angles.y = math.ApproachAngle( self.__vm_angles.y, view.vm_angles.y, aratio*3 )
			--self.__vm_angles.r = math.ApproachAngle( self.__vm_angles.r, view.vm_angles.r, aratio*3 )
			--print(FrameTime())
			
			/*self.__vm_angles.p = math.ApproachAngle( self.__vm_angles.p, view.vm_angles.p, aratio*FrameTime()/0.03*7 )
			self.__vm_angles.y = math.ApproachAngle( self.__vm_angles.y, view.vm_angles.y, aratio*FrameTime()/0.03*7 )
			self.__vm_angles.r = math.ApproachAngle( self.__vm_angles.r, view.vm_angles.r, aratio*FrameTime()/0.03*7 )*/
			
			local ap,ay,ar = math.AngleDifference(view.vm_angles.p, self.__vm_angles.p), math.AngleDifference(view.vm_angles.y, self.__vm_angles.y), math.AngleDifference(view.vm_angles.r, self.__vm_angles.r)
			--local ap,ay,ar = math.AngleDifference(self.__vm_angles.p, view.vm_angles.p), math.AngleDifference(self.__vm_angles.y, view.vm_angles.y), math.AngleDifference(self.__vm_angles.r, view.vm_angles.r)
			local dp,dy,dr = math.AngleDifference(self.__vm_angles_delta.p, ap), math.AngleDifference(self.__vm_angles_delta.y, ay), math.AngleDifference(self.__vm_angles_delta.r, ar)
		
			self.__vm_angles_delta.p = math.ApproachAngle( self.__vm_angles_delta.p, ap, dp*FrameTime()/0.03*self.smooth)
			self.__vm_angles_delta.y = math.ApproachAngle( self.__vm_angles_delta.y, ay, dy*FrameTime()/0.03*self.smooth)
			self.__vm_angles_delta.r = math.ApproachAngle( self.__vm_angles_delta.r, ar, dr*FrameTime()/0.03*self.smooth)
			
			self.__vm_angles.p = view.vm_angles.p + self.__vm_angles_delta.p
			self.__vm_angles.y = view.vm_angles.y + self.__vm_angles_delta.y
			self.__vm_angles.r = view.vm_angles.r + self.__vm_angles_delta.r
			
			view.vm_angles.p = self.__vm_angles.p 
			view.vm_angles.y = self.__vm_angles.y
			view.vm_angles.r = self.__vm_angles.r
		end
		
		local pos = view.vm_origin or view.origin
		local Forward = view.vm_angles:Forward()
		local Right   = view.vm_angles:Right()
		view.vm_origin = pos - Forward * self.__diligent * self.dispFromEdge * ratio^2 + Right * self.__raccor_x_quo * self.handShiftX * (VIEWMODEL_FLIP and -1 or 1) * ratio^2
		
	end
	
end


local lastRealViewAng = false

function sharpeye_focus:CreateMove( cmd )
	self:EvaluateMessyVars()
	if self:HasFocus() then
		local pl = LocalPlayer()
	
		self.computeViewAng = cmd:GetViewAngles()
	
		--LocalPlayer():GetActiveWeapon():Thinkie()
		
		--LocalPlayer():AddTWRecoil(cmd)
		
		// Since this is always TRUE then remove the whole useless block
		//if VIEWMODEL_FCT_STATIONAIMON then
			if not self.lockedViewAng then
				self.lockedViewAng = cmd:GetViewAngles()
				self.lockedViewAngOffset = Angle (0,0,0)
			end
			self.__anglecompar.p = self.lockedViewAng.p
			self.__anglecompar.y = self.lockedViewAng.y
			self.__anglecompar.r = self.lockedViewAng.r
			
			--sensitivity
			local angles = cmd:GetViewAngles()
			if lastRealViewAng then
				self:SimilarizeAngles (lastRealViewAng, angles)
				local diff = angles - lastRealViewAng
				diff = diff * VIEWMODEL_MOUSESENSITIVITY
				angles = lastRealViewAng + diff
			end
			
			lastRealViewAng = angles
			
			--
			self:SimilarizeAngles (self.lockedViewAng, angles)
			local ydiff = (angles.y - self.lockedViewAng.y)
			if ydiff > self.allowedFromCentreX then
				self.lockedViewAng.y = angles.y - self.allowedFromCentreX
			elseif ydiff < -self.allowedFromCentreX then
				self.lockedViewAng.y = angles.y + self.allowedFromCentreX
			end
			local pdiff = (angles.p - self.lockedViewAng.p)
			if pdiff > self.allowedFromCentreY then
				self.lockedViewAng.p = angles.p - self.allowedFromCentreY
			elseif pdiff < -self.allowedFromCentreY then
				self.lockedViewAng.p = angles.p + self.allowedFromCentreY
			end
			cmd:SetViewAngles (angles)
		//	Plus predict the divide by zero if this chunk of code was actually played out
		/*elseif self.lockedViewAng then
			--cmd:SetViewAngles (self.lockedViewAng)
			--self.lockedViewAng = false
			--lastRealViewAng = false
			local angles = cmd:GetViewAngles()
			
			if lastRealViewAng then
				self:SimilarizeAngles (lastRealViewAng, angles)
				local diff = angles - lastRealViewAng
				--diff = diff * (LocalPlayer():GetActiveWeapon().MouseSensitivity or 1)
				self.lockedViewAng = self.lockedViewAng + diff
			end
			
			if not returnJourney then
				self:SimilarizeAngles (self.lockedViewAng, angles)
				returnJourney = self.lockedViewAng - angles
				returnJourney = returnJourney * (1/VIEWMODEL_DEGREEOFZOOM)
			end
			
			if VIEWMODEL_DEGREEOFZOOM > 0 then
				angles = angles + (returnJourney * (FrameTime() / VIEWMODEL_ZOOMTIME))
				cmd:SetViewAngles (angles)
				lastRealViewAng = angles
			else
				self.lockedViewAng = false
				lastRealViewAng = false
				returnJourney = false
			end
		end*/
		if self.lockedViewAng and ( self.__anglecompar ~= self.lockedViewAng ) then
			 self.__bViewWasModifiedTime = CurTime()

		end
		--LocalPlayer():SetFOV(VIEWMODEL_FOVTOSET or nil)
		
	else
		if self.lockedViewAng then
			self.lockedViewAng = false
			lastRealViewAng = false
			--LocalPlayer():SetFOV(nil)
		end
	end
end

function sharpeye_focus.CommandToggleFocus()
	return sharpeye_focus:ToggleFocus()
end

function sharpeye_focus.CommandEnableFocus()
	return sharpeye_focus:EnableFocus()
end

function sharpeye_focus.CommandDisableFocus()
	return sharpeye_focus:DisableFocus()
end

function sharpeye_focus:Mount()
	concommand.Add("sharpeye_focus_toggle", sharpeye_focus.CommandToggleFocus)
	concommand.Add("+sharpeye_focus",       sharpeye_focus.CommandEnableFocus)
	concommand.Add("-sharpeye_focus",       sharpeye_focus.CommandDisableFocus)
	
	self.__hasfocus = false
	self.__decotime = 0

	self.__vm_origin = Vector(0,0,0)
	self.__vm_angles = Angle(0,0,0)
	self.__vm_angles_delta = Angle(0,0,0)
	self.__oriAngle  = Angle(0,0,0)
	self.__anglecompar = Angle(0,0,0)
	self.__bViewWasModified      = true --True for viewmodel angle initialization
	self.__bViewWasModifiedTime  = 0
	self.__bViewWasModifiedDelay = 0.2
	
	//TOMAKE
	self.__fov = 75
	self.__diligent = 0
	self.__raccor_x = 0
	self.__raccor_y = 0
	self.__raccor_x_quo = 0
	
	self:InitializeMessyVars()

	
end

function sharpeye_focus:Unmount()
	concommand.Remove("sharpeye_focus_toggle")
	concommand.Remove("+sharpeye_focus")
	concommand.Remove("-sharpeye_focus")
	
end


