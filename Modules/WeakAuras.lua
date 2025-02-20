local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

local module = AliasesNamespace:NewModule("weakauras", {
	name = "WeakAuras",
	desc = AliasesNamespace.L["Changes names formatted by WeakAuras"],
	addonName = "WeakAuras",
})

function AliasesNamespace.HookWeakAuras()
	if C_AddOns.IsAddOnLoadable(module.addonName) then
		EventUtil.ContinueOnAddOnLoaded(module.addonName, function()
			AliasesNamespace.debugPrint("WeakAuras HOOKED")
			AliasesNamespace.hookedModules["weakauras"] = true


			local RG_UnitName = AliasesNamespace.RG_UnitName
			local WeakAuras = WeakAuras
			if WeakAuras.GetName then
				WeakAuras.GetName = function(name)
					if not name then return end

					return RG_UnitName(name) or name
				end
			end

			if WeakAuras.UnitName then
				WeakAuras.UnitName = function(unit)
					if not unit then return end

					local name, realm = UnitName(unit)

					if not name then return end

					return RG_UnitName(unit) or name, realm
				end
			end

			if WeakAuras.GetUnitName then
				WeakAuras.GetUnitName = function(unit, showServerName)
					if not unit then return end

					if not UnitIsPlayer(unit) then
						return GetUnitName(unit)
					end

					local name = UnitNameUnmodified(unit)
					local nameRealm = GetUnitName(unit, showServerName)
					local suffix = nameRealm:match(".+(%s%(%*%))") or nameRealm:match(".+(%-.+)") or ""

					return string.format("%s%s", RG_UnitName(unit) or name, suffix)
				end
			end

			if WeakAuras.UnitFullName then
				WeakAuras.UnitFullName = function(unit)
					if not unit then return end

					local name, realm = UnitFullName(unit)

					if not name then return end

					return RG_UnitName(unit) or name, realm
				end
			end

		end)
	end
end