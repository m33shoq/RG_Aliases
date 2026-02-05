local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

-- M33kAuras compatibility
local M33kAurasExists = C_AddOns.DoesAddOnExist("M33kAuras")
local M33kAurasEnabled = C_AddOns.GetAddOnEnableState("M33kAuras", UnitGUID("player")) ~= 0

local module = AliasesNamespace:NewModule("weakauras", {
	name = M33kAurasExists and "M33kAuras" or "WeakAuras",
	desc = AliasesNamespace.L["Changes names formatted by WeakAuras or M33kAuras"],
	addonName = M33kAurasExists and "M33kAuras" or "WeakAuras",
})

function AliasesNamespace.HookWeakAuras()
	if C_AddOns.IsAddOnLoadable(module.addonName) then
		EventUtil.ContinueOnAddOnLoaded(module.addonName, function()
			local WeakAuras = M33kAurasEnabled and M33kAuras or WeakAuras
			if not WeakAuras then
				return
			end

			local RG_UnitName = AliasesNamespace.RG_UnitName

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

			AliasesNamespace.debugPrint("WeakAuras HOOKED")
			AliasesNamespace.hookedModules["weakauras"] = true
		end)
	end
end