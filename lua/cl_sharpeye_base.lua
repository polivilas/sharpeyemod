////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Base                                       //
////////////////////////////////////////////////

sharpeye_focus = {}

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
	
	sharpeye_dat.wind = {
		"sharpeye/wind1.wav"
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
		"depthhud/X_CircleSolid.vmt",
		"depthhud/X_CircleShadow.vmt",
		"depthhud/focus.vmt",
		"depthhud/focusshadow.vmt"
	}
	
	sharpeye_dat.overlays = {
		"sharpeye/sharpeye_tunnel"
	}
	sharpeye_dat.main_overlay = "sharpeye/sharpeye_tunnel"
	
	--sharpeye_dat.materialtables = {
	// Need to fill this
	--}
	
	--sharpeye_day.player_RunSpeed = 100
	sharpeye_dat.player_LastRelSpeed = 0
	sharpeye_dat.player_LastWaterLevel = 0
	
	sharpeye_dat.player_RelStop = 2.2
	
	sharpeye_dat.player_Stamina = 0
	sharpeye_dat.player_StaminaSpeedFactor = 0.01
	--sharpeye_dat.player_StaminaRecover    = 0.97
	
	sharpeye_dat.player_CrouchSmooth = 0
	
	sharpeye_dat.player_TimeOffGround = 0
	sharpeye_dat.player_TimeOffGroundWhenLanding = 0
	
	sharpeye_dat.player_PitchInfluence = 0
	sharpeye_dat.player_RollChange = 0
	
	sharpeye_dat.player_TimeShift = 0
	sharpeye_dat.player_TimeRun = 0
	
	sharpeye_dat.bumpsounds_LastTime = 0
	sharpeye_dat.bumpsounds_delay    = 0.1
	
	
	sharpeye_dat.breathing_LastMode = -1
	sharpeye_dat.breathing_LastModel = ""
	sharpeye_dat.breathing_LastGender = 0
	sharpeye_dat.breathing_WasBreathing = false
	
	sharpeye_dat.motion_hooked = false
	sharpeye_dat.focus_hooked = false
	
	sharpeye_dat.EXT_RollSwitch = false
	sharpeye_dat.motion_firstframe = true
	
	
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

function sharpeye.EXT_IsPCSEnabled()
	return (sharpeye.GetVarNumber("sharpeye_ext_perfectedclimbswep") > 0)
end

-- Player custom status
function sharpeye.GetBasisHealthBehavior()
	-- Default is 5, so 0.5
	return math.Clamp(sharpeye.GetVarNumber("sharpeye_basis_healthbased") * 0.1, 0, 1)
end

function sharpeye.GetBasisHealthyLevel()
	-- Default is 100, so 100
	return math.Clamp(sharpeye.GetVarNumber("sharpeye_basis_healthylevel"), 1, 10000)
end

function sharpeye.GetHealthFactor()
	-- returns 1 if Health doesn't count
	-- returns 1 if Player is in good health
	-- returns 0.? if player is in bad shape 	
	local behav = sharpeye.GetBasisHealthBehavior()
	return (1 - behav) + math.Clamp(LocalPlayer():Health() / sharpeye.GetBasisHealthyLevel(), 0, 1) * behav
end

function sharpeye.GetBasisRunSpeed()
	-- Defaulted to 100
	return 1 + math.abs(sharpeye.GetVarNumber("sharpeye_basis_runspeed"))
end

function sharpeye.GetBasisStaminaRecover()
	-- Default is 5, so 0.25 that means 0.97
	return 0.995 - math.abs(sharpeye.GetVarNumber("sharpeye_basis_staminarecover") * 0.1 * 0.05) * sharpeye.GetHealthFactor()
end

function sharpeye.GetStamina()
	-- Dorky return ><
	if sharpeye.EXT_IsPCSEnabled() then
		local weapon = LocalPlayer():GetActiveWeapon()
		if ValidEntity( weapon ) and (weapon:GetClass() == "climb_swep") then
			
			return math.Max(sharpeye_dat.player_Stamina, 1 - (LocalPlayer():GetNWInt("FATIG_AMOUNT") or 100) * 0.01)
		end
		
	end
	
	return sharpeye_dat.player_Stamina
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
	if not sharpeye.IsEnabled() then
		-- There's already a check in UnhookMotion
		sharpeye.UnhookMotion()
		sharpeye.UnhookFocus()
		return
	end
	
	if sharpeye.IsMotionEnabled() then
		-- There's already a check in there
		sharpeye.HookMotion()
		
		if sharpeye.IsFocusEnabled() then
			sharpeye.HookFocus()
			
		else
			sharpeye.UnhookFocus()
			
		end
		
	else
		-- There's already a check in there
		sharpeye.UnhookMotion()
		sharpeye.UnhookFocus()
		-- Can't collapse with IsEnabled due to return
		
	end
	
	/*
	if false do
		local ply = LocalPlayer()
		if sharpeye.EXT_IsPCSEnabled() then
			if ply.CLHasDoneARoll then
				-- print( ply.__pitch )
				print( "PCS Motion Blur Override should be " .. (360 - ply.__pitch) / 360 )
			end
		end
	end
	*/
	
	local ply = LocalPlayer()
	
	local relativeSpeed = ply:GetVelocity():Length() / sharpeye.GetBasisRunSpeed()
	local clampedSpeed = (relativeSpeed > 1) and 1 or relativeSpeed
	
	local correction = math.Clamp(FrameTime() * 33, 0, 1)
	
	-- Crouch
	sharpeye_dat.player_CrouchSmooth = sharpeye_dat.player_CrouchSmooth + ((ply:Crouching() and 1 or 0) - sharpeye_dat.player_CrouchSmooth) * correction * 0.05
	
	-- Stamina
	if not ply:Alive() then
		sharpeye_dat.player_Stamina = 0
		
	else
		sharpeye_dat.player_Stamina = sharpeye_dat.player_Stamina + (-1 * sharpeye_dat.player_Stamina * (1 - sharpeye.GetBasisStaminaRecover()) * (1 - relativeSpeed) + sharpeye_dat.player_StaminaSpeedFactor * relativeSpeed) * correction * 0.2
		sharpeye_dat.player_Stamina = math.Clamp( sharpeye_dat.player_Stamina, 0, 1 )
		//print( sharpeye_dat.player_Stamina)
		
	end
	
	-- Reset previous tick ground landing memoryvar
	if sharpeye_dat.player_TimeOffGroundWhenLanding > 0 then
		sharpeye_dat.player_TimeOffGroundWhenLanding = 0
	end
	
	--print(sharpeye_dat.player_Stamina)
	
	local isInDeepWater = ply:WaterLevel() >= 3
	local isInModerateWater = (ply:WaterLevel() == 1) or (ply:WaterLevel() == 2)
	
	-- Off ground
	if not ply:IsOnGround() then
		if not isInDeepWater then
			sharpeye_dat.player_TimeOffGround = sharpeye_dat.player_TimeOffGround + FrameTime() // TOKEN : SERVER-CLIENT DEPMATCH FRAMETIME
			
		else
			sharpeye_dat.player_TimeOffGround = 0
		end
		
	elseif sharpeye_dat.player_TimeOffGround > 0 then
		sharpeye_dat.player_TimeOffGroundWhenLanding = sharpeye_dat.player_TimeOffGround
		sharpeye_dat.player_TimeOffGround = 0	
	
	end
	
	-- Sound Think
	if sharpeye.SoundThink then
		--if not ((CurTime() - sharpeye_dat.bumpsounds_LastTime) < sharpeye_dat.bumpsounds_delay) then
		--	sharpeye_dat.bumpsounds_LastTime = CurTime()
			

			local shouldTriggerStopSound = (sharpeye_dat.player_LastRelSpeed - relativeSpeed) > sharpeye_dat.player_RelStop
			local shouldTriggerWaterFlop = (sharpeye_dat.player_LastWaterLevel - ply:WaterLevel()) <= -2
			sharpeye.SoundThink( shouldTriggerStopSound, shouldTriggerWaterFlop, isInModerateWater, isInDeepWater )
			
		--end
		
	end
	
	-- Data store
	sharpeye_dat.player_LastRelSpeed = relativeSpeed
	sharpeye_dat.player_LastWaterLevel = ply:WaterLevel()
	
end

function sharpeye.RevertDetails()
	-- Disable this for the moment due to new cvar style.
	do
		--nothing
	end
	
end

-- Load
function sharpeye.Util_AppendCvar( tGroup, sName, oDefault, sType, ... )
	if not sType then
		tGroup[sName] = oDefault
		
	elseif sType == "color" then
		tGroup[sName .. "_r"] = oDefault[1]
		tGroup[sName .. "_g"] = oDefault[2]
		tGroup[sName .. "_b"] = oDefault[3]
		tGroup[sName .. "_a"] = oDefault[4]
		
	end
	
	
end

function sharpeye.Util_BuildCvars( tGroup, sPrefix )
	if not sPrefix then return end
	
	for sName,oDefault in pairs( tGroup ) do
		sharpeye.CreateVar( tostring( sPrefix ) .. tostring( sName ), tostring( oDefault ), true, false )
		
	end
	
end

function sharpeye.Util_RestoreCvars( tGroup, sPrefix )
	if not sPrefix then return end
	
	for sName,oDefault in pairs( tGroup ) do
		sharpeye.SetVar( tostring( sPrefix ) .. tostring( sName ), tostring( oDefault ) )
		
	end
	
end

