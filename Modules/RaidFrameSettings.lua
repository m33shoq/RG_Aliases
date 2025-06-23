local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

local moduleKey = "rfs"

AliasesNamespace:NewModule(moduleKey, {
	name = "RaidFrameSettings",
	desc = AliasesNamespace.L["Changes names on RaidFrameSettings' Frames."] .. "\n\n" .. AliasesNamespace.L["RFSDisalbeTip"],
	addonName = "RaidFrameSettings",
})


local function hookRFS()
	local RaidFrameSettings = LibStub("AceAddon-3.0"):GetAddon("RaidFrameSettings")
	AliasesNamespace.debugPrint("RFS HOOKED")
	AliasesNamespace.hookedModules[moduleKey] = true

	if not RaidFrameSettings.UpdateNicknames then
		error("RaidFrameSettings:UpdateNicknames() not found, contact author of RakGamingAliases")
	end
	-- RaidFrameSettings.db.profile.Nicknames [name-realm] or [name] = nickname

	local updateNicknamesTimer
	local function scheduleUpdateNicknames()
		if updateNicknamesTimer then
			return
		end
		updateNicknamesTimer = C_Timer.NewTimer(0.2, function()
			updateNicknamesTimer = nil
			RaidFrameSettings:UpdateNicknames()
		end)
	end

	AliasesNamespace.RegisterCallback("ModuleEnabled", function(event, moduleName)
		if moduleName == moduleKey then
			AliasesNamespace.RFSUpdateNicknames()
			StaticPopupDialogs["RAKGAMINGALIASES_RFS_DISABLE_NOTIFICATION"] = {
				text = "|cffee5555[Rak Gaming Aliases]|r\n\n" .. AliasesNamespace.L["RFSDisalbeTip"],
				button1 = ACCEPT,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
			}
			StaticPopup_Show("RAKGAMINGALIASES_RFS_DISABLE_NOTIFICATION")
		end
	end)

	AliasesNamespace.RegisterCallback("ModuleDisabled", function(event, moduleName)
		if moduleName == moduleKey then
			-- clear RaidFrameSettings.db.profile.Nicknames
			RaidFrameSettings.db.profile.Nicknames = {}
			RaidFrameSettings:UpdateNicknames()
		end
	end)

	AliasesNamespace.RegisterCallback("AliasRemoved", function(event, name)
		if RaidFrameSettings.db.profile.Nicknames[name] then
			RaidFrameSettings.db.profile.Nicknames[name] = nil
			scheduleUpdateNicknames()
		end
	end)

	AliasesNamespace.RegisterCallback("AliasAdded", function(event, name)
		if not RaidFrameSettings.db.profile.Nicknames[name] then
			RaidFrameSettings.db.profile.Nicknames[name] = name
			scheduleUpdateNicknames()
		end
	end)

	function AliasesNamespace.RFSUpdateNicknames()
		RaidFrameSettings.db.profile.Nicknames = CopyTable(RG_ALTS_DB)
		RaidFrameSettings:UpdateNicknames()
	end

	AliasesNamespace.RFSUpdateNicknames()
end

function AliasesNamespace.HookRFS()
	if C_AddOns.IsAddOnLoadable("RaidFrameSettings") then
		EventUtil.ContinueOnAddOnLoaded("RaidFrameSettings", function()
			 -- delay to ensure RFS db is properly loaded into the addon table
			C_Timer.After(1, hookRFS)
		end)
	end
end
