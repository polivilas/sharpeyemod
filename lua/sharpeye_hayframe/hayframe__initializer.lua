////////////////////////////////////////////////
// -- HayFrame                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Utility functions                          //
////////////////////////////////////////////////


local HAY_MAIN     = sharpeye
local HAY_INTERNAL = sharpeye_internal
local HAY_CLOUD    = sharpeye_cloud
local HAY_UTIL     = sharpeye_util
local HAY_NAME     = SHARPEYE_NAME
local HAY_SHORT    = SHARPEYE_SHORT
local HAY_DEBUG    = SHARPEYE_DEBUG

local HAY_LOCAL = {}
HAY_LOCAL.concmd_prefix = "sharpeye_"
HAY_LOCAL.var_prefix    = "sharpeye_" -- No cl_ for backwards compatibility.


//local HAY_MAIN, HAY_INTERNAL, HAY_CLOUD, HAY_UTIL = HAYFRAME_SetupReferences( )
//local HAY_NAME, HAY_SHORT, HAY_DEBUG = HAYFRAME_SetupConstants( )

-- These functions shall NEVER be called in real time.
--   Only on initialization.
function HAYFRAME_SetupReferences( )
	return HAY_MAIN, HAY_INTERNAL, HAY_CLOUD, HAY_UTIL
	
end

function HAYFRAME_SetupConstants( )
	return HAY_NAME, HAY_SHORT, HAY_DEBUG
	
end

function HAYFRAME_SetupParameter( sParam )
	return HAY_LOCAL[ sParam ]
	
end
