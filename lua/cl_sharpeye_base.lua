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
	
	sharpeye_dat.player_RunSpeed = 128
	sharpeye_dat.player_LastRelSpeed = 0
	sharpeye_dat.player_LastWaterLevel = 0
	
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
	if not SinglePlayer() and not ply == LocalPlayer() then return end

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
	
	local shouldTriggerStopSound = (sharpeye_dat.player_LastRelSpeed - relativeSpeed) > 0.5
	sharpeye_dat.player_LastRelSpeed = relativeSpeed
	
	local shouldTriggerWaterFlop = (sharpeye_dat.player_LastWaterLevel - ply:WaterLevel()) <= -2
	sharpeye_dat.player_LastWaterLevel = ply:WaterLevel()
	
	local isInDeepWater = ply:WaterLevel() >= 3
	local isInModerateWater = (ply:WaterLevel() == 1) or (ply:WaterLevel() == 2)
	
	
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
			
	end
	
	sharpeye = nil
	sharpeye_dat = nil
	
	print("[ " .. SHARPEYE_NAME .. " is now unmounted. ]")
	print("")
end
