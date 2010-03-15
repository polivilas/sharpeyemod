////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Sound                                      //
////////////////////////////////////////////////

function sharpeye.IsSoundEnabled()
	return ((sharpeye.GetVar("sharpeye_core_sound") or 0) > 0)
end

function sharpeye.GetBreathingMode()
	return math.Clamp( math.floor(sharpeye.GetVar("sharpeye_breathing")), 0, 4)
end

function sharpeye.GetBreathingGender()
	local mode = sharpeye.GetBreathingMode()
	if mode == 0 then return 0 end
	if mode > 1  then return (mode - 1) end
	
	local model = LocalPlayer():GetModel()
	if (model ~= sharpeye_dat.breathing_LastModel) or (sharpeye_dat.breathing_LastMode ~= mode) then
		if string.find(model, "female")
			or string.find(model, "alyx")
			or string.find(model, "mossman")
			or string.find(model, "gman") then
			return 2
			
		elseif string.find(model, "male")
			or string.find(model, "barney")
			or string.find(model, "kleiner")
			or string.find(model, "monk")
			or string.find(model, "breen")
			or string.find(model, "eli")
			or string.find(model, "gman")
			or string.find(model, "odessa") then
			return 1
			
		else
			return 3
			
		end
		
	else
		return sharpeye_dat.breathing_LastGender
		
	end
end

function sharpeye.StoreBreathingGender()
	sharpeye_dat.breathing_LastGender = sharpeye.GetBreathingGender()
	sharpeye_dat.breathing_LastModel  = LocalPlayer():GetModel()
	sharpeye_dat.breathing_LastMode   = sharpeye.GetBreathingMode()
end

function sharpeye.PlayerFootstep( ply, pos, foot, sound, volume, rf )
	if not sharpeye.IsEnabled() then return end
	if not sharpeye.IsSoundEnabled() then return end
	if not SinglePlayer() and not (ply == LocalPlayer()) then return end

	local relativeSpeed = ply:GetVelocity():Length() / sharpeye.GetBasisRunSpeed()
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

function sharpeye.Breathing()
	if not sharpeye.IsEnabled() then return end
	if not sharpeye.IsSoundEnabled() then return end
	if (sharpeye.GetBreathingMode() == 0) then return end
	
	local gender = sharpeye.GetBreathingGender()
	--print(sharpeye.GetBreathingMode() , sharpeye.GetBreathingGender())
	
	if not sharpeye_dat.breathing_cached then
		sharpeye_dat.breathing_cached = {}
		
		for k,path in pairs(sharpeye_dat.breathing) do
			sharpeye_dat.breathing_cached[k] = CreateSound( LocalPlayer(), path )
		end
		
	end
	
	if sharpeye_dat.breathing_LastGender ~= gender then
		if sharpeye_dat.breathing_cached[sharpeye_dat.breathing_LastTrack] then
			sharpeye_dat.breathing_cached[sharpeye_dat.breathing_LastTrack]:Stop()
		end
		
		sharpeye_dat.breathing_WasBreathing = false
		
		--if (gender > 0) then
		--	sharpeye_dat.breathing_cached[gender]:PlayEx(0.0, 100)
		--end
	end
	
	local breathingcap = 0.7 - (1 - sharpeye.GetHealthFactor()) * 0.4
	
	if (sharpeye_dat.player_Stamina > breathingcap) then
		if not sharpeye_dat.breathing_WasBreathing then
			sharpeye_dat.breathing_cached[gender]:PlayEx(sharpeye_dat.player_Stamina * sharpeye_dat.breathing_MaxVolume, 100)
			sharpeye_dat.breathing_WasBreathing = true
			
		else
			sharpeye_dat.breathing_cached[gender]:ChangeVolume(sharpeye_dat.player_Stamina * sharpeye_dat.breathing_MaxVolume, 100)
			
		end
		
	elseif (sharpeye_dat.player_Stamina < breathingcap) and sharpeye_dat.breathing_WasBreathing then
		sharpeye_dat.breathing_cached[gender]:FadeOut(0.5)
			sharpeye_dat.breathing_WasBreathing = false
		
	end
	
	sharpeye.StoreBreathingGender()
	
end

function sharpeye.SoundThink(shouldTriggerStopSound, shouldTriggerWaterFlop, isInModerateWater, isInDeepWater)
	if not sharpeye.IsEnabled() then return end
	if not sharpeye.IsSoundEnabled() then return end
	
	local ply = LocalPlayer()
	
	if shouldTriggerStopSound and not shouldTriggerWaterFlop and not isInModerateWater and not isInDeepWater and not sharpeye.IsNoclipping() then
		local dice = sharpeye.DiceNoRepeat(sharpeye_dat.stops, sharpeye_dat.footsteps_LastPlayed)
		sharpeye_dat.footsteps_LastPlayed = dice
	
		ply:EmitSound(sharpeye_dat.stops[dice], 128, math.random(95, 105))
	end
	
	if shouldTriggerWaterFlop then
		local dice = sharpeye.DiceNoRepeat(sharpeye_dat.waterflop, sharpeye_dat.waterflop_LastPlayed)
		sharpeye_dat.waterflop_LastPlayed = dice
		
		ply:EmitSound(sharpeye_dat.waterflop[dice], 128, math.random(95, 105))
	end
	
	sharpeye.Breathing()
	
end

