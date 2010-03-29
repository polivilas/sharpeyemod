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
	
	sharpeye_dat.breathing = {
		"sharpeye/breathe_male.wav",
		"sharpeye/breathe_female.wav",
		"sharpeye/breathe_mask.wav"
	}
	
	sharpeye_dat.soundtables = {
		sharpeye_dat.footsteps,
		sharpeye_dat.sloshsteps,
		sharpeye_dat.watersteps,
		sharpeye_dat.stops,
		sharpeye_dat.waterflop,
		sharpeye_dat.breathing
	}
	
	sharpeye_dat.crosshairshapes = {
		"depthhud/linebow_crosshair.vmt",
		"depthhud/X_CircleSolid.vmt"
	}
	
	--sharpeye_day.player_RunSpeed = 100
	sharpeye_dat.player_LastRelSpeed = 0
	sharpeye_dat.player_LastWaterLevel = 0
	
	sharpeye_dat.player_RelStop = 2.2
	
	sharpeye_dat.player_Stamina = 0
	sharpeye_dat.player_StaminaSpeedFactor = 0.01
	--sharpeye_dat.player_StaminaRecover    = 0.97
	
	sharpeye_dat.player_TimeOffGround = 0
	sharpeye_dat.player_TimeOffGroundWhenLanding = 0
	
	sharpeye_dat.player_PitchInfluence = 0
	sharpeye_dat.player_RollChange = 0
	
	sharpeye_dat.player_TimeShift = 0
	
	sharpeye_dat.bumpsounds_LastTime = 0
	sharpeye_dat.bumpsounds_delay    = 0.1
	
	
	sharpeye_dat.breathing_LastMode = -1
	sharpeye_dat.breathing_LastModel = ""
	sharpeye_dat.breathing_LastGender = 0
	sharpeye_dat.breathing_WasBreathing = false
	
	
	for _,subtable in pairs(sharpeye_dat.soundtables) do
		for k,path in pairs(subtable) do
			Sound(path)
		end
	end
	
end

-- Player status
function sharpeye.IsEnabled()
	return (sharpeye.GetVarNumber("sharpeye_core_enable") > 0)
end

function sharpeye.IsInVehicle()
	return LocalPlayer():InVehicle()
	
	--[[
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
	]]--
end

function sharpeye.InMachinimaMode()
	return (sharpeye.GetVarNumber("sharpeye_opt_machinimamode") > 0)
end

function sharpeye.IsNoclipping()
	return (LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP)
end

function sharpeye.IsUsingSandboxTools()
	local myWeapon = LocalPlayer():GetActiveWeapon()
	return ( ValidEntity(myWeapon) and ((myWeapon:GetClass() == "gmod_tool") or (myWeapon:GetClass() == "weapon_physgun")) )
end

-- Player custom status
function sharpeye.GetBasisHealthBehavior()
	-- Default is 5, so 0.5
	return math.Clamp(sharpeye.GetVarNumber("sharpeye_basis_healthbased") * 0.1, 0, 1)
end

function sharpeye.GetHealthFactor()
	-- returns 1 if Health doesn't count
	-- returns 1 if Player is in good health
	-- returns 0.? if player is in bad shape 	
	local behav = sharpeye.GetBasisHealthBehavior()
	return (1 - behav) + math.Clamp(LocalPlayer():Health() * 0.01, 0, 1) * behav
end

function sharpeye.GetBasisRunSpeed()
	-- Defaulted to 100
	return 1 + math.abs(sharpeye.GetVarNumber("sharpeye_basis_runspeed"))
end

function sharpeye.GetBasisStaminaRecover()
	-- Default is 5, so 0.25 that means 0.97
	return 0.995 - math.abs(sharpeye.GetVarNumber("sharpeye_basis_staminarecover") * 0.1 * 0.05) * sharpeye.GetHealthFactor()
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

function sharpeye.GetVarNumber( sVar )
	return (tonumber(sharpeye.GetVar(sVar)) or 0)
end

-- Data
function sharpeye.GamemodeInitialize()
	-- Try to solve compatibilities
	sharpeye.SolveCompatilibityIssues()
	
end

function sharpeye.Think( )
	if not sharpeye.IsEnabled() then return end
	
	if (CurTime() - sharpeye_dat.bumpsounds_LastTime) < sharpeye_dat.bumpsounds_delay then return end
	sharpeye_dat.bumpsounds_LastTime = CurTime()
	
	local ply = LocalPlayer()
	
	local relativeSpeed = ply:GetVelocity():Length() / sharpeye.GetBasisRunSpeed()
	local clampedSpeed = (relativeSpeed > 1) and 1 or relativeSpeed
	
	-- Stamina
	if not ply:Alive() then
		sharpeye_dat.player_Stamina = 0
		
	else
		sharpeye_dat.player_Stamina = sharpeye_dat.player_Stamina * sharpeye.GetBasisStaminaRecover() + sharpeye_dat.player_StaminaSpeedFactor * relativeSpeed
		sharpeye_dat.player_Stamina = (sharpeye_dat.player_Stamina > 1) and 1 or sharpeye_dat.player_Stamina
		
	end
	
	--print(sharpeye_dat.player_Stamina)
	
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

