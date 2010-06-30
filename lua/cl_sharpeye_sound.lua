////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Sound                                      //
////////////////////////////////////////////////

function sharpeye.IsSoundEnabled()
	return (sharpeye.GetVarNumber("sharpeye_core_sound") > 0)
end

function sharpeye.GetBreathingMode()
	return math.Clamp( math.floor(sharpeye.GetVarNumber("sharpeye_opt_breathing")), 0, 4)
end

function sharpeye.GetBreathingVolume()
	return math.Clamp(sharpeye.GetVarNumber("sharpeye_snd_breathing_vol") * 0.1, 0, 1)
end

function sharpeye.GetFootstepsVolume()
	return math.Clamp(sharpeye.GetVarNumber("sharpeye_snd_footsteps_vol") * 0.1, 0, 1)
end

function sharpeye.GetWindVelocityIncap()
	-- Default is 5, so 350
	return 5 + math.Clamp( sharpeye.GetVarNumber("sharpeye_snd_windvelocityincap") * 50, 0, 16000)
end

function sharpeye.GetIsWindEnabled()
	return sharpeye.GetVarNumber("sharpeye_snd_windenable") > 0
end

function sharpeye.GetIsWindEnabledOnGround()
	return sharpeye.GetVarNumber("sharpeye_snd_windonground") > 0
end

function sharpeye.GetIsWindEnabledOnNoclip()
	return sharpeye.GetVarNumber("sharpeye_snd_windonnoclip") > 0
end

function sharpeye.GetBreathingGender()
	local mode = sharpeye.GetBreathingMode()
	if mode == 0 then return 0 end
	if mode > 1  then return (mode - 1) end
	
	local model = LocalPlayer():GetModel()
	if (model ~= sharpeye_dat.breathing_LastModel) or (sharpeye_dat.breathing_LastMode ~= mode) then
		if string.find(model, "female")
			or string.find(model, "alyx")
			or string.find(model, "mossman") then
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
	
	local sndPitch  = 30 + clampedSpeed * 128
	local sndVolume = 1 + ((sharpeye.GetFootstepsVolume() > 0) and (20 + clampedSpeed * sharpeye.GetFootstepsVolume() * 90) or 0)
	
	if not isInDeepWater and not isInModerateWater then
	
		local dice = sharpeye.DiceNoRepeat(sharpeye_dat.footsteps, sharpeye_dat.footsteps_LastPlayed)
		sharpeye_dat.footsteps_LastPlayed = dice
		
		ply:EmitSound(sharpeye_dat.footsteps[dice], sndVolume, sndPitch)
		
	elseif isInModerateWater then
	
		local dice = sharpeye.DiceNoRepeat(sharpeye_dat.sloshsteps, sharpeye_dat.sloshsteps_LastPlayed)
		sharpeye_dat.sloshsteps_LastPlayed = dice
		
		ply:EmitSound(sharpeye_dat.sloshsteps[dice], sndVolume, sndPitch * 0.8)
	
	else
		local dice = sharpeye.DiceNoRepeat(sharpeye_dat.watersteps, sharpeye_dat.watersteps_LastPlayed)
		sharpeye_dat.watersteps_LastPlayed = dice
		
		ply:EmitSound(sharpeye_dat.watersteps[dice], sndVolume, sndPitch * 0.8)
		
	end
	
	--return true
end

