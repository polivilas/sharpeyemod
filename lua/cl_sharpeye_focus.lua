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
local sharpeye = sharpeye
local sharpeye_focus = sharpeye_focus

function sharpeye:IsFocusEnabled()
	return self:GetVar("opt_focus") > 0
end

function sharpeye:HookFocus()
	if self.dat.focus_hooked then return end
	hook.Add("CreateMove", "sharpeye_CreateMove", function(cmd) return sharpeye_focus:CreateMove(cmd) end)
	
	self.dat.focus_hooked = true
	
end

function sharpeye:UnhookFocus()
	if not self.dat.focus_hooked then return end
	hook.Remove("CreateMove", "sharpeye_CreateMove")
	
	self.dat.focus_hooked = false
	
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

function sharpeye_focus:IsRelaxEnabled()
	return (sharpeye:GetVar("opt_relax") > 0) and not sharpeye:IsInThirdPersonMode()
	
end

function sharpeye_focus:HasFocus()
	return self.__hasfocus or sharpeye:IsWiimoteEnabled( )
	
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

--local FOV_DEFAULT
local FOCUS_FOVTOSET
local FOCUS_FOV
local FOCUS_MOUSESENSITIVITY
local FOCUS_ZOOMTIME

local FOCUS_LIMITANGLE_CSTBASE = 35
local FOCUS_LIMITANGLE_X
local FOCUS_LIMITANGLE_Y
local FOCUS_BACKING
local FOCUS_HANDSHIFT
local FOCUS_HANDPULL
local FOCUS_SMOOTHWEAPON
local FOCUS_SMOOTHLOOK
local FOCUS_HANDLEAN

function sharpeye_focus:EvaluateConfigVars( optbNoPlayer )
	local relaxMode = sharpeye_focus:IsRelaxEnabled() and not self:HasFocus()
	
	FOCUS_FOVTOSET     = GetConVarNumber("fov_desired") or 75
	FOCUS_FOV          = FOCUS_FOVTOSET + 33 + sharpeye:GetVar("detail_focus_aimsimalter" ) * 3.0 -- Default is 5 so 15
	FOCUS_MOUSESENSITIVITY = 1
	FOCUS_ZOOMTIME         = 1.0
	
	FOCUS_FLIP         = optbNoPlayer and false or LocalPlayer():GetActiveWeapon().ViewModelFlip

	FOCUS_LIMITANGLE_X = relaxMode and 0 or sharpeye:GetVar("detail_focus_anglex" )
	FOCUS_LIMITANGLE_Y = relaxMode and 0 or sharpeye:GetVar("detail_focus_angley" )
	FOCUS_BACKING       = sharpeye:GetVar("detail_focus_backing" )                -- Default is 5 so 5.
	//FOCUS_HANDALTERNATE = (sharpeye:GetVar("detail_focus_handalternate" ) > 0)
	FOCUS_HANDSHIFT     = sharpeye:GetVar("detail_focus_handshiftx" ) * 0.5       -- Default is 5 so 2.5.
	FOCUS_HANDPULL      = (sharpeye:GetVar("detail_focus_handalternate") > 0) and FOCUS_HANDSHIFT or sharpeye:GetVar("detail_focus_handshifty" ) * 0.5       -- Default is 5 so 2.5.
	FOCUS_SMOOTHWEAPON  = 1 - (sharpeye:GetVar("detail_focus_smoothing" ) * 0.1) * 0.95  -- Default is 5 so 2.5.
	FOCUS_SMOOTHLOOK    = 1 - (sharpeye:GetVar("detail_focus_smoothlook" ) * 0.1) * 0.95 -- Default is 5 so 2.5.
	FOCUS_HANDLEAN    = (sharpeye:GetVar("detail_focus_handlean" ) * 0.1) * 64
	
end

