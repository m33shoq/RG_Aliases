local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

function AliasesNamespace.HookCell()
	if C_AddOns.IsAddOnLoadable("Cell") then
		EventUtil.ContinueOnAddOnLoaded("Cell", function()
			AliasesNamespace.debugPrint("Cell HOOKED")
			local Cell = _G.Cell
			local F = Cell.funcs
			local RG_UnitName = AliasesNamespace.RG_UnitName
			F.GetNickname = function (self,shortName,fullName)
				return fullName and RG_UnitName(fullName) or shortName and RG_UnitName(shortName) or shortName or _G.UNKNOWNOBJECT
			end
		end)
	end
end