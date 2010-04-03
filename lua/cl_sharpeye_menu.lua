////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Menu                                       //
////////////////////////////////////////////////

include( 'CtrlColor.lua' )

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

function sharpeye.Util_MakeFrame( width, height )
	local myPanel = vgui.Create( "DFrame" )
	local border = 4
	
	myPanel.W_HEIGHT = height - 20
	myPanel.W_WIDTH = width - 2 * border
	
	myPanel:SetPos( ScrW() * 0.5 - width * 0.5 , ScrH() * 0.5 - height * 0.5 )
	myPanel:SetSize( width, height )
	myPanel:SetTitle( SHARPEYE_NAME )
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

function sharpeye.BuildMenu( opt_tExpand )
	if sharpeye.DermaPanel then sharpeye.DermaPanel:Remove() end
	
	local MY_VERSION, SVN_VERSION, DOWNLOAD_LINK = sharpeye.GetVersionData()
	
	sharpeye.DermaPanel = sharpeye.Util_MakeFrame( 256, ScrH() * 0.7 )
	local refPanel = sharpeye.DermaPanel
	
	sharpeye.Util_MakeCategory( refPanel, "General", 1 )
	sharpeye.Util_AppendCheckBox( refPanel, "Enable" , "sharpeye_core_enable" )
	sharpeye.Util_AppendCheckBox( refPanel, "Use Motion" , "sharpeye_core_motion" )
	sharpeye.Util_AppendCheckBox( refPanel, "Use Sounds" , "sharpeye_core_sound" )
	sharpeye.Util_AppendCheckBox( refPanel, "Use Crosshair" , "sharpeye_core_crosshair" )
	sharpeye.Util_AppendCheckBox( refPanel, "Disable motion with Toolgun and Physgun" , "sharpeye_opt_disablewithtools" )
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
		if not (MY_VERSION and SVN_VERSION and (MY_VERSION < SVN_VERSION)) then
			GeneralTextLabelMessage = GeneralTextLabelMessage .. "Example : To assign " .. SHARPEYE_NAME .. " menu to F10, type in the console :"
			
		else
			GeneralTextLabelMessage = GeneralTextLabelMessage .. "Your version is "..MY_VERSION.." and the updated one is "..SVN_VERSION.." ! You should update !"
			
		end
		sharpeye.Util_AppendLabel( refPanel, GeneralTextLabelMessage, 50, true )
		
	end
	--Helper multiline
	do
		local GeneralCommandLabel = vgui.Create("DTextEntry")
		local hasUpdate = (MY_VERSION and SVN_VERSION and (MY_VERSION < SVN_VERSION) and DOWNLOAD_LINK)
		
		if not hasUpdate then
			GeneralCommandLabel:SetText( "bind \"F10\" \"sharpeye_menu\"" )
			
		else
			GeneralCommandLabel:SetText( DOWNLOAD_LINK )
			
		end
		GeneralCommandLabel:SetEditable( false )
		if hasUpdate then
			GeneralCommandLabel:SetMultiline( true )
			GeneralCommandLabel:SetSize( refPanel.W_WIDTH, 60 )
		end

		sharpeye.Util_AppendPanel( refPanel, GeneralCommandLabel )
		
	end
	
	
	sharpeye.Util_MakeCategory( refPanel, "Advanced", 0 )
	
	sharpeye.Util_AppendLabel( refPanel, "Machinima mode allows you to enable SharpeYe even if noclipping or inside a vehicle. Remember to disable it during normal gameplay.", 40 + 10, true )
	sharpeye.Util_AppendCheckBox( refPanel, "Machinima mode" , "sharpeye_opt_machinimamode" )
	
	sharpeye.Util_AppendLabel( refPanel, SHARPEYE_NAME .. " has an integrated Motion blur extension to hub with Source Engine motion blur. However, experienced users may want to use the integrated Source \"Forward motion blur\" and disable this one.", 60 + 10, true )
	sharpeye.Util_AppendCheckBox( refPanel, "Use " .. SHARPEYE_NAME .. " Motion blur" , "sharpeye_opt_motionblur" )
	
	
	sharpeye.Util_AppendLabel( refPanel, "If Machinima Mode is enabled, only Motion stays enabled.", 20 + 10, true )
	sharpeye.Util_AppendCheckBox( refPanel, "Disable Motion and Motion blur in Third Person mode" , "sharpeye_opt_disableinthirdperson" )
	
	sharpeye.Util_MakeCategory( refPanel, "Head motion not working ? [DEBUG]", 0)
	sharpeye.Util_AppendLabel( refPanel, "WARNING : Make sure you are NOT holding the Toolgun or Physgun for testing.\nIf you encounter issues with head motion not working, please post this report :", 70, true )
	--Report multiline
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
	
	sharpeye.Util_AppendLabel( refPanel, "If you are a developer and you know what you are doing, you can try to unhook some functions to figure out which one is the culprit :", 50, true )
	--Disabler
	do
		local counter = 0
		for k,v in pairs( hook.GetTable()["CalcView"] ) do
			if not string.find( k , "sharpeye" ) then
				counter = counter + 1
				local DisablerButton = vgui.Create("DButton")
				DisablerButton:SetText( "Unhook " .. k )
				DisablerButton.DoClick = function()
					hook.Remove("CalcView", k)
					DisablerButton:SetDisabled( true )
				end
				
				sharpeye.Util_AppendPanel( refPanel, DisablerButton )
			end
		end
		if counter == 0 then
			sharpeye.Util_AppendLabel( refPanel, "<No hooks to display.>" )
		end
	end
	
	
	sharpeye.Util_MakeCategory( refPanel, "Details and Crosshair", 0 )
	--Revert button
	do
		local CDetailsRevertButton = vgui.Create("DButton")
		CDetailsRevertButton:SetText( "Revert to Defaults" )
		CDetailsRevertButton.DoClick = function()
			sharpeye.RevertDetails( )
		end
		
		sharpeye.Util_AppendPanel( refPanel, CDetailsRevertButton )
	end
	
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
	
	sharpeye.Util_AppendSlider( refPanel, "Crosshair : Static Reticule Size",  "sharpeye_xhair_staticsize", 0, 8, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Crosshair : Dynamic Reticule Size",  "sharpeye_xhair_dynamicsize", 0, 8, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Sound : Footsteps Volume",  "sharpeye_snd_footsteps_vol", 0, 10, 0 )
	sharpeye.Util_AppendSlider( refPanel, "Sound : Breathing Volume",  "sharpeye_snd_breathing_vol", 0, 10, 0 )
	
	sharpeye.Util_ApplyCategories( refPanel )
end

function sharpeye.ShowMenu()
	if not sharpeye.DermaPanel then
		sharpeye.BuildMenu()
	end
	--sharpeye.DermaPanel:Center()
	sharpeye.DermaPanel:MakePopup()
	sharpeye.DermaPanel:SetVisible( true )
end

function sharpeye.DestroyMenu()
	if sharpeye.DermaPanel then
		sharpeye.DermaPanel:Remove()
		sharpeye.DermaPanel = nil
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
	concommand.Add( "sharpeye_menu", sharpeye.ShowMenu )
	concommand.Add( "sharpeye_call_menu", sharpeye.ShowMenu )
	hook.Add( "PopulateToolMenu", "AddSharpeYePanel", sharpeye.AddPanel )
end

function sharpeye.UnmountMenu()
	sharpeye.DestroyMenu()

	concommand.Remove( "sharpeye_call_menu" )
	concommand.Remove( "sharpeye_menu" )
	hook.Remove( "PopulateToolMenu", "AddSharpeYePanel" )
end

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////