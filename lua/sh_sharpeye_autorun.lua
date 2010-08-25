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

-- Developer notes :
--   "--" comments should be used for regular comments.
--   "//" comments should be used for debugging / technical / header comments.

SHARPEYE_NAME = "SharpeYe"
SHARPEYE_FOCUS_NAME = "SharpeYe :: Focus"

SHARPEYE_FORCE_VERSION = false
SHARPEYE_FORCE_USE_CLOUD = true

if (CLIENT or SinglePlayer()) then
	if (sharpeye and sharpeye.Unmount) then sharpeye.Unmount() end
	
	include("cl_sharpeye_cloudloader.lua")
	include("cl_sharpeye_version.lua")
	
	--sharpeye = {}
	--sharpeye_dat = {}
	--sharpeye_focus = {} // Did in the focus lua file
	
	if not SHARPEYE_FORCE_VERSION then
		local function SHARPEYE_CheckResponse()
			if not sharpeye_internal.HasReceivedResponse() then
				print(" > " .. SHARPEYE_NAME .. " did not get a response from Cloud Version query. Now loading Locale.")
				sharpeye_cloud.LoadLocale()
				
			end
			
		end
		
		local function SHARPEYE_CallbackResponse()
			local MY_VERSION, ONLINE_VERSION, DOWNLOAD_LINK = sharpeye_internal.GetVersionData()
			if MY_VERSION < ONLINE_VERSION then
				print(" > " .. SHARPEYE_NAME .. " found an updated version from the Cloud (Locale is ".. MY_VERSION .. ", Online is " .. ONLINE_VERSION .. "). Now querying Cloud.")
				sharpeye_cloud.Ask()
			
			else
				print(" > " .. SHARPEYE_NAME .. " Locale seems as up to date as the Cloud. Loading Locale.")
				sharpeye_cloud.LoadLocale()
				
			end
			
		end
		
		print(" > " .. SHARPEYE_NAME .. " is in normal mode. Now querying Version.")
		sharpeye_internal.QueryVersion( SHARPEYE_CallbackResponse )
		timer.Simple( 10, SHARPEYE_CheckResponse )
	
	elseif SHARPEYE_FORCE_USE_CLOUD then
		print(" > " .. SHARPEYE_NAME .. " is in Cloud force mode. Now querying Cloud.")
		sharpeye_cloud.Ask()
		
	else
		print(" > " .. SHARPEYE_NAME .. " is in Locale force mode. Now loading Locale.")
		sharpeye_cloud.LoadLocale()
		
	end
	
	SHARPEYE_INCLUDED_AT_LEAST_ONCE = true
end
