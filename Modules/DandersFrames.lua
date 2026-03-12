local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

local module = AliasesNamespace:NewModule("dandersframes", {
	name = "DandersFrames",
	desc = AliasesNamespace.L["Changes names on DandersFrames frames"],
	addonName = "DandersFrames",
})

function AliasesNamespace.HookDandersFrames()
	if C_AddOns.IsAddOnLoadable(module.addonName) then
		EventUtil.ContinueOnAddOnLoaded(module.addonName, function()
			AliasesNamespace.debugPrint("DandersFrames HOOKED")
			AliasesNamespace.hookedModules["dandersframes"] = true
			local DF = _G.DandersFrames

			local RG_UnitName = AliasesNamespace.RG_UnitName

			function DF:GetUnitName(unit)
				return RG_UnitName(unit)
			end

			local function fullUpdate()
				DF:IterateCompactFrames(function(frame)
					if type(DF.UpdateNameText) == "function" then
						DF:UpdateNameText(frame)
					else
						DF:UpdateName(frame)
					end
				end)
			end
			fullUpdate()

			AliasesNamespace.RegisterCallback("DbUpdated", function()
				fullUpdate()
			end)

			AliasesNamespace:DisableBlizzardHook()
		end)
	end
end