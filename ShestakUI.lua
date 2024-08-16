local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

local function HookShestakUI()
	if not ShestakUI then return end
	local T = ShestakUI[1]
	local Tags = ShestakUI.oUF and ShestakUI.oUF.Tags

	local RG_UnitName = AliasesNamespace.RG_UnitName
	Tags.Methods["NameArena"] = function(unit)
		local name = RG_UnitName(unit) or UnitName(unit) or UNKNOWN
		return T.UTF(name, 4, false)
	end

	Tags.Methods["NameShort"] = function(unit)
		local name = RG_UnitName(unit) or UnitName(unit) or UNKNOWN
		return T.UTF(name, 8, false)
	end

	Tags.Methods["NameMedium"] = function(unit)
		local name = RG_UnitName(unit) or UnitName(unit) or UNKNOWN
		return T.UTF(name, 11, true)
	end

	Tags.Methods["NameLong"] = function(unit)
		local name = RG_UnitName(unit) or UnitName(unit) or UNKNOWN
		return T.UTF(name, 18, true)
	end

	Tags.Methods["NameLongAbbrev"] = function(unit)
		local name = RG_UnitName(unit) or UnitName(unit) or UNKNOWN
		if string.len(name) > 18 then
			name = string.gsub(name, "-", "")
			name = string.gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ")
		end
		return T.UTF(name, 18, false)
	end
	AliasesNamespace.debugPrint("ShestakUI HOOKED")
end

function AliasesNamespace.HookShestakUI()
	if C_AddOns.IsAddOnLoadable("ShestakUI") then
		EventUtil.ContinueOnAddOnLoaded("ShestakUI", HookShestakUI)
	end
end