function sharpeye_focus:IsApproach()
	if not self or (self.__decotime == nil) then
		sharpeye_util.OutputError( "CRITICAL ERROR : Please send the following report :: <<" .. tostring( self ) )
		debug.Trace()
		sharpeye_util.OutputError( ">> :: END OF CRITICA ERROR. Please send the report above." )
		
	end
	return (not self:HasFocus()) and (CurTime() - self.__decotime) < FOCUS_ZOOMTIME
	
end

function sharpeye_focus:ApproachRatio()
	if not self or (self.__decotime == nil) then
		sharpeye_util.OutputError( "CRITICAL ERROR : Please send the following report :: <<" .. tostring( self ) )
		debug.Trace()
		sharpeye_util.OutputError( ">> :: END OF CRITICA ERROR. Please send the report above." )
		
	end
	return 1 - (CurTime() - self.__decotime) / FOCUS_ZOOMTIME
	
end

-- BlackOps' Legs addon compatibility test
function sharpeye_focus:GetBiaisViewAngles()
	// IMPORTANT : sharpeye_focus used for LEGACY WITH BlackOps' Legs
	
	if not sharpeye:IsEnabled() or not sharpeye:IsFocusEnabled() or not (sharpeye_focus:HasFocus() or sharpeye_focus:IsRelaxEnabled())  then
		return nil
		
	end
	
	return sharpeye_focus.lockedViewAng or nil

end

function sharpeye_focus:GetSmoothedViewAngles()
	// IMPORTANT : sharpeye_focus used for LEGACY WITH BlackOps' Legs
	
	if not sharpeye:IsEnabled() or not sharpeye:IsFocusEnabled() or not (sharpeye_focus:HasFocus() or sharpeye_focus:IsRelaxEnabled()) then
		return nil
		
	end
	
	return sharpeye_focus.__smoothCameraAngles or nil

end

