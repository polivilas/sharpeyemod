////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Motion                                     //
////////////////////////////////////////////////
local sharpeye = sharpeye

function sharpeye:IsMotionEnabled()
	return self:GetVar("core_motion") > 0
end

function sharpeye:IsUsingEmotion()
	return false or self:GetVar("core_emotion") > 0
end

function sharpeye:HookMotion()
	if self.dat.motion_hooked then return end
	hook.Add("CalcView", "sharpeye_CalcView", sharpeye.CalcView)
	
	self.dat.motion_hooked = true
	
end

function sharpeye:UnhookMotion()
	if not self.dat.motion_hooked then return end
	hook.Remove("CalcView", "sharpeye_CalcView")
	
	self.dat.motion_hooked = false
end

function sharpeye:IsFirstFrame()
	return self.dat.motion_firstframe
end

function sharpeye:IsFirstPersonDeathEnabled()
	return self:GetVar("opt_firstpersondeath") > 0
end

function sharpeye:IsFirstPersonDeathHighSpeed()
	return self:GetVar("opt_firstpersondeath_highspeed") > 0
end

function sharpeye:IsMotionBlurEnabled()
	return self:GetVar("opt_motionblur") > 0
end

function sharpeye:IsInThirdPersonMode()
	return (GetViewEntity() ~= LocalPlayer()) or LocalPlayer():ShouldDrawLocalPlayer()
	--return false
	--return self.dat.hasDrawnLocalPlayer
	--return GAMEMODE:ShouldDrawLocalPlayer()

	-- LocalPlayer():ShouldDrawLocalPlayer() was undocumented back then
end

function sharpeye:IsInRagdollMode()
	return self:IsFirstPersonDeathEnabled() and (self:IsFirstPersonDeathHighSpeed() or not LocalPlayer():Alive()) and ValidEntity( LocalPlayer():GetRagdollEntity() )
	
end

function sharpeye:ShouldMotionDisableInThirdPerson()
	return (self:GetVar("opt_disableinthirdperson") > 0) and self:IsInThirdPersonMode()
end

function sharpeye:ShouldBobbingDisableCompletely()
	return self:GetVar("opt_disablebobbing") > 0
end

function sharpeye:ShouldBobbingDisableWithTools()
	return (self:GetVar("opt_disablewithtools") > 0) and self:IsUsingSandboxTools()
end

function sharpeye:Detail_GetMasterMod()
	-- Default is 5, so 1
	return self:GetVar("detail_mastermod") * 0.1 * 2 * math.Clamp(1 - self:Detail_GetCrouchMod() * self.dat.player_CrouchSmooth, 0, 1 )
end


function sharpeye:Detail_GetCrouchMod()
	-- Default is 5, so 0.5
	return self:GetVar("detail_crouchmod") * 0.1
end

function sharpeye:Detail_GetLeaningAngle()
	-- Default is 5, so 8
	return self:GetVar("detail_leaningangle") * 1.6
end

function sharpeye:Detail_GetLandingAngle()
	-- Default is 5, so 12
	return self:GetVar("detail_landingangle") * 2.4
end

function sharpeye:Detail_GetBreatheBobDistance()
	-- Default is 5, so 30
	return self:GetVar("detail_breathebobdist") * 6 * (3 - self:GetHealthFactor() * 2)
end

function sharpeye:Detail_GetRunningBobFrequency()
	-- OLD : Default is 5, so 0.2
	-- Default is 5, so 0.2
	return 0.06 + self:GetVar("detail_runningbobfreq") * 0.02
end
function sharpeye:Detail_GetStepmodFrequency()
	-- Default is ????
	return 3 + (self:GetVar("detail_stepmodfrequency") - 5) * 0.6
end

function sharpeye:Detail_GetStepmodIntensity()
	-- Default is 5, so 10
	return self:GetVar("detail_stepmodintensity") * 2
end

function sharpeye:Detail_GetShakemodIntensity()
	-- Default is 5, so 0.1
	return self:GetVar("detail_shakemodintensity") * 0.02
