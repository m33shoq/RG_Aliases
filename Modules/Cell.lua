local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

local module = AliasesNamespace:NewModule("cell", {
	name = "Cell",
	desc = AliasesNamespace.L["Changes names on Cell frames"],
	addonName = "Cell",
})

function AliasesNamespace.HookCell()
	if C_AddOns.IsAddOnLoadable(module.addonName) then
		EventUtil.ContinueOnAddOnLoaded(module.addonName, function()
			AliasesNamespace.debugPrint("Cell HOOKED")
			AliasesNamespace.hookedModules["cell"] = true

			local Cell = _G.Cell
			local F = Cell.funcs
			local RG_UnitName = AliasesNamespace.RG_UnitName
			F.GetNickname = function(self,shortName,fullName)
				return fullName and RG_UnitName(fullName) or shortName and RG_UnitName(shortName) or shortName or _G.UNKNOWNOBJECT
			end
		end)
	end
end