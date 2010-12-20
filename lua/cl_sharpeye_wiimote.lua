////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Wiimote support                            //
////////////////////////////////////////////////
local sharpeye = sharpeye


function sharpeye:IsWiimoteEnabled( )
	return self:GetVar("wiimote_enable") > 0
	
end

function sharpeye.InputMouseApply( cmd, x, y, angle )
	if not sharpeye:IsEnabled( ) or not sharpeye:IsWiimoteEnabled( ) then return end
	
	SHARPE_TEST = 0.3
	
	if (x == 0) and (y == 0) then return end
	
	local biais = sharpeye_focus:GetBiaisViewAngles()
	if not biais then return end
	angle.y = biais.y - x / ScrW() * 35 * SHARPE_TEST
	angle.p = biais.p + y / ScrH() * 35 * SHARPE_TEST
	cmd:SetViewAngles( angle )
	
	return true

end