end

function sharpeye:Detail_GetShakemodHealthMod()
	-- Default is 5, so 6
	return self:GetVar("detail_shakemodhealth") * 1.2
end

function sharpeye:Detail_GetPermablurAmount()
	return self:GetVar("detail_permablur") * 0.005
end

function sharpeye:ApplyMotion( ply, origin, angles, fov, view )
	local relativeSpeed = ply:GetVelocity():Length() / self:GetBasisRunSpeed()
	local clampedSpeedCustom = (relativeSpeed > 3) and 1 or (relativeSpeed / 3)
	
	local fStamina = self:GetStamina()
	local correction = math.Clamp( FrameTime() * 33 , 0 , 1	)
	local shiftMod = self.dat.player_TimeShift + fStamina * self:Detail_GetRunningBobFrequency() * ( 1 + clampedSpeedCustom ) / 2 * correction
	local runMod = self.dat.player_TimeRun + 0.05 * ( 1 + clampedSpeedCustom ) / 2 * correction
	local distMod  = (1 + fStamina * 7 * ( 2 + clampedSpeedCustom ) / 3) * self:Detail_GetMasterMod()
	local breatheMod  = (1 + fStamina * self:Detail_GetBreatheBobDistance() * (1 - clampedSpeedCustom)^2)
	
	--Step algo
	local stepMod = (self.dat.player_TimeOffGround < 0.5) and (self:Detail_GetStepmodIntensity() * clampedSpeedCustom * math.abs( math.sin( CurTime() * 2 + runMod * self:Detail_GetStepmodFrequency() ) ) * (1 - self.dat.player_TimeOffGround * 2)) or 0
	
	self.dat.player_TimeShift = shiftMod
	self.dat.player_TimeRun   = runMod
	
	view.origin.x = view.origin.x + self:Modulation(27, 1, shiftMod) * distMod
	view.origin.y = view.origin.y + self:Modulation(16, 1, shiftMod) * distMod
	view.origin.z = view.origin.z + self:Modulation(7 , 1, shiftMod) * distMod + stepMod
	
	self.dat.player_PitchInfluence = self.dat.player_PitchInfluence - (self.dat.player_PitchInfluence * 0.1 * correction)
	--print(self.dat.player_PitchInfluence)
	
	if self.dat.player_TimeOffGroundWhenLanding > 0 then
		local timeFactor = self.dat.player_TimeOffGroundWhenLanding
		timeFactor = (timeFactor > 2) and 1 or (timeFactor / 2)
		self.dat.player_PitchInfluence = self.dat.player_PitchInfluence + timeFactor * self:Detail_GetLandingAngle()
		
	end
	
	local pitchMod = self.dat.player_PitchInfluence
	-- This should not execute in Machinima Mode
	if not self:IsNoclipping() then
		pitchMod = pitchMod - ((self.dat.player_TimeOffGround > 0) and ((1 + ((self.dat.player_TimeOffGround > 2) and 1 or (self.dat.player_TimeOffGround / 2))) * self:Detail_GetLandingAngle() / 6) or 0)
		
	end
	
	local rollCalc = 0
	if (relativeSpeed > 1.8) then
		local angleDiff = math.AngleDifference(ply:GetVelocity():Angle().y, ply:EyeAngles().y)
		if math.abs(angleDiff) < 110 then
			rollCalc = ((angleDiff > 0) and 1 or -1) * (1 - ((1 - (math.abs(angleDiff) / 110)) ^ 2)) * self:Detail_GetLeaningAngle() * math.Clamp((relativeSpeed - 1.8), 0, 1) ^ 2

		else
			rollCalc = 0
			
		end
		
	else
		rollCalc = 0
		
	end
	self.dat.player_RollChange = self.dat.player_RollChange + (rollCalc - self.dat.player_RollChange) * math.Clamp( 0.2 * FrameTime() * 25 , 0 , 1 )
	
	local precisionShot = ((math.Clamp(view.fov, 20, 75) - 15) / 60)
	
	--Distorsion algorithm
	local healthFactorDecreased = 1 - self:GetHealthFactor() ^ 2
	// Please check. In theory, the shake will never aim the center except if intensity is set to 0.
	local slightDistorsionAccident = self:Detail_GetShakemodIntensity() * (2 + (1 - healthFactorDecreased) * self:Modulation(11, 1, shiftMod) + healthFactorDecreased * self:Modulation(11, 1 + self:Detail_GetShakemodHealthMod(), shiftMod)) ^ 2
	// Check neglictible nature of the first sine
	//local slightDistorsionAngle = self:Modulation(24, 1, shiftMod) + CurTime() - self:Modulation(7, 1, shiftMod) * 4
	local slightDistorsionAngle = CurTime() + self:Modulation(7, 1, shiftMod) * 4
	local sD_changeY, sD_changeP = math.cos( slightDistorsionAngle ) * slightDistorsionAccident, math.sin( slightDistorsionAngle ) * slightDistorsionAccident
	
	view.angles.p = view.angles.p + precisionShot * self:Modulation(8 , 1, shiftMod * 0.7) * 0.2 * breatheMod + pitchMod + sD_changeP
	view.angles.y = view.angles.y + self:Modulation(11, 1, shiftMod) * 0.1 * distMod + sD_changeY
	view.angles.r = view.angles.r + self:Modulation(24, 1, shiftMod) * 0.1 * distMod - self.dat.player_RollChange
	view.angles.p = math.Clamp(view.angles.p, -89.99, 89.99)
	
