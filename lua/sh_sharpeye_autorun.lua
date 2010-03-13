////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Shared Autorun                             //
////////////////////////////////////////////////

if SHARPEYE_DEBUG == nil then
	SHARPEYE_DEBUG = false
end

SHARPEYE_NAME = "SharpeYe"

if (CLIENT) then
	if (sharpeye and sharpeye.Unmount) then sharpeye.Unmount() end
	sharpeye = {}
	sharpeye_dat = {}
	
	include("cl_sharpeye_base.lua")
	include("cl_sharpeye_version.lua")
	include("cl_sharpeye_cvar_custom.lua")
	
	sharpeye.Mount()
end
