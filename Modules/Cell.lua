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


			-- special request by Mate
			if RG_ALTS_SETTINGS["cell_use_own_nickname"] then
				local playerName = UnitName("player")

				local function Cell_UnitName(name)
					if name == playerName then
						if _G.CellDB and _G.CellDB["nicknames"] and _G.CellDB["nicknames"]["mine"] then
							local cellNick = _G.CellDB["nicknames"]["mine"]
							if cellNick and cellNick ~= "" then
								return cellNick
							end
						end
						return name
					end

					return RG_UnitName(name)
				end

				F.GetNickname = function(shortName,fullName)
					return fullName and Cell_UnitName(fullName) or shortName and Cell_UnitName(shortName) or shortName or _G.UNKNOWNOBJECT
				end
			else
				F.GetNickname = function(shortName,fullName)
					return fullName and RG_UnitName(fullName) or shortName and RG_UnitName(shortName) or shortName or _G.UNKNOWNOBJECT
				end
			end
		end)
	end
end