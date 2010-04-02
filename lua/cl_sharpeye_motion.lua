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

function sharpeye.IsMotionBlurEnabled()
	return (sharpeye.GetVarNumber("sharpeye_opt_motionblur") > 0)
end

function sharpeye.IsInThirdPersonMode()
	return false
	--return GAMEMODE:ShouldDrawLocalPlayer()
end

function sharpeye.ShouldMotionDisableInThirdPerson()
	return ((sharpeye.GetVarNumber("sharpeye_opt_disableinthirdperson") > 0) and sharpeye.IsInThirdPersonMode())
end

function sharpeye.ShouldMotionDisableWithTools()
	return ((sharpeye.GetVarNumber("sharpeye_opt_disablewithtools") > 0) and sharpeye.IsUsingSandboxTools())
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

function sharpeye.CalcView( ply, origin, angles, fov )
	if not sharpeye.IsEnabled() then return end
	if not sharpeye.IsMotionEnabled() then return end
	if not sharpeye.InMachinimaMode() and (sharpeye.IsNoclipping() or sharpeye.IsInVehicle() or sharpeye.ShouldMotionDisableWithTools() or sharpeye.ShouldMotionDisableInThirdPerson()) then return end
	

	if not sharpeye_dat.player_view then
		sharpeye_dat.player_view = {}
		sharpeye_dat.player_oriangle = Angle(0,0,0)
	end
	
	sharpeye_dat.player_oriangle.p = angles.p
	sharpeye_dat.player_oriangle.y = angles.y
	sharpeye_dat.player_oriangle.r = angles.r
	
	local view = sharpeye_dat.player_view
	view.origin = origin
	view.angles = angles
	view.fov = fov
	
	local relativeSpeed = ply:GetVelocity():Length() / sharpeye.GetBasisRunSpeed()
	local clampedSpeedCustom = (relativeSpeed > 3) and 1 or (relativeSpeed / 3)
	
	local shiftMod = sharpeye_dat.player_TimeShift + sharpeye_dat.player_Stamina * sharpeye.Detail_GetRunningBobFrequency() * ( 1 + clampedSpeedCustom ) / 2
	local distMod  = 1 + sharpeye_dat.player_Stamina * 7 * ( 2 + clampedSpeedCustom ) / 3
	local breatheMod  = 1 + sharpeye_dat.player_Stamina * sharpeye.Detail_GetBreatheBobDistance() * (1 - clampedSpeedCustom)^2
	
	sharpeye_dat.player_TimeShift = shiftMod
	
	view.origin.x = view.origin.x + sharpeye.Modulation(27, 1, shiftMod) * 1 * distMod
	view.origin.y = view.origin.y + sharpeye.Modulation(16, 1, shiftMod) * 1 * distMod
	view.origin.z = view.origin.z + sharpeye.Modulation(7 , 1, shiftMod) * 1 * distMod
	
	sharpeye_dat.player_PitchInfluence = sharpeye_dat.player_PitchInfluence * 0.75
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
			--local angleProspect = (1 - (1 - math.abs(angleDiff) / 110 ) ^ 2 ) * ((angleDiff > 0) and 110 or -110)
			--local angleProspect = ( 1 - (1 - math.abs(angleDiff) / 110 ) ^ 10 ) * ((angleDiff > 0) and 70 or -70)
			--local cosProspect = math.cos( math.rad( angleProspect * 2 ) )
			--print( angleDiff, angleProspect, cosProspect )
			--cosProspect = (1 - (1 - math.abs(cosProspect)) ^ 2) * ((cosProspect > 0) and 1 or -1)
			
			--rollCalc = ((angleDiff > 0) and 1 or -1) * (1 - ((1 - (math.abs(angleDiff) / 110)) ^ 2)) * sharpeye.Detail_GetLeaningAngle() * math.Clamp((relativeSpeed - 1.8), 0, 1) ^ 2 * -cosProspect
			--local angleProspect = (1 - (1 - math.abs(angleDiff) / 90 ) ^ 2 ) * ((angleDiff > 0) and 180 or -180)
			--print( angleDiff * 2, angleProspect )
			--rollCalc = ((angleDiff > 0) and 1 or -1) * (1 - ((1 - (math.abs(angleDiff) / 110)) ^ 2)) * sharpeye.Detail_GetLeaningAngle() * math.Clamp((relativeSpeed - 1.8), 0, 1)^2 * -math.cos( math.rad( angleProspect ) )
			--rollCalc = ((angleDiff > 0) and 1 or -1) * (1 - ((1 - (math.abs(angleDiff) / 110)) ^ 2)) * sharpeye.Detail_GetLeaningAngle() * math.Clamp((relativeSpeed - 1.8), 0, 1)^2 * -math.cos( math.rad( angleDiff * 2 ) )
			--rollCalc = (1 - ((1 - (angleDiff / 110)) ^ 2)) * 8
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

	
	local wep = ply:GetActiveWeapon()
	if ( ValidEntity( wep ) ) then
	
		local func = wep.GetViewModelPosition
		if ( func ) then
			view.vm_origin, view.vm_angles = func( wep, view.origin*1, view.angles*1 )
			view.vm_angles = view.vm_angles + (sharpeye_dat.player_oriangle - view.angles)
			
		else
			view.vm_origin = nil
			view.vm_angles = sharpeye_dat.player_oriangle
		end
		
		local func = wep.CalcView
		if ( func ) then view.origin, view.angles, view.fov = func( wep, ply, view.origin*1, view.angles*1, view.fov ) end
	else
		view.vm_origin = nil
		view.vm_angles = sharpeye_dat.player_oriangle
		
	end
	
	if sharpeye_focus and sharpeye_focus:IsEnabled() then
		sharpeye_focus:AppendCalcView( view )
	end
	
	return view
	
end

function sharpeye.GetMotionBlurValues( y, x, fwd, spin ) 
	if not sharpeye.IsEnabled() then return end
	if not sharpeye.IsMotionEnabled() then return end
	if not sharpeye.IsMotionBlurEnabled() then return end
	if sharpeye.IsInVehicle() then return end
	if sharpeye.ShouldMotionDisableInThirdPerson() then return end
	
	local ply = LocalPlayer()
	
	local relativeSpeed = ply:GetVelocity():Length() / sharpeye.GetBasisRunSpeed()
	local clampedSpeedCustom = (relativeSpeed > 3) and 1 or (relativeSpeed / 3)

	fwd = fwd + (clampedSpeedCustom ^ 2) * relativeSpeed * 0.005

	return y, x, fwd, spin

end
