////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Menu                                       //
////////////////////////////////////////////////

include( 'CtrlColor.lua' )

local SHARPEYE_PRESET_LOC = "sharpeye"

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//// DERMA PANEL .

function sharpeye.Util_FrameGetExpandTable( myPanel )
	local expandTable = {}
	
	for k,subtable in pairs( myPanel.Categories ) do
		table.insert(expandTable, subtable[1]:GetExpanded())
		
	end
	
	return expandTable
end

function sharpeye.Util_AppendPanel( myPanel, thisPanel )
	local toAppendIn = myPanel.Categories[#myPanel.Categories][1].List
	
	thisPanel:SetParent( toAppendIn )
	toAppendIn:AddItem( thisPanel )
	
end

function sharpeye.Util_AppendCheckBox( myPanel, title, cvar )

	local checkbox = vgui.Create( "DCheckBoxLabel" )
	checkbox:SetText( title )
	checkbox:SetConVar( cvar )
	
	sharpeye.Util_AppendPanel( myPanel, checkbox )
	
end

function sharpeye.Util_AppendLabel( myPanel, sText, optiSize, optbWrap )

	local label = vgui.Create( "DLabel" )
	label:SetText( sText )
	
	if optiSize then
		label:SetWrap( true )
		label:SetContentAlignment( 2 )
		label:SetSize( myPanel.W_WIDTH, optiSize )
		
	end
	
	if optbWrap then
		label:SetWrap( true )
		
	end
	
	sharpeye.Util_AppendPanel( myPanel, label )
	
end

function sharpeye.Util_AppendSlider( myPanel, sText, sCvar, fMin, fMax, iDecimals)
	local slider = vgui.Create("DNumSlider")
	slider:SetText( sText )
	slider:SetMin( fMin )
	slider:SetMax( fMax )
	slider:SetDecimals( iDecimals )
	slider:SetConVar( sCvar )
	
	sharpeye.Util_AppendPanel( myPanel, slider )
end

function sharpeye.Util_AppendPreset( myPanel, sFolder, tCvars, opttOptions )
	local ctrl = vgui.Create( "ControlPresets", self )
	
	ctrl:SetPreset( sFolder )
	
	if ( opttOptions ) then
		for k, v in pairs( opttOptions ) do
			if ( k != "id" ) then
				ctrl:AddOption( k, v )
			end
		end
	end
	
	if ( tCvars ) then
		for k, v in pairs( tCvars ) do
			ctrl:AddConVar( v )
		end
	end
	
	sharpeye.Util_AppendPanel( myPanel, ctrl )
	
end

function sharpeye.Util_MakeFrame( width, height, optsTitleAppend )
	local myPanel = vgui.Create( "DFrame" )
	local border = 4
	
	myPanel.W_HEIGHT = height - 20
	myPanel.W_WIDTH = width - 2 * border
	
	myPanel:SetPos( ScrW() * 0.5 - width * 0.5 , ScrH() * 0.5 - height * 0.5 )
	myPanel:SetSize( width, height )
	myPanel:SetTitle( SHARPEYE_NAME .. (sharpeye_internal.IsUsingCloud and sharpeye_internal.IsUsingCloud() and " over Cloud" or "" ) .. (optsTitleAppend or "" ) )
	myPanel:SetVisible( false )
	myPanel:SetDraggable( true )
	myPanel:ShowCloseButton( true )
	myPanel:SetDeleteOnClose( false )
	
	myPanel.Contents = vgui.Create( "DPanelList", myPanel )
	myPanel.Contents:SetPos( border , 22 + border )
	myPanel.Contents:SetSize( myPanel.W_WIDTH, height - 2 * border - 22 )
	myPanel.Contents:SetSpacing( 5 )
	myPanel.Contents:EnableHorizontal( false )
	myPanel.Contents:EnableVerticalScrollbar( false )
	
	myPanel.Categories = {}
	
	return myPanel
end

function sharpeye.Util_MakeCategory( myPanel, sTitle, bExpandDefault )
	local category = vgui.Create("DCollapsibleCategory", myPanel.Contents)
	category.List  = vgui.Create("DPanelList", category )
	table.insert( myPanel.Categories, {category, bExpandDefault} )
	category:SetSize( myPanel.W_WIDTH, 50 )
	category:SetLabel( sTitle )
	
	category.List:EnableHorizontal( false )
	category.List:EnableVerticalScrollbar( false )
	
	return category
end

function sharpeye.Util_ApplyCategories( myPanel )
	for k,subtable in pairs( myPanel.Categories ) do
		subtable[1]:SetExpanded( opt_tExpand and (opt_tExpand[k] and 1 or 0) or subtable[2] )
		subtable[1].List:SetSize( myPanel.W_WIDTH, myPanel.W_HEIGHT - #myPanel.Categories * 10 - 10 )
		subtable[1]:SetSize( myPanel.W_WIDTH, myPanel.W_HEIGHT - #myPanel.Categories * 10 )
		
		subtable[1].List:PerformLayout()
		subtable[1].List:SizeToContents()
		
		subtable[1]:SetContents( subtable[1].List )
		
		myPanel.Contents:AddItem( subtable[1] )
	end
	
end

function sharpeye.MenuCall_ReloadFromCloud()
	if sharpeye_cloud then
		sharpeye_cloud:Ask()
	end
	
end

function sharpeye.MenuCall_ReloadFromLocale()
	if sharpeye_cloud then
		sharpeye_cloud:LoadLocale()
	end
	
end

function sharpeye.BuildMenu( opt_tExpand )
	if sharpeye.DermaPanel then sharpeye.DermaPanel:Remove() end
	
	local bCanGetVersion = sharpeye_internal ~= nil
	local MY_VERSION, ONLINE_VERSION, DOWNLOAD_LINK
	local ONLINE_VERSION_READ = -1
	if bCanGetVersion then
		MY_VERSION, ONLINE_VERSION, DOWNLOAD_LINK = sharpeye_internal.GetVersionData()
		
		if ONLINE_VERSION == -1 then
			ONLINE_VERSION_READ = "<offline>"
		else
			ONLINE_VERSION_READ = tostring( ONLINE_VERSION )
		end
		
	end
	
	sharpeye.DermaPanel = sharpeye.Util_MakeFrame( 256, ScrH() * 0.80 )
	local refPanel = sharpeye.DermaPanel
	
	sharpeye.Util_MakeCategory( refPanel, "General", 1 )
	sharpeye.Util_AppendCheckBox( refPanel, "Enable" , "sharpeye_core_enable" )
	sharpeye.Util_AppendCheckBox( refPanel, "Use Motion (Disable to fix gamemode)" , "sharpeye_core_motion" )
	sharpeye.Util_AppendCheckBox( refPanel, "Use First Person Deathcam", "sharpeye_opt_firstpersondeath" )
	sharpeye.Util_AppendCheckBox( refPanel, "Use Sounds" , "sharpeye_core_sound" )
	sharpeye.Util_AppendCheckBox( refPanel, "Use Crosshair" , "sharpeye_core_crosshair" )
	sharpeye.Util_AppendCheckBox( refPanel, "Use Tunnel" , "sharpeye_core_overlay" )
	sharpeye.Util_AppendCheckBox( refPanel, "Disable Motion in Third Person mode" , "sharpeye_opt_disableinthirdperson" )
	sharpeye.Util_AppendCheckBox( refPanel, "Disable bobbing with Toolgun and Physgun" , "sharpeye_opt_disablewithtools" )
	sharpeye.Util_AppendCheckBox( refPanel, "Disable bobbing completely" , "sharpeye_opt_disablebobbing" )
	sharpeye.Util_AppendCheckBox( refPanel, "Allow Relax mode" , "sharpeye_opt_relax" )
	sharpeye.Util_AppendLabel( refPanel, "Breathing mode :" )
	--Breathing mode Choice
	do
		local GeneralBreathingMulti = vgui.Create( "DMultiChoice" )
		GeneralBreathingMulti:AddChoice( "No breathing" )
		GeneralBreathingMulti:AddChoice( "Based on player model" )
		GeneralBreathingMulti:AddChoice( "Always Male" )
		GeneralBreathingMulti:AddChoice( "Always Female" )
		GeneralBreathingMulti:AddChoice( "Always Gas mask" )
		
		GeneralBreathingMulti.OnSelect = function(index, value, data)
			sharpeye.SetVar( "sharpeye_opt_breathing", (value - 1) or 0 )
		end
		
		GeneralBreathingMulti:ChooseOptionID( 1 + sharpeye.GetBreathingMode() )
		
		GeneralBreathingMulti:PerformLayout()
		GeneralBreathingMulti:SizeToContents()
		
		sharpeye.Util_AppendPanel( refPanel, GeneralBreathingMulti )
		
	end
	
	--Helper label
	do
		local GeneralTextLabelMessage = "The command \"sharpeye_menu\" calls this menu.\n"
		GeneralTextLabelMessage = GeneralTextLabelMessage .. "Example : To assign " .. SHARPEYE_NAME .. " menu to F10, type in the console :"
		
		sharpeye.Util_AppendLabel( refPanel, GeneralTextLabelMessage, 50, true )
		
	end
	
	--Helper multiline
	do
		local GeneralCommandLabel = vgui.Create("DTextEntry")
		GeneralCommandLabel:SetText( "bind \"F10\" \"sharpeye_menu\"" )
		GeneralCommandLabel:SetEditable( false )

		sharpeye.Util_AppendPanel( refPanel, GeneralCommandLabel )
		
	end
	
	
	--Update label
	do
		if bCanGetVersion and (MY_VERSION and ONLINE_VERSION and (MY_VERSION < ONLINE_VERSION)) then
			GeneralTextLabelMessage = "Your version is "..MY_VERSION.." and the updated one is "..ONLINE_VERSION.." ! You should update !"
			sharpeye.Util_AppendLabel( refPanel, GeneralTextLabelMessage, 50, true )
			
			if sharpeye_internal.GetReplicate then
				local CReload = vgui.Create("DButton")
				CReload:SetText( "Open full Changelog" )
				CReload.DoClick = sharpeye.ShowChangelog
				sharpeye.Util_AppendPanel( refPanel, CReload )
				
				sharpeye.Util_AppendLabel( refPanel, "" )
				
				if ONLINE_VERSION and ONLINE_VERSION ~= -1 then
					local myVer = MY_VERSION or 0
					
					local contents = sharpeye_internal.GetReplicate() or ( tostring( MY_VERSION or 0 ) .. "\n<Nothing to show>" )
					local split = string.Explode( "\n", contents )
					if (#split % 2) == 0 then
						local dList = vgui.Create("DListView")
						dList:SetMultiSelect( false )
						dList:SetTall( 150 )
						dList:AddColumn( "Ver." ):SetMaxWidth( 45 ) -- Add column
						dList:AddColumn( "Log" )
						
						local gotMyVer = false
						local i = 1
						while (i <= #split) and not gotMyVer do
							local iVer = tonumber( split[i] or 0 ) or 0
							if not gotMyVer and iVer ~= 0 and iVer <= myVer and (split[i+2] ~= "&") then
								dList:AddLine( "*" .. myVer .. "*", "< Locale version >" )
								gotMyVer = true
								
							else
								local myLine = dList:AddLine( (split[i] ~= "&") and split[i] or "", split[i+1] or "" )
								myLine:SizeToContents()
								
							end
							
							i = i + 2
							
						end
						
						sharpeye.Util_AppendPanel( refPanel, dList )
						
					end
					
				end
				
			else
				local GeneralCommandLabel = vgui.Create("DTextEntry")
				GeneralCommandLabel:SetText( DOWNLOAD_LINK )
				GeneralCommandLabel:SetEditable( false )
				GeneralCommandLabel:SetMultiline( true )
				GeneralCommandLabel:SetSize( refPanel.W_WIDTH, 60 )
				sharpeye.Util_AppendPanel( refPanel, GeneralCommandLabel )
				
			end
			
		end
		
	end
	
	-- Presets
	/*
	sharpeye.Util_MakeCategory( refPanel, "Presets", 0 )
	sharpeye.Util_AppendLabel( myPanel, "Motion" )
	sharpeye.Util_AppendPreset( myPanel, SHARPEYE_PRESET_LOC .. "_motion",
		{
			"sharpeye_core_motion",
			"sharpeye_opt_focus",
			"sharpeye_opt_relax",
			"sharpeye_opt_firstpersondeath",
			"sharpeye_opt_firstpersondeath_highspeed",
			"sharpeye_opt_disablewithtools",
			"sharpeye_opt_disablebobbing",
			"sharpeye_opt_disableinthirdperson",
			"sharpeye_ext_perfectedclimbswep",
			"sharpeye_detail_mastermod"
			--UNCOMLPLETE
		}, opttOptions )
	*/
	
	-- Focus
	sharpeye.Util_MakeCategory( refPanel, SHARPEYE_FOCUS_NAME, 0 )
	sharpeye.Util_AppendCheckBox( refPanel, "Allow "..SHARPEYE_FOCUS_NAME , "sharpeye_opt_focus" )
	sharpeye.Util_AppendCheckBox( refPanel, "Allow Relax mode" , "sharpeye_opt_relax" )
	do
		local GeneralTextLabelMessage = "The binding \"+sharpeye_focus\" allows you to enter "..SHARPEYE_FOCUS_NAME.." mode (with a 'hold key' action).\nExample : To assign it to the key 'v', type in the console :"
		sharpeye.Util_AppendLabel( refPanel, GeneralTextLabelMessage, 70, true )
		
	end
	do
		local GeneralCommandLabel = vgui.Create("DTextEntry")
		GeneralCommandLabel:SetText( "bind \"v\" \"+sharpeye_focus\"" )
		GeneralCommandLabel:SetEditable( false )
		sharpeye.Util_AppendPanel( refPanel, GeneralCommandLabel )
	end
	do
		local GeneralTextLabelMessage = "You can also use toggle mode (like the Crossbow zoom) using \"sharpeye_focus_toggle\" command.\nExample : To assign it to the key 'v', type in the console :"
		sharpeye.Util_AppendLabel( refPanel, GeneralTextLabelMessage, 70, true )
		
	end
	do
		local GeneralCommandLabel = vgui.Create("DTextEntry")
		GeneralCommandLabel:SetText( "bind \"v\" \"sharpeye_focus_toggle\"" )
		GeneralCommandLabel:SetEditable( false )
		sharpeye.Util_AppendPanel( refPanel, GeneralCommandLabel )
	end
	sharpeye.Util_AppendSlider( refPanel, "Left-Right pan angles",    "sharpeye_detail_focus_anglex", 8, 32, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Up-Down pan angles",       "sharpeye_detail_focus_angley", 8, 16, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Weapon backing intensity on edges",  "sharpeye_detail_focus_backing", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Viewmodel visual smoothing",  "sharpeye_detail_focus_smoothing", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Camera visual smoothing",  "sharpeye_detail_focus_smoothlook", 0, 10, 0 )
	
	sharpeye.Util_AppendSlider( refPanel, "Aim Simulation (Angle approximation)",  "sharpeye_detail_focus_aimsim", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Hand Shift (Weapon X-Perspective)",  "sharpeye_detail_focus_handshiftx", 0, 10, 0 )
	sharpeye.Util_AppendLabel( refPanel, "Use AS/HS preset :" )
	--FocusPreset mode Choice
	do
		local GeneralBreathingMulti = vgui.Create( "DMultiChoice" )
		GeneralBreathingMulti:AddChoice( "Custom" )
		GeneralBreathingMulti:AddChoice( "Old School" )
		GeneralBreathingMulti:AddChoice( "Hand Shift Optimized" )
		
		GeneralBreathingMulti.OnSelect = function(index, value, data)
			if value == 2 then
				sharpeye.SetVar( "sharpeye_detail_focus_aimsim" , 5 )
				sharpeye.SetVar( "sharpeye_detail_focus_handshiftx" , 0 )
			elseif value == 3 then
				sharpeye.SetVar( "sharpeye_detail_focus_aimsim" , 8 )
				sharpeye.SetVar( "sharpeye_detail_focus_handshiftx" , 4 )
			end
		end
		
		do
			local as = sharpeye.GetVar("sharpeye_detail_focus_aimsim")
			local hs = sharpeye.GetVar("sharpeye_detail_focus_handshiftx")
			GeneralBreathingMulti:ChooseOptionID( ((as == 5) and (hs == 0)) and 2 or ((as == 8) and (hs == 4)) and 3 or 1 )
		
		end
		
		GeneralBreathingMulti:PerformLayout()
		GeneralBreathingMulti:SizeToContents()
		
		sharpeye.Util_AppendPanel( refPanel, GeneralBreathingMulti )
		
	end
	
	sharpeye.Util_AppendSlider( refPanel, "Left-Right pan angles (Extended)",    "sharpeye_detail_focus_anglex", 0, 60, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Up-Down pan angles (Extended)",       "sharpeye_detail_focus_angley", 0, 60, 0 )
	--ToggleFocus button
	do
		local CDetailsRevertButton = vgui.Create("DButton")
		CDetailsRevertButton:SetText( "Toggle Focus" )
		CDetailsRevertButton.DoClick = function()
			if sharpeye_focus and sharpeye_focus.ToggleFocus then sharpeye_focus:ToggleFocus() end
		end
		
		sharpeye.Util_AppendPanel( refPanel, CDetailsRevertButton )
	end
	sharpeye.Util_AppendLabel( refPanel, "SharpeYe::Focus is a derivative from Devenger's work, who is the author of the \"Twitch Weaponry\" SWEP pack in which ::Focus originates from.", 70, true )
	
	
	sharpeye.Util_MakeCategory( refPanel, "Advanced / Extra", 0 )
	sharpeye.Util_AppendLabel( refPanel, "You can quickly call the menu by binding \"+sharpeye_menu\" to one of your keys : The menu closes when you release the key.", 40, true )
	
	sharpeye.Util_AppendSlider( refPanel, "Master Scale", "sharpeye_detail_mastermod", 0, 10, 0 )
	
	sharpeye.Util_AppendLabel( refPanel, SHARPEYE_NAME .. " has an integrated Motion blur extension to hub with Source Engine motion blur. However, experienced users may want to use the integrated Source \"Forward motion blur\" and disable this one.", 60 + 10, true )
	sharpeye.Util_AppendCheckBox( refPanel, "Use " .. SHARPEYE_NAME .. " Motion blur" , "sharpeye_opt_motionblur" )
	sharpeye.Util_AppendSlider( refPanel, "Permablur Amount", "sharpeye_detail_permablur", 0, 10, 0 )
	
	sharpeye.Util_AppendLabel( refPanel, "Machinima mode allows you to enable SharpeYe bobbing even if noclipping or inside a vehicle. Remember to disable it during normal gameplay.", 40 + 10, true )
	sharpeye.Util_AppendCheckBox( refPanel, "Machinima mode" , "sharpeye_opt_machinimamode" )

	sharpeye.Util_AppendLabel( refPanel, "Highspeed Deathcam allows the deathcam to be immediate when the player has a death ragdoll. This may cause issues on some gamemodes (simulate death).", 50 + 10, true )
	sharpeye.Util_AppendCheckBox( refPanel, "First Person Deathcam - Highspeed Mode", "sharpeye_opt_firstpersondeath_highspeed" )
	
	sharpeye.Util_AppendLabel( refPanel, "You can cross \"SharpeYe's Stamina\" and \"Perfected Climb SWEP Fatigue\" (by -[SB]- Spy and Kogitsune) using this.", 40 + 10, true )
	sharpeye.Util_AppendCheckBox( refPanel, "Cross with Perfected Climb SWEP" , "sharpeye_ext_perfectedclimbswep" )
	
	sharpeye.Util_MakeCategory( refPanel, "New bobbing options", 1 )
	sharpeye.Util_AppendLabel( refPanel, "MACHINIMA MAKERS, PLEASE READ :", 10 + 10, true )
	sharpeye.Util_AppendLabel( refPanel, "Players can set these options to zero to get their old SharpeYe settings back.", 40, true )
	sharpeye.Util_AppendLabel( refPanel, "", 10, true )
	sharpeye.Util_AppendSlider( refPanel, "Stepmod : Elevation Intensity", "sharpeye_detail_stepmodintensity", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Stepmod : Elevation Frequency", "sharpeye_detail_stepmodfrequency", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Shakemod : Intensity",  "sharpeye_detail_shakemodintensity", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Shakemod : Health influence",  "sharpeye_detail_shakemodhealth", 0, 10, 0 )
	
	
	sharpeye.Util_MakeCategory( refPanel, "Head motion not working ? [DEBUG]", 0)
	
	
	-- Dynamic Debugger
	do
		local okayColor = Color(0, 255, 0, 255)
		local overvColor = Color(255, 255, 0, 255)
		local warnColor = Color(255, 128, 0, 255)
		local failColor = Color(255, 0, 0, 255)
		local neutralColor = Color(255, 255, 255, 255)
		
		do
			local label = vgui.Create("DLabel")
			label:SetSize( refPanel.W_WIDTH, 10 )
			label:SetContentAlignment( 2 )
			label.Okay = nil
			function label:Think()
				local measureOkay = sharpeye.IsEnabled()
				if measureOkay ~= self.Okay then
					if measureOkay then
						label:SetText("SharpeYe is Enabled. OK")
						label:SetColor( okayColor )
						
					else
						label:SetText("SharpeYe is Disabled. FAIL")
						label:SetColor( failColor )
						
					end
					self.Okay = measureOkay
				
				end
			
			end
			sharpeye.Util_AppendPanel( refPanel, label )
		end
		do
			local label = vgui.Create("DLabel")
			label:SetSize( refPanel.W_WIDTH, 10 )
			label:SetContentAlignment( 2 )
			label.Okay = nil
			function label:Think()
				local measureOkay = sharpeye.IsMotionEnabled()
				if measureOkay ~= self.Okay then
					if measureOkay then
						label:SetText("Motion is Enabled. OK")
						label:SetColor( okayColor )
						
					else
						label:SetText("Motion is Disabled. FAIL")
						label:SetColor( failColor )
						
					end
					self.Okay = measureOkay
				
				end
			
			end
			sharpeye.Util_AppendPanel( refPanel, label )
		end
		do
			local label = vgui.Create("DLabel")
			label:SetSize( refPanel.W_WIDTH, 10 )
			label:SetContentAlignment( 2 )
			label.Okay = nil
			function label:Think()
				local measureOkay = not sharpeye.ShouldBobbingDisableCompletely()
				if measureOkay ~= self.Okay then
					if measureOkay then
						label:SetText("Bobbing is Allowed. OK")
						label:SetColor( okayColor )
						
					else
						label:SetText("Bobbing is permanently Disabled. WARNING")
						label:SetColor( warnColor )
						
					end
					self.Okay = measureOkay
				
				end
			
			end
			sharpeye.Util_AppendPanel( refPanel, label )
		end
		do
			local label = vgui.Create("DLabel")
			label:SetSize( refPanel.W_WIDTH, 10 )
			label:SetContentAlignment( 2 )
			label.Okay = nil
			function label:Think()
				local measureOkay = not sharpeye.ShouldBobbingDisableWithTools()
				if measureOkay ~= self.Okay then
					if measureOkay then
						label:SetText("Bobbing is Allowed (Tool mode). OK")
						label:SetColor( okayColor )
						
					else
						label:SetText("Bobbing is Disabled with Tools. WARNING")
						label:SetColor( warnColor )
						
					end
					self.Okay = measureOkay
				
				end
			
			end
			sharpeye.Util_AppendPanel( refPanel, label )
		end
		do
			local label = vgui.Create("DLabel")
			label:SetSize( refPanel.W_WIDTH, 10 )
			label:SetContentAlignment( 2 )
			label.Okay = nil
			function label:Think()
				local measureOkay = math.abs( sharpeye.Detail_GetMasterMod() ) > 0.6
				if measureOkay ~= self.Okay then
					if measureOkay then
						label:SetText("Master Scale is set to a noticeable value. OK")
						label:SetColor( okayColor )
						
					else
						label:SetText("Master Scale is set to a Low value. WARNING")
						label:SetColor( warnColor )
						
					end
					self.Okay = measureOkay
				
				end
			
			end
			sharpeye.Util_AppendPanel( refPanel, label )
		end
		do
			local label = vgui.Create("DLabel")
			label:SetSize( refPanel.W_WIDTH, 10 )
			label:SetContentAlignment( 2 )
			label.Okay = nil
			function label:Think()
				local measureOkay = not sharpeye.InMachinimaMode()
				if measureOkay ~= self.Okay then
					if measureOkay then
						label:SetText("Machinima Mode is Disabled. NORMAL MODE")
						label:SetColor( okayColor )
						
					else
						label:SetText("Machinima Mode is Enabled. OVERRIDE MODE")
						label:SetColor( overvColor )
						
					end
					self.Okay = measureOkay
				
				end
			
			end
			sharpeye.Util_AppendPanel( refPanel, label )
		end
		do
			local label = vgui.Create("DLabel")
			label:SetSize( refPanel.W_WIDTH, 10 )
			label:SetContentAlignment( 2 )
			label.Okay = nil
			function label:Think()
				local measureOkay = not sharpeye.ShouldMotionDisableInThirdPerson()
				if measureOkay ~= self.Okay then
					if measureOkay then
						label:SetText("Third Person mode is Undetected. OKAY")
						label:SetColor( okayColor )
						
					else
						label:SetText("Motion is Disabled in Third Person. FAIL EX OV.")
						label:SetColor( failColor )
						
					end
					self.Okay = measureOkay
				
				end
			
			end
			sharpeye.Util_AppendPanel( refPanel, label )
		end
		do
			local label = vgui.Create("DLabel")
			label:SetSize( refPanel.W_WIDTH, 10 )
			label:SetContentAlignment( 2 )
			label.Okay = nil
			function label:Think()
				local measureOkay = not sharpeye.IsInVehicle()
				if measureOkay ~= self.Okay then
					if measureOkay then
						label:SetText("Vehicle mode is Undetected. OKAY")
						label:SetColor( okayColor )
						
					else
						label:SetText("Vehicle mode is Detected. FAIL EX OV.")
						label:SetColor( failColor )
						
					end
					self.Okay = measureOkay
				
				end
			
			end
			sharpeye.Util_AppendPanel( refPanel, label )
		end
		do
			local label = vgui.Create("DLabel")
			label:SetSize( refPanel.W_WIDTH, 10 )
			label:SetContentAlignment( 2 )
			label.Okay = nil
			function label:Think()
				local measureOkay = not sharpeye.IsNoclipping()
				if measureOkay ~= self.Okay then
					if measureOkay then
						label:SetText("Noclip mode is Undetected. OKAY")
						label:SetColor( okayColor )
						
					else
						label:SetText("Noclip mode is Detected. WARNING EX OV.")
						label:SetColor( warnColor )
						
					end
					self.Okay = measureOkay
				
				end
			
			end
			sharpeye.Util_AppendPanel( refPanel, label )
		end
		
	end
	
	
	
	
	sharpeye.Util_AppendLabel( refPanel, "WARNING : Make sure you are NOT holding the Toolgun or Physgun for testing.\nIf you encounter issues with head motion not working, then an addon is overriding SharpeYe. There is no way to fix it.", 100, true )
	--Report multiline
	/*
	do
		local DevtMultiline = vgui.Create("DTextEntry")
		DevtMultiline:SetMultiline( true )
		do
			local myText = ""
			local M_R_O, M_R_A, M_R_F = EyePos(), EyeAngles(), 75
			myText = myText .. "REF :: "
			myText = myText .. "( " .. tostring(M_R_O) .. " , " .. tostring(M_R_A) .. " , " .. tostring(M_R_F) .. " )\n"
			for k,v in pairs( hook.GetTable()["CalcView"] ) do
				local I_R_O, I_R_A, I_R_F = v( LocalPlayer(), M_R_O, M_R_A, M_R_F )
				local wasTable = false
				if type(I_R_O) == "table" then
					wasTable = true
					local I_R_T = I_R_O
					I_R_F = I_R_T.fov
					I_R_A = I_R_T.angles
					I_R_O = I_R_T.origin
				end
				myText = myText .. tostring(k) .. " >> "
				myText = myText .. "( " .. tostring(I_R_O) .. " , " .. tostring(I_R_A) .. " , " .. tostring(I_R_F) .. " )::" .. (wasTable and "tbl" or "oaf") .. "\n"
			end
			DevtMultiline:SetText( myText )
		end
		DevtMultiline:SetEditable( false )
		DevtMultiline:SetSize( refPanel.W_WIDTH, 100 )
		
		sharpeye.Util_AppendPanel( refPanel, DevtMultiline )
		
	end
	*/
	
	sharpeye.Util_AppendLabel( refPanel, "If you are a developer and you know what you are doing, you can try to unhook some overrides. Warning, unhooking will break other addons. :", 70, true )
	--Disabler
	do
		local counter = 0
		local tCalcView = hook.GetTable()["CalcView"] or {}
		for k,v in pairs( tCalcView ) do
			--if not string.find( k , "sharpeye" ) then
				counter = counter + 1
				local DisablerButton = vgui.Create("DButton")
				DisablerButton.__IsEnabled = true
				DisablerButton.__Keyword = k
				DisablerButton.__Reference = v
				if not string.find( k , "sharpeye" ) then
					DisablerButton:SetText( "Unhook " .. k )
					DisablerButton.DoClick = function()
						if DisablerButton.__IsEnabled then
							DisablerButton.__IsEnabled = false
							hook.Remove("CalcView", DisablerButton.__Keyword)
							DisablerButton:SetText( "Hook back " .. k )
							
						else
							DisablerButton.__IsEnabled = true
							hook.Add("CalcView", DisablerButton.__Keyword, DisablerButton.__Reference)
							DisablerButton:SetText( "Unhook " .. k )
						
						end
						--DisablerButton:SetDisabled( true )
					end
					
				else
					DisablerButton:SetText( "<--" .. k .. "-->" )
					DisablerButton.DoClick = function() return nil end
				
				end
				
				sharpeye.Util_AppendPanel( refPanel, DisablerButton )
			--end
		end
		if counter == 0 then
			sharpeye.Util_AppendLabel( refPanel, "<No hooks to display.>" )
		end
	end
	do
		local DevtMultiline = vgui.Create("DTextEntry")
		DevtMultiline:SetMultiline( true )
		do
			local myText = "REF :: "
			for k,v in pairs( hook.GetTable()["CalcView"] ) do
				myText = myText .. tostring(k) .. " >> "
			end
			DevtMultiline:SetText( myText )
		end
		DevtMultiline:SetEditable( false )
		DevtMultiline:SetSize( refPanel.W_WIDTH, 100 )
		
		sharpeye.Util_AppendPanel( refPanel, DevtMultiline )
		
	end
	
	sharpeye.Util_MakeCategory( refPanel, "Crosshair", 0 )
	sharpeye.Util_AppendLabel( refPanel, "Crosshair color" )
	--XHair Color
	do
		local CDetailsCrosshairColor = vgui.Create("CtrlColor")
		CDetailsCrosshairColor.Prefix = "sharpeye_xhair_color"
		CDetailsCrosshairColor:SetConVarR(CDetailsCrosshairColor.Prefix .."_r")
		CDetailsCrosshairColor:SetConVarG(CDetailsCrosshairColor.Prefix .."_g")
		CDetailsCrosshairColor:SetConVarB(CDetailsCrosshairColor.Prefix .."_b")
		CDetailsCrosshairColor:SetConVarA(CDetailsCrosshairColor.Prefix .."_a")
		sharpeye.Util_AppendPanel(refPanel, CDetailsCrosshairColor)
	end
	
	sharpeye.Util_AppendLabel( refPanel, "Crosshair Shadow color" )
	--ShadXHair Color
	do
		local CDetailsCrosshairColor = vgui.Create("CtrlColor")
		CDetailsCrosshairColor.Prefix = "sharpeye_xhair_shadcolor"
		CDetailsCrosshairColor:SetConVarR(CDetailsCrosshairColor.Prefix .."_r")
		CDetailsCrosshairColor:SetConVarG(CDetailsCrosshairColor.Prefix .."_g")
		CDetailsCrosshairColor:SetConVarB(CDetailsCrosshairColor.Prefix .."_b")
		CDetailsCrosshairColor:SetConVarA(CDetailsCrosshairColor.Prefix .."_a")
		sharpeye.Util_AppendPanel(refPanel, CDetailsCrosshairColor)
	end
	
	sharpeye.Util_AppendSlider( refPanel, "Crosshair : Static Reticule Size",  "sharpeye_xhair_staticsize", 0, 8, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Crosshair : Dynamic Reticule Size",  "sharpeye_xhair_dynamicsize", 0, 8, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Crosshair : Dynamic Dropshadow Size",  "sharpeye_xhair_shadowsize", 0, 8, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Crosshair : Focus Size",  "sharpeye_xhair_focussize", 0, 8, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Crosshair : Focus Dropshadow Size",  "sharpeye_xhair_focusshadowsize", 0, 8, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Crosshair : Focus Spin",  "sharpeye_xhair_focusspin", -4, 4, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Crosshair : Focus Base Angle",  "sharpeye_xhair_focusangle", 0, 7, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Crosshair : Focus Base Angle (Extend)",  "sharpeye_xhair_focusangle", 0, 32, 0 )
	
	sharpeye.Util_MakeCategory( refPanel, "Details", 0 )
	
	// PRESETS : STYLE
	--[[
	local CDetailsSaver = sharpeye.MakePresetPanel( {
		options = { ["default"] = theme:GetThemeDefaultsTable() },
		cvars = theme:GetThemeConvarTable(),
		folder = "sharpeye_themes_"..theme:GetRawName()
	} )
	]]--
	
	sharpeye.Util_AppendSlider( refPanel, "Breathing : Bobbing Distance", "sharpeye_detail_breathebobdist", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Running : Bobbing Frequency",  "sharpeye_detail_runningbobfreq", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Running : Leaning Angle",  "sharpeye_detail_leaningangle", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Jumping : Landing Angle",  "sharpeye_detail_landingangle", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Basis : Run Speed Reference (inches/s)", "sharpeye_basis_runspeed", 50, 150, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Basis : Faster Stamina Recovery",  "sharpeye_basis_staminarecover", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Basis : Healthy Level",  "sharpeye_basis_healthylevel", 0, 100, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Basis : Health-based Behavior",  "sharpeye_basis_healthbased", 0, 10, 0 )
	
	sharpeye.Util_AppendSlider( refPanel, "Sound : Footsteps Volume",  "sharpeye_snd_footsteps_vol", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Sound : Breathing Volume",  "sharpeye_snd_breathing_vol", 0, 10, 0 )
	sharpeye.Util_AppendCheckBox( refPanel, "Wind : Enable",  "sharpeye_snd_windenable" )
	sharpeye.Util_AppendSlider( refPanel, "Wind : Minimum velocity",  "sharpeye_snd_windvelocityincap", 0, 10, 0 )
	sharpeye.Util_AppendCheckBox( refPanel, "Wind : Heard even on Ground",  "sharpeye_snd_windonground" )
	sharpeye.Util_AppendCheckBox( refPanel, "Wind : Heard even on Noclip",  "sharpeye_snd_windonnoclip" )
	
	--Revert button
	do
		local CDetailsRevertButton = vgui.Create("DButton")
		CDetailsRevertButton:SetText( "Revert to Defaults" )
		CDetailsRevertButton.DoClick = function()
			sharpeye.RevertDetails( )
		end
		
		sharpeye.Util_AppendPanel( refPanel, CDetailsRevertButton )
	end

	sharpeye.Util_MakeCategory( refPanel, "Cloud" .. (bCanGetVersion and (" [ v" .. tostring(MY_VERSION) .. " >> v" .. tostring(ONLINE_VERSION_READ) .. " ]") or " Version" ), 0 )
	-- Reload from Cloud Button
	do
		local CReload = vgui.Create("DButton")
		CReload:SetText( "Reload from Cloud" )
		CReload.DoClick = sharpeye.MenuCall_ReloadFromCloud
		sharpeye.Util_AppendPanel( refPanel, CReload )
	end
	
	-- Reload from Locale Button
	if sharpeye_internal then
		local CReload = vgui.Create("DButton")
		CReload:SetText( "Reload from Locale" )
		CReload.DoClick = sharpeye.MenuCall_ReloadFromLocale
		sharpeye.Util_AppendPanel( refPanel, CReload )
	end
	
	-- Changelog Button
	if sharpeye_internal and sharpeye_internal.GetReplicate then
		sharpeye.Util_AppendLabel( refPanel, "" )
		
		local CChangelog = vgui.Create("DButton")
		CChangelog:SetText( "Open Changelog" )
		CChangelog.DoClick = sharpeye.ShowChangelog
		sharpeye.Util_AppendPanel( refPanel, CChangelog )
	end
	
	sharpeye.Util_ApplyCategories( refPanel )
end


function sharpeye.ShowMenuNoOverride( )
	sharpeye.ShowMenu( true )
end

function sharpeye.ShowMenu( optbKeyboardShouldNotOverride )
	if not sharpeye.DermaPanel then
		sharpeye.BuildMenu()
	end
	--sharpeye.DermaPanel:Center()
	sharpeye.DermaPanel:MakePopup()
	sharpeye.DermaPanel:SetKeyboardInputEnabled( not optbKeyboardShouldNotOverride )
	sharpeye.DermaPanel:SetVisible( true )
end

function sharpeye.HideMenu()
	if not sharpeye.DermaPanel then
		return
	end
	sharpeye.DermaPanel:SetVisible( false )
end

function sharpeye.DestroyMenu()
	if sharpeye.DermaPanel then
		sharpeye.DermaPanel:Remove()
		sharpeye.DermaPanel = nil
	end
end

-----------

function sharpeye.BuildChangelog( opt_tExpand )
	if sharpeye.ChangelogPanel then sharpeye.ChangelogPanel:Remove() end
	
	local bCanGetVersion = sharpeye_internal ~= nil
	local MY_VERSION, ONLINE_VERSION, DOWNLOAD_LINK
	local ONLINE_VERSION_READ = -1
	if bCanGetVersion then
		MY_VERSION, ONLINE_VERSION, DOWNLOAD_LINK = sharpeye_internal.GetVersionData()
		
		if ONLINE_VERSION == -1 then
			ONLINE_VERSION_READ = "<offline>"
		else
			ONLINE_VERSION_READ = tostring( ONLINE_VERSION )
		end
		
	end
	
	sharpeye.ChangelogPanel = sharpeye.Util_MakeFrame( ScrW() * 0.95, ScrH() * 0.75, " - Changelog" )
	local refPanel = sharpeye.ChangelogPanel
	
	sharpeye.Util_MakeCategory( refPanel, "Changelog", 1 )
	
	if ONLINE_VERSION and ONLINE_VERSION ~= -1 and sharpeye_internal.GetReplicate then
		local myVer = MY_VERSION or 0
		
		local contents = sharpeye_internal.GetReplicate() or ( tostring( MY_VERSION or 0 ) .. "\n<Nothing to show>" )
		local split = string.Explode( "\n", contents )
		if (#split % 2) == 0 then
			local dList = vgui.Create("DListView")
			dList:SetMultiSelect( false )
			dList:SetTall( refPanel.W_HEIGHT )
			dList:AddColumn( "Ver." ):SetMaxWidth( 45 ) -- Add column
			dList:AddColumn( "Log" )
			
			local gotMyVer = false
			for i=1, #split, 2 do
				local iVer = tonumber( split[i] or 0 ) or 0
				if not gotMyVer and iVer ~= 0 and iVer <= myVer and (split[i+2] ~= "&") then
					dList:AddLine( "*" .. myVer .. "*", "< Locale version >" )
					gotMyVer = true
					
				end
				local myLine = dList:AddLine( (split[i] ~= "&") and split[i] or "", split[i+1] or "" )
				myLine:SizeToContents()
				
			end
			
			sharpeye.Util_AppendPanel( refPanel, dList )
			--dList:SizeToContents()
			
		else
			sharpeye.Util_AppendLabel( refPanel, "<Changelog data is corrupted>", 70, true )
			
		end
		
	else
		sharpeye.Util_AppendLabel( refPanel, "Couldn't load changelog because your Locale version is too old.", 70, true )
	
	end
	
	sharpeye.Util_ApplyCategories( refPanel )

end

function sharpeye.ShowChangelog( optbKeyboardShouldNotOverride )
	if not sharpeye.ChangelogPanel then
		sharpeye.BuildChangelog()
	end
	sharpeye.ChangelogPanel:MakePopup()
	sharpeye.ChangelogPanel:SetKeyboardInputEnabled( not optbKeyboardShouldNotOverride )
	sharpeye.ChangelogPanel:SetVisible( true )
end

function sharpeye.HideChangelog()
	if not sharpeye.ChangelogPanel then
		return
	end
	sharpeye.ChangelogPanel:SetVisible( false )
end

function sharpeye.DestroyChangelog()
	if sharpeye.ChangelogPanel then
		sharpeye.ChangelogPanel:Remove()
		sharpeye.ChangelogPanel = nil
	end
end

--[[
function sharpeye.MakePresetPanel( data )
	local ctrl = vgui.Create( "ControlPresets", self )
	
	ctrl:SetPreset( data.folder )
	
	if ( data.options ) then
		for k, v in pairs( data.options ) do
			if ( k != "id" ) then
				ctrl:AddOption( k, v )
			end
		end
	end
	
	if ( data.cvars ) then
		for k, v in pairs( data.cvars ) do
			ctrl:AddConVar( v )
		end
	end
	
	return ctrl
end
]]--

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//// SANDBOX PANEL .

function sharpeye.Panel(Panel)	
	Panel:AddControl("Checkbox", {
			Label = "Enable", 
			Description = "Enable", 
			Command = "sharpeye_core_enable" 
		}
	)
	Panel:AddControl("Button", {
			Label = "Open Menu (sharpeye_menu)", 
			Description = "Open Menu (sharpeye_menu)", 
			Command = "sharpeye_menu"
		}
	)
	
	Panel:Help("To trigger the menu in any gamemode, type sharpeye_menu in the console, or bind this command to any key.")
end

function sharpeye.AddPanel()
	spawnmenu.AddToolMenuOption("Options", "Player", SHARPEYE_NAME, SHARPEYE_NAME, "", "", sharpeye.Panel, {SwitchConVar = 'sharpeye_core_enable'})
end

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
// MOUNT FCTS.

function sharpeye.MountMenu()
	concommand.Add( "sharpeye_menu", sharpeye.ShowMenuNoOverride )
	concommand.Add( "sharpeye_call_menu", sharpeye.ShowMenuNoOverride )
	concommand.Add( "+sharpeye_menu", sharpeye.ShowMenu )
	concommand.Add( "-sharpeye_menu", sharpeye.HideMenu )
	--hook.Add( "PopulateToolMenu", "AddSharpeYePanel", sharpeye.AddPanel )
end

function sharpeye.UnmountMenu()
	sharpeye.DestroyMenu()

	concommand.Remove( "sharpeye_call_menu" )
	concommand.Remove( "sharpeye_menu" )
	concommand.Remove( "+sharpeye_menu" )
	concommand.Remove( "-sharpeye_menu" )
	--hook.Remove( "PopulateToolMenu", "AddSharpeYePanel" )
end

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////