function sharpeye.Breathing()
	if not sharpeye.IsEnabled() then return end
	if not sharpeye.IsSoundEnabled() then return end
	if (sharpeye.GetBreathingMode() == 0) and (sharpeye_dat.breathing_LastGender == 0) then return end
	
	local gender = sharpeye.GetBreathingGender()
	--print(sharpeye.GetBreathingMode() , sharpeye.GetBreathingGender())
	
	if not sharpeye_dat.breathing_cached then
		sharpeye_dat.breathing_cached = {}
		
		for k,path in pairs(sharpeye_dat.breathing) do
			sharpeye_dat.breathing_cached[k] = CreateSound( LocalPlayer(), path )
		end
		
	end
	
	if sharpeye_dat.breathing_LastGender ~= gender then
		if sharpeye_dat.breathing_cached[sharpeye_dat.breathing_LastGender] then
			sharpeye_dat.breathing_cached[sharpeye_dat.breathing_LastGender]:Stop()
		end
		
		sharpeye_dat.breathing_WasBreathing = false
		
		--if (gender > 0) then
		--	sharpeye_dat.breathing_cached[gender]:PlayEx(0.0, 100)
		--end
	end
	
	if (gender > 0) then
		local fStamina = sharpeye.GetStamina()
		local breathingcap = 0.7 - (1 - sharpeye.GetHealthFactor()) * 0.4
		if (fStamina > breathingcap) then
			if not sharpeye_dat.breathing_WasBreathing then
				sharpeye_dat.breathing_cached[gender]:PlayEx(fStamina * sharpeye.GetBreathingVolume(), 100)
				sharpeye_dat.breathing_WasBreathing = true
				
			else
				sharpeye_dat.breathing_cached[gender]:ChangeVolume(fStamina * sharpeye.GetBreathingVolume(), 100)
				
			end
			
		elseif (fStamina < breathingcap) and sharpeye_dat.breathing_WasBreathing then
			sharpeye_dat.breathing_cached[gender]:FadeOut(0.5)
				sharpeye_dat.breathing_WasBreathing = false
			
		end
	end
	
	sharpeye.StoreBreathingGender()
	
end

function sharpeye.SoundWind()
	if not sharpeye.IsEnabled() then return end
	if not sharpeye.IsSoundEnabled() then return end
	if not sharpeye.GetIsWindEnabled() then return end
	
	local ply = LocalPlayer()
	
	if not sharpeye_dat.wind_cached then
		sharpeye_dat.wind_cached = {}
		
		for k,path in pairs(sharpeye_dat.wind) do
			sharpeye_dat.wind_cached[k] = CreateSound( ply, path )
		end
		
	end
	
	if not ply:Alive() and ValidEntity( ply:GetRagdollEntity() ) then
		sharpeye_dat.wind_velocity = ply:GetRagdollEntity():GetVelocity():Length()
		
	elseif not sharpeye.IsInVehicle() then
		sharpeye_dat.wind_velocity = ply:GetVelocity():Length()
	
	else
		sharpeye_dat.wind_velocity = ply:GetVehicle():GetVelocity():Length()
		
	end
	
	local iVeloIncap = sharpeye.GetWindVelocityIncap()
	if (sharpeye_dat.wind_velocity > iVeloIncap) then
		local shouldForce = sharpeye.GetIsWindEnabledOnGround() or not ply:Alive()
		local shouldNotPlay  = not sharpeye.GetIsWindEnabledOnNoclip() and sharpeye.IsNoclipping()
		local volume = shouldNotPlay and 0 or shouldForce and 1 or math.Clamp( (sharpeye_dat.player_TimeOffGround * 0.5) ^ 2 , 0, 1) * sharpeye_dat.wind_velocity / 64
		volume = (volume > 1) and 1 or volume
		
		local pitch = ( math.Clamp((sharpeye_dat.wind_velocity - iVeloIncap) / (iVeloIncap * 2), 0, 1) ) * 120 + 80
		if not sharpeye_dat.wind_IsPlaying then
			sharpeye_dat.wind_cached[1]:PlayEx(volume, pitch)
			sharpeye_dat.wind_IsPlaying = true
			
		else
			sharpeye_dat.wind_cached[1]:ChangeVolume(volume)
			sharpeye_dat.wind_cached[1]:ChangePitch(pitch)
			
		end
		
	--elseif sharpeye_dat.wind_IsPlaying then
	--	sharpeye_dat.wind_cached[1]:FadeOut(0.1)
	--	sharpeye_dat.wind_IsPlaying = false
	--	
	--end
	else
		-- The reason we're doing this is that stopping the sound plays it back to zero. It creates too much of a sense of loop
		sharpeye_dat.wind_cached[1]:ChangeVolume(0)
		
	end
	
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
	sharpeye.SoundWind()
	
end

