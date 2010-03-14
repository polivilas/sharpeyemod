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

function sharpeye.PlayerFootstep( ply, pos, foot, sound, volume, rf )
	if not sharpeye.IsEnabled() then return end
	if not sharpeye.IsSoundEnabled() then return end
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
	
end
