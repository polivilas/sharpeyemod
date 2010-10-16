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
	
	local sharpeye.dat = {}
	self.dat.footsteps = {
		"sharpeye/boots1.wav",
		"sharpeye/boots2.wav",
		"sharpeye/boots3.wav",
		"sharpeye/boots4.wav"
	}
	self.dat.sloshsteps = {
		"sharpeye/slosh1.wav",
		"sharpeye/slosh2.wav",
		"sharpeye/slosh3.wav",
		"sharpeye/slosh4.wav"
	}
	self.dat.watersteps = {
		"sharpeye/waterstep1.wav",
		"sharpeye/waterstep2.wav",
		"sharpeye/waterstep3.wav",
		"sharpeye/waterstep4.wav"
	}
	self.dat.stops = {
		"sharpeye/gear1.wav",
		"sharpeye/gear2.wav",
		"sharpeye/gear3.wav",
		"sharpeye/gear4.wav",
		"sharpeye/gear5.wav",
		"sharpeye/gear6.wav"
	}
	self.dat.waterflop = {
		"sharpeye/water_splash1.wav",
		"sharpeye/water_splash2.wav",
		"sharpeye/water_splash3.wav"
	}
	self.dat.breathing = {
		"sharpeye/breathe_male.wav",
		"sharpeye/breathe_female.wav",
		"sharpeye/breathe_mask.wav"
	}
	self.dat.wind = {
		"sharpeye/wind1.wav"
	}
	self.dat.soundtables = {
		self.dat.footsteps,
		self.dat.sloshsteps,
		self.dat.watersteps,
		self.dat.stops,
		self.dat.waterflop,
		self.dat.breathing,
		self.dat.wind
	}
	
	for _,subtable in pairs(self.dat.soundtables) do
		for k,path in pairs(subtable) do
			resource.AddFile("sound/" .. path)
		end
	end
	
	resource.AddFile("materials/depthhud/circle.vtf")
	resource.AddFile("materials/depthhud/linebow_crosshair.vmt")
	resource.AddFile("materials/depthhud/linebow_crosshair.vtf")
	resource.AddFile("materials/depthhud/X_CircleSolid.vmt")
	
end