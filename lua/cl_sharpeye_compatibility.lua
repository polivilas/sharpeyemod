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
	sharpeye.Compatibility_MakeWeaponSeatsCompatible( optbForce )
end

// PROCESS Function
function sharpeye.ProcessCompatibleCalcView( ply, origin, angles, fov, tCalcView)
	local modified = false
	if sharpeye_dat.comp.spacebuild then
		modified = modified or sharpeye.Compatibility_SBEPBMView( ply, origin, angles, fov, tCalcView)
	end
	if sharpeye_dat.comp.scars then
		modified = modified or sharpeye.Compatibility_SCarCalcView( ply, origin, angles, fov, tCalcView)
	end
	if sharpeye_dat.comp.weaponseats then
		modified = modified or sharpeye.Compatibility_WeaponSeat( ply, origin, angles, fov, tCalcView)
	end
	
	return modified
end

// The following compatibility fix contains a direct copy
// from a chunk of code
// taken from the addon Spacebuild.

function sharpeye.Compatibility_ShouldOverrideSpacebuild( optbForce )
	if not optbForce and (sharpeye_dat.comp.spacebuild or CALCVIEW_ISFIXED_SPACEBUILD) then
		return false
		
	elseif hook.GetTable()["CalcView"] and hook.GetTable()["CalcView"]["SBEPBMView"] then
		return true
		
	else
		return false
	end
end

function sharpeye.Compatibility_MakeSpacebuildCompatible( optbForce )
	if not sharpeye.Compatibility_ShouldOverrideSpacebuild( optbForce ) then return end
	sharpeye_dat.comp.spacebuild = true
	
	print("[ > " .. SHARPEYE_NAME .. " has found a potential uncompatibility with Spacebuild. Patching... ]")
	
	hook.Remove("CalcView", "SBEPBMView")
	--local sbview = {}
	function sharpeye.Compatibility_SBEPBMView(ply, origin, angles, fov, tCalcView)
		if not (ply.BCMode and ply.BComp and ply.BComp:IsValid()) then return end
		
		tCalcView.origin = origin + ply.BComp.CVVec
		tCalcView.angles = Angle(90,0,0)
		
		return true
	end
	--hook.Add("CalcView", "SBEPBMView_sharpeye", SBEPBMView_sharpeye)
end


// The following compatibility fix contains a direct copy
// from a chunk of code that is Copyright (c) 2010 Sakarias Johansson
// taken from the addon SCars.

function sharpeye.Compatibility_ShouldOverrideSCars( optbForce )
	if not optbForce and (sharpeye_dat.comp.scars or CALCVIEW_ISFIXED_SCARS) then
		return false
		
	elseif hook.GetTable()["CalcView"] and hook.GetTable()["CalcView"]["SCar CalcView"] then
		return true
		
	else
		return false
	end
end

function sharpeye.Compatibility_MakeSCarsCompatible( optbForce )
	if not sharpeye.Compatibility_ShouldOverrideSCars( optbForce ) then return end
	sharpeye_dat.comp.scars = true
	
	print("[ > " .. SHARPEYE_NAME .. " has found a potential uncompatibility with SCars. Patching... ]")
	
	hook.Remove("CalcView", "SCar CalcView")
	--local sbview = {}
	function sharpeye.Compatibility_SCarCalcView(ply, origin, angles, fov, tCalcView)
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
			
			tCalcView.origin = position
			tCalcView.angles = angles
			tCalcView.fov    = fov
			
			return true
			
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
			
			tCalcView.origin = position
			tCalcView.angles = angles
			tCalcView.fov    = fov
			
			return true
			
		end
	end
	--hook.Add("CalcView", "SCarCalcView_sharpeye", SCarCalcView_sharpeye)
end

// The following compatibility fix contains a direct copy
// from a chunk of code by CapsAdmin
// taken from the addon Weapon Seats.

function sharpeye.Compatibility_ShouldOverrideWeaponSeats( optbForce )
	if not optbForce and (sharpeye_dat.comp.weaponseats or CALCVIEW_ISFIXED_WEAPONSEATS) then
		return false
		
	elseif hook.GetTable()["CalcView"] and hook.GetTable()["CalcView"]["Weapon Seat"] then
		return true
		
	else
		return false
	end
end

function sharpeye.Compatibility_MakeWeaponSeatsCompatible( optbForce )
	if not sharpeye.Compatibility_ShouldOverrideWeaponSeats( optbForce ) then return end
	sharpeye_dat.comp.weaponseats = true
	
	print("[ > " .. SHARPEYE_NAME .. " has found a potential uncompatibility with Weapon Seats. Patching... ]")
	
	hook.Remove("CalcView", "Weapon Seat")
	local function WeaponSeat_DrawPlayerInSeat()
		for key, ply in pairs(player.GetAll()) do
			local seat = ply:GetNWEntity("weapon seat")
			if ValidEntity(seat) and ValidEntity(ply) then
				local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"))
				local angles = seat:GetAngles()
				angles:RotateAroundAxis(seat:GetUp(), 90)
				ply:SetAngles(angles)
				ply:SetPos(posang.Pos)
				local angle = math.NormalizeAngle(ply:EyeAngles().y-90)/180
				ply:SetPoseParameter("body_yaw", angle*29.7)
				ply:SetPoseParameter("spine_yaw", angle*30.7)
				ply:SetPoseParameter("aim_yaw", angle*52.5)
				ply:SetPoseParameter("head_yaw", angle*30.7)
			end
		end
	end
	
	--local sbview = {}
	function sharpeye.Compatibility_WeaponSeat(ply, origin, angles, fov, tCalcView)
		WeaponSeat_DrawPlayerInSeat()
		local seat = ply:GetNWEntity("weapon seat")
		if ply:GetNWBool("is in weapon seat") and ValidEntity(seat) and not ply.weapon_seat_visible then
			local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"))
			tCalcView.origin = posang.Pos + posang.Ang:Up() * 25
			return true
		end
		
		return
	end
	--hook.Add("CalcView", "WeaponSeat_sharpeye", WeaponSeat_sharpeye)
end

if SHARPEYE_INCLUDED_AT_LEAST_ONCE then sharpeye.SolveCompatilibityIssues( ) end
