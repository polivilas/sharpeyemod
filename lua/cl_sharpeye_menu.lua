////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Menu                                       //
////////////////////////////////////////////////
local sharpeye = sharpeye

local SHARPEYE_MENU = nil

function sharpeye:GetMenu()
	return SHARPEYE_MENU or self:BuildMenu()
	
end

function sharpeye:UpdateMenuPosition()
	local pos = self:GetVar( "menu_position" )
	if pos > 0 then
		SHARPEYE_MENU:SetPos( ScrW() - SHARPEYE_MENU:GetWide(), 0 )
		SHARPEYE_MENU:GetContents()._p_topPanel._p_positionBox:SetType( "left" )
		
	else
		SHARPEYE_MENU:SetPos( 0, 0 )
		SHARPEYE_MENU:GetContents()._p_topPanel._p_positionBox:SetType( "right" )
		
	end
	
end

function sharpeye:BuildMenuContainer()
	self:RemoveMenu()
	
	local WIDTH = 260
	SHARPEYE_MENU = vgui.Create( SHARPEYE_SHORT .. "_ContextContainer" )
	SHARPEYE_MENU:SetSize( WIDTH, ScrH() )
	SHARPEYE_MENU:GetCanvas( ):SetDrawBackground( false )
	
	local mainPanel = vgui.Create( "DPanel" )
	SHARPEYE_MENU:SetContents( mainPanel )
	
	///
	
	//mainPanel:SetDrawBackground( false )
	/*mainPanel.Paint = function (self)
		surface.SetDrawColor( 255, 0, 0, 96 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end*/
	
	SHARPEYE_MENU.Paint = function (self)
		surface.SetDrawColor( 0, 0, 0, 96 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end
	
	mainPanel.Paint = function (self)
		surface.SetDrawColor( 0, 0, 0, 96 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end
	
	return SHARPEYE_MENU
	
end

function sharpeye:BuildMenu()
	if not ValidPanel( SHARPEYE_MENU ) then
		self:BuildMenuContainer()
		
	end
	
	local mainPanel = SHARPEYE_MENU:GetContents()
	
	////
	local topPanel = self:BuildHeader( mainPanel, SHARPEYE_NAME )
	
	////
	local tabMaster = vgui.Create( "DPropertySheet", mainPanel )
	do
		local formOptions = vgui.Create( "DPanelList" )
		do
			do
				local category = vgui.Create("DCollapsibleCategory", formOptions)
				category:SetExpanded( true )
				category:SetLabel( "Modules" )
				
				category.List  = vgui.Create("DPanelList", category )
				category.List:EnableHorizontal( false )
				category.List:EnableVerticalScrollbar( false )
				category.List:SetAutoSize( true )
				
				category:SetContents( category.List )
				formOptions:AddItem( category )
				
				category.List:AddItem( self:BuildParamPanel( "core_motion", { Type = "bool", Text = "Enable Motion Module" } ) )
				category.List:AddItem( self:BuildParamPanel( "core_sound", { Type = "bool", Text = "Enable Sounds" } ) )
				category.List:AddItem( self:BuildParamPanel( "core_crosshair", { Type = "bool", Text = "Enable Crosshair" } ) )
				category.List:AddItem( self:BuildParamPanel( "core_overlay", { Type = "bool", Text = "Enable Tunnel" } ) )
			end
			
			do
				local category = vgui.Create("DCollapsibleCategory", formOptions)
				category:SetExpanded( true )
				category:SetLabel( "Motion Modifiers" )
				
				category.List  = vgui.Create("DPanelList", category )
				category.List:EnableHorizontal( false )
				category.List:EnableVerticalScrollbar( false )
				category.List:SetAutoSize( true )
				
				category:SetContents( category.List )
				formOptions:AddItem( category )
				
				category.List:AddItem( self:BuildParamPanel( "opt_firstpersondeath", { Type = "bool", Text = "Use First Person Deathcam" } ) )
				category.List:AddItem( self:BuildParamPanel( "opt_relax", { Type = "bool", Text = "Use Relax Mode (Smoothed view)" } ) )
				category.List:AddItem( self:BuildParamPanel( "opt_disableinthirdperson", { Type = "bool", Text = "Disable Motion in Third Person Mode" } ) )
				category.List:AddItem( self:BuildParamPanel( "opt_disablewithtools", { Type = "bool", Text = "Disable Bobbing with Toolgun and Physgun" } ) )
				category.List:AddItem( self:BuildParamPanel( "opt_disablebobbing", { Type = "bool", Text = "Disable Bobbing entierely (Keep Focus)" } ) )
				
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "Breathing mode :" } ) )
				do
					local GeneralBreathingMulti = vgui.Create( "DMultiChoice" )
					GeneralBreathingMulti:AddChoice( "No breathing" )
					GeneralBreathingMulti:AddChoice( "Based on player model" )
					GeneralBreathingMulti:AddChoice( "Always Male" )
					GeneralBreathingMulti:AddChoice( "Always Female" )
					GeneralBreathingMulti:AddChoice( "Always Gas mask" )
					
					GeneralBreathingMulti.OnSelect = function(index, value, data)
						sharpeye:SetVar( "opt_breathing", (value - 1) or 0 )
					end
					
					GeneralBreathingMulti:ChooseOptionID( 1 + sharpeye:GetBreathingMode() )
					
					GeneralBreathingMulti:PerformLayout()
					GeneralBreathingMulti:SizeToContents()
					
					category.List:AddItem( GeneralBreathingMulti )
					
				end
				
			end
		end
		
		local formDetails = vgui.Create( "DPanelList" )
		do
			do
				local category = vgui.Create("DCollapsibleCategory", formOptions)
				category:SetExpanded( false )
				category:SetLabel( "Focus mode Help" )
				
				category.List  = vgui.Create("DPanelList", category )
				category.List:EnableHorizontal( false )
				category.List:EnableVerticalScrollbar( false )
				category.List:SetAutoSize( true )
				
				category:SetContents( category.List )
				formDetails:AddItem( category )
				
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "\nThe binding \"+sharpeye_focus\" allows you to enter Focus mode (with a 'hold key' action).\nExample : To assign it to the key 'v', type in the console :", Wrap = true } ) )
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_readonly", Text = "bind \"v\" \"+sharpeye_focus\"" } ) )
				
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "\nYou can also use toggle mode (like the Crossbow zoom) using \"focus_toggle\" command.\nExample : To assign it to the key 'v', type in the console :", Wrap = true } ) )
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_readonly", Text = "bind \"v\" \"sharpeye_focus_toggle\"" } ) )
				
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "\nSharpeYe::Focus is a derivative from Devenger's work, who is the author of the \"Twitch Weaponry\" SWEP pack in which ::Focus originates from.", Wrap = true } ) )
				
			end
			
			do				
				local category = vgui.Create("DCollapsibleCategory", formOptions)
				category:SetExpanded( false )
				category:SetLabel( "Focus mode Options" )
				
				category.List  = vgui.Create("DPanelList", category )
				category.List:EnableHorizontal( false )
				category.List:EnableVerticalScrollbar( false )
				category.List:SetAutoSize( true )
				
				category:SetContents( category.List )
				formDetails:AddItem( category )
				
				category.List:AddItem( self:BuildParamPanel( "opt_focus", { Type = "bool", Text = "Allow Focus mode" } ) )
				category.List:AddItem( self:BuildParamPanel( "opt_relax", { Type = "bool", Text = "Allow Relax mode" } ) )
				
				category.List:AddItem( self:BuildParamPanel( "detail_focus_anglex", { Type = "range", Text = "Left-Right pan angles", Min = 8, Max = 32, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_focus_angley", { Type = "range", Text = "Up-Down pan angles", Min = 8, Max = 16, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_focus_backing", { Type = "range", Text = "Weapon backing intensity on edges", Min = 0, Max = 16, Decimals = 0 } ) )
				
				category.List:AddItem( self:BuildParamPanel( "detail_focus_smoothing", { Type = "range", Text = "Viewmodel visual smoothing", Min = 0, Max = 16, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_focus_smoothlook", { Type = "range", Text = "Camera visual smoothing", Min = 0, Max = 16, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_focus_aimsim", { Type = "range", Text = "Aim Simulation (Angle approximation)", Min = 0, Max = 16, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_focus_handshiftx", { Type = "range", Text = "Hand Shift (Weapon X-Perspective)", Min = 0, Max = 16, Decimals = 0 } ) )
				
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label",Text = "Use AS/HS preset :" } ) )
				
				do
					local GeneralMulti = vgui.Create( "DMultiChoice" )
					GeneralMulti:AddChoice( "Custom" )
					GeneralMulti:AddChoice( "Old School" )
					GeneralMulti:AddChoice( "Hand Shift Optimized" )
					
					GeneralMulti.OnSelect = function(index, value, data)
						if value == 2 then
							self:SetVar( "detail_focus_aimsim" , 5 )
							self:SetVar( "detail_focus_handshiftx" , 0 )
							
						elseif value == 3 then
							self:SetVar( "detail_focus_aimsim" , 8 )
							self:SetVar( "detail_focus_handshiftx" , 4 )
							
						end
						
					end
					
					do
						local as = self:GetVar("detail_focus_aimsim")
						local hs = self:GetVar("detail_focus_handshiftx")
						GeneralMulti:ChooseOptionID( ((as == 5) and (hs == 0)) and 2 or ((as == 8) and (hs == 4)) and 3 or 1 )
					
					end
					
					category.List:AddItem( GeneralMulti )
					
				end
				
				category.List:AddItem( self:BuildParamPanel( "detail_focus_anglex", { Type = "range", Text = "Left-Right pan angles (Extended)", Min = 0, Max = 60, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_focus_angley", { Type = "range", Text = "Up-Down pan angles (Extended)", Min = 0, Max = 60, Decimals = 0 } ) )
				
				local toggleButton = self:BuildParamPanel( "noconvars", { Type = "panel_button", Text = "Toggle Focus", DoClick = function() sharpeye_focus:ToggleFocus() end } )
				toggleButton:SetTooltip( "This should only be used to quickly debug if it gets stuck." )
				category.List:AddItem( toggleButton )
				
			end
			
			do				
				local category = vgui.Create("DCollapsibleCategory", formOptions)
				category:SetExpanded( false )
				category:SetLabel( "Alignment Meters" )
				
				category.List  = vgui.Create("DPanelList", category )
				category.List:EnableHorizontal( false )
				category.List:EnableVerticalScrollbar( false )
				category.List:SetAutoSize( true )
				
				category:SetContents( category.List )
				formDetails:AddItem( category )
				
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "These are modifiers used as reference to simulate SharpeYe behavior. For example, Run Speed reference is used as a reference to determine which speed is considered as exhausting.", Wrap = true } ) )
				category.List:AddItem( self:BuildParamPanel( "basis_healthylevel", { Type = "range", Text = "Heathy Level reference", Min = 0, Max = 100, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "basis_runspeed", { Type = "range", Text = "Run Speed reference (inches/s)", Min = 50, Max = 150, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "basis_staminarecover", { Type = "range", Text = "Stamina Recovery Speed", Min = 0, Max = 10, Decimals = 0 } ) )
				
				category.List:AddItem( self:BuildParamPanel( "basis_healthbased", { Type = "range", Text = "Behaviour Intensity by health", Min = 0, Max = 10, Decimals = 0 } ) )
				
			end
			
			do				
				local category = vgui.Create("DCollapsibleCategory", formOptions)
				category:SetExpanded( false )
				category:SetLabel( "Bobbing" )
				
				category.List  = vgui.Create("DPanelList", category )
				category.List:EnableHorizontal( false )
				category.List:EnableVerticalScrollbar( false )
				category.List:SetAutoSize( true )
				
				category:SetContents( category.List )
				formDetails:AddItem( category )
				
				category.List:AddItem( self:BuildParamPanel( "detail_breathebobdist", { Type = "range", Text = "Breathing Simulation Intensity", Min = 0, Max = 10, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_runningbobfreq", { Type = "range", Text = "Breathing Simulation Frequency while running", Min = 0, Max = 10, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_leaningangle", { Type = "range", Text = "Leaning Intensity", Min = 0, Max = 10, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_landingangle", { Type = "range", Text = "Landing Intensity", Min = 0, Max = 10, Decimals = 0 } ) )
				
				
				category.List:AddItem( self:BuildParamPanel( "detail_crouchmod", { Type = "range", Text = "Bobbing reduction while crouched", Min = 0, Max = 10, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_stepmodintensity", { Type = "range", Text = "Stepping Simulation Intensity", Min = 0, Max = 10, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_stepmodfrequency", { Type = "range", Text = "Stepping Simulation Frequency", Min = 0, Max = 10, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_shakemodintensity", { Type = "range", Text = "Twitching Intensity", Min = 0, Max = 10, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_shakemodhealth", { Type = "range", Text = "Twitching Scale by health", Min = 0, Max = 10, Decimals = 0 } ) )
				
			end
			
			
			do				
				local category = vgui.Create("DCollapsibleCategory", formOptions)
				category:SetExpanded( false )
				category:SetLabel( "Crosshair Options" )
				
				category.List  = vgui.Create("DPanelList", category )
				category.List:EnableHorizontal( false )
				category.List:EnableVerticalScrollbar( false )
				category.List:SetAutoSize( true )
				
				category:SetContents( category.List )
				formDetails:AddItem( category )
				
				
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "Main color" } ) )
				category.List:AddItem( self:BuildParamPanel( "xhair_color", { Type = "color" } ) )
				
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "Shadow color" } ) )
				category.List:AddItem( self:BuildParamPanel( "xhair_shadcolor", { Type = "color" } ) )
				
				category.List:AddItem( self:BuildParamPanel( "xhair_staticsize", { Type = "bool", Text = "Draw Static Reticle" } ) )
				category.List:AddItem( self:BuildParamPanel( "xhair_staticsize", { Type = "range", Text = "Static Reticle Size", Min = 0, Max = 8, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "xhair_dynamicsize", { Type = "range", Text = "Dynamic Reticle Size", Min = 0, Max = 8, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "xhair_shadowsize", { Type = "range", Text = "Dynamic Dropshadow Size", Min = 0, Max = 8, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "xhair_focussize", { Type = "range", Text = "Focus Reticle Size", Min = 0, Max = 8, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "xhair_focusshadowsize", { Type = "range", Text = "Focus Dropshadow Size", Min = 0, Max = 8, Decimals = 0 } ) )
				
				local focusSpin = self:BuildParamPanel( "xhair_focusspin", { Type = "range", Text = "Focus Spin", Min = -4, Max = 4, Decimals = 0 } )
				focusSpin:SetTooltip( "Spin allows you to check if you're aiming far and not close i.e. near walls." )
				category.List:AddItem( focusSpin )
				category.List:AddItem( self:BuildParamPanel( "xhair_focusangle", { Type = "range", Text = "Focus Starting Angle", Min = 0, Max = 7, Decimals = 0 } ) )
				
			end
			
			do				
				local category = vgui.Create("DCollapsibleCategory", formOptions)
				category:SetExpanded( false )
				category:SetLabel( "Sounds" )
				
				category.List  = vgui.Create("DPanelList", category )
				category.List:EnableHorizontal( false )
				category.List:EnableVerticalScrollbar( false )
				category.List:SetAutoSize( true )
				
				category:SetContents( category.List )
				formDetails:AddItem( category )
				
				category.List:AddItem( self:BuildParamPanel( "snd_footsteps_vol", { Type = "bool", Text = "Footsteps Volume" } ) )
				category.List:AddItem( self:BuildParamPanel( "snd_breathing_vol", { Type = "range", Text = "Breathing Volume", Min = 0, Max = 8, Decimals = 0 } ) )
				
				category.List:AddItem( self:BuildParamPanel( "snd_windenable", { Type = "bool", Text = "Enable Wind"} ) )
				category.List:AddItem( self:BuildParamPanel( "snd_windvelocityincap", { Type = "range", Text = "Wind Minimum Velocity", Min = 0, Max = 8, Decimals = 0 } ) )
				category.List:AddItem( self:BuildParamPanel( "snd_windonground", { Type = "bool", Text = "Allow Wind while on ground"} ) )
				category.List:AddItem( self:BuildParamPanel( "snd_windonnoclip", { Type = "bool", Text = "Allow Wind while noclipping"} ) )
				
			end
			
		end
		
		local formAdvanced = vgui.Create( "DPanelList" )
		do
			do
				local category = vgui.Create("DCollapsibleCategory", formOptions)
				category:SetExpanded( false )
				category:SetLabel( "Advanced Tweakings" )
				
				category.List  = vgui.Create("DPanelList", category )
				category.List:EnableHorizontal( false )
				category.List:EnableVerticalScrollbar( false )
				category.List:SetAutoSize( true )
				
				category:SetContents( category.List )
				formAdvanced:AddItem( category )
				
				category.List:AddItem( self:BuildParamPanel( "detail_mastermod", { Type = "range", Text = "Master Spark", Min = 0, Max = 10, Decimals = 0 } ) )
				
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "\nYou can either use " .. tostring(SHARPEYE_NAME) .. " integrated Motion blur extension which hubs with Source Engine's motion blur. However, experienced users may want to use the integrated Source \"Forward motion blur\" and disable this one.", Wrap = true } ) )
				category.List:AddItem( self:BuildParamPanel( "opt_motionblur", { Type = "bool", Text = "Use " .. tostring(SHARPEYE_NAME) .. " Motion Blur" } ) )
				category.List:AddItem( self:BuildParamPanel( "detail_permablur", { Type = "range", Text = "Permablur Amount", Min = 0, Max = 10, Decimals = 0 } ) )
				
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "\nMachinima mode allows you to enable SharpeYe bobbing even if noclipping or inside a vehicle. Remember to disable it during normal gameplay.", Wrap = true } ) )
				category.List:AddItem( self:BuildParamPanel( "opt_machinimamode", { Type = "bool", Text = "Enable Machinima Override Mode" } ) )
				

				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "\nHighspeed Deathcam allows the deathcam to be immediate when the player has a death ragdoll, which totally ignores if you are dead or not. This may cause issues on some gamemodes (such as gamemodes that have a simulate death feature).", Wrap = true } ) )
				category.List:AddItem( self:BuildParamPanel( "opt_firstpersondeath_highspeed", { Type = "bool", Text = "Enable Deathcam Highspeed Mode" } ) )
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "\nYou can cross \"SharpeYe's Stamina\" and \"Perfected Climb SWEP Fatigue\" (by -[SB]- Spy and Kogitsune) using this.", Wrap = true } ) )
				category.List:AddItem( self:BuildParamPanel( "ext_perfectedclimbswep", { Type = "bool", Text = "Cross with Perfected Climb SWEP" } ) )
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "\nYou can enable SharpeYe to allows a Graphics Tablet or a Wiimote pointer to aim.", Wrap = true } ) )
				category.List:AddItem( self:BuildParamPanel( "wiimote_enable", { Type = "bool", Text = "Enable Wiimote / Tablet input" } ) )
				
			end
			
			do
				local category = vgui.Create("DCollapsibleCategory", formOptions)
				category:SetExpanded( true )
				category:SetLabel( "Motion Debug" )
				
				category.List  = vgui.Create("DPanelList", category )
				category.List:EnableHorizontal( false )
				category.List:EnableVerticalScrollbar( false )
				category.List:SetAutoSize( true )
				
				category:SetContents( category.List )
				formAdvanced:AddItem( category )
				
				do
						local okayColor = Color(0, 255, 0, 255)
						local overvColor = Color(255, 255, 0, 255)
						local warnColor = Color(255, 128, 0, 255)
						local failColor = Color(255, 0, 0, 255)
						local neutralColor = Color(255, 255, 255, 255)
						
						do
							local label = vgui.Create("DLabel")
							label:SetContentAlignment( 2 )
							label.Okay = nil
							function label:Think()
								local measureOkay = sharpeye:IsEnabled()
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
							category.List:AddItem( label )
						end
						do
							local label = vgui.Create("DLabel")
							label:SetContentAlignment( 2 )
							label.Okay = nil
							function label:Think()
								local measureOkay = sharpeye:IsMotionEnabled()
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
							category.List:AddItem( label )
						end
						do
							local label = vgui.Create("DLabel")
							label:SetContentAlignment( 2 )
							label.Okay = nil
							function label:Think()
								local measureOkay = not sharpeye:ShouldBobbingDisableCompletely()
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
							category.List:AddItem( label )
						end
						do
							local label = vgui.Create("DLabel")
							label:SetContentAlignment( 2 )
							label.Okay = nil
							function label:Think()
								local measureOkay = not sharpeye:ShouldBobbingDisableWithTools()
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
							category.List:AddItem( label )
						end
						do
							local label = vgui.Create("DLabel")
							label:SetContentAlignment( 2 )
							label.Okay = nil
							function label:Think()
								local measureOkay = math.abs( sharpeye:Detail_GetMasterMod() ) > 0.6
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
							category.List:AddItem( label )
						end
						do
							local label = vgui.Create("DLabel")
							label:SetContentAlignment( 2 )
							label.Okay = nil
							function label:Think()
								local measureOkay = not sharpeye:InMachinimaMode()
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
							category.List:AddItem( label )
						end
						do
							local label = vgui.Create("DLabel")
							label:SetContentAlignment( 2 )
							label.Okay = nil
							function label:Think()
								local measureOkay = not sharpeye:ShouldMotionDisableInThirdPerson()
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
							category.List:AddItem( label )
						end
						do
							local label = vgui.Create("DLabel")
							label:SetContentAlignment( 2 )
							label.Okay = nil
							function label:Think()
								local measureOkay = not sharpeye:IsInVehicle()
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
							category.List:AddItem( label )
						end
						do
							local label = vgui.Create("DLabel")
							label:SetContentAlignment( 2 )
							label.Okay = nil
							function label:Think()
								local measureOkay = not sharpeye:IsNoclipping()
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
							category.List:AddItem( label )
						end
						
					end
			
			end
			
			
			do
				local category = vgui.Create("DCollapsibleCategory", formOptions)
				category:SetExpanded( true )
				category:SetLabel( "Unhooker" )
				
				category.List  = vgui.Create("DPanelList", category )
				category.List:EnableHorizontal( false )
				category.List:EnableVerticalScrollbar( false )
				category.List:SetAutoSize( true )
				
				category:SetContents( category.List )
				formAdvanced:AddItem( category )
				
				category.List:AddItem( self:BuildParamPanel( "noconvars", { Type = "panel_label", Text = "If you are a developer and you know what you are doing, you can try to unhook some overrides. Warning, unhooking will break other addons. :", Wrap = true } ) )
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
							
							category.List:AddItem( DisablerButton )
					end
					if counter == 0 then
						category.List:AddItem( "<No hooks to display.>" )
					end
				end
				do
					local DevtMultiline = vgui.Create("DTextEntry")
					DevtMultiline:SetMultiline( true )
					do
						local myText = "REFERENCE :: "
						for k,v in pairs( hook.GetTable()["CalcView"] ) do
							myText = myText .. tostring(k) .. " >> "
						end
						DevtMultiline:SetText( myText )
					end
					DevtMultiline:SetEditable( false )
					DevtMultiline:SetTall( 100 )
					
					category.List:AddItem( DevtMultiline )
					
				end
				
				
			end
			
		end
		
		formOptions:EnableVerticalScrollbar( true )
		formDetails:EnableVerticalScrollbar( true )
		formAdvanced:EnableVerticalScrollbar( true )
		
		tabMaster:AddSheet( "Master", formOptions, "gui/silkicons/application_view_detail", false, false, "The things you're likely need to change in-game from time to time." )
		tabMaster:AddSheet( "Details", formDetails, "gui/silkicons/palette", false, false, "The things you're likely set up once and forget." )
		tabMaster:AddSheet( "Advanced", formAdvanced, "gui/silkicons/wrench", false, false, "The things you'll use to tweak it even more or debug." )
		
	end
	
	////
	local optionsForm = vgui.Create( "DForm", mainPanel )
	do
		optionsForm:SetName( "Status" )
		
		local label = vgui.Create( "DLabel" )
		label:SetText( "None." )
		optionsForm:AddItem( label )
		
	end
	
	////
	mainPanel._p_topPanel = topPanel
	mainPanel._p_tabMaster = tabMaster
	mainPanel._p_optionsForm = optionsForm
	
	mainPanel._n_Spacing = 5
	mainPanel.PerformLayout = function (self)
		self:GetParent():StretchToParent( 0, 0, 0, 0 )
		self:StretchToParent( self._n_Spacing, self._n_Spacing, self._n_Spacing, self._n_Spacing )
		self._p_topPanel:PerformLayout()
		self._p_tabMaster:PerformLayout()
		self._p_optionsForm:PerformLayout()
		self._p_topPanel:Dock( TOP )
		self._p_optionsForm:Dock( BOTTOM )
		self._p_tabMaster:Dock( FILL )
	end
	
	SHARPEYE_MENU:UpdateContents()
	self:UpdateMenuPosition()
	
	return SHARPEYE_MENU
	
