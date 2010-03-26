////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Compatibility Fixes                        //
////////////////////////////////////////////////

function sharpeye.ForceSolveCompatilibityIssues( )
	sharpeye.SolveCompatilibityIssues( true )
	
end

function sharpeye.SolveCompatilibityIssues( optbForce )
	if not sharpeye_dat.comp then
		sharpeye_dat.comp = {}
	end
	
	sharpeye.Compatibility_MakeSpacebuildCompatible( optbForce )
	sharpeye.Compatibility_MakeSCarsCompatible( optbForce )
end

function sharpeye.Compatilibity_ShouldOverrideSpacebuild( optbForce )
	if not optbForce and sharpeye_dat.comp.spacebuild then
		return false
		
	elseif hook.GetTable()["CalcView"] and hook.GetTable()["CalcView"]["SBEPBMView"] then
		return true
		
	else
		return false
	end
end

function sharpeye.Compatibility_MakeSpacebuildCompatible( optbForce )
	if not sharpeye.Compatilibity_ShouldOverrideSpacebuild( optbForce ) then return end
	sharpeye_dat.comp.spacebuild = true
	
	print("[ > " .. SHARPEYE_NAME .. " has found a potential uncompatibility with Spacebuild. Patching... ]")
	
	hook.Remove("CalcView", "SBEPBMView")
	local sbview = {}
	function SBEPBMView_sharpeye(ply, origin, angles, fov)
		if not (ply.BCMode and ply.BComp and ply.BComp:IsValid()) then return end
		
		sbview.origin = origin + ply.BComp.CVVec
		sbview.angles = Angle(90,0,0)
		
		return sbview
	end
	hook.Add("CalcView", "SBEPBMView_sharpeye", SBEPBMView_sharpeye)
end


// The following compatibility fix contains a direct copy
// from a chunk of broken code that is Copyright (c) 2010 Sakarias Johansson

function sharpeye.Compatilibity_ShouldOverrideSCars( optbForce )
	if not optbForce and sharpeye_dat.comp.scars then
		return false
		
	elseif hook.GetTable()["CalcView"] and hook.GetTable()["CalcView"]["SCar CalcView"] then
		return true
		
	else
		return false
	end
end

