-- DevTool:AddData(ShadowUF)
--[[
Посмотреть /dev че там в этих рофлан тагах, захардкодить таг c RG_UnitName()

ShadowUF.Tags:Reload(tagName) ??? tagName is optional
/dump IsAddOnLoaded("ShadowedUnitFrames")

В гайде добавить отдельное упоминание про то что при создании нового профиля что бы добавился тэг нужно перезагрузить интерфейс
]]

local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

function AliasesNamespace.HookSUF()
	-- options
	EventUtil.ContinueOnAddOnLoaded("ShadowedUF_Options", function()
		AliasesNamespace.debugPrint("SUF TAGS LOADED AS CUSTOM TAGS")
		local ShadowUF = _G.ShadowUF
		if not ShadowUF then return end
		ShadowUF.db.profile.tags["RG_Name"] = {
			["func"] = [[function(unit, unitOwner)
				return RG_UnitName and RG_UnitName(unitOwner) or UnitName(unitOwner) or UNKNOWN
			end]],
			["events"] = "UNIT_NAME_UPDATE",
			["name"] = "RG Alias",
			["help"] = "Shows Rak Gaming Alias",
			["category"] = "misc",
		}
		ShadowUF.db.profile.tags["RG_Name_ClassColored"] = {
			["func"] = [[function(unit, unitOwner)
				local color = ShadowUF:GetClassColor(unitOwner)
				local name = RG_UnitName and RG_UnitName(unitOwner) or UnitName(unitOwner) or UNKNOWN
				if not color then
					return name
				end
				return string.format("%s%s|r", color, name)
			end]],
			["events"] = "UNIT_NAME_UPDATE",
			["name"] = "RG Alias(Class colored)",
			["help"] = "Shows Rak Gaming Alias with class color",
			["category"] = "misc",
		}
		for _,profile in pairs(ShadowUF.db.profiles) do
			if profile and profile.tags then
				profile.tags["RG_Name"] = ShadowUF.db.profile.tags["RG_Name"]
				profile.tags["RG_Name_ClassColored"] = ShadowUF.db.profile.tags["RG_Name_ClassColored"]
			end
		end
	end)


	-- main addon
	EventUtil.ContinueOnAddOnLoaded("ShadowedUnitFrames", function()
		AliasesNamespace.debugPrint("SUF TAGS ADDED")
		local ShadowUF = _G.ShadowUF
		if not ShadowUF then return end

		ShadowUF.Tags.defaultCategories["RG_Name"] = "misc"
		ShadowUF.Tags.defaultEvents["RG_Name"] = "UNIT_NAME_UPDATE"
		ShadowUF.Tags.defaultHelp["RG_Name"] = "Shows Rak Gaming Alias"
		ShadowUF.Tags.defaultNames["RG_Name"] = "RG Alias"
		ShadowUF.Tags.defaultTags["RG_Name"] = [[function(unit, unitOwner) return RG_UnitName and RG_UnitName(unitOwner) or UnitName(unitOwner) or UNKNOWN end]]

		ShadowUF.Tags.defaultCategories["RG_Name_ClassColored"] = "misc"
		ShadowUF.Tags.defaultEvents["RG_Name_ClassColored"] = "UNIT_NAME_UPDATE"
		ShadowUF.Tags.defaultHelp["RG_Name_ClassColored"] = "Shows Rak Gaming Alias with class color"
		ShadowUF.Tags.defaultNames["RG_Name_ClassColored"] = "RG Alias(Class colored)"
		ShadowUF.Tags.defaultTags["RG_Name_ClassColored"] = [[function(unit, unitOwner)
			local color = ShadowUF:GetClassColor(unitOwner)
			local name = RG_UnitName and RG_UnitName(unitOwner) or UnitName(unitOwner) or UNKNOWN
			if not color then
				return name
			end
			return string.format("%s%s|r", color, name)
		end]]
	end)
end