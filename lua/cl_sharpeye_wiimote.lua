////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Wiimote support                            //
////////////////////////////////////////////////


function sharpeye.IsWiimoteEnabled( )
	return sharpeye.GetVarNumber("sharpeye_wiimote_enable") > 0
	
end

function sharpeye.InputMouseApply( cmd, x, y, angle )
	if not sharpeye.IsEnabled( ) or not sharpeye.IsWiimoteEnabled( ) then return end
	
	local biais = sharpeye_focus:GetBiaisViewAngles()
	if not biais then return end
	angle.y = biais.y - x / ScrW() * 35
	angle.p = biais.p + y / ScrH() * 35
	cmd:SetViewAngles( angle )
	
	return true

end