end

function sharpeye.CalcView( ply, origin, angles, fov )
	local self = sharpeye
	// Disabled Compatibility Module
	/*
	if not self.dat.player_view_med then
		self.dat.player_view_med = {}
	end
	self.dat.player_view_med.origin = origin
	self.dat.player_view_med.angles = angles
	self.dat.player_view_med.fov    = fov
	
	local bCustomChanged = sharpeye:ProcessCompatibleCalcView( ply, origin, angles, fov, self.dat.player_view_med )
	origin = self.dat.player_view_med.origin
	angles = self.dat.player_view_med.angles
	fov    = self.dat.player_view_med.fov
	
	local defaultReturn = bCustomChanged and self.dat.player_view_med or nil*/
	
	local defaultReturn = nil
	
	if not self:IsEnabled() then
		self.dat.motion_firstframe = true
		return defaultReturn
	end
	if not self:IsMotionEnabled() then
		self.dat.motion_firstframe = true
		return defaultReturn
	end
	if not self:InMachinimaMode() and (self:IsInVehicle() or self:ShouldMotionDisableInThirdPerson()) then
		self.dat.motion_firstframe = true
		return defaultReturn
	end
	

	-- EKUSUTARA : DONT USE
	--if not self.dat.player_view then
	--	self.dat.player_view = {}
	--	self.dat.player_oriangle = Angle(0,0,0)
	--end
	
	-- EKUSUTARA 
	if not self.dat.player_oriangle then
		self.dat.player_oriangle = Angle(0,0,0)
	end
	
	self.dat.player_oriangle.p = angles.p
	self.dat.player_oriangle.y = angles.y
	self.dat.player_oriangle.r = angles.r
	
	-- EKUSUTARA : DONT USE
	--self.dat.player_view = GAMEMODE:CalcView( ply, origin, angles, fov )
	--local view = self.dat.player_view
	
	-- EKUSUTARA 
	local view = GAMEMODE:CalcView( ply, origin, angles, fov )
	
	
	// Disabled Compatibility Module
	/*view.origin = self.dat.player_view_med.origin
	view.angles = self.dat.player_view_med.angles
	view.fov    = self.dat.player_view_med.fov*/
	
	-- EKUSUTARA : DONT USE
	--view.origin = origin
	--view.angles = angles
	--view.fov    = fov
	
	
	local ragdollMode = self:IsInRagdollMode()
	if not self:ShouldBobbingDisableCompletely() and (self:InMachinimaMode() or (not self:IsNoclipping() and not self:ShouldBobbingDisableWithTools() and not ragdollMode)) then
		if self:IsUsingEmotion() then
			self:ApplyEmotion( ply, origin, angles, fov, view )
			
		else
			self:ApplyMotion( ply, origin, angles, fov, view )
			
		end
		
	elseif ragdollMode then -- Player is dead and has a ragdoll

		local ragdoll = LocalPlayer():GetRagdollEntity()
		local attachment = ragdoll:GetAttachment( 1 )
		
		if not ragdoll.triedHeadSnap then
			ragdoll.BuildBonePositions = function( self, numbones, numphysbones )
				if not self.s__boneid then
					self.s__boneid = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
				end
				if self.s__boneid and self.s__boneid ~= -1 then
					local matBone = ragdoll:GetBoneMatrix( self.s__boneid )
					matBone:Scale( Vector( 0.01, 0.01, 0.01 ) )
					ragdoll:SetBoneMatrix( self.s__boneid, matBone )
					
				end
			end
			ragdoll.triedHeadSnap = true
			
		end

		view.origin = attachment.Pos - attachment.Ang:Forward() * 0.4
		view.angles = attachment.Ang
	
	end
	
	--WEAPON TAP
	local wep = ply:GetActiveWeapon()
	if ( ValidEntity( wep ) ) then
	
		local func = wep.GetViewModelPosition
		if ( func ) then
			view.vm_origin, view.vm_angles = func( wep, view.origin*1, view.angles*1 )
			
		else
			view.vm_origin = nil
			view.vm_angles = view.angles*1
		end
		
		local func = wep.CalcView
		if ( func ) then view.origin, view.angles, view.fov = func( wep, ply, view.origin*1, view.angles*1, view.fov ) end
	else
		view.vm_origin = nil
		view.vm_angles = view.angles*1
		
	end
	view.vm_angle_aimdelta = self.dat.player_oriangle - view.angles
	
	--if sharpeye_focus then
		sharpeye_focus:AppendCalcView( view )
	--end
	
	--WEAPON TAP END : ADD BOB
	view.vm_angles = view.vm_angles + view.vm_angle_aimdelta
	
	if sharpeye_drops and sharpeye_drops:IsEnabled() then
		sharpeye_drops:AppendCalcView( view )
	end
	
	self.dat.motion_firstframe = false
	return view
	
