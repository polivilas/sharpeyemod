////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//

function sharpeye_Panel(Panel)	
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

function sharpeye_AddPanel()
	spawnmenu.AddToolMenuOption("Options", "Player", SHARPEYE_NAME, SHARPEYE_NAME, "", "", sharpeye_Panel, {SwitchConVar = 'sharpeye_core_enable'})
	
end

function sharpeye_InitLoad()
	hook.Add( "PopulateToolMenu", "AddSharpeYePanel", sharpeye_AddPanel )
	
end

