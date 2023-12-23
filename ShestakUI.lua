if not ShestakUI then return end

addonName, addonTable = ...

function addonTable.HookShestakUI()
	local T = ShestakUI[1]
	local Tags = ShestakUI.oUF and ShestakUI.oUF.Tags

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
	print("|cffee5555[Rak Gaming Aliases]|r ShestakUI HOOKED")
end