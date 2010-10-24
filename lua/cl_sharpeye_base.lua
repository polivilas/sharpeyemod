////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Base                                       //
////////////////////////////////////////////////
SHARPEYE_SHORT = "SHARPEYE"

sharpeye_util = {}
sharpeye_focus = {}

-- Initialization
function sharpeye:InitializeData() 
	self.dat.footsteps = {
		"sharpeye/boots1.wav",
		"sharpeye/boots2.wav",
		"sharpeye/boots3.wav",
		"sharpeye/boots4.wav"
	}
	self.dat.footsteps_LastPlayed = 1
	
	self.dat.sloshsteps = {
		"sharpeye/slosh1.wav",
		"sharpeye/slosh2.wav",
		"sharpeye/slosh3.wav",
		"sharpeye/slosh4.wav"
	}
	self.dat.sloshsteps_LastPlayed = 1

	self.dat.watersteps = {
		"sharpeye/waterstep1.wav",
		"sharpeye/waterstep2.wav",
		"sharpeye/waterstep3.wav",
		"sharpeye/waterstep4.wav"
	}
	self.dat.watersteps_LastPlayed = 1
	
	self.dat.stops = {
		"sharpeye/gear1.wav",
		"sharpeye/gear2.wav",
		"sharpeye/gear3.wav",
		"sharpeye/gear4.wav",
		"sharpeye/gear5.wav",
		"sharpeye/gear6.wav"
	}
	self.dat.stops_LastPlayed = 1
	
	self.dat.waterflop = {
		"sharpeye/water_splash1.wav",
		"sharpeye/water_splash2.wav",
		"sharpeye/water_splash3.wav"
	}
	self.dat.waterflop_LastPlayed = 1
	
	self.dat.breathing = {
		"sharpeye/breathe_male.wav",
		"sharpeye/breathe_female.wav",
		"sharpeye/breathe_mask.wav"
	}
	
	self.dat.wind = {
		"sharpeye/wind1.wav"
	}
	
	self.dat.soundtables = {
		self.dat.footsteps,
		self.dat.sloshsteps,
		self.dat.watersteps,
		self.dat.stops,
		self.dat.waterflop,
		self.dat.breathing
	}
	
	self.dat.crosshairshapes = {
		"depthhud/linebow_crosshair.vmt",
		"depthhud/X_CircleSolid.vmt",
		"depthhud/X_CircleShadow.vmt",
		"depthhud/focus.vmt",
		"depthhud/focusshadow.vmt"
	}
	
	self.dat.overlays = {
		"sharpeye/sharpeye_tunnel"
	}
	self.dat.main_overlay = "sharpeye/sharpeye_tunnel"
	
	--self.dat.materialtables = {
	// Need to fill this
	--}
	
	--sharpeye_day.player_RunSpeed = 100
	self.dat.player_LastRelSpeed = 0
	self.dat.player_LastWaterLevel = 0
	
	self.dat.player_RelStop = 2.2
	
	self.dat.player_Stamina = 0
	self.dat.player_StaminaSpeedFactor = 0.01
	--self.dat.player_StaminaRecover    = 0.97
	
	self.dat.player_CrouchSmooth = 0
	
	self.dat.player_TimeOffGround = 0
	self.dat.player_TimeOffGroundWhenLanding = 0
	
	self.dat.player_PitchInfluence = 0
	self.dat.player_RollChange = 0
	
	self.dat.player_TimeShift = 0
	self.dat.player_TimeRun = 0
	
	self.dat.bumpsounds_LastTime = 0
	self.dat.bumpsounds_delay    = 0.1
	
	
	self.dat.breathing_LastMode = -1
	self.dat.breathing_LastModel = ""
	self.dat.breathing_LastGender = 0
	self.dat.breathing_WasBreathing = false
	
	self.dat.motion_hooked = false
	self.dat.focus_hooked = false
	
	self.dat.EXT_RollSwitch = false
	self.dat.motion_firstframe = true
	
	
	for _,subtable in pairs(self.dat.soundtables) do
		for k,path in pairs(subtable) do
			Sound(path)
		end
	end
	
end

function sharpeye.IsEnabled()
	return sharpeye:GetVar("core_enable") > 0
end

function sharpeye.ReloadFromCloud()
	if sharpeye_cloud then
		sharpeye_cloud:Ask()
	end
	
end

function sharpeye.ReloadFromLocale()
	if sharpeye_cloud then
		sharpeye_cloud:LoadLocale()
	end
	
end

function sharpeye.RevertDetails()
	-- Disable this for the moment due to new cvar style.
	do
		--nothing
	end
	
end

function sharpeye.ShutDown()
	sharpeye.Unmount()
	
end

