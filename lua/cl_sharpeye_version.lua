////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Version II                                 //
////////////////////////////////////////////////

sharpeye_internal = {}

local MY_VERSION = tonumber(string.Explode( "\n", file.Read("sharpeye.txt"))[1])
local ONLINE_VERSION = nil
local DOWNLOAD_LINK = nil
local RECEIVED_RESPONSE = false
local CONTENTS_REPLICATE = nil

function sharpeye_internal.IsUsingCloud()
	return sharpeye_cloud and sharpeye_cloud.IsUsingCloud and sharpeye_cloud:IsUsingCloud() or nil
end

function sharpeye_internal.HasReceivedResponse()
	return RECEIVED_RESPONSE
end

function sharpeye_internal.GetVersionData()
	return MY_VERSION, ONLINE_VERSION, DOWNLOAD_LINK
end

function sharpeye_internal.GetReplicate( ) -- >= cv1.1
	return CONTENTS_REPLICATE
end

function sharpeye_internal.ReceiveVersion( args, contents , size )
	
	--Taken from RabidToaster Achievements mod.
	CONTENTS_REPLICATE = contents
	local split = string.Explode( "\n", contents )
	local version = tonumber( split[ 1 ] or "" )
	
	if ( !version ) then
		ONLINE_VERSION = -1
		return
	end
	
	ONLINE_VERSION = version
	
	if ( split[ 2 ] ) then
		DOWNLOAD_LINK = split[ 2 ]
	end
	
	RECEIVED_RESPONSE = true
	if args and args[1] then args[1]() end
	
end

function sharpeye_internal.QueryVersion( funcCallback )
	http.Get( "http://sharpeyemod.googlecode.com/svn/trunk/data/sharpeye.txt", "", sharpeye_internal.ReceiveVersion, funcCallback )
	
end
