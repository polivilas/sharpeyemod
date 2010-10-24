////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Sound                                      //
////////////////////////////////////////////////
local sharpeye = sharpeye

function sharpeye:IsSoundEnabled()
	return self:GetVar("core_sound") > 0
end

function sharpeye:GetBreathingMode()
	return math.Clamp( math.floor(self:GetVar("opt_breathing")), 0, 4)
end

function sharpeye:GetBreathingVolume()
	return math.Clamp(self:GetVar("snd_breathing_vol") * 0.1, 0, 1)
end

function sharpeye:GetFootstepsVolume()
	return math.Clamp(self:GetVar("snd_footsteps_vol") * 0.1, 0, 1)
end

function sharpeye:GetWindVelocityIncap()
	-- Default is 5, so 350
	return 5 + math.Clamp( self:GetVar("snd_windvelocityincap") * 50, 0, 16000)
end

function sharpeye:GetIsWindEnabled()
	return self:GetVar("snd_windenable") > 0
end

function sharpeye:GetIsWindEnabledOnGround()
	return self:GetVar("snd_windonground") > 0
end

function sharpeye:GetIsWindEnabledOnNoclip()
	return self:GetVar("snd_windonnoclip") > 0
end

function sharpeye:GetBreathingGender()
	local mode = self:GetBreathingMode()
	if mode == 0 then return 0 end
	if mode > 1  then return (mode - 1) end
	
	local model = LocalPlayer():GetModel()
	if (model ~= self.dat.breathing_LastModel) or (self.dat.breathing_LastMode ~= mode) then
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
		return self.dat.breathing_LastGender
		
	end
end

function sharpeye:StoreBreathingGender()
	self.dat.breathing_LastGender = self:GetBreathingGender()
	self.dat.breathing_LastModel  = LocalPlayer():GetModel()
	self.dat.breathing_LastMode   = self:GetBreathingMode()
end

function sharpeye.PlayerFootstep( ply, pos, foot, sound, volume, rf )
	local self = sharpeye
	
	if not self:IsEnabled() then return end
	if not self:IsSoundEnabled() then return end
	if not SinglePlayer() and not (ply == LocalPlayer()) then return end

	local relativeSpeed = ply:GetVelocity():Length() / self:GetBasisRunSpeed()
	local clampedSpeed = (relativeSpeed > 1) and 1 or relativeSpeed
	
	local isInDeepWater = ply:WaterLevel() >= 3
	local isInModerateWater = (ply:WaterLevel() == 1) or (ply:WaterLevel() == 2)
	
	local sndPitch  = 30 + clampedSpeed * 128
	local sndVolume = 1 + ((self:GetFootstepsVolume() > 0) and (20 + clampedSpeed * self:GetFootstepsVolume() * 90) or 0)
	
	if not isInDeepWater and not isInModerateWater then
	
		local dice = sharpeye_util.DiceNoRepeat(self.dat.footsteps, self.dat.footsteps_LastPlayed)
		self.dat.footsteps_LastPlayed = dice
		
		ply:EmitSound(self.dat.footsteps[dice], sndVolume, sndPitch)
		
	elseif isInModerateWater then
	
		local dice = sharpeye_util.DiceNoRepeat(self.dat.sloshsteps, self.dat.sloshsteps_LastPlayed)
		self.dat.sloshsteps_LastPlayed = dice
		
		ply:EmitSound(self.dat.sloshsteps[dice], sndVolume, sndPitch * 0.8)
	
	else
		local dice = sharpeye_util.DiceNoRepeat(self.dat.watersteps, self.dat.watersteps_LastPlayed)
		self.dat.watersteps_LastPlayed = dice
		
		ply:EmitSound(self.dat.watersteps[dice], sndVolume, sndPitch * 0.8)
		
	end
	
	--return true
end

