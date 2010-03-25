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
	
	print("[ > SharpeYe has found a potential uncompatibility with Spacebuild. Patching... ]")
	
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