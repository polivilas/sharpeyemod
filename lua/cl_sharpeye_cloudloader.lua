////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Cloud Loader                               //
////////////////////////////////////////////////

if sharpeye_cloud then pcall(function() sharpeye_cloud.Unmount() end) end

sharpeye_cloud = {}
sharpeye_cloudloader_version = 1.0

local SHARPEYE_IsUsingCloud = false

local SHARPEYE_CloudReceiverTimeoutDelay = 5

local SHARPEYE_CloudReceiverQueried    = 0
local SHARPEYE_CloudReceiverResponded  = false
local SHARPEYE_CloudReceiverAborted    = false

local SHARPEYE_CloudReceiverNumTries   = 3

local SHARPEYE_CloudContents = ""
--local SHARPEYE_CloudComposedContents = ""
local SHARPEYE_CloudFileList = {}
local SHARPEYE_CloudSubContents = {}
local SHARPEYE_Origin = "http://sharpeyemod.googlecode.com/svn/trunk/lua/"
local SHARPEYE_Start  = "cd_sharpeye_includelist.lua"


function sharpeye_cloud.IsUsingCloud()
	return SHARPEYE_IsUsingCloud
	
end

function sharpeye_cloud.BuildBase()
	pcall(function() if sharpeye and sharpeye.Unmount then sharpeye.Unmount() end end)
	sharpeye = {}
	sharpeye_dat = {}
	
end

local function SHARPEYE_ReceiveCloud( contents , size )
	if SHARPEYE_CloudReceiverResponded or SHARPEYE_CloudReceiverAborted then return end
	
	//debug should perform checks here
	SHARPEYE_CloudContents = contents
	
	SHARPEYE_CloudReceiverResponded = true
	
	// debug direct load
	sharpeye_cloud.Load()
	
end

