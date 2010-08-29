////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Motion                                     //
////////////////////////////////////////////////

function sharpeye.IsMotionEnabled()
	return (sharpeye.GetVarNumber("sharpeye_core_motion") > 0)
end

function sharpeye.HookMotion()
	if sharpeye_dat.motion_hooked then return end
	hook.Add("CalcView", "sharpeye_CalcView", sharpeye.CalcView)
	
	sharpeye_dat.motion_hooked = true
	
end

function sharpeye.UnhookMotion()
	if not sharpeye_dat.motion_hooked then return end
	hook.Remove("CalcView", "sharpeye_CalcView")
	
	sharpeye_dat.motion_hooked = false
end

function sharpeye.IsFirstFrame()
	return sharpeye_dat.motion_firstframe
end

function sharpeye.IsFirstPersonDeathEnabled()
	return (sharpeye.GetVarNumber("sharpeye_opt_firstpersondeath") > 0)
end

function sharpeye.IsFirstPersonDeathHighSpeed()
	return (sharpeye.GetVarNumber("sharpeye_opt_firstpersondeath_highspeed") > 0)
end

function sharpeye.IsMotionBlurEnabled()
	return (sharpeye.GetVarNumber("sharpeye_opt_motionblur") > 0)
end

function sharpeye.IsInThirdPersonMode()
	return (GetViewEntity() ~= LocalPlayer()) or LocalPlayer():ShouldDrawLocalPlayer()
	--return false
	--return sharpeye_dat.hasDrawnLocalPlayer
	--return GAMEMODE:ShouldDrawLocalPlayer() -- LocalPlayer():ShouldDrawLocalPlayer() was undocumented back then
end

function sharpeye.IsInRagdollMode()
	return sharpeye.IsFirstPersonDeathEnabled() and (sharpeye.IsFirstPersonDeathHighSpeed() or not LocalPlayer():Alive()) and ValidEntity( LocalPlayer():GetRagdollEntity() )
	
end

function sharpeye.ShouldMotionDisableInThirdPerson()
	return ((sharpeye.GetVarNumber("sharpeye_opt_disableinthirdperson") > 0) and sharpeye.IsInThirdPersonMode())
end

function sharpeye.ShouldBobbingDisableCompletely()
	return (sharpeye.GetVarNumber("sharpeye_opt_disablebobbing") > 0) 
end

function sharpeye.ShouldBobbingDisableWithTools()
	return ((sharpeye.GetVarNumber("sharpeye_opt_disablewithtools") > 0) and sharpeye.IsUsingSandboxTools())
end

function sharpeye.Detail_GetMasterMod()
	-- Default is 5, so 1
	return (sharpeye.GetVarNumber("sharpeye_detail_mastermod") * 0.1) * 2
end

function sharpeye.Detail_GetLeaningAngle()
	-- Default is 5, so 8
	return (sharpeye.GetVarNumber("sharpeye_detail_leaningangle") * 0.1) * 16
end

function sharpeye.Detail_GetLandingAngle()
	-- Default is 5, so 12
	return (sharpeye.GetVarNumber("sharpeye_detail_landingangle") * 0.1) * 24
end

function sharpeye.Detail_GetBreatheBobDistance()
	-- Default is 5, so 30
	return (sharpeye.GetVarNumber("sharpeye_detail_breathebobdist") * 0.1) * 60 * (3 - sharpeye.GetHealthFactor() * 2)
end

function sharpeye.Detail_GetRunningBobFrequency()
	-- OLD : Default is 5, so 0.2
	-- Default is 5, so 0.2
	return 0.06 + (sharpeye.GetVarNumber("sharpeye_detail_runningbobfreq") * 0.1) * 0.2
end

function sharpeye.Detail_GetSlightDistorsionIntensity()
	return 1
end

function sharpeye.Detail_GetRunningDistorsionIntensity()
	return 1
end

function sharpeye.Detail_GetPermablurAmount()
	return (sharpeye.GetVarNumber("sharpeye_detail_permablur") * 0.005)
end

function sharpeye.CalcView( ply, origin, angles, fov )
	// Disabled Compatibility Module
	/*
	if not sharpeye_dat.player_view_med then
		sharpeye_dat.player_view_med = {}
	end
	sharpeye_dat.player_view_med.origin = origin
	sharpeye_dat.player_view_med.angles = angles
	sharpeye_dat.player_view_med.fov    = fov
	
	local bCustomChanged = sharpeye.ProcessCompatibleCalcView( ply, origin, angles, fov, sharpeye_dat.player_view_med )
	origin = sharpeye_dat.player_view_med.origin
	angles = sharpeye_dat.player_view_med.angles
	fov    = sharpeye_dat.player_view_med.fov
	
	local defaultReturn = bCustomChanged and sharpeye_dat.player_view_med or nil*/
	
	local defaultReturn = nil
	
	if not sharpeye.IsEnabled() then
		sharpeye_dat.motion_firstframe = true
		return defaultReturn
	end
	if not sharpeye.IsMotionEnabled() then
		sharpeye_dat.motion_firstframe = true
		return defaultReturn
	end
	if not sharpeye.InMachinimaMode() and (sharpeye.IsInVehicle() or sharpeye.ShouldMotionDisableInThirdPerson()) then
		sharpeye_dat.motion_firstframe = true
		return defaultReturn
	end
	

	-- EKUSUTARA : DONT USE
	--if not sharpeye_dat.player_view then
	--	sharpeye_dat.player_view = {}
	--	sharpeye_dat.player_oriangle = Angle(0,0,0)
	--end
	
	-- EKUSUTARA 
	if not sharpeye_dat.player_oriangle then
		sharpeye_dat.player_oriangle = Angle(0,0,0)
	end
	
	sharpeye_dat.player_oriangle.p = angles.p
	sharpeye_dat.player_oriangle.y = angles.y
	sharpeye_dat.player_oriangle.r = angles.r
	
	-- EKUSUTARA : DONT USE
	--sharpeye_dat.player_view = GAMEMODE:CalcView( ply, origin, angles, fov )
	--local view = sharpeye_dat.player_view
	
	-- EKUSUTARA 
	local view = GAMEMODE:CalcView( ply, origin, angles, fov )
	
	
	// Disabled Compatibility Module
	/*view.origin = sharpeye_dat.player_view_med.origin
	view.angles = sharpeye_dat.player_view_med.angles
	view.fov    = sharpeye_dat.player_view_med.fov*/
	
	-- EKUSUTARA : DONT USE
	--view.origin = origin
	--view.angles = angles
	--view.fov    = fov
	
	
	local ragdollMode = sharpeye.IsInRagdollMode()
	if not sharpeye.ShouldBobbingDisableCompletely() and (sharpeye.InMachinimaMode() or (not sharpeye.IsNoclipping() and not sharpeye.ShouldBobbingDisableWithTools() and not ragdollMode)) then
		
		local relativeSpeed = ply:GetVelocity():Length() / sharpeye.GetBasisRunSpeed()
		local clampedSpeedCustom = (relativeSpeed > 3) and 1 or (relativeSpeed / 3)
		
		local fStamina = sharpeye.GetStamina()
		local correction = math.Clamp( FrameTime() * 66 , 0 , 1	)
		local shiftMod = sharpeye_dat.player_TimeShift + fStamina * sharpeye.Detail_GetRunningBobFrequency() * ( 1 + clampedSpeedCustom ) / 2 * correction
		local distMod  = (1 + fStamina * 7 * ( 2 + clampedSpeedCustom ) / 3) * sharpeye.Detail_GetMasterMod()
		local breatheMod  = (1 + fStamina * sharpeye.Detail_GetBreatheBobDistance() * (1 - clampedSpeedCustom)^2)
		
		sharpeye_dat.player_TimeShift = shiftMod
		
		view.origin.x = view.origin.x + sharpeye.Modulation(27, 1, shiftMod) * distMod
		view.origin.y = view.origin.y + sharpeye.Modulation(16, 1, shiftMod) * distMod
		view.origin.z = view.origin.z + sharpeye.Modulation(7 , 1, shiftMod) * distMod
		
		sharpeye_dat.player_PitchInfluence = sharpeye_dat.player_PitchInfluence * 0.90 * correction
		--print(sharpeye_dat.player_PitchInfluence)
		
		if sharpeye_dat.player_TimeOffGroundWhenLanding > 0 then
			local timeFactor = sharpeye_dat.player_TimeOffGroundWhenLanding
			timeFactor = (timeFactor > 2) and 1 or (timeFactor / 2)
			sharpeye_dat.player_PitchInfluence = sharpeye_dat.player_PitchInfluence + timeFactor * sharpeye.Detail_GetLandingAngle()
			
		end
		
		local pitchMod = sharpeye_dat.player_PitchInfluence
		-- This should not execute in Machinima Mode
		if not sharpeye.IsNoclipping() then
			pitchMod = pitchMod - ((sharpeye_dat.player_TimeOffGround > 0) and ((1 + ((sharpeye_dat.player_TimeOffGround > 2) and 1 or (sharpeye_dat.player_TimeOffGround / 2))) * sharpeye.Detail_GetLandingAngle() / 6) or 0)
			
		end
		
		local rollCalc = 0
		if (relativeSpeed > 1.8) then
			local angleDiff = math.AngleDifference(ply:GetVelocity():Angle().y, ply:EyeAngles().y)
			if math.abs(angleDiff) < 110 then
				rollCalc = ((angleDiff > 0) and 1 or -1) * (1 - ((1 - (math.abs(angleDiff) / 110)) ^ 2)) * sharpeye.Detail_GetLeaningAngle() * math.Clamp((relativeSpeed - 1.8), 0, 1) ^ 2

			else
				rollCalc = 0
				
			end
			
		else
			rollCalc = 0
			
		end
		sharpeye_dat.player_RollChange = sharpeye_dat.player_RollChange + (rollCalc - sharpeye_dat.player_RollChange) * math.Clamp( 0.2 * FrameTime() * 25 , 0 , 1 )
		
		local precisionShot = ((math.Clamp(view.fov, 20, 75) - 15) / 60)
		
		view.angles.p = view.angles.p + precisionShot * sharpeye.Modulation(8 , 1, shiftMod * 0.7) * 0.2 * breatheMod + pitchMod
		view.angles.y = view.angles.y + sharpeye.Modulation(11, 1, shiftMod) * 0.1 * distMod
		view.angles.r = view.angles.r + sharpeye.Modulation(24, 1, shiftMod) * 0.1 * distMod - sharpeye_dat.player_RollChange
		view.angles.p = math.Clamp(view.angles.p, -89.99, 89.99)
		
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
	view.vm_angle_aimdelta = sharpeye_dat.player_oriangle - view.angles
	
	--if sharpeye_focus then
		sharpeye_focus:AppendCalcView( view )
	--end
	
	--WEAPON TAP END : ADD BOB
	view.vm_angles = view.vm_angles + view.vm_angle_aimdelta
	
	if sharpeye_drops and sharpeye_drops:IsEnabled() then
		sharpeye_drops:AppendCalcView( view )
	end
	
	sharpeye_dat.motion_firstframe = false
	return view
	
end

function sharpeye.GetMotionBlurValues( y, x, fwd, spin )
	if not sharpeye.IsEnabled() then return end
	if not sharpeye.IsMotionEnabled() then return end
	if not sharpeye.IsMotionBlurEnabled() then return end
	if sharpeye.IsInVehicle() then return end
	if sharpeye.ShouldMotionDisableInThirdPerson() then return end
	
	local ply = LocalPlayer()
	--local velocity = ply:GetVelocity()
	--local velocityAngle = velocity:Angle()
	--local eyeAngles = EyeAngles()
	
	local relativeSpeed = ply:GetVelocity():Length() / sharpeye.GetBasisRunSpeed()
	local clampedSpeedCustom = (relativeSpeed > 3) and 1 or (relativeSpeed / 3)

	fwd = fwd + (clampedSpeedCustom ^ 2) * relativeSpeed * 0.005 + sharpeye.Detail_GetPermablurAmount()
	--y = y + clampedSpeedCustom * math.sin(math.AngleDifference( velocityAngle.y, eyeAngles.y ) / 360) ^ 3
	--x = x + clampedSpeedCustom * math.sin(math.AngleDifference( velocityAngle.p, eyeAngles.p ) / 360) ^ 3
	
	if sharpeye.EXT_IsPCSEnabled() then
		if ply.CLHasDoneARoll then
			-- print( ply.__pitch )
			--print( "PCS Motion Blur Override should be " .. (360 - ply.__pitch) / 360 )
			x = x + (360 - ply.__pitch) / 360
		end
	end

	return y, x, fwd, spin

end
