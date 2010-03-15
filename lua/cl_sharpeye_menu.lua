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

function sharpeye.MenuGetExpandTable()
	return {
		sharpeye.DermaPanel.GeneralCategory:GetExpanded(),
		sharpeye.DermaPanel.CDetailsCategory:GetExpanded()
		}
end

function sharpeye.Util_CheckBox( title, cvar )
	local myPanel = vgui.Create( "DCheckBoxLabel" )
	myPanel:SetText( title )
	myPanel:SetConVar( cvar )
	
	return myPanel
end

function sharpeye.BuildMenu( opt_tExpand )
	if sharpeye.DermaPanel then sharpeye.DermaPanel:Remove() end
	
	local MY_VERSION, SVN_VERSION, DOWNLOAD_LINK = sharpeye.GetVersionData()
	
	sharpeye.DermaPanel = vgui.Create( "DFrame" )
	local w, h = 256, ScrH() * 0.7
	local border = 4
	local W_WIDTH = w - 2*border
	
	////// // // THE FRAME
	sharpeye.DermaPanel:SetPos( ScrW()*0.5 - w*0.5 , ScrH()*0.5 - h*0.5 )
	sharpeye.DermaPanel:SetSize( w, h )
	sharpeye.DermaPanel:SetTitle( SHARPEYE_NAME )
	sharpeye.DermaPanel:SetVisible( false )
	sharpeye.DermaPanel:SetDraggable( true )
	sharpeye.DermaPanel:ShowCloseButton( true )
	sharpeye.DermaPanel:SetDeleteOnClose( false )
	
	local PanelList = vgui.Create( "DPanelList", sharpeye.DermaPanel )
	PanelList:SetPos( border , 22 + border )
	PanelList:SetSize( W_WIDTH, h - 2*border - 22 )
	PanelList:SetSpacing( 5 )
	PanelList:EnableHorizontal( false )
	PanelList:EnableVerticalScrollbar( false )
	
	
	
	////// CATEGORY : GENERAL
	sharpeye.DermaPanel.GeneralCategory = vgui.Create("DCollapsibleCategory", PanelList)
	sharpeye.DermaPanel.GeneralCategory:SetSize( W_WIDTH, 50 )
	sharpeye.DermaPanel.GeneralCategory:SetLabel( "General" )
	
	local GeneralCatList = vgui.Create( "DPanelList" )
	GeneralCatList:SetSize(W_WIDTH, h - 160 )
	GeneralCatList:EnableHorizontal( false )
	GeneralCatList:EnableVerticalScrollbar( false )
	
	local GeneralEnableCheck = sharpeye.Util_CheckBox( "Enable" , "sharpeye_core_enable" )
	local GeneralMotionCheck = sharpeye.Util_CheckBox( "Use Motion" , "sharpeye_core_motion" )
	local GeneralSoundCheck  = sharpeye.Util_CheckBox( "Use Sounds" , "sharpeye_core_sound" )
	local GeneralCrosshairCheck  = sharpeye.Util_CheckBox( "Use Crosshair" , "sharpeye_core_crosshair" )
	
	
	local GeneralBreathingLabel = vgui.Create("DLabel")
	GeneralBreathingLabel:SetText( "Breathing mode :" )
	
	local GeneralBreathingMulti = vgui.Create( "DMultiChoice" )
	
	GeneralBreathingMulti:AddChoice( "No breathing" )
	GeneralBreathingMulti:AddChoice( "Based on player model" )
	GeneralBreathingMulti:AddChoice( "Always Male" )
	GeneralBreathingMulti:AddChoice( "Always Female" )
	GeneralBreathingMulti:AddChoice( "Always Gas mask" )
	
	GeneralBreathingMulti.OnSelect = function(index, value, data)
		sharpeye.SetVar( "sharpeye_breathing", (value - 1) or 0 )
	end
	
	GeneralBreathingMulti:ChooseOptionID( 1 + sharpeye.GetBreathingMode() )
	
	GeneralBreathingMulti:PerformLayout()
	GeneralBreathingMulti:SizeToContents()
	
	// DHDIV	
	local GeneralTextLabel = vgui.Create("DLabel")
	local GeneralTextLabelMessage = "The command \"sharpeye_menu\" calls this menu.\n"
	if not (MY_VERSION and SVN_VERSION and (MY_VERSION < SVN_VERSION)) then
		GeneralTextLabelMessage = GeneralTextLabelMessage .. "Example : To assign SharpeYe menu to F10, type in the console :"
	else
		GeneralTextLabelMessage = GeneralTextLabelMessage .. "Your version is "..MY_VERSION.." and the updated one is "..SVN_VERSION.." ! You should update !"
	end
	GeneralTextLabel:SetWrap( true )
	GeneralTextLabel:SetText( GeneralTextLabelMessage )
	GeneralTextLabel:SetContentAlignment( 2 )
	GeneralTextLabel:SetSize( W_WIDTH, 50 )
	
	// DHMENU BUTTON
	local GeneralCommandLabel = vgui.Create("DTextEntry")
	if not (MY_VERSION and SVN_VERSION and (MY_VERSION < SVN_VERSION) and DOWNLOAD_LINK) then
		GeneralCommandLabel:SetText( "bind \"F10\" \"sharpeye_menu\"" )
	else
		GeneralCommandLabel:SetText( DOWNLOAD_LINK )
	end
	GeneralCommandLabel:SetEditable( false )
	
	// MAKE: GENERAL
	GeneralCatList:AddItem( GeneralEnableCheck )
	GeneralCatList:AddItem( GeneralMotionCheck )
	GeneralCatList:AddItem( GeneralSoundCheck )
	GeneralCatList:AddItem( GeneralCrosshairCheck )
	GeneralCatList:AddItem( GeneralBreathingLabel )
	GeneralCatList:AddItem( GeneralBreathingMulti )
	GeneralCatList:AddItem( GeneralTextLabel )
	GeneralCatList:AddItem( GeneralCommandLabel )
	GeneralCatList:PerformLayout()
	GeneralCatList:SizeToContents()
	sharpeye.DermaPanel.GeneralCategory:SetContents( GeneralCatList ) // CATEGORY GENERAL FILLED


	////// CATEGORY : CDetails
	sharpeye.DermaPanel.CDetailsCategory = vgui.Create("DCollapsibleCategory", PanelList)
	sharpeye.DermaPanel.CDetailsCategory:SetSize( W_WIDTH, 50 )
	sharpeye.DermaPanel.CDetailsCategory:SetLabel( "Details and Crosshair" )
	
	local CDetailsCatList = vgui.Create( "DPanelList" )
	CDetailsCatList:SetSize(W_WIDTH, 128 )
	CDetailsCatList:EnableHorizontal( false )
	CDetailsCatList:EnableVerticalScrollbar( false )
	
	// REVERT BUTTON
	local CDetailsRevertButton = vgui.Create("DButton")
	CDetailsRevertButton:SetText( "Revert to Defaults" )
	CDetailsRevertButton.DoClick = function()
		sharpeye.RevertDetails( )
	end
	
	// PRESETS : STYLE
	--[[
	local CDetailsSaver = sharpeye.MakePresetPanel( {
		options = { ["default"] = theme:GetThemeDefaultsTable() },
		cvars = theme:GetThemeConvarTable(),
		folder = "sharpeye_themes_"..theme:GetRawName()
	} )
	]]--
	
	local CDetailsBreathingBobDist = vgui.Create("DNumSlider")
	CDetailsBreathingBobDist:SetText( "Breathing : Bobbing Distance" )
	CDetailsBreathingBobDist:SetMin( 0 )
	CDetailsBreathingBobDist:SetMax( 10 )
	CDetailsBreathingBobDist:SetDecimals( 0 )
	CDetailsBreathingBobDist:SetConVar("sharpeye_detail_breathebobdist")
	

	local CDetailsRunningBobFreq = vgui.Create("DNumSlider")
	CDetailsRunningBobFreq:SetText( "Running : Bobbing Frequency" )
	CDetailsRunningBobFreq:SetMin( 0 )
	CDetailsRunningBobFreq:SetMax( 10 )
	CDetailsRunningBobFreq:SetDecimals( 0 )
	CDetailsRunningBobFreq:SetConVar("sharpeye_detail_runningbobfreq")
	
	
	local CDetailsRunSpeed = vgui.Create("DNumSlider")
	CDetailsRunSpeed:SetText( "Basis : Run Speed reference (inches/s)" )
	CDetailsRunSpeed:SetMin( 50 )
	CDetailsRunSpeed:SetMax( 150 )
	CDetailsRunSpeed:SetDecimals( 0 )
	CDetailsRunSpeed:SetConVar("sharpeye_basis_runspeed")
	
	local CDetailsStaminaRecovery = vgui.Create("DNumSlider")
	CDetailsStaminaRecovery:SetText( "Basis : Faster Stamina recovery" )
	CDetailsStaminaRecovery:SetMin( 0 )
	CDetailsStaminaRecovery:SetMax( 10 )
	CDetailsStaminaRecovery:SetDecimals( 0 )
	CDetailsStaminaRecovery:SetConVar("sharpeye_basis_staminarecover")
	
	local CDetailsHealthBased = vgui.Create("DNumSlider")
	CDetailsHealthBased:SetText( "Basis : Health-based behavior" )
	CDetailsHealthBased:SetMin( 0 )
	CDetailsHealthBased:SetMax( 10 )
	CDetailsHealthBased:SetDecimals( 0 )
	CDetailsHealthBased:SetConVar("sharpeye_basis_healthbased")
	

	local CDetailsCrosshairColorLabel = vgui.Create("DLabel")
	CDetailsCrosshairColorLabel:SetText("Crosshair color")
	
	local CDetailsCrosshairColor = vgui.Create("CtrlColor")
	CDetailsCrosshairColor.Prefix = "sharpeye_xhair_color"
	CDetailsCrosshairColor:SetConVarR(CDetailsCrosshairColor.Prefix .."_r")
	CDetailsCrosshairColor:SetConVarG(CDetailsCrosshairColor.Prefix .."_g")
	CDetailsCrosshairColor:SetConVarB(CDetailsCrosshairColor.Prefix .."_b")
	CDetailsCrosshairColor:SetConVarA(CDetailsCrosshairColor.Prefix .."_a")
	
	local CDetailsCrosshairStatic = vgui.Create("DNumSlider")
	CDetailsCrosshairStatic:SetText( "Static Crosshair Reticule size" )
	CDetailsCrosshairStatic:SetMin( 0 )
	CDetailsCrosshairStatic:SetMax( 8 )
	CDetailsCrosshairStatic:SetDecimals( 0 )
	CDetailsCrosshairStatic:SetConVar("sharpeye_xhair_staticsize")
	
	local CDetailsCrosshairDynamic = vgui.Create("DNumSlider")
	CDetailsCrosshairDynamic:SetText( "Dynamic Crosshair Reticule size" )
	CDetailsCrosshairDynamic:SetMin( 0 )
	CDetailsCrosshairDynamic:SetMax( 8 )
	CDetailsCrosshairDynamic:SetDecimals( 0 )
	CDetailsCrosshairDynamic:SetConVar("sharpeye_xhair_dynamicsize")

	
	// MAKE: CDetails
	CDetailsCatList:AddItem( CDetailsRevertButton )
	--CDetailsCatList:AddItem( CDetailsSaver )
	CDetailsCatList:AddItem( CDetailsBreathingBobDist )
	CDetailsCatList:AddItem( CDetailsRunningBobFreq )
	CDetailsCatList:AddItem( CDetailsRunSpeed )
	CDetailsCatList:AddItem( CDetailsStaminaRecovery )
	CDetailsCatList:AddItem( CDetailsHealthBased )
	CDetailsCatList:AddItem( CDetailsCrosshairColorLabel )
	CDetailsCatList:AddItem( CDetailsCrosshairColor )
	CDetailsCatList:AddItem( CDetailsCrosshairStatic )
	CDetailsCatList:AddItem( CDetailsCrosshairDynamic )
	
	
	CDetailsCatList:PerformLayout()
	CDetailsCatList:SizeToContents()
	sharpeye.DermaPanel.CDetailsCategory:SetContents( CDetailsCatList ) // CATEGORY GENERAL FILLED

	
	sharpeye.DermaPanel.GeneralCategory:SetExpanded( opt_tExpand and (opt_tExpand[1] and 1 or 0) or 1 )
	sharpeye.DermaPanel.CDetailsCategory:SetExpanded( opt_tExpand and (opt_tExpand[2] and 1 or 0) or 0 )
	
	//FINISHING THE PANEL
	PanelList:AddItem( sharpeye.DermaPanel.GeneralCategory )  //CATEGORY GENERAL CREATED
	PanelList:AddItem( sharpeye.DermaPanel.CDetailsCategory )  //CATEGORY CDetails CREATED
end

function sharpeye.ShowMenu()
	if not sharpeye.DermaPanel then
		sharpeye.BuildMenu()
	end
	//sharpeye.DermaPanel:Center()
	sharpeye.DermaPanel:MakePopup()
	sharpeye.DermaPanel:SetVisible( true )
end

function sharpeye.DestroyMenu()
	if sharpeye.DermaPanel then
		sharpeye.DermaPanel:Remove()
		sharpeye.DermaPanel = nil
	end
end

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