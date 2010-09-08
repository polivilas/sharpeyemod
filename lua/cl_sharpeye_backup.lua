////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Backup manager                             //
////////////////////////////////////////////////


function sharpeye.UserCall_DumpConfig( )
	sharpeye.DumpConfig( sharpeye.cvarGroups, "sharpeye_" )
	
end

function sharpeye.DumpConfig( tCvarGroups, sPrefix )
	local sBuild = ""
	for sGroup,tCvarGroup in pairs( tCvarGroups ) do
		for sName,oDefault in pairs( tCvarGroup ) do
			sBuild = sBuild .. sGroup .. "+" .. sName .. "+" .. tostring(sharpeye.GetVar( tostring( sPrefix ) .. tostring( sGroup ) .. "_" .. tostring( sName ) ) )  .. "\n"
		
		end
		
	end
	
	file.Write( "sharpeye_config_dump.txt", sBuild )
	
end

--function sharpeye.AmpConfig( sHypo )
function sharpeye.AmpConfig( )
	local tNewBuild = {}
	
	local sHypo = file.Read( "sharpeye_config_dump.txt" )
	local tLines = string.Explode("\n", sHypo)
	
	for _,sLine in pairs( tLines ) do
		local tFizz = string.Explode("+", sLine)
		if #tFizz == 3 then
			if sharpeye.cvarGroups[ tostring(tFizz[1]) ] and sharpeye.cvarGroups[ tostring(tFizz[1]) ][ tostring(tFizz[2]) ] then
				sharpeye.Util_AppendCvar( tNewBuild, tostring(tFizz[1]) .. "_" .. tostring(tFizz[2]) , tostring(tFizz[3]) )
				ErrorNoHalt( tostring(tFizz[1]) .. "_" .. tostring(tFizz[2]) .. " = " .. tostring(tFizz[3]) .. "\n" )
			end
			
		end
	
	end
	
	--PrintTable( tNewBuild )
	
	return tNewBuild
	
end

function sharpeye.AmpConfigToString( )
	local tNewBuild = {}
	
	local sHypo = file.Read( "sharpeye_config_dump.txt" )
	local tLines = string.Explode("\n", sHypo)
	
	local DUMPED = ""
	
	for _,sLine in pairs( tLines ) do
		local tFizz = string.Explode("+", sLine)
		if #tFizz == 3 then
			if sharpeye.cvarGroups[ tostring(tFizz[1]) ] and sharpeye.cvarGroups[ tostring(tFizz[1]) ][ tostring(tFizz[2]) ] then
				sharpeye.Util_AppendCvar( tNewBuild, tostring(tFizz[1]) .. "_" .. tostring(tFizz[2]) , tostring(tFizz[3]) )
				DUMPED = DUMPED .. tostring(tFizz[1]) .. "_" .. tostring(tFizz[2]) .. " = " .. tostring(tFizz[3]) .. "\n"
			end
			
		end
	
	end
	
	--PrintTable( tNewBuild )
	
	return DUMPED
	
end

function sharpeye.RebuildConfig()
	local tNewBuild = {}
	
	local sHypo = file.Read( "sharpeye_config_dump.txt" )
	local tLines = string.Explode("\n", sHypo)
	
	for _,sLine in pairs( tLines ) do
		local tFizz = string.Explode("+", sLine)
		if #tFizz == 3 then
			if sharpeye.cvarGroups[ tostring(tFizz[1]) ] and sharpeye.cvarGroups[ tostring(tFizz[1]) ][ tostring(tFizz[2]) ] then
				sharpeye.Util_AppendCvar( tNewBuild, tostring(tFizz[1]) .. "_" .. tostring(tFizz[2]) , tostring(tFizz[3]) )
				
			end
			
		end
	
	end
	
	if table.Count( tNewBuild ) > 0 then
		sharpeye.Util_RestoreCvars( tNewBuild, "sharpeye_" )
		
	end
	
end