function sharpeye.Mount()
	print("")
	print("[ Mounting " .. SHARPEYE_NAME .. " ... ]")
	
	sharpeye.cvarGroups = {}
	sharpeye.cvarGroups.core   = {}
	sharpeye.cvarGroups.opt    = {}
	sharpeye.cvarGroups.ext    = {}
	sharpeye.cvarGroups.basis  = {}
	sharpeye.cvarGroups.detail = {}
	sharpeye.cvarGroups.xhair  = {}
	sharpeye.cvarGroups.snd    = {}
	
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.core, "enable", "1")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.core, "motion", "1")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.core, "sound" , "1")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.core, "crosshair" , "1")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.core, "overlay" , "0")
	
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.opt, "focus", "1")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.opt, "relax", "0")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.opt, "firstpersondeath" , "1")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.opt, "firstpersondeath_highspeed" , "0")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.opt, "breathing" , "1")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.opt, "disablewithtools" , "1")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.opt, "disablebobbing" , "0")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.opt, "machinimamode" , "0")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.opt, "motionblur", "1")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.opt, "disableinthirdperson", "1")
	
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.ext, "perfectedclimbswep", "1")
	
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "mastermod" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "crouchmod" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "stepmodintensity" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "stepmodfrequency" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "shakemodintensity" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "shakemodhealth" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "breathebobdist" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "runningbobfreq" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "leaningangle" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "landingangle" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "focus_anglex" , "20")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "focus_angley" , "12")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "focus_backing" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "focus_smoothing" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "focus_smoothlook" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "focus_aimsim" , "8")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "focus_handshiftx" , "4")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "focus_handalternate" , "1")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.detail, "permablur" , "0")
	
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.basis, "runspeed" , "100")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.basis, "staminarecover" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.basis, "healthylevel" , "100")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.basis, "healthbased" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.xhair, "color" , {"255", "220", "0", "255"}, "color")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.xhair, "shadcolor" , {"0", "0", "0", "64"}, "color")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.xhair, "staticsize" , "8")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.xhair, "dynamicsize" , "8")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.xhair, "shadowsize" , "8")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.xhair, "focussize" , "8")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.xhair, "focusshadowsize" , "8")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.xhair, "focusspin" , "2")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.xhair, "focusangle" , "0")
	
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.snd, "footsteps_vol" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.snd, "breathing_vol" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.snd, "windenable" , "1")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.snd, "windvelocityincap" , "5")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.snd, "windonground" , "0")
	sharpeye.Util_AppendCvar( sharpeye.cvarGroups.snd, "windonnoclip" , "0")
	
	for sSubFix,tCvarGroup in pairs( sharpeye.cvarGroups ) do
		sharpeye.Util_BuildCvars( tCvarGroup, "sharpeye_" .. sSubFix .. "_" )
		
	end
	
	sharpeye.InitializeData()
	
	if (SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT) then
		--If SinglePlayer, hook this server-side
		hook.Add("PlayerFootstep", "sharpeye_PlayerFootstep", sharpeye.PlayerFootstep)
		
	end
	
	if CLIENT then
		hook.Add("Think", "sharpeye_Think", sharpeye.Think)
		--SharpeYe CalcView hook should now be evaluated.
		--hook.Add("CalcView", "sharpeye_CalcView", sharpeye.CalcView)
		hook.Add("GetMotionBlurValues", "sharpeye_GetMotionBlurValues", sharpeye.GetMotionBlurValues)
		hook.Add("HUDShouldDraw", "sharpeye_HUDShouldDraw", sharpeye.HUDShouldDraw)
		hook.Add("HUDPaint", "sharpeye_HUDPaint", sharpeye.HUDPaint)
		hook.Add("RenderScreenspaceEffects", "sharpeye_RenderScreenspaceEffects", sharpeye.RenderScreenspaceEffects)
		hook.Add("Initialize", "sharpeye_Initialize", sharpeye.GamemodeInitialize)
		concommand.Add( "sharpeye_call_forcesolvecompatibilities", sharpeye.ForceSolveCompatilibityIssues)
		
		if sharpeye.MountMenu then
			sharpeye.MountMenu()
		end
		sharpeye_focus:Mount()
		
	end
	
	print("[ " .. SHARPEYE_NAME .. " is now mounted. ]")
	print("")
end

function sharpeye.Unmount()
	print("")
	print("] Unmounting " .. SHARPEYE_NAME .. " ... [")

	local bOkay, strErr = pcall(function()
	
	if (SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT) then
		hook.Remove("PlayerFootstep", "sharpeye_PlayerFootstep")
		
	end
	
	if CLIENT then
		hook.Remove("Think", "sharpeye_Think")
		sharpeye.UnhookMotion()
		sharpeye.UnhookFocus()
		--hook.Remove("CalcView", "sharpeye_CalcView")
		hook.Remove("GetMotionBlurValues", "sharpeye_GetMotionBlurValues")
		hook.Remove("RenderScreenspaceEffects", "sharpeye_RenderScreenspaceEffects")
		hook.Remove("HUDPaint", "sharpeye_HUDPaint")
		hook.Remove("HUDShouldDraw", "sharpeye_HUDShouldDraw")
		hook.Remove("Initialize", "sharpeye_Initialize")
		concommand.Remove( "sharpeye_call_forcesolvecompatibilities")

		sharpeye_focus:Unmount()
		
		if sharpeye.UnmountMenu then
			sharpeye.UnmountMenu()
		end
	end
	
	end)
	
	if not bOkay then
		print("[<<< " .. SHARPEYE_NAME .. " failed to unmount properly : " .. tostring(strErr) .. " ]")
		
	end
	
	sharpeye = nil
	sharpeye_dat = nil
	sharpeye_focus = nil
	
	print("[ " .. SHARPEYE_NAME .. " is now unmounted. ]")
	print("")
end