function sharpeye.RevertDetails()
	sharpeye.SetVar("sharpeye_detail_breathebobdist" , "5")
	sharpeye.SetVar("sharpeye_detail_runningbobfreq" , "5")
	sharpeye.SetVar("sharpeye_basis_runspeed" , "100")
	sharpeye.SetVar("sharpeye_basis_staminarecover" , "5")
	sharpeye.SetVar("sharpeye_basis_healthbased" , "5")
	sharpeye.SetVar("sharpeye_detail_leaningangle" , "5")
	sharpeye.SetVar("sharpeye_detail_landingangle" , "5")
	sharpeye.SetVar("sharpeye_snd_footsteps_vol" , "5")
	sharpeye.SetVar("sharpeye_snd_breathing_vol" , "5")
	
end

-- Load
function sharpeye.Mount()
	print("")
	print("[ Mounting " .. SHARPEYE_NAME .. " ... ]")
	
	sharpeye.CreateVar("sharpeye_core_enable", "1", true, false)
	sharpeye.CreateVar("sharpeye_core_motion", "1", true, false)
	sharpeye.CreateVar("sharpeye_core_sound" , "1", true, false)
	sharpeye.CreateVar("sharpeye_core_crosshair" , "1", true, false)
	sharpeye.CreateVar("sharpeye_opt_breathing" , "1", true, false)
	sharpeye.CreateVar("sharpeye_opt_disablewithtools" , "1", true, false)
	sharpeye.CreateVar("sharpeye_opt_machinimamode" , "0", true, false)
	sharpeye.CreateVar("sharpeye_opt_motionblur", "1", true, false)
	sharpeye.CreateVar("sharpeye_opt_disableinthirdperson", "1", true, false)
	
	sharpeye.CreateVar("sharpeye_detail_breathebobdist" , "5", true, false)
	sharpeye.CreateVar("sharpeye_detail_runningbobfreq" , "5", true, false)
	sharpeye.CreateVar("sharpeye_detail_leaningangle" , "5", true, false)
	sharpeye.CreateVar("sharpeye_detail_landingangle" , "5", true, false)
	sharpeye.CreateVar("sharpeye_basis_runspeed" , "100", true, false)
	sharpeye.CreateVar("sharpeye_basis_staminarecover" , "5", true, false)
	sharpeye.CreateVar("sharpeye_basis_healthbased" , "5", true, false)
	sharpeye.CreateVar("sharpeye_xhair_color_r" , "255", true, false)
	sharpeye.CreateVar("sharpeye_xhair_color_g" , "220", true, false)
	sharpeye.CreateVar("sharpeye_xhair_color_b" , "0", true, false)
	sharpeye.CreateVar("sharpeye_xhair_color_a" , "255", true, false)
	sharpeye.CreateVar("sharpeye_xhair_staticsize" , "8", true, false)
	sharpeye.CreateVar("sharpeye_xhair_dynamicsize" , "8", true, false)
	sharpeye.CreateVar("sharpeye_snd_footsteps_vol" , "5", true, false)
	sharpeye.CreateVar("sharpeye_snd_breathing_vol" , "5", true, false)
	sharpeye.InitializeData()
	
	if (SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT) then
		--If SinglePlayer, hook this server-side
		hook.Add("PlayerFootstep", "sharpeye_PlayerFootstep", sharpeye.PlayerFootstep)
		
	end
	
	if CLIENT then
		hook.Add("Think", "sharpeye_Think", sharpeye.Think)
		hook.Add("CalcView", "sharpeye_CalcView", sharpeye.CalcView)
		hook.Add("GetMotionBlurValues", "sharpeye_GetMotionBlurValues", sharpeye.GetMotionBlurValues)
		hook.Add("HUDPaint", "sharpeye_HUDPaint", sharpeye.HUDPaint)
		hook.Add("Initialize", "shapeye_Initialize", sharpeye.GamemodeInitialize)
		concommand.Add( "sharpeye_call_forcesolvecompatibilities", sharpeye.ForceSolveCompatilibityIssues)
		
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
		hook.Remove("HUDPaint", "sharpeye_HUDPaint")
		hook.Remove("Initialize", "shapeye_Initialize")
		concommand.Remove( "sharpeye_call_forcesolvecompatibilities")
			
		if sharpeye.UnmountMenu then
			sharpeye.UnmountMenu()
		end
	end
	
	sharpeye = nil
	sharpeye_dat = nil
	
	print("[ " .. SHARPEYE_NAME .. " is now unmounted. ]")
	print("")
end
