////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Compatibility Fixes                        //
////////////////////////////////////////////////

function sharpeye.SolveCompatilibityIssues()
	sharpeye.Compatibility_MakeSpacebuildCompatible()
end

function sharpeye.Compatilibity_ShouldOverrideSpacebuild()
	if sharpeye_dat.comp_spacebuild then
		return false
		
	elseif hook.GetTable()["CalcView"] and hook.GetTable()["CalcView"]["SBEPBMView"] then
		return true
		
	else
		return false
	end
end

function sharpeye.Compatibility_MakeSpacebuildCompatible()
	if not sharpeye.Compatilibity_ShouldOverrideSpacebuild() then return end
	sharpeye_dat.comp_spacebuild = true
	
	hook.Remove("CalcView", "SBEPBMView")
	local sbview = {}
	function SBEPBMView_sharpeye(ply, origin, angles, fov)
		if ply.BCMode then
			if ply.BComp and ply.BComp:IsValid() then
				sbview.origin = origin + ply.BComp.CVVec
				sbview.angles = Angle(90,0,0)
				return sbview
			end
		end
	end
	hook.Add("CalcView", "SBEPBMView_sharpeye", SBEPBMView_sharpeye)
end