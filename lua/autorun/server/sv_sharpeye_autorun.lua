SHARPEYE_SENDCOPY = false

if (SinglePlayer()) then
	include("sh_sharpeye_autorun.lua")
	
elseif SHARPEYE_SENDCOPY then
	AddCSLuaFile( "autorun/client/cl_sharpeye_autorun.lua" )
	AddCSLuaFile( "cl_sharpeye_base.lua" )
	AddCSLuaFile( "cl_sharpeye_cvar_custom.lua" )
	AddCSLuaFile( "cl_sharpeye_menu.lua" )
	AddCSLuaFile( "cl_sharpeye_motion.lua" )
	AddCSLuaFile( "cl_sharpeye_sound.lua" )
	AddCSLuaFile( "cl_sharpeye_version.lua" )
	AddCSLuaFile( "cl_sharpeye_compatibility" )
	AddCSLuaFile( "cl_sharpeye_vision.lua" )
	--AddCSLuaFile( "CtrlColor.lua" )
	AddCSLuaFile( "sh_sharpeye_autorun.lua" )
	
	local sharpeye_dat = {}
	sharpeye_dat.footsteps = {
		"sharpeye/boots1.wav",
		"sharpeye/boots2.wav",
		"sharpeye/boots3.wav",
		"sharpeye/boots4.wav"
	}
	sharpeye_dat.sloshsteps = {
		"sharpeye/slosh1.wav",
		"sharpeye/slosh2.wav",
		"sharpeye/slosh3.wav",
		"sharpeye/slosh4.wav"
	}
	sharpeye_dat.watersteps = {
		"sharpeye/waterstep1.wav",
		"sharpeye/waterstep2.wav",
		"sharpeye/waterstep3.wav",
		"sharpeye/waterstep4.wav"
	}
	sharpeye_dat.stops = {
		"sharpeye/gear1.wav",
		"sharpeye/gear2.wav",
		"sharpeye/gear3.wav",
		"sharpeye/gear4.wav",
		"sharpeye/gear5.wav",
		"sharpeye/gear6.wav"
	}
	sharpeye_dat.waterflop = {
		"sharpeye/water_splash1.wav",
		"sharpeye/water_splash2.wav",
		"sharpeye/water_splash3.wav"
	}
	sharpeye_dat.breathing = {
		"sharpeye/breathe_male.wav",
		"sharpeye/breathe_female.wav",
		"sharpeye/breathe_mask.wav"
	}
	sharpeye_dat.wind = {
		"sharpeye/wind1.wav"
	}
	sharpeye_dat.soundtables = {
		sharpeye_dat.footsteps,
		sharpeye_dat.sloshsteps,
		sharpeye_dat.watersteps,
		sharpeye_dat.stops,
		sharpeye_dat.waterflop,
		sharpeye_dat.breathing,
		sharpeye_dat.wind
	}
	
	for _,subtable in pairs(sharpeye_dat.soundtables) do
		for k,path in pairs(subtable) do
			resource.AddFile("sound/" .. path)
		end
	end
	
	resource.AddFile("materials/depthhud/circle.vtf")
	resource.AddFile("materials/depthhud/linebow_crosshair.vmt")
	resource.AddFile("materials/depthhud/linebow_crosshair.vtf")
	resource.AddFile("materials/depthhud/X_CircleSolid.vmt")
	
end