function sharpeye_cloud.Load()
	if SHARPEYE_CloudContents == "" then return end
	
	ADDON_PROP = {}
	
	local bOkay, strErr = pcall(function() sharpeye_cloud.InternalLoad() end)
	local bCouldLoad = false
	
	if not bOkay then
		print(" > " .. SHARPEYE_NAME .. " Cloud Contents failed to pass semantics : ".. strErr)
		
	elseif (ADDON_PROP == nil) or (type(ADDON_PROP) ~= "table") or (#ADDON_PROP == 0) then
		print(" > " .. SHARPEYE_NAME .. " Cloud Contents misses standard table.")
		
	else
		SHARPEYE_CloudFileList = table.Copy(ADDON_PROP)
		bCouldLoad = true
		
		print(" > " .. SHARPEYE_NAME .. " Cloud Contents now gathering Cloud Contents...")
		sharpeye_cloud.GatherSubContents()
		
	end

	ADDON_PROP = nil
	
	if not bCouldLoad then
		print(" > " .. SHARPEYE_NAME .. " couldn't load from Cloud. Now using Locale.")
		sharpeye_cloud.LoadLocale()
		
	end
	
end

local function SHARPEYE_ReceiveSubContents( args ,contents , size )
	if SHARPEYE_CloudReceiverResponded or SHARPEYE_CloudReceiverAborted then return end
	
	local packet_num = args[1]
	SHARPEYE_CloudSubContents[packet_num] = contents
	print(" > " .. SHARPEYE_NAME .. " Cloud Contents received packet #".. packet_num .." of ".. #SHARPEYE_CloudFileList .. " :: ".. SHARPEYE_CloudFileList[packet_num])
	
	if table.Count(SHARPEYE_CloudSubContents) == #SHARPEYE_CloudFileList then
		SHARPEYE_CloudReceiverResponded = true
		print(" > " .. SHARPEYE_NAME .. " Cloud Contents trying to mount from Cloud...")
		sharpeye_cloud.LoadComposition()
		
	end
	
end

function sharpeye_cloud.GatherSubContents()
	for k,path in pairs( SHARPEYE_CloudFileList ) do
		http.Get( SHARPEYE_Origin ..  path , "", SHARPEYE_ReceiveSubContents, k )
		sharpeye_cloud.CheckTimeout( true )
		
	end
	
end

function sharpeye_cloud.InternalLoad()
	CompileString( SHARPEYE_CloudContents , "SHARPEYE_InternalLoad" )()
	
end

function sharpeye_cloud.LoadComposition()
	
	local bOkay, strErr = pcall(function() sharpeye_cloud.InternalCompose() end)
	local bCouldLoad = false
	
	if not bOkay then
		print(" > " .. SHARPEYE_NAME .. " Cloud Contents Composition failed to pass semantics : ".. strErr)
		
		print(" > " .. SHARPEYE_NAME .. " couldn't load from Cloud. Now using Locale.")
		sharpeye_cloud.LoadLocale()
		
	else
		sharpeye_cloud.AttemptMount()
		
	end
	
end

function sharpeye_cloud.InternalCompose()
	sharpeye_cloud.BuildBase()
	for i = 1, #SHARPEYE_CloudSubContents do
		CompileString( SHARPEYE_CloudSubContents[i] , "SHARPEYE_INTERNALCOMPOSE__PACKET" .. tostring(i) )()
		
	end
	
end

function sharpeye_cloud.AttemptMount()
	SHARPEYE_IsUsingCloud = true
	local bCouldLoad = false

	local strBivalErr = ""
	bCouldLoad, strBivalErr = pcall(function() sharpeye.Mount() end)
	if not bCouldLoad then
		print(" > " .. SHARPEYE_NAME .. " Cloud Contents failed to mount : ".. strBivalErr)
		//Now used in buildbase
		//pcall(function() sharpeye.Unmount() end)
		
		print(" > " .. SHARPEYE_NAME .. " couldn't load from Cloud. Now using Locale.")
		sharpeye_cloud.LoadLocale()
	else
		print(" > " .. SHARPEYE_NAME .. " successfully loaded from Cloud.")
		
	end
	
end

function sharpeye_cloud.CheckTimeout( bFirst )
	if bFirst then
		timer.Create("SHARPEYE_CLOUD_TIMEOUT", SHARPEYE_CloudReceiverTimeoutDelay, 1, sharpeye_cloud.CheckTimeout)
		SHARPEYE_CloudReceiverQueried = 0
		SHARPEYE_CloudReceiverResponded = false
		SHARPEYE_CloudReceiverAborted   = false

	elseif not SHARPEYE_CloudReceiverResponded then
		SHARPEYE_CloudReceiverQueried = SHARPEYE_CloudReceiverQueried + 1
		
		if SHARPEYE_CloudReceiverQueried <= SHARPEYE_CloudReceiverNumTries then
			print(" > " .. SHARPEYE_NAME .. " Cloud Contents failed to respond on check #" .. SHARPEYE_CloudReceiverQueried .. ". Waiting.")
			timer.Create("SHARPEYE_CLOUD_TIMEOUT", SHARPEYE_CloudReceiverTimeoutDelay, 1, sharpeye_cloud.CheckTimeout)
		
		else
			print(" > " .. SHARPEYE_NAME .. " Cloud Contents failed to respond on check #" .. SHARPEYE_CloudReceiverQueried .. ".")
			sharpeye_cloud.Abort()
			
		end
		
	end
		
	
end

function sharpeye_cloud.Abort()
	if SHARPEYE_CloudReceiverAborted then return end
	
	print(" > " .. SHARPEYE_NAME .. " Cloud Contents loading aborted. Now using Locale.")
	SHARPEYE_CloudReceiverAborted = true
	sharpeye_cloud.LoadLocale()
	
end

function sharpeye_cloud.LoadLocale()
	SHARPEYE_IsUsingCloud = false
	sharpeye_cloud.BuildBase()
	
	ADDON_PROP = {}
	
	include( SHARPEYE_Start )
	
	for i = 1, #ADDON_PROP do
		include( ADDON_PROP[i] )
		
	end
	
	ADDON_PROP = nil
	
	if sharpeye.Mount then
		sharpeye.Mount()
		
	end
	
end

function sharpeye_cloud.Ask()
	print(" > " .. SHARPEYE_NAME .. " now trying to reach Cloud...")
	
	SHARPEYE_CloudReceiverQueried   = 0
	SHARPEYE_CloudContents = ""
	SHARPEYE_CloudFileList = {}
	SHARPEYE_CloudSubContents = {}

	sharpeye_cloud.Query()
	sharpeye_cloud.CheckTimeout( true )
	
end

function sharpeye_cloud.Query()
	http.Get( SHARPEYE_Origin .. SHARPEYE_Start, "", SHARPEYE_ReceiveCloud )
	
end

function sharpeye_cloud.Mount()
	concommand.Add( "sharpeye_cloud_ask", sharpeye_cloud.Ask )
	
end


function sharpeye_cloud.Unmount()
	concommand.Remove( "sharpeye_cloud_ask" )

end

sharpeye_cloud.Mount()