function sharpeye_focus:AppendCalcView( view )
	if not sharpeye:IsFocusEnabled() then return end
	
	self:EvaluateConfigVars()
	if sharpeye_focus:IsRelaxEnabled() and (sharpeye:IsFirstFrame() or not LocalPlayer():Alive() or sharpeye:IsInRagdollMode()) then
		self.__bRelaxRequireReset = true
		
	end
	
	if self:HasFocus() or sharpeye_focus:IsRelaxEnabled() or self:IsApproach() then
		local smoothFactorWeapon = math.Clamp( FrameTime() / 0.03, 0, 1 )
		local smoothFactorLook = math.Clamp( FrameTime() / 0.03, 0, 1 )
		
		if self:IsApproach() then
			local ratio = self:ApproachRatio() ^ 0.5
			
			smoothFactorWeapon = smoothFactorWeapon * (1 - (1 - FOCUS_SMOOTHWEAPON) * ratio)
			smoothFactorLook   = smoothFactorLook * (1 - (1 - FOCUS_SMOOTHLOOK) * ratio)
		else
			smoothFactorWeapon = smoothFactorWeapon * FOCUS_SMOOTHWEAPON
			smoothFactorLook   = smoothFactorLook * FOCUS_SMOOTHLOOK
		
		end
		
		-- Step 1 : Save original angles for viewmodel rotation fix (models that use custom angles)
		self.__oriAngle.p = view.angles.p
		self.__oriAngle.y = view.angles.y
		self.__oriAngle.r = view.angles.r
		
		-- We'll use angles as a synonym for view.angles (Reference)
		local angles = view.angles
		
		-- Find the actual view angles : The camera angle we want to reach.
		local actualViewAng
		if self.lockedViewAng then
			self.computeViewAng = self.lockedViewAng - self.computeViewAng + angles
			actualViewAng = self.computeViewAng
			
			-- Unshifting
			local fUnshifting = 0.2 + math.Clamp( 1 - (75 - view.fov) / 30, 0, 1 ) * 0.8
			actualViewAng = actualViewAng * fUnshifting + angles * (1 - fUnshifting)
			
		else
			actualViewAng = angles
			
		end
		
		if self.__bRelaxRequireReset or (self.__bViewWasModified and not sharpeye_focus:IsRelaxEnabled()) then
			self.__bRelaxRequireReset = false
			
			self.__smoothCameraAngles.p = actualViewAng.p
			self.__smoothCameraAngles.y = actualViewAng.y
			self.__smoothCameraAngles.r = actualViewAng.r
			
		else -- Else, approach it using a smoothing of the delta of the angles smoothed.
			local tp,ty,tr = math.AngleDifference(self.__smoothCameraAngles.p, actualViewAng.p), math.AngleDifference(self.__smoothCameraAngles.y, actualViewAng.y), math.AngleDifference(self.__smoothCameraAngles.r, actualViewAng.r)
			
			-- Normalize the output angles : It causes issues with the viewmodel otherwise.
			self.__smoothCameraAngles.p = math.NormalizeAngle( math.ApproachAngle( self.__smoothCameraAngles.p, actualViewAng.p, tp * smoothFactorLook) )
			self.__smoothCameraAngles.y = math.NormalizeAngle( math.ApproachAngle( self.__smoothCameraAngles.y, actualViewAng.y, ty * smoothFactorLook) )
			self.__smoothCameraAngles.r = math.NormalizeAngle( math.ApproachAngle( self.__smoothCameraAngles.r, actualViewAng.r, tr * smoothFactorLook) )
			
		end
		
		
		-- Now set the camera angles, and set a new logical reference.
		local usefulViewAng = self.__smoothCameraAngles
		view.angles = usefulViewAng
		
		-- REMEMBER : "angle" variable is a reference to what view.angle referenced BEFORE.
		--
		--[[ Using view.angles = usefulViewAng, we ONLY set a new reference to this table index.
			That means even though we could think :

			angles = view.angles
			view.angles = usefulViewAng

			actually:
			angles != usefulViewAng. Because WE SWAPPED REFERENCES. We are manipulating structural objects.
		]]
		--
		-- That means, don't think we can simplify loads of code because angles seem to be equal to usefulViewAng.
		
		
		
		-- Since CalcView is executed, the player exists. (which is not the case when the addon is loaded up in locale force mode)
		local pl = LocalPlayer()
		
		self:SimilarizeAngles(angles, usefulViewAng)
		
		-- Fov is variable from aimsimulation.
		local fovratio = FOCUS_FOVTOSET / FOCUS_FOV
		angles = (angles * fovratio) + (usefulViewAng * (1 - fovratio))
		local diff_p = angles.p
		local diff_y = angles.y
		
		-- CS:S models needs to have YAW flipped.
		if FOCUS_FLIP then
			angles.y = 2 * usefulViewAng.y - angles.y
		end
		

		---- RACCOR Script
		--self.__raccor_x = (diff_y - usefulViewAng.y)/FOCUS_LIMITANGLE_X
		--self.__raccor_y = (diff_p - usefulViewAng.p)/FOCUS_LIMITANGLE_Y
		self.__raccor_x = math.NormalizeAngle(diff_y - usefulViewAng.y) / FOCUS_LIMITANGLE_CSTBASE
		self.__raccor_y = math.NormalizeAngle(diff_p - usefulViewAng.p) / FOCUS_LIMITANGLE_CSTBASE
		self.__diligent = (self.__raccor_x^2 + self.__raccor_y^2)^0.5
		self.__raccor_x_quo = self.__raccor_x_quo + (self.__raccor_x - self.__raccor_x_quo) * smoothFactorWeapon
		self.__raccor_y_quo = self.__raccor_y_quo + (self.__raccor_y - self.__raccor_y_quo) * smoothFactorWeapon
		
		
		angles.r = angles.r + self.__raccor_x_quo * FOCUS_HANDLEAN
		
		-- Rotate for SWEPs with custom angles.
		local Forward 	= angles:Forward()
		local Right 	= angles:Right()
		local Up 	    = angles:Up()
		
		if view.vm_angles then
			angles:RotateAroundAxis( angles:Right(), 	- view.vm_angles.p + self.__oriAngle.p )
			angles:RotateAroundAxis( angles:Up(), 		view.vm_angles.y - self.__oriAngle.y ) 
			angles:RotateAroundAxis( angles:Forward(),  view.vm_angles.r - self.__oriAngle.r )
		end
		
		--angles.r = self.__raccor_x_quo * 24
		
		if self.__bViewWasModified then -- If first frame then Snap.
			self.__bViewWasModified = false
			
			local ap,ay,ar = math.AngleDifference(angles.p, usefulViewAng.p), math.AngleDifference(angles.y, usefulViewAng.y), math.AngleDifference(angles.r, usefulViewAng.r)
		
			self.__vm_angles_delta.p = ap
			self.__vm_angles_delta.y = ay
			self.__vm_angles_delta.r = ar
			
			self.__vm_angles.p = angles.p
			self.__vm_angles.y = angles.y
			self.__vm_angles.r = angles.r
			
			---- Commented out to remove abrupt snapping when refocusing smoothed
			--self.__raccor_x_quo = 0
			--self.__raccor_y_quo = 0
			
		else -- Else, approach the deltas from model to the centre view using a smoothing of the delta of the remaining angle.
			local ap,ay,ar = math.AngleDifference(angles.p, usefulViewAng.p), math.AngleDifference(angles.y, usefulViewAng.y), math.AngleDifference(angles.r, usefulViewAng.r)
			local dp,dy,dr = math.AngleDifference(self.__vm_angles_delta.p, ap), math.AngleDifference(self.__vm_angles_delta.y, ay), math.AngleDifference(self.__vm_angles_delta.r, ar)
		
			self.__vm_angles_delta.p = math.ApproachAngle( self.__vm_angles_delta.p, ap, dp * smoothFactorWeapon )
			self.__vm_angles_delta.y = math.ApproachAngle( self.__vm_angles_delta.y, ay, dy * smoothFactorWeapon )
			self.__vm_angles_delta.r = math.ApproachAngle( self.__vm_angles_delta.r, ar, dr * smoothFactorWeapon )
			
			self.__vm_angles.p = usefulViewAng.p + self.__vm_angles_delta.p
			self.__vm_angles.y = usefulViewAng.y + self.__vm_angles_delta.y
			self.__vm_angles.r = usefulViewAng.r + self.__vm_angles_delta.r
			
		end
		
		/*view.vm_angles.p = self.__vm_angles.p 
		view.vm_angles.y = self.__vm_angles.y
		view.vm_angles.r = self.__vm_angles.r*/
		view.vm_angles = self.__vm_angles
		
		
		local pos = view.vm_origin or view.origin
		local Forward 	= angles:Forward()
		local Right 	= angles:Right()
		local Up 	    = angles:Up()
		// RACCOR USED TO BE HERE
		
		pos = pos - Forward * self.__diligent * FOCUS_BACKING + Right * self.__raccor_x_quo * FOCUS_HANDSHIFT * (FOCUS_FLIP and -1 or 1) + Up * self.__raccor_y_quo * FOCUS_HANDPULL
		--pos = pos + Right * -4
		
		---- Focus Leaning
		-- Don't delete the following lines of code
		--local vario = self.__smoothCameraAngles:Right() * self.__raccor_x_quo^3 * -32 + self.__smoothCameraAngles:Up() * self.__raccor_y_quo^3 * -32 * -1
		--view.origin = view.origin + vario
		--pos = pos - vario
		----self.__smoothCameraAngles.r = self.__smoothCameraAngles.r + self.__raccor_x_quo^3 * -40
		
		/*if self.__shiftenable then
			self.__shiftat = self.__shiftat + (self:HasFocus() and (self.__shiftme - self.__shiftat) or -1 * self.__shiftat) * smoothFactorWeapon
			pos = pos + Forward * self.__shiftat.z * (1 - smoothFactorWeapon) + Right * self.__shiftat.x * (1 - smoothFactorWeapon) + Up * self.__shiftat.y * (1 - smoothFactorWeapon)
		end*/
		view.vm_origin = pos

	--[[elseif self:IsApproach() then
		local ratio = self:ApproachRatio()
		local ratioSq = ratio ^ 2
		local spratio = 1 + (1 - ratioSq) * 0.5
		
		local smoothFactorWeapon = math.Clamp( FrameTime() / 0.03, 0, 1 ) * FOCUS_SMOOTHWEAPON * spratio
		local smoothFactorLook = math.Clamp( FrameTime() / 0.03, 0, 1 ) * FOCUS_SMOOTHLOOK * spratio
		
		self.__oriAngle.p = view.angles.p
		self.__oriAngle.y = view.angles.y
		self.__oriAngle.r = view.angles.r
		
		local angles = view.angles -- Redundant, but we do the analogy with the code before
		local actualViewAng = view.angles
		local tp,ty,tr = math.AngleDifference(self.__smoothCameraAngles.p, actualViewAng.p), math.AngleDifference(self.__smoothCameraAngles.y, actualViewAng.y), math.AngleDifference(self.__smoothCameraAngles.r, actualViewAng.r)
		
		self.__smoothCameraAngles.p = math.NormalizeAngle( math.ApproachAngle( self.__smoothCameraAngles.p, actualViewAng.p, tp * smoothFactorLook) )
		self.__smoothCameraAngles.y = math.NormalizeAngle( math.ApproachAngle( self.__smoothCameraAngles.y, actualViewAng.y, ty * smoothFactorLook) )
		self.__smoothCameraAngles.r = math.NormalizeAngle( math.ApproachAngle( self.__smoothCameraAngles.r, actualViewAng.r, tr * smoothFactorLook) )
		
		/*view.angles.p = self.__smoothCameraAngles.p
		view.angles.y = self.__smoothCameraAngles.y
		view.angles.r = self.__smoothCameraAngles.r*/
		
		local usefulViewAng = self.__smoothCameraAngles
		view.angles = usefulViewAng
		
		-- Fov is variable from aimsimulation.
		local fovratio = FOCUS_FOVTOSET / FOCUS_FOV
		angles = (angles * fovratio) + (usefulViewAng * (1 - fovratio))
		
		-- CS:S models needs to have YAW flipped.
		if FOCUS_FLIP then
			angles.y = 2 * usefulViewAng.y - angles.y
		end
		
		-- Rotate for SWEPs with custom angles.
		/*if view.vm_angles then
			angles:RotateAroundAxis( angles:Right(), 	view.vm_angles.p - self.__oriAngle.p )
			angles:RotateAroundAxis( angles:Up(), 		view.vm_angles.y - self.__oriAngle.y ) 
			angles:RotateAroundAxis( angles:Forward(),  view.vm_angles.r - self.__oriAngle.r )
		end*/
		
		if view.vm_angles then
			local ap,ay,ar = math.AngleDifference(angles.p, usefulViewAng.p), math.AngleDifference(angles.y, usefulViewAng.y), math.AngleDifference(angles.r, usefulViewAng.r)
			local dp,dy,dr = math.AngleDifference(self.__vm_angles_delta.p, ap), math.AngleDifference(self.__vm_angles_delta.y, ay), math.AngleDifference(self.__vm_angles_delta.r, ar)
		
			self.__vm_angles_delta.p = math.ApproachAngle( self.__vm_angles_delta.p, ap, dp * smoothFactorWeapon ) * ratioSq
			self.__vm_angles_delta.y = math.ApproachAngle( self.__vm_angles_delta.y, ay, dy * smoothFactorWeapon ) * ratioSq
			self.__vm_angles_delta.r = math.ApproachAngle( self.__vm_angles_delta.r, ar, dr * smoothFactorWeapon ) * ratioSq
			
			self.__vm_angles.p = usefulViewAng.p + self.__vm_angles_delta.p
			self.__vm_angles.y = usefulViewAng.y + self.__vm_angles_delta.y
			self.__vm_angles.r = usefulViewAng.r + self.__vm_angles_delta.r

			/*view.vm_angles.p = self.__vm_angles.p 
			view.vm_angles.y = self.__vm_angles.y
			view.vm_angles.r = self.__vm_angles.r*/
			view.vm_angles = self.__vm_angles
			
		end
		
		local pos = view.vm_origin or view.origin
		local Forward = view.vm_angles:Forward()
		local Right   = view.vm_angles:Right()
		local Up 	  = view.vm_angles:Up()
		view.vm_origin = pos - Forward * self.__diligent * FOCUS_BACKING * ratioSq + Right * self.__raccor_x_quo * FOCUS_HANDSHIFT * (FOCUS_FLIP and -1 or 1) * ratioSq + Up * self.__raccor_y_quo * FOCUS_HANDSHIFT * ratioSq 
		]]--
	end
	