end

function sharpeye:RemoveMenu()
	if ValidPanel( SHARPEYE_MENU ) then
		SHARPEYE_MENU:Remove()
		SHARPEYE_MENU = nil
	
	end
	
end

function sharpeye:MountMenu()
	self:CreateVarParam( "bool", "menu_position", "0", { callback = function ( a, b, c ) sharpeye:UpdateMenuPosition() end } )
	-- do nothing
	
end

function sharpeye:UnmountMenu()
	self:RemoveMenu()
	
end

function sharpeye:OpenMenu()
	self:GetMenu():Open()
	
end

function sharpeye:CloseMenu()
	self:GetMenu():Close()
	
end



function sharpeye:BuildHeader( mainPanel, sHeaderName )
	////
	local topPanel = vgui.Create( "DPanel", mainPanel )
	do
		local title = self:BuildParamPanel( "noconvar", { Type = "panel_label", Text = sHeaderName, ContentAlignment = 5, Font = "DefaultBold" } )
		title.Paint = function (self)
			surface.SetDrawColor( 0, 0, 0, 96 )
			surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
		end
		title:SetParent( topPanel )
		
		local subTitle = nil
		do
			local MY_VERSION, ONLINE_VERSION = sharpeye_internal.GetVersionData()
			MY_VERSION = "v" .. tostring(MY_VERSION)
			ONLINE_VERSION = (ONLINE_VERSION == -1) and "(?)" or ("v" .. tostring( ONLINE_VERSION ))
			subTitle = self:BuildParamPanel( "noconvar", { Type = "panel_label", Text = "Using " .. (sharpeye_cloud:IsUsingCloud() and "Cloud " .. ONLINE_VERSION or "Locale " .. MY_VERSION), ContentAlignment = 4 } )
		end
		subTitle:SetParent( topPanel )
		
		local MY_VERSION, ONLINE_VERSION = sharpeye_internal.GetVersionData()
		if ((MY_VERSION < ONLINE_VERSION) and sharpeye_cloud:IsUsingCloud()) then
			subTitle:SetToolTip( "There is an update ! You're currently using a temporary copy of the new version (You have v" .. tostring( MY_VERSION ) .. " installed)." )
			subTitle.Think = function (self)
				local blink = 127 + (math.sin( math.pi * CurTime() * 0.5 ) + 1 ) * 64
				self:SetColor( Color( 255, 255, 255, blink ) ) // TODO : ?
				
			end
			
		end
		
		local enableBox = self:BuildParamPanel( "core_enable", { Type = "bool_nolabel", Style = "grip" } )
		enableBox:SetParent( title )
		enableBox:SetToolTip( "Toggle " .. tostring( sHeaderName ) .. "." )
		enableBox.Paint = function (self)
			local isEnabled = self:GetChecked()
			if isEnabled then
				--local blink = (math.sin( math.pi * CurTime() ) + 1 ) / 2 * 64
				local blink = 222 + (math.sin( math.pi * CurTime() ) + 1 ) * 16
				surface.SetDrawColor( blink, blink, blink, 255 )
				
			else
				surface.SetDrawColor( 192, 192, 192, 255 )
				
			end
			
			surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
			
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawOutlinedRect( 0, 0, self:GetWide(), self:GetTall() )
			
			if not isEnabled and ( CurTime() % 1 > 0.5 ) then
				surface.DrawOutlinedRect( 2, 2, self:GetWide() - 4, self:GetTall() - 4 )
				
			end
			
		end
		
		local closeBox = self:BuildParamPanel( "noconvar", { Type = "panel_sysbutton", Style = "close", DoClick = function ( self ) sharpeye:CallCmd("-menu") end } )
		closeBox:SetParent( title )
		closeBox:SetToolTip( "Close menu." )
		
		local positionBox = self:BuildParamPanel( "noconvar", { Type = "panel_sysbutton", Style = "left", DoClick = function ( self ) sharpeye:SetVar( "menu_position", (sharpeye:GetVar( "menu_position" ) > 0) and 0 or 1 ) end } )
		positionBox:SetParent( title )
		positionBox:SetToolTip( "Change menu dock position." )
		
		local reloadCloud = self:BuildParamPanel( "noconvar", { Type = "panel_imagebutton", Material = "gui/silkicons/toybox", DoClick = function() sharpeye:CallCmd("-menu") sharpeye:ReloadFromCloud() end } )
		reloadCloud:SetParent( subTitle )
		reloadCloud:SetToolTip( "Press to use the latest version from the Cloud." )
		
		local reloadLocale = self:BuildParamPanel( "noconvar", { Type = "panel_imagebutton", Material = "gui/silkicons/application_put", DoClick = function() sharpeye:CallCmd("-menu") sharpeye:ReloadFromLocale() end } )
		reloadLocale:SetParent( subTitle )
		reloadLocale:SetToolTip( "Press to use your Locale installed version." )
		
		local loadChangelog = self:BuildParamPanel( "noconvar", { Type = "panel_button", Text = "Changelog", DoClick = function() sharpeye:CallCmd("call_changelog") end } )
		loadChangelog:SetParent( subTitle )
		loadChangelog:SetToolTip( "Press to view the changelog." )
		
		if MY_VERSION < ONLINE_VERSION then
			loadChangelog.PaintOver = function ( self )
				local blink = (math.sin( math.pi * CurTime() * 0.5 ) + 1 ) * 64
				surface.SetDrawColor( 255, 255, 255, blink )
				draw.RoundedBoxEx( 2, 0, 0, self:GetWide(), self:GetTall(), Color( 255, 255, 255, blink ), true, true, true, true  )
				
			end
			loadChangelog:SetToolTip( "There are updates ! You should update your Locale." )
			
		else
			loadChangelog:SetToolTip( "Press to view the changelog." )
			
		end
		
		
		topPanel._p_title = title
		topPanel._p_subTitle = subTitle
		topPanel._p_enableBox = enableBox
		topPanel._p_closeBox = closeBox
		topPanel._p_positionBox = positionBox
		
		topPanel._p_reloadCloud = reloadCloud
		topPanel._p_reloadLocale = reloadLocale
		topPanel._p_loadChangelog = loadChangelog
	
	end
	topPanel.Paint = function (self)
		surface.SetDrawColor( 0, 0, 0, 96 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end
	topPanel.PerformLayout = function (self)
		self:SetWide( self:GetParent():GetWide() )
		self._p_title:SetWide( self:GetWide() )
		self._p_subTitle:SetWide( self:GetWide() )
		
		self._p_title:PerformLayout( )
		self._p_subTitle:PerformLayout( )
		self._p_enableBox:PerformLayout( )
		self._p_positionBox:PerformLayout( )
		self._p_closeBox:PerformLayout( )
		
		self._p_reloadCloud:PerformLayout( )
		self._p_reloadLocale:PerformLayout( )
		self._p_loadChangelog:PerformLayout( )
		
		self._p_title:CenterHorizontal( )
		self._p_subTitle:CenterHorizontal( )
		
		self:SetTall( self._p_title:GetTall() + self._p_subTitle:GetTall() )
		
		self._p_title:AlignTop( 0 )
		self._p_subTitle:SetWide( self._p_subTitle:GetWide() - 4 )
		self._p_subTitle:AlignLeft( 4 )
		self._p_subTitle:MoveBelow( self._p_title, 0 )
		
		local boxSize = self._p_title:GetTall()
		self._p_enableBox:SetSize( boxSize * 0.8, boxSize * 0.8 )
		self._p_positionBox:SetSize( boxSize * 0.8, boxSize * 0.8 )
		self._p_closeBox:SetSize( boxSize * 0.8, boxSize * 0.8 )
		self._p_enableBox:CenterVertical( )
		self._p_positionBox:CenterVertical( )
		self._p_closeBox:CenterVertical( )
		self._p_enableBox:AlignLeft( boxSize * 0.1 )
		self._p_closeBox:AlignRight( boxSize * 0.1 )
		self._p_positionBox:MoveLeftOf( self._p_closeBox, boxSize * 0.1 )
		
		local buttonSize = self._p_subTitle:GetTall()
		self._p_reloadCloud:SetSize( buttonSize * 0.8, buttonSize * 0.8 )
		self._p_reloadLocale:SetSize( buttonSize * 0.8, buttonSize * 0.8 )
		self._p_loadChangelog:SizeToContents( )
		self._p_loadChangelog:SetSize( self._p_loadChangelog:GetWide() + 6, buttonSize * 0.8 )
		self._p_reloadCloud:CenterVertical( )
		self._p_reloadLocale:CenterVertical( )
		self._p_loadChangelog:CenterVertical( )
		self._p_reloadCloud:AlignRight( boxSize * 0.1 )
		self._p_reloadLocale:MoveLeftOf( self._p_reloadCloud, boxSize * 0.1 )
		self._p_loadChangelog:MoveLeftOf( self._p_reloadLocale, boxSize * 0.3 )
	end
	
	return topPanel
	
end
