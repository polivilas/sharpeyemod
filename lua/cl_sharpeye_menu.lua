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
		sharpeye.DermaPanel.GeneralCategory:GetExpanded()--,
		--sharpeye.DermaPanel.UIStyleCategory:GetExpanded()
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
	local w, h = 256, ScrH() * 0.4
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
	local GeneralCrosshairCheck  = sharpeye.Util_CheckBox( "Use Crosshair (Not yet available)" , "sharpeye_core_crosshair" )
	
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
	GeneralCatList:AddItem( GeneralTextLabel )
	GeneralCatList:AddItem( GeneralCommandLabel )
	GeneralCatList:PerformLayout()
	GeneralCatList:SizeToContents()
	sharpeye.DermaPanel.GeneralCategory:SetContents( GeneralCatList ) // CATEGORY GENERAL FILLED


	--[[
	////// CATEGORY : UIStyle
	sharpeye.DermaPanel.UIStyleCategory = vgui.Create("DCollapsibleCategory", PanelList)
	sharpeye.DermaPanel.UIStyleCategory:SetSize( W_WIDTH, 50 )
	sharpeye.DermaPanel.UIStyleCategory:SetLabel( "UI Design" )
	
	local UIStyleCatList = vgui.Create( "DPanelList" )
	UIStyleCatList:SetSize(W_WIDTH, 128 )
	UIStyleCatList:EnableHorizontal( false )
	UIStyleCatList:EnableVerticalScrollbar( false )
	
	// REVERT BUTTON
	local UIStyleRevertButton = vgui.Create("DButton")
	UIStyleRevertButton:SetText( "Revert Theme back to Defaults" )
	UIStyleRevertButton.DoClick = function()
		sharpeye.RevertTheme( )
	end
	
	// PRESETS : STYLE
	local UIStyleSaver = sharpeye.MakePresetPanel( {
		options = { ["default"] = theme:GetThemeDefaultsTable() },
		cvars = theme:GetThemeConvarTable(),
		folder = "sharpeye_themes_"..theme:GetRawName()
	} )
	
	// SIZE XREL
	local UIStyleSpacingSlider = vgui.Create("DNumSlider")
	UIStyleSpacingSlider:SetText( "Spacing" )
	UIStyleSpacingSlider:SetMin( 0 )
	UIStyleSpacingSlider:SetMax( 2 )
	UIStyleSpacingSlider:SetDecimals( 1 )
	UIStyleSpacingSlider:SetConVar("sharpeye_core_ui_spacing")
	
	// MAKE: UIStyle
	UIStyleCatList:AddItem( UIStyleRevertButton )
	UIStyleCatList:AddItem( UIStyleSaver )
	UIStyleCatList:AddItem( UIStyleSpacingSlider )
	
	
	local themeParamsNames = theme:GetParametersNames()
	for k,sName in pairs(themeParamsNames) do
		local myPanel = theme:BuildParameterPanel( sName )
		UIStyleCatList:AddItem( myPanel )
	end
	
	UIStyleCatList:PerformLayout()
	UIStyleCatList:SizeToContents()
	sharpeye.DermaPanel.UIStyleCategory:SetContents( UIStyleCatList ) // CATEGORY GENERAL FILLED
]]--
	
	sharpeye.DermaPanel.GeneralCategory:SetExpanded( opt_tExpand and (opt_tExpand[1] and 1 or 0) or 1 )
	--sharpeye.DermaPanel.UIStyleCategory:SetExpanded( opt_tExpand and (opt_tExpand[3] and 1 or 0) or 0 )
	
	//FINISHING THE PANEL
	PanelList:AddItem( sharpeye.DermaPanel.GeneralCategory )  //CATEGORY GENERAL CREATED
	--PanelList:AddItem( sharpeye.DermaPanel.UIStyleCategory )  //CATEGORY UIStyle CREATED
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