function sharpeye.Compatibility_MakeSCarsCompatible( optbForce )
	if not sharpeye.Compatilibity_ShouldOverrideSCars( optbForce ) then return end
	sharpeye_dat.comp.scars = true
	
	print("[ > " .. SHARPEYE_NAME .. " has found a potential uncompatibility with SCars. Patching... ]")
	
	hook.Remove("CalcView", "SCar CalcView")
	local sbview = {}
	function SCarCalcView_sharpeye(ply, origin, angles, fov)
		if not ply:Alive() then return end
		if ((ply:GetActiveWeapon() == NULL) or (ply:GetActiveWeapon() == "Camera")) then return end
		if GetViewEntity() ~= ply then return end
		

		local veh = LocalPlayer():GetVehicle()
		local isScarSeat = 0
		
		if ValidEntity(veh) then
			isScarSeat = veh:GetNetworkedInt( "SCarSeat" )
		end
		
		local ThirdPersonView = 0
		
		if isScarSeat == 1 then
			ThirdPersonView = veh:GetNetworkedInt( "SCarThirdPersonView" )
		end
		
		if (veh ~= nil) and (isScarSeat ~= nil) and (isScarSeat == 1) and (ThirdPersonView == 1) then

			local SCar = veh:GetNetworkedEntity("SCarEnt")
			local pos =  SCar:WorldToLocal( position )
			local cameraCorrection = veh:GetNetworkedInt( "SCarCameraCorrection" )
		
			
		
			if string.find(SCar:GetModel(), "models/splayn/hummer_h2.mdl") then
				position = position + ( SCar:GetForward() * -250 ) + ( SCar:GetUp() * 50 ) + ( SCar:GetForward() * pos.x ) + ( SCar:GetRight() * pos.y ) + ( SCar:GetUp() * pos.z )
			elseif string.find(SCar:GetModel(), "models/props_vehicles/van001a_physics.mdl") then
				position = position + ( SCar:GetForward() * -330 ) + ( SCar:GetUp() * 20 ) + ( SCar:GetForward() * pos.x ) + ( SCar:GetRight() * pos.y ) + ( SCar:GetUp() * pos.z )		
			elseif string.find(SCar:GetModel(), "models/borderlands/bus/bus.mdl") then
				position = position + ( SCar:GetForward() * -650 ) + ( SCar:GetUp() * 20 ) + ( SCar:GetForward() * pos.x ) + ( SCar:GetRight() * pos.y ) + ( SCar:GetUp() * pos.z )			
			elseif string.find(SCar:GetModel(), "models/vigilante8/mothtruck.mdl") then
				position = position + ( SCar:GetForward() * -330 ) + ( SCar:GetForward() * pos.x ) + ( SCar:GetRight() * pos.y ) + ( SCar:GetUp() * pos.z )	
			elseif string.find(SCar:GetModel(), "models/dean/gtaiv*") then	
				position = position + ( SCar:GetForward() * -150 ) + ( SCar:GetUp() * -5 ) + ( SCar:GetForward() * pos.x ) + ( SCar:GetRight() * pos.y ) + ( SCar:GetUp() * pos.z )			
			else
				position = position + ( SCar:GetForward() * -200 ) + ( SCar:GetForward() * pos.x ) + ( SCar:GetRight() * pos.y ) + ( SCar:GetUp() * pos.z )	
			end
			
			
			
			local vel = SCar:GetVelocity():Length()
			local direction = SCar:GetVelocity():Normalize()	
			local newDirection = ply:GetAimVector()
			
			direction.y = direction.y * -1
			
			if vel > 5000 then
				vel = 5000
			end

			
			
			if vel > 50 then
				newDirection = newDirection + ((direction - newDirection) / 5) 
			else
				local divider = 55 - vel
				newDirection = newDirection + ((direction - newDirection) / divider) 		
			end
			
			if cameraCorrection == 1 then
				angles = newDirection:Angle()
			end

			
			vel = (vel / 5000) * 90
			fov = 75 + vel
			
			local Trace = {}
			Trace.start = ply:GetShootPos() + ( SCar:GetUp() * 10 )
			Trace.endpos = position
			Trace.filter = {ply,SCar,veh}
			local tr = util.TraceLine(Trace)
			if tr.Hit then	
				position = tr.HitPos
			end	
			
			sbview.origin = position
			sbview.angles = angles
			sbview.fov    = fov
			
			return sbview
			
		elseif (veh ~= nil) and (isScarSeat ~= nil) and (isScarSeat == 1) and (ThirdPersonView == 0) then 	
			

			local SCar = veh:GetNetworkedEntity("SCarEnt")
			local cameraCorrection = veh:GetNetworkedInt( "SCarCameraCorrection" )
			local vel = SCar:GetVelocity():Length()
			local VecVel =  veh:GetVelocity()
			local direction = SCar:GetVelocity():Normalize()	
			local newDirection = ply:GetAimVector()
			
			direction.y = direction.y * -1
			
			if vel > 50 then
				newDirection = newDirection + ((direction - newDirection) / 5) 
				
			else
				local divider = 50 - vel
				divider = divider * 10 + 5
				newDirection = newDirection + ((direction - newDirection) / divider) 	
				
			end
			
			if cameraCorrection == 1 then
				angles = newDirection:Angle()
				
			end
			
			sbview.origin = position
			sbview.angles = angles
			sbview.fov    = fov
			
			return sbview
			
		end
	end
	hook.Add("CalcView", "SCarCalcView_sharpeye", SCarCalcView_sharpeye)
end

sharpeye.SolveCompatilibityIssues( )
