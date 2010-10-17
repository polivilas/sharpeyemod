////////////////////////////////////////////////
// -- HayFrame                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// HayFrame Backup                            //
////////////////////////////////////////////////


local HAY_MAIN, HAY_INTERNAL, HAY_CLOUD, HAY_UTIL = HAYFRAME_SetupReferences( )
local HAY_NAME, HAY_SHORT, HAY_DEBUG = HAYFRAME_SetupConstants( )

function HAY_MAIN:BackupGet( tVarList )
	local tBase = {}
	
	for var in pairs( tVarList ) do
		tBase[ var ] = tostring( self:GetVar( var ) )
		
	end
	
	return tBase
	
end

function HAY_MAIN:BackupSet( tDump )
	local tBase = {}
	
	for var,value in pairs( tDump ) do
		self:SetVar( var, value )
		
	end
	
	return tBase
	
end

function HAY_MAIN:BackupReadDump()
	local tDump = {}
	
	local sHypo = file.Read( "sharpeye_config_dump.txt" )
	local tLines = string.Explode("\n", sHypo)
	
	for iLine,sLine in pairs( tLines ) do
		local space = string.find( sLine, " " )
		if space then
			local var   = string.sub( sLine, 1, space - 1 )
			local value = string.sub( sLine, space + 1 )
			
			tDump[ var ] = value
			
		end
		
	end
	return tDump
	
end

function HAY_MAIN:BackupWriteDump( tDump )
	local sBuild = ""
	
	for var,value in pairs( tDump ) do
		sBuild = sBuild .. var .. " " .. tostring( value ) .. "\n"
		
	end
	file.Write( "sharpeye_config_dump.txt", sBuild )
	
end


function HAY_MAIN:BackupGetCurrent( )
	return self:BackupGet( self:GetVarList() )
	
end

function HAY_MAIN:BackupWriteCurrent( )
	self:BackupWriteDump( self:BackupGetCurrent( ) )
	
end

function HAY_MAIN:BackupSetDump( )
	return self:BackupSet( self:BackupReadDump() )
	
end

function HAY_MAIN:BackupCompare( myDump, bCountHoles )
	local tCurrent = self:BackupGetCurrent()
	local tDump = myDump or self:BackupReadDump()
	
	local differences = 0
	
	for k in pairs( tCurrent ) do
		if bCountHoles or not (tDump[k] == nil) then
			if tCurrent[k] ~= tDump[k] then
				differences = differences + 1
				
			end
		end
		
	end
	
	return differences
	
end
