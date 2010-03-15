////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Motion                                     //
////////////////////////////////////////////////

function sharpeye.IsMotionEnabled()
	return ((sharpeye.GetVar("sharpeye_core_motion") or 0) > 0)
end

function sharpeye.Detail_GetBreatheBobDistance()
	-- Default is 5, so 30
	return (tonumber(sharpeye.GetVar("sharpeye_detail_breathebobdist")) * 0.1) * 60 * (3 - sharpeye.GetHealthFactor() * 2)
end

function sharpeye.Detail_GetRunningBobFrequency()
	-- Default is 5, so 0.2
	return 0.1 + (tonumber(sharpeye.GetVar("sharpeye_detail_runningbobfreq")) * 0.1) * 0.2
end

function sharpeye.CalcView( ply, origin, angles, fov )
	if not sharpeye.IsEnabled() then return end
	if not sharpeye.IsMotionEnabled() then return end
	if sharpeye.IsNoclipping() or sharpeye.IsInVehicle() then return end
	

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
		sharpeye_dat.player_PitchInfluence = sharpeye_dat.player_PitchInfluence + timeFactor * 12
	end
	
	local pitchMod = sharpeye_dat.player_PitchInfluence - ((sharpeye_dat.player_TimeOffGround > 0) and ((1 + ((sharpeye_dat.player_TimeOffGround > 2) and 1 or (sharpeye_dat.player_TimeOffGround / 2))) * 2) or 0)
	
	local rollCalc = 0
	if (relativeSpeed > 1) then
		local angleDiff = math.AngleDifference(ply:GetVelocity():Angle().y, ply:EyeAngles().y)
		if math.abs(angleDiff) < 110 then
			rollCalc = ((angleDiff > 0) and 1 or -1) * (1 - ((1 - (math.abs(angleDiff) / 110)) ^ 2)) * 8
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
	
	
	return view
	
end

function sharpeye.GetMotionBlurValues( y, x, fwd, spin ) 
	if not sharpeye.IsEnabled() then return end
	if not sharpeye.IsMotionEnabled() then return end
	if sharpeye.IsInVehicle() then return end
	
	local ply = LocalPlayer()
	
	local relativeSpeed = ply:GetVelocity():Length() / sharpeye.GetBasisRunSpeed()
	local clampedSpeedCustom = (relativeSpeed > 3) and 1 or (relativeSpeed / 3)

	fwd = fwd + (clampedSpeedCustom ^ 2) * relativeSpeed * 0.005

	return y, x, fwd, spin

end
