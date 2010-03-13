////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Version                                    //
////////////////////////////////////////////////

local MY_VERSION = tonumber(string.Explode( "\n", file.Read("sharpeye.txt"))[1])
local SVN_VERSION = nil
local DOWNLOAD_LINK = nil

function sharpeye.GetVersionData()
	return MY_VERSION, SVN_VERSION, DOWNLOAD_LINK
end

function sharpeye.GetVersion( contents , size )
	--Taken from RabidToaster Achievements mod.
	local split = string.Explode( "\n", contents )
	local version = tonumber( split[ 1 ] or "" )
	
	if ( !version ) then
		SVN_VERSION = -1
		return
	end
	
	SVN_VERSION = version
	
	if ( split[ 2 ] ) then
		DOWNLOAD_LINK = split[ 2 ]
	end
	
	--print( MY_VERSION , SVN_VERSION , DOWNLOAD_LINK )
end
http.Get( "http://sharpeyemod.googlecode.com/svn/trunk/data/sharpeyemod.txt", "", sharpeye.GetVersion )