function sharpeye.Mount()
	local self = sharpeye
	
	if SERVER then
		return
	end
	
	sharpeye_util.OutputLineBreak( )
	sharpeye_util.OutputIn( "Mounting ..." )
	
	if sharpeye_internal and SHARPEYE_FORCE_VERSION and not SHARPEYE_FORCE_USE_CLOUD then	
		sharpeye_internal.QueryVersion( nil )
	end
	
	//if (SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT) then
		--If SinglePlayer, hook this server-side
		//Something weird is happening. Ignore the thing.
		hook.Add("PlayerFootstep", "sharpeye_PlayerFootstep", sharpeye.PlayerFootstep)
		
	//end
	
	self.dat = {}
	/*if SERVER then
		--self:InitializeData()
		return
	end*/
	
	self:RequireParameterMediator( )
	
	self:CreateVarParam( "bool", "core_enable", "1" )
	self:CreateVarParam( "bool", "core_enable", "1")
	self:CreateVarParam( "bool", "core_motion", "1")
	self:CreateVarParam( "bool", "core_sound" , "1")
	self:CreateVarParam( "bool", "core_crosshair" , "1")
	self:CreateVarParam( "bool", "core_overlay" , "0")
	
	self:CreateVarParam( "bool", "opt_focus", "1")
	self:CreateVarParam( "bool", "opt_relax", "0")
	self:CreateVarParam( "bool", "opt_firstpersondeath" , "1")
	self:CreateVarParam( "bool", "opt_firstpersondeath_highspeed" , "0")
	self:CreateVarParam( "range", "opt_breathing" , "1")
	self:CreateVarParam( "bool", "opt_disablewithtools" , "1")
	self:CreateVarParam( "bool", "opt_disablebobbing" , "0")
	self:CreateVarParam( "bool", "opt_machinimamode" , "0")
	self:CreateVarParam( "bool", "opt_motionblur", "1")
	self:CreateVarParam( "bool", "opt_disableinthirdperson", "1")
	
	self:CreateVarParam( "bool", "ext_perfectedclimbswep", "1")
	
	self:CreateVarParam( "range", "detail_mastermod" , "5")
	self:CreateVarParam( "range", "detail_crouchmod" , "5")
	self:CreateVarParam( "range", "detail_stepmodintensity" , "5")
	self:CreateVarParam( "range", "detail_stepmodfrequency" , "5")
	self:CreateVarParam( "range", "detail_shakemodintensity" , "5")
	self:CreateVarParam( "range", "detail_shakemodhealth" , "5")
	self:CreateVarParam( "range", "detail_breathebobdist" , "5")
	self:CreateVarParam( "range", "detail_runningbobfreq" , "5")
	self:CreateVarParam( "range", "detail_leaningangle" , "5")
	self:CreateVarParam( "range", "detail_landingangle" , "5")
	self:CreateVarParam( "range", "detail_focus_anglex" , "20")
	self:CreateVarParam( "range", "detail_focus_angley" , "12")
	self:CreateVarParam( "range", "detail_focus_backing" , "5")
	self:CreateVarParam( "range", "detail_focus_smoothing" , "5")
	self:CreateVarParam( "range", "detail_focus_smoothlook" , "5")
	self:CreateVarParam( "range", "detail_focus_aimsimalter" , "0")
	self:CreateVarParam( "range", "detail_focus_handshiftx" , "6")
	self:CreateVarParam( "range", "detail_focus_handshifty" , "6")
	self:CreateVarParam( "range", "detail_focus_handlean" , "0")
	self:CreateVarParam( "range", "detail_focus_handalternate" , "1")
	self:CreateVarParam( "range", "detail_permablur" , "0")
	
	self:CreateVarParam( "range", "basis_runspeed" , "100")
	self:CreateVarParam( "range", "basis_staminarecover" , "5")
	self:CreateVarParam( "range", "basis_healthylevel" , "100")
	self:CreateVarParam( "range", "basis_healthbased" , "5")
	self:CreateVarParam( "color", "xhair_color" , {255, 220, 0, 255}, "color")
	self:CreateVarParam( "color", "xhair_shadcolor" , {0, 0, 0, 64}, "color")
	self:CreateVarParam( "range", "xhair_staticsize" , "8")
	self:CreateVarParam( "range", "xhair_dynamicsize" , "8")
	self:CreateVarParam( "range", "xhair_shadowsize" , "8")
	self:CreateVarParam( "range", "xhair_focussize" , "8")
	self:CreateVarParam( "range", "xhair_focusshadowsize" , "8")
	self:CreateVarParam( "range", "xhair_focusspin" , "2")
	self:CreateVarParam( "range", "xhair_focusangle" , "4")
	
	self:CreateVarParam( "range", "snd_footsteps_vol" , "5")
	self:CreateVarParam( "range", "snd_breathing_vol" , "5")
	self:CreateVarParam( "bool", "snd_windenable" , "1")
	self:CreateVarParam( "range", "snd_windvelocityincap" , "5")
	self:CreateVarParam( "bool", "snd_windonground" , "0")
	self:CreateVarParam( "bool", "snd_windonnoclip" , "0")
	
	self:CreateVarParam( "bool", "wiimote_enable" , "0")
	
	self.cmdGroups = {}
	self.cmdGroups.call = {}
	--self:AppendCmd( self.cmdGroups, "core_enable", function(p,c,args) self:SetVar("core_enable", args[1] ) end )
	self:AppendCmd( self.cmdGroups.call, "changelog", function() self.ShowChangelog( self ) end )
	self:AppendCmd( self.cmdGroups.call, "menu", function() self.OpenMenu( self ) end )
	self:AppendCmd( self.cmdGroups, "menu", function() self.OpenMenu( self ) end )
	self:AppendCmd( self.cmdGroups, "+menu", function() self.OpenMenu( self ) end )
	self:AppendCmd( self.cmdGroups, "-menu", function() self.CloseMenu( self ) end )
	
	self:AppendCmd( self.cmdGroups, "+focus", sharpeye_focus.CommandEnableFocus )
	self:AppendCmd( self.cmdGroups, "-focus", sharpeye_focus.CommandDisableFocus )
	self:AppendCmd( self.cmdGroups, "focus_toggle", sharpeye_focus.CommandToggleFocus )
	
	self.cmdGroupsNoRemove = {}
	self:AppendCmd( self.cmdGroupsNoRemove, "cloud_locale", sharpeye.ReloadFromLocale )
	
	self:BuildCmds( self.cmdGroups, "" )
	self:BuildCmds( self.cmdGroupsNoRemove, "" )
	
	self:InitializeData()
	sharpeye_focus:Mount()
	
	hook.Add("Think", "sharpeye_Think", sharpeye.Think)
	--SharpeYe CalcView hook should now be evaluated.
	--hook.Add("CalcView", "sharpeye_CalcView", sharpeye.CalcView)
	hook.Add("GetMotionBlurValues", "sharpeye_GetMotionBlurValues", sharpeye.GetMotionBlurValues)
	hook.Add("HUDShouldDraw", "sharpeye_HUDShouldDraw", sharpeye.HUDShouldDraw)
	hook.Add("HUDPaint", "sharpeye_HUDPaint", sharpeye.HUDPaint)
	hook.Add("RenderScreenspaceEffects", "sharpeye_RenderScreenspaceEffects", sharpeye.RenderScreenspaceEffects)
	hook.Add("Initialize", "sharpeye_Initialize", sharpeye.GamemodeInitialize)
	hook.Add("InputMouseApply", "sharpeye_InputMouseApply", sharpeye.InputMouseApply)
	hook.Add("ShutDown", "sharpeye_ShutDown", sharpeye.ShutDown)
	concommand.Add( "sharpeye_call_forcesolvecompatibilities", sharpeye.ForceSolveCompatilibityIssues)
	
	self:CheckBackupInit()
	self:MountMenu()
		
	sharpeye_util.OutputIn( "Mount complete : " .. (sharpeye_internal.IsUsingCloud() and "Cloud" or "Locale") )
	sharpeye_util.OutputLineBreak( )
end

function sharpeye.Unmount()
	local self = sharpeye

	local bOkay, strErr = pcall(function()
		sharpeye_util.OutputLineBreak( )
		sharpeye_util.OutputOut( "Unmounting ..." )
		
		if (SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT) then
			hook.Remove("PlayerFootstep", "sharpeye_PlayerFootstep")
			
		end
		
		if CLIENT then
			sharpeye_util.OutputLineBreak( )
			sharpeye_util.OutputOut( "Unmounting ..." )
			
			self:TryExitBackup()
			
			hook.Remove("Think", "sharpeye_Think")
			--hook.Remove("CalcView", "sharpeye_CalcView")
			hook.Remove("GetMotionBlurValues", "sharpeye_GetMotionBlurValues")
			hook.Remove("RenderScreenspaceEffects", "sharpeye_RenderScreenspaceEffects")
			hook.Remove("HUDPaint", "sharpeye_HUDPaint")
			hook.Remove("HUDShouldDraw", "sharpeye_HUDShouldDraw")
			hook.Remove("Initialize", "sharpeye_Initialize")
			hook.Remove("InputMouseApply", "sharpeye_InputMouseApply")
			hook.Add("ShutDown", "sharpeye_ShutDown")
			concommand.Remove( "sharpeye_call_forcesolvecompatibilities")
			
			sharpeye_focus:Unmount()
			sharpeye:UnhookMotion()
			
			self:DestroyChangelog()
			self:UnmountMenu()
			self:DismountCmds( self.cmdGroups )
			
			sharpeye_util.OutputOut( "Unmount complete." )
			sharpeye_util.OutputLineBreak( )
		end
	
	end)
	if not bOkay then
		sharpeye_util.OutputError( tostring(strErr) , "while unmounting" )
		
	end
	
	sharpeye.dat = nil
	sharpeye = nil
	
end