function sharpeye:Breathing()
	if not self:IsEnabled() then return end
	if not self:IsSoundEnabled() then return end
	if (self:GetBreathingMode() == 0) and (self.dat.breathing_LastGender == 0) then return end
	
	local gender = self:GetBreathingGender()
	
	if not self.dat.breathing_cached then
		self.dat.breathing_cached = {}
		
		for k,path in pairs(self.dat.breathing) do
			self.dat.breathing_cached[k] = CreateSound( LocalPlayer(), path )
		end
		
	end
	
	if self.dat.breathing_LastGender ~= gender then
		if self.dat.breathing_cached[self.dat.breathing_LastGender] then
			self.dat.breathing_cached[self.dat.breathing_LastGender]:Stop()
		end
		
		self.dat.breathing_WasBreathing = false
		
		--if (gender > 0) then
		--	self.dat.breathing_cached[gender]:PlayEx(0.0, 100)
		--end
	end
	
	if (gender > 0) then
		local fStamina = self:GetStamina()
		local breathingcap = 0.7 - (1 - self:GetHealthFactor()) * 0.4
		if (fStamina > breathingcap) then
			if not self.dat.breathing_WasBreathing then
				self.dat.breathing_cached[gender]:PlayEx(fStamina * self:GetBreathingVolume(), 100)
				self.dat.breathing_WasBreathing = true
				
			else
				self.dat.breathing_cached[gender]:ChangeVolume(fStamina * self:GetBreathingVolume(), 100)
				
			end
			
		elseif (fStamina < breathingcap) and self.dat.breathing_WasBreathing then
			self.dat.breathing_cached[gender]:FadeOut(0.5)
				self.dat.breathing_WasBreathing = false
			
		end
	end
	
	self:StoreBreathingGender()
	
end

function sharpeye:SoundWind()
	if not self:IsEnabled() then return end
	if not self:IsSoundEnabled() then return end
	if not self:GetIsWindEnabled() then return end
	
	local ply = LocalPlayer()
	
	if not self.dat.wind_cached then
		self.dat.wind_cached = {}
		
		for k,path in pairs(self.dat.wind) do
			self.dat.wind_cached[k] = CreateSound( ply, path )
		end
		
	end
	
	if not ply:Alive() and ValidEntity( ply:GetRagdollEntity() ) then
		self.dat.wind_velocity = ply:GetRagdollEntity():GetVelocity():Length()
		
	elseif not self:IsInVehicle() then
		self.dat.wind_velocity = ply:GetVelocity():Length()
	
	else
		self.dat.wind_velocity = ply:GetVehicle():GetVelocity():Length()
		
	end
	
	local iVeloIncap = self:GetWindVelocityIncap()
	if (self.dat.wind_velocity > iVeloIncap) then
		local shouldForce = self:GetIsWindEnabledOnGround() or not ply:Alive()
		local shouldNotPlay  = not self:GetIsWindEnabledOnNoclip() and self:IsNoclipping()
		local volume = shouldNotPlay and 0 or shouldForce and 1 or math.Clamp( (self.dat.player_TimeOffGround * 0.5) ^ 2 , 0, 1) * self.dat.wind_velocity / 64
		volume = (volume > 1) and 1 or volume
		
		local pitch = ( math.Clamp((self.dat.wind_velocity - iVeloIncap) / (iVeloIncap * 2), 0, 1) ) * 120 + 80
		if not self.dat.wind_IsPlaying then
			self.dat.wind_cached[1]:PlayEx(volume, pitch)
			self.dat.wind_IsPlaying = true
			
		else
			self.dat.wind_cached[1]:ChangeVolume(volume)
			self.dat.wind_cached[1]:ChangePitch(pitch)
			
		end
		
	--elseif self.dat.wind_IsPlaying then
	--	self.dat.wind_cached[1]:FadeOut(0.1)
	--	self.dat.wind_IsPlaying = false
	--	
	--end
	else
		-- The reason we're doing this is that stopping the sound plays it back to zero. It creates too much of a sense of loop
		self.dat.wind_cached[1]:ChangeVolume(0)
		
	end
	
end

function sharpeye:SoundThink(shouldTriggerStopSound, shouldTriggerWaterFlop, isInModerateWater, isInDeepWater)
	if not self:IsEnabled() then return end
	if not self:IsSoundEnabled() then return end
	
	local ply = LocalPlayer()
	
	if shouldTriggerStopSound and not shouldTriggerWaterFlop and not isInModerateWater and not isInDeepWater and not self:IsNoclipping() then
		local dice = sharpeye_util.DiceNoRepeat(self.dat.stops, self.dat.footsteps_LastPlayed)
		self.dat.footsteps_LastPlayed = dice
	
		ply:EmitSound(self.dat.stops[dice], 128, math.random(95, 105))
	end
	
	if shouldTriggerWaterFlop then
		local dice = sharpeye_util.DiceNoRepeat(self.dat.waterflop, self.dat.waterflop_LastPlayed)
		self.dat.waterflop_LastPlayed = dice
		
		ply:EmitSound(self.dat.waterflop[dice], 128, math.random(95, 105))
	end
	
	self:Breathing()
	self:SoundWind()
	
end

