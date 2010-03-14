////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Base                                       //
////////////////////////////////////////////////

function sharpeye.InitializeData() 
	sharpeye_dat.footsteps = {
		"sharpeye/boots1.wav",
		"sharpeye/boots2.wav",
		"sharpeye/boots3.wav",
		"sharpeye/boots4.wav"
	}
	sharpeye_dat.footsteps_LastPlayed = 1
	
	sharpeye_dat.sloshsteps = {
		"sharpeye/slosh1.wav",
		"sharpeye/slosh2.wav",
		"sharpeye/slosh3.wav",
		"sharpeye/slosh4.wav"
	}
	sharpeye_dat.sloshsteps_LastPlayed = 1

	sharpeye_dat.watersteps = {
		"sharpeye/waterstep1.wav",
		"sharpeye/waterstep2.wav",
		"sharpeye/waterstep3.wav",
		"sharpeye/waterstep4.wav"
	}
	sharpeye_dat.watersteps_LastPlayed = 1
	
	sharpeye_dat.stops = {
		"sharpeye/gear1.wav",
		"sharpeye/gear2.wav",
		"sharpeye/gear3.wav",
		"sharpeye/gear4.wav",
		"sharpeye/gear5.wav",
		"sharpeye/gear6.wav"
	}
	sharpeye_dat.stops_LastPlayed = 1
	
	sharpeye_dat.waterflop = {
		"sharpeye/water_splash1.wav",
		"sharpeye/water_splash2.wav",
		"sharpeye/water_splash3.wav"
	}
	sharpeye_dat.waterflop_LastPlayed = 1
	
	sharpeye_dat.player_RunSpeed = 100
	sharpeye_dat.player_LastRelSpeed = 0
	sharpeye_dat.player_LastWaterLevel = 0
	
	sharpeye_dat.player_RelStop = 2.2
	
	sharpeye_dat.player_Stamina = 0
	sharpeye_dat.player_StaminaSpeedFactor = 0.01
	sharpeye_dat.player_StaminaRecover     = 0.97
	
	sharpeye_dat.player_TimeOffGround = 0
	sharpeye_dat.player_TimeOffGroundWhenLanding = 0
	
	sharpeye_dat.player_PitchInfluence = 0
	sharpeye_dat.player_RollChange = 0
	
	sharpeye_dat.player_TimeShift = 0
	
	sharpeye_dat.bumpsounds_LastTime = 0
	sharpeye_dat.bumpsounds_delay    = 0.1
	
	
end

