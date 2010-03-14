////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Base                                       //
////////////////////////////////////////////////

-- Initialization
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

-- Player status
function sharpeye.IsEnabled()
	return ((sharpeye.GetVar("sharpeye_core_enable") or 0) > 0)
end

function sharpeye.IsInVehicle()
	local ply = LocalPlayer()
	local Vehicle = ply:GetVehicle()
	if ( ValidEntity( Vehicle ) and gmod_vehicle_viewmode:GetInt() == 1 ) then
		return true
	end

	local ScriptedVehicle = ply:GetScriptedVehicle()
	if ( ValidEntity( ScriptedVehicle ) ) then
		return true
	end
	
	return false
end

function sharpeye.IsNoclipping()
	return (LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP)
end

-- Generation
function sharpeye.Modulation( magic, speedMod, shift )
	local aa = -1^magic        + (((0 + magic * 7 ) % 11) / 11) * 0.3
	local bb = -1^(magic % 7)  + (((7 + magic * 11) % 29) / 29) * 0.3
	local cc = -1^(magic % 11) + (((11 + magic * 3) % 37) / 37) * 0.3
	
	return math.sin( CurTime()*aa*speedMod + bb*6 + shift ) * math.sin( CurTime()*bb*speedMod + cc*6 + shift ) * math.sin( CurTime()*cc*speedMod + aa*6 + shift )
end

function sharpeye.DiceNoRepeat( myTable, lastUsed )
	local dice = math.random(1, #myTable - 1)
	if (dice >= lastUsed) then
		dice = dice + 1
	end
	
	return dice
end

-- Data
function sharpeye.Think( ) 
	if not sharpeye.IsEnabled() then return end
	
	if (CurTime() - sharpeye_dat.bumpsounds_LastTime) < sharpeye_dat.bumpsounds_delay then return end
	sharpeye_dat.bumpsounds_LastTime = CurTime()
	
	local ply = LocalPlayer()
	
	local relativeSpeed = ply:GetVelocity():Length() / sharpeye_dat.player_RunSpeed
	local clampedSpeed = (relativeSpeed > 1) and 1 or relativeSpeed
	
	-- Stamina
	sharpeye_dat.player_Stamina = sharpeye_dat.player_Stamina * sharpeye_dat.player_StaminaRecover + sharpeye_dat.player_StaminaSpeedFactor * relativeSpeed
	sharpeye_dat.player_Stamina = (sharpeye_dat.player_Stamina > 1) and 1 or sharpeye_dat.player_Stamina
	
	-- Reset previous tick ground landing memoryvar
	if sharpeye_dat.player_TimeOffGroundWhenLanding > 0 then
		sharpeye_dat.player_TimeOffGroundWhenLanding = 0
	end
	
	--print(sharpeye_dat.player_Stamina)
	
	local shouldTriggerStopSound = (sharpeye_dat.player_LastRelSpeed - relativeSpeed) > sharpeye_dat.player_RelStop
	local shouldTriggerWaterFlop = (sharpeye_dat.player_LastWaterLevel - ply:WaterLevel()) <= -2
	
	local isInDeepWater = ply:WaterLevel() >= 3
	local isInModerateWater = (ply:WaterLevel() == 1) or (ply:WaterLevel() == 2)
	
	-- Off ground
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
	
	-- Data store
	sharpeye_dat.player_LastRelSpeed = relativeSpeed
	sharpeye_dat.player_LastWaterLevel = ply:WaterLevel()
	
	-- Sound Think
	if sharpeye.SoundThink then
		sharpeye.SoundThink( shouldTriggerStopSound, shouldTriggerWaterFlop, isInModerateWater, isInDeepWater )
	end
	
end


-- Load
function sharpeye.Mount()
	print("")
	print("[ Mounting " .. SHARPEYE_NAME .. " ... ]")
	
	sharpeye.CreateVar("sharpeye_core_enable", "1", true, false)
	sharpeye.CreateVar("sharpeye_core_motion", "1", true, false)
	sharpeye.CreateVar("sharpeye_core_sound" , "1", true, false)
	sharpeye.CreateVar("sharpeye_core_crosshair" , "1", true, false)
	sharpeye.InitializeData()
	
	if (SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT) then
		--If SinglePlayer, hook this server-side
		hook.Add("PlayerFootstep", "sharpeye_PlayerFootstep", sharpeye.PlayerFootstep)
		
	end
	
	if CLIENT then
		hook.Add("Think", "sharpeye_Think", sharpeye.Think)
		hook.Add("CalcView", "sharpeye_CalcView", sharpeye.CalcView)
		hook.Add("GetMotionBlurValues", "sharpeye_GetMotionBlurValues", sharpeye.GetMotionBlurValues)
		
		if sharpeye.MountMenu then
			sharpeye.MountMenu()
		end
		
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
			
		if sharpeye.UnmountMenu then
			sharpeye.UnmountMenu()
		end
	end
	
	sharpeye = nil
	sharpeye_dat = nil
	
	print("[ " .. SHARPEYE_NAME .. " is now unmounted. ]")
	print("")
end
