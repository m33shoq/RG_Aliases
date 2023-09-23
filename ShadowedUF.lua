-- DevTool:AddData(ShadowUF)
--[[
Посмотреть /dev че там в этих рофлан тагах, захардкодить таг c RG_UnitName()

ShadowUF.Tags:Reload(tagName) ??? tagName is optional
/dump IsAddOnLoaded("ShadowedUnitFrames")

В гайде добавить отдельное упоминание про то что при создании нового профиля что бы добавился тэг нужно перезагрузить интерфейс
]]

local addonName, addonTable = ...

function addonTable.HookSUF()
	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", function(self, event, addon)
		if addon == "ShadowedUF_Options" then --/suf
			print("|cffee5555[Rak Gaming Aliases]|r SUF TAGS UPDATED")
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
			ShadowUF.Tags:Reload()
		end
	end)
end