function sharpeye.DiceNoRepeat( myTable, lastUsed )
	local dice = math.random(1, #myTable - 1)
	if (dice >= lastUsed) then
		dice = dice + 1
	end
	
	return dice
end

function sharpeye.PlayerFootstep( ply, pos, foot, sound, volume, rf )
	if not sharpeye.IsEnabled() then return end
	if not SinglePlayer() and not (ply == LocalPlayer()) then return end

	local relativeSpeed = ply:GetVelocity():Length() / sharpeye_dat.player_RunSpeed
	local clampedSpeed = (relativeSpeed > 1) and 1 or relativeSpeed
	
	local isInDeepWater = ply:WaterLevel() >= 3
	local isInModerateWater = (ply:WaterLevel() == 1) or (ply:WaterLevel() == 2)
	
	if not isInDeepWater and not isInModerateWater then
	
		local dice = sharpeye.DiceNoRepeat(sharpeye_dat.footsteps, sharpeye_dat.footsteps_LastPlayed)
		sharpeye_dat.footsteps_LastPlayed = dice
		
		ply:EmitSound(sharpeye_dat.footsteps[dice], 30 + clampedSpeed * 128, 80 + clampedSpeed * 70)
		
	elseif isInModerateWater then
	
		local dice = sharpeye.DiceNoRepeat(sharpeye_dat.sloshsteps, sharpeye_dat.sloshsteps_LastPlayed)
		sharpeye_dat.sloshsteps_LastPlayed = dice
		
		ply:EmitSound(sharpeye_dat.sloshsteps[dice], 30 + clampedSpeed * 128, 80 + clampedSpeed * 50)
	
	else
		local dice = sharpeye.DiceNoRepeat(sharpeye_dat.watersteps, sharpeye_dat.watersteps_LastPlayed)
		sharpeye_dat.watersteps_LastPlayed = dice
		
		ply:EmitSound(sharpeye_dat.watersteps[dice], 30 + clampedSpeed * 128, 80 + clampedSpeed * 70)
		
	end
	
	--return true
end

function sharpeye.Think( ) 
	if not sharpeye.IsEnabled() then return end
	if (CurTime() - sharpeye_dat.bumpsounds_LastTime) < sharpeye_dat.bumpsounds_delay then return end
	sharpeye_dat.bumpsounds_LastTime = CurTime()
	
	local ply = LocalPlayer()
	
	local relativeSpeed = ply:GetVelocity():Length() / sharpeye_dat.player_RunSpeed
	local clampedSpeed = (relativeSpeed > 1) and 1 or relativeSpeed
	
	
	sharpeye_dat.player_Stamina = sharpeye_dat.player_Stamina * sharpeye_dat.player_StaminaRecover + sharpeye_dat.player_StaminaSpeedFactor * relativeSpeed
	sharpeye_dat.player_Stamina = (sharpeye_dat.player_Stamina > 1) and 1 or sharpeye_dat.player_Stamina
	
	if sharpeye_dat.player_TimeOffGroundWhenLanding > 0 then
		sharpeye_dat.player_TimeOffGroundWhenLanding = 0
	end
	
	--print(sharpeye_dat.player_Stamina)
	
	local shouldTriggerStopSound = (sharpeye_dat.player_LastRelSpeed - relativeSpeed) > sharpeye_dat.player_RelStop
	sharpeye_dat.player_LastRelSpeed = relativeSpeed
	
	local shouldTriggerWaterFlop = (sharpeye_dat.player_LastWaterLevel - ply:WaterLevel()) <= -2
	sharpeye_dat.player_LastWaterLevel = ply:WaterLevel()
	
	local isInDeepWater = ply:WaterLevel() >= 3
	local isInModerateWater = (ply:WaterLevel() == 1) or (ply:WaterLevel() == 2)
	
	if not ply:IsOnGround() then
		if not isInDeepWater then
			sharpeye_dat.player_TimeOffGround = sharpeye_dat.player_TimeOffGround + sharpeye_dat.bumpsounds_delay
		else
			sharpeye_dat.player_TimeOffGround = 0
		end
		
	elseif sharpeye_dat.player_TimeOffGround > 0 then
		sharpeye_dat.player_TimeOffGroundWhenLanding = sharpeye_dat.player_TimeOffGround
		sharpeye_dat.player_TimeOffGround = 0	
	
	end
	
	if shouldTriggerStopSound and not shouldTriggerWaterFlop and not isInModerateWater and not isInDeepWater and (ply:GetMoveType() ~= MOVETYPE_NOCLIP) then
		local dice = sharpeye.DiceNoRepeat(sharpeye_dat.stops, sharpeye_dat.footsteps_LastPlayed)
		sharpeye_dat.footsteps_LastPlayed = dice
	
		ply:EmitSound(sharpeye_dat.stops[dice], 128, math.random(95, 105))
	end
	
	if shouldTriggerWaterFlop then
		local dice = sharpeye.DiceNoRepeat(sharpeye_dat.waterflop, sharpeye_dat.waterflop_LastPlayed)
		sharpeye_dat.waterflop_LastPlayed = dice
		
		ply:EmitSound(sharpeye_dat.waterflop[dice], 128, math.random(95, 105))
	end
	
	--return true
end

function sharpeye.Modulation( magic, speedMod, shift )
	local aa = -1^magic        + (((0 + magic * 7 ) % 11) / 11) * 0.3
	local bb = -1^(magic % 7)  + (((7 + magic * 11) % 29) / 29) * 0.3
	local cc = -1^(magic % 11) + (((11 + magic * 3) % 37) / 37) * 0.3
	
	return math.sin( CurTime()*aa*speedMod + bb*6 + shift ) * math.sin( CurTime()*bb*speedMod + cc*6 + shift ) * math.sin( CurTime()*cc*speedMod + aa*6 + shift )
end

function sharpeye.CalcView( ply, origin, angles, fov )
	if not sharpeye.IsEnabled() then return end

	if not sharpeye_dat.player_view then
		sharpeye_dat.player_view = {}
	end
	
	local view = sharpeye_dat.player_view
	view.origin = origin
	view.angles = angles
	view.fov = fov
	
	local relativeSpeed = ply:GetVelocity():Length() / sharpeye_dat.player_RunSpeed
	local clampedSpeedCustom = (relativeSpeed > 3) and 1 or (relativeSpeed / 3)
	
	local shiftMod = sharpeye_dat.player_TimeShift + sharpeye_dat.player_Stamina * 0.2 * ( 1 + clampedSpeedCustom ) / 2
	local distMod  = 1 + sharpeye_dat.player_Stamina * 7 * ( 2 + clampedSpeedCustom ) / 3
	local breatheMod  = 1 + sharpeye_dat.player_Stamina * 30 * (1 - clampedSpeedCustom)^2
	
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
			rollCalc = angleDiff * 0.15
		else
			rollCalc = 0
		end
		
	else
		rollCalc = 0
		
	end
	sharpeye_dat.player_RollChange = sharpeye_dat.player_RollChange + (rollCalc - sharpeye_dat.player_RollChange) * math.Clamp( 0.2 * FrameTime() * 25 , 0 , 1 )
	
	view.angles.p = view.angles.p + sharpeye.Modulation(8 , 1, shiftMod * 0.7) * 0.2 * breatheMod + pitchMod
	view.angles.y = view.angles.y + sharpeye.Modulation(11, 1, shiftMod) * 0.1 * distMod
	view.angles.r = view.angles.r + sharpeye.Modulation(24, 1, shiftMod) * 0.1 * distMod - sharpeye_dat.player_RollChange

	//--[[
	local wep = ply:GetActiveWeapon()
	if ( ValidEntity( wep ) ) then
	
		local func = wep.GetViewModelPosition
		if ( func ) then
			view.vm_origin, view.vm_angles = func( wep, view.origin*1, view.angles*1 )
		else
			view.vm_origin = nil
			view.vm_angles = nil
		end
		
		local func = wep.CalcView
		if ( func ) then view.origin, view.angles, view.fov = func( wep, ply, view.origin*1, view.angles*1, view.fov ) end
	else
		view.vm_origin = nil
		view.vm_angles = nil
		
	end
	//]]--
	
	return view
	
end

function sharpeye.GetMotionBlurValues( y, x, fwd, spin ) 
	if not sharpeye.IsEnabled() then return end
	
	local ply = LocalPlayer()
	
	local relativeSpeed = ply:GetVelocity():Length() / sharpeye_dat.player_RunSpeed
	local clampedSpeedCustom = (relativeSpeed > 3) and 1 or (relativeSpeed / 3)

	fwd = fwd + (clampedSpeedCustom ^ 2) * relativeSpeed * 0.005

	return y, x, fwd, spin

end

function sharpeye.IsEnabled()
	return ((sharpeye.GetVar("sharpeye_core_enable") or 0) > 0)
end

function sharpeye.Mount()
	print("")
	print("[ Mounting " .. SHARPEYE_NAME .. " ... ]")
	
	sharpeye.CreateVar("sharpeye_core_enable", "1", true, false)
	sharpeye.InitializeData()
	
	if (SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT) then
		--If SinglePlayer, hook this server-side
		hook.Add("PlayerFootstep", "sharpeye_PlayerFootstep", sharpeye.PlayerFootstep)
		
	end
	
	if CLIENT then
		hook.Add("Think", "sharpeye_Think", sharpeye.Think)
		hook.Add("CalcView", "sharpeye_CalcView", sharpeye.CalcView)
		hook.Add("GetMotionBlurValues", "sharpeye_GetMotionBlurValues", sharpeye.GetMotionBlurValues)
		
	end
	
	print("[ " .. SHARPEYE_NAME .. " is now mounted. ]")
	print("")
end

function sharpeye.Unmount()
	print("")
	print("] Unmounting " .. SHARPEYE_NAME .. " ... [")

	if (SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT) then
		hook.Remove("PlayerFootstep", "sharpeye_PlayerFootstep")
		
	end
	
	if CLIENT then
		hook.Remove("Think", "sharpeye_Think")
		hook.Remove("CalcView", "sharpeye_CalcView")
		hook.Remove("GetMotionBlurValues", "sharpeye_GetMotionBlurValues")
			
	end
	
	sharpeye = nil
	sharpeye_dat = nil
	
	print("[ " .. SHARPEYE_NAME .. " is now unmounted. ]")
	print("")
end