end

function sharpeye.GetMotionBlurValues( y, x, fwd, spin )
	local self = sharpeye
	if not self:IsEnabled() then return end
	if not self:IsMotionEnabled() then return end
	if not self:IsMotionBlurEnabled() then return end
	if self:IsInVehicle() then return end
	if self:ShouldMotionDisableInThirdPerson() then return end
	
	local ply = LocalPlayer()
	--local velocity = ply:GetVelocity()
	--local velocityAngle = velocity:Angle()
	--local eyeAngles = EyeAngles()
	
	local relativeSpeed = ply:GetVelocity():Length() / self:GetBasisRunSpeed()
	local clampedSpeedCustom = (relativeSpeed > 3) and 1 or (relativeSpeed / 3)

	fwd = fwd + (clampedSpeedCustom ^ 2) * relativeSpeed * 0.005 + self:Detail_GetPermablurAmount()
	--y = y + clampedSpeedCustom * math.sin(math.AngleDifference( velocityAngle.y, eyeAngles.y ) / 360) ^ 3
	--x = x + clampedSpeedCustom * math.sin(math.AngleDifference( velocityAngle.p, eyeAngles.p ) / 360) ^ 3
	
	if self:EXT_IsPCSEnabled() then
		if ply.CLHasDoneARoll then
			-- print( ply.__pitch )
			--print( "PCS Motion Blur Override should be " .. (360 - ply.__pitch) / 360 )
			x = x + (360 - ply.__pitch) / 360
		end
	end

	return y, x, fwd, spin

end