end


local lastRealViewAng = false

function sharpeye_focus:CreateMove( cmd )
	self:EvaluateConfigVars()
	if self:HasFocus() then
		local pl = LocalPlayer()
	
		self.computeViewAng = cmd:GetViewAngles()
		
		///
		do -- Enclose Theme
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
				diff = diff * FOCUS_MOUSESENSITIVITY
				angles = lastRealViewAng + diff
			end
			
			lastRealViewAng = angles
			
			--
			self:SimilarizeAngles (self.lockedViewAng, angles)
			local ydiff = (angles.y - self.lockedViewAng.y)
			if ydiff > FOCUS_LIMITANGLE_X then
				self.lockedViewAng.y = angles.y - FOCUS_LIMITANGLE_X
			elseif ydiff < -FOCUS_LIMITANGLE_X then
				self.lockedViewAng.y = angles.y + FOCUS_LIMITANGLE_X
			end
			local pdiff = (angles.p - self.lockedViewAng.p)
			if pdiff > FOCUS_LIMITANGLE_Y then
				self.lockedViewAng.p = angles.p - FOCUS_LIMITANGLE_Y
			elseif pdiff < -FOCUS_LIMITANGLE_Y then
				self.lockedViewAng.p = angles.p + FOCUS_LIMITANGLE_Y
			end
			cmd:SetViewAngles (angles)
			
		end
		///
		
		if self.lockedViewAng and ( self.__anglecompar ~= self.lockedViewAng ) then
			 self.__bViewWasModifiedTime = CurTime()

		end
		--LocalPlayer():SetFOV(FOCUS_FOVTOSET or nil)
		
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
	//concommand.Add("sharpeye_focus_toggle", sharpeye_focus.CommandToggleFocus)
	//concommand.Add("+sharpeye_focus",       sharpeye_focus.CommandEnableFocus)
	//concommand.Add("-sharpeye_focus",       sharpeye_focus.CommandDisableFocus)
	
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
	self.__bRelaxRequireReset      = false --True for viewmodel angle initialization
	
	self.__smoothCameraAngles = Angle(0,0,0)
	
	self.__diligent = 0
	self.__raccor_x = 0
	self.__raccor_y = 0
	self.__raccor_x_quo = 0
	self.__raccor_y_quo = 0
	
	//self.__shiftme = Vector( 0, 0, 0 )
	//self.__shiftat = Vector( 0, 0, 0 )
	
	self:EvaluateConfigVars( true )

	
end

function sharpeye_focus:Unmount()
	//concommand.Remove("sharpeye_focus_toggle")
	//concommand.Remove("+sharpeye_focus")
	//concommand.Remove("-sharpeye_focus")
	sharpeye:UnhookFocus()
	
end


