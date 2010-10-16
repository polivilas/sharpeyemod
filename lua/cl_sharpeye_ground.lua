////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Ground                                     //
////////////////////////////////////////////////
local sharpeye = sharpeye

function sharpeye:IsInVehicle()
	return LocalPlayer():InVehicle()
	
end

function sharpeye:InMachinimaMode()
	return self:GetVar("opt_machinimamode") > 0
end

function sharpeye:IsNoclipping()
	return LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP
end

function sharpeye:IsUsingSandboxTools()
	local myWeapon = LocalPlayer():GetActiveWeapon()
	return ( ValidEntity(myWeapon) and ((myWeapon:GetClass() == "gmod_tool") or (myWeapon:GetClass() == "weapon_physgun")) )
end

function sharpeye:EXT_IsPCSEnabled()
	return self:GetVar("ext_perfectedclimbswep") > 0
end

-- Player custom status
function sharpeye:GetBasisHealthBehavior()
	-- Default is 5, so 0.5
	return math.Clamp(self:GetVar("basis_healthbased") * 0.1, 0, 1)
end

function sharpeye:GetBasisHealthyLevel()
	-- Default is 100, so 100
	return math.Clamp(self:GetVar("basis_healthylevel"), 1, 10000)
end

function sharpeye:GetHealthFactor()
	-- returns 1 if Health doesn't count
	-- returns 1 if Player is in good health
	-- returns 0.? if player is in bad shape 	
	local behav = self:GetBasisHealthBehavior()
	return (1 - behav) + math.Clamp(LocalPlayer():Health() / self:GetBasisHealthyLevel(), 0, 1) * behav
end

function sharpeye:GetBasisRunSpeed()
	-- Defaulted to 100
	-- Assume the end user will never make it negative.
	return 1 + self:GetVar("basis_runspeed")
end

function sharpeye:GetBasisStaminaRecover()
	-- Default is 5, so 0.25 that means 0.97
	-- Assume the end user will never make it negative.
	return 0.995 - self:GetVar("basis_staminarecover") * 0.005 * self:GetHealthFactor()
end

function sharpeye:GetStamina()
	// IMPORTANT : sharpeye used for LEGACY WITH BlackOps' Legs
	
	-- Dorky return ><
	if sharpeye:EXT_IsPCSEnabled() then
		local weapon = LocalPlayer():GetActiveWeapon()
		if ValidEntity( weapon ) and (weapon:GetClass() == "climb_swep") then
			
			return math.Max(sharpeye.dat.player_Stamina, 1 - (LocalPlayer():GetNWInt("FATIG_AMOUNT") or 100) * 0.01)
		end
		
	end
	
	return sharpeye.dat.player_Stamina
end

-- Generation
/*function sharpeye:Modulation( magic, speedMod, shift )
	local aa = -1^magic        + (((0 + magic * 7 ) % 11) / 11) * 0.3
	local bb = -1^(magic % 7)  + (((7 + magic * 11) % 29) / 29) * 0.3
	local cc = -1^(magic % 11) + (((11 + magic * 3) % 37) / 37) * 0.3
	
	return math.sin( CurTime()*aa*speedMod + bb*6 + shift ) * math.sin( CurTime()*bb*speedMod + cc*6 + shift ) * math.sin( CurTime()*cc*speedMod + aa*6 + shift )
end*/

function sharpeye:Modulation( magic, speedMod, shift )
	local aa = -1^magic        + (( magic * 7 ) % 11) * 0.027
	local bb = -1^(magic % 7)  + ((7 + magic * 11) % 29) * 0.011
	local cc = -1^(magic % 11) + ((11 + magic * 3) % 37) * 0.008
	
	return math.sin( CurTime()*aa*speedMod + bb*6 + shift ) * math.sin( CurTime()*bb*speedMod + cc*6 + shift ) * math.sin( CurTime()*cc*speedMod + aa*6 + shift )
end

function sharpeye:DiceNoRepeat( myTable, lastUsed )
	local dice = math.random(1, #myTable - 1)
	if (dice >= lastUsed) then
		dice = dice + 1
	end
	
	return dice
end

-- Data
function sharpeye:GamemodeInitialize()
	-- Try to solve compatibilities
	self:SolveCompatilibityIssues()
	
end

function sharpeye.Think( )
	local self = sharpeye
	
	if not self:IsEnabled() then
		-- There's already a check in UnhookMotion
		self:UnhookMotion()
		self:UnhookFocus()
		return
	end
	
	if self:IsMotionEnabled() then
		-- There's already a check in there
		self:HookMotion()
		
		if self:IsFocusEnabled() then
			self:HookFocus()
			
		else
			self:UnhookFocus()
			
		end
		
	else
		-- There's already a check in there
		self:UnhookMotion()
		self:UnhookFocus()
		-- Can't collapse with IsEnabled due to return
		
	end
	
	local ply = LocalPlayer()
	
	local relativeSpeed = ply:GetVelocity():Length() / self:GetBasisRunSpeed()
	local clampedSpeed = (relativeSpeed > 1) and 1 or relativeSpeed
	
	local correction = math.Clamp(FrameTime() * 33, 0, 1)
	
	-- Crouch
	self.dat.player_CrouchSmooth = self.dat.player_CrouchSmooth + ((ply:Crouching() and 1 or 0) - self.dat.player_CrouchSmooth) * correction * 0.05
	
	-- Stamina
	if not ply:Alive() then
		self.dat.player_Stamina = 0
		
	else
		self.dat.player_Stamina = self.dat.player_Stamina + (-1 * self.dat.player_Stamina * (1 - self:GetBasisStaminaRecover()) * (1 - relativeSpeed) + self.dat.player_StaminaSpeedFactor * relativeSpeed) * correction * 0.2
		self.dat.player_Stamina = math.Clamp( self.dat.player_Stamina, 0, 1 )
		
	end
	
	-- Reset previous tick ground landing memoryvar
	if self.dat.player_TimeOffGroundWhenLanding > 0 then
		self.dat.player_TimeOffGroundWhenLanding = 0
	end
	
	--print(self.dat.player_Stamina)
	
	local isInDeepWater = ply:WaterLevel() >= 3
	local isInModerateWater = (ply:WaterLevel() == 1) or (ply:WaterLevel() == 2)
	
	-- Off ground
	if not ply:IsOnGround() then
		if not isInDeepWater then
			self.dat.player_TimeOffGround = self.dat.player_TimeOffGround + FrameTime() // TOKEN : SERVER-CLIENT DEPMATCH FRAMETIME
			
		else
			self.dat.player_TimeOffGround = 0
		end
		
	elseif self.dat.player_TimeOffGround > 0 then
		self.dat.player_TimeOffGroundWhenLanding = self.dat.player_TimeOffGround
		self.dat.player_TimeOffGround = 0	
	
	end
	
	-- Sound Think
	local shouldTriggerStopSound = (self.dat.player_LastRelSpeed - relativeSpeed) > self.dat.player_RelStop
	local shouldTriggerWaterFlop = (self.dat.player_LastWaterLevel - ply:WaterLevel()) <= -2
	self:SoundThink( shouldTriggerStopSound, shouldTriggerWaterFlop, isInModerateWater, isInDeepWater )
	
	-- Data store
	self.dat.player_LastRelSpeed = relativeSpeed
	self.dat.player_LastWaterLevel = ply:WaterLevel()
	
end
