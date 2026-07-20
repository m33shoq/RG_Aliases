-- 14.08.2024
local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

_G.RG_ALIAS = AliasesNamespace

local realmKey = GetRealmName() or ""
local charName = UnitName'player' or ""
realmKey = realmKey:gsub(" ","")
AliasesNamespace.realmKey = realmKey
AliasesNamespace.charKey = charName .. "-" .. realmKey
AliasesNamespace.charName = charName
local issecretvalue = issecretvalue or function() return false end

function AliasesNamespace.print(...)
	print("|cffee5555[Rak Gaming Aliases]|r", ...)
end

-- /run RG_ALTS_SETTINGS.debug = true
function AliasesNamespace.debugPrint(...)
	if RG_ALTS_SETTINGS and RG_ALTS_SETTINGS.debug then
		AliasesNamespace.print("Debug:",...)
	end
end

function AliasesNamespace.convertToTable(selectedText)
	local alts_db = {}
	for line in selectedText:gmatch("[^\r\n]+") do
	  	local alias, names = line:match("^(%S+)%s*-%s*(.+)$")
	  	if alias and names then
			for name in names:gmatch("%S+") do
				alts_db[name] = alias
			end
	  	end
	end
	return alts_db
end

function RG_ALIASES_SET_ALTS_DB(char_db)
	RG_ALTS_DB = setmetatable(char_db or {}, {
		__index = function(t, k)
			if not k then return nil end
			if not UnitIsPlayer(k) then return nil end

			-- somehow can't figure out how to be safe here so just pcall and call it a day
			local ok, GUIDOrError = pcall(UnitGUID, k)
			if not ok or not GUIDOrError then return nil end

			local bFriend = C_BattleNet.GetAccountInfoByGUID(GUIDOrError)
			if bFriend and bFriend.battleTag then
				local alias = rawget(t, bFriend.battleTag)
				if alias then
					return alias
				end
			end

			return nil
		end
	})

	AliasesNamespace.UpdateDB()
end

local db = {}
function AliasesNamespace.UpdateDB()
	db = RG_ALTS_DB
	AliasesNamespace.db = db
	AliasesNamespace.FireCallback("DbUpdated")
end

local function RG_UnitName(unit)
	if issecretvalue(unit) then
		return
	end
	local name, realm = UnitName(unit)
	if issecretvalue(name) then
		return name, realm
	end
	return RG_ALTS_DB[name] or name, realm
end

local function RG_ClassColorName(unit)
	if unit and not issecretvalue(unit) and UnitExists(unit) then
		local name = RG_UnitName(unit)
		local _, class = UnitClass(unit)
		if not class then
			return name
		else
			local classData = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
			local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
			return coloredName
		end
	else
	  	return "" -- ¯\_(ツ)_/¯
	end
  end

_G.RG_UnitName = RG_UnitName
_G.RG_ClassColorName = RG_ClassColorName

AliasesNamespace.RG_UnitName = RG_UnitName
AliasesNamespace.RG_ClassColorName = RG_ClassColorName

local callbacks = {}

function AliasesNamespace.FireCallback(event, ...)
	if callbacks[event] then
		for _, callback in pairs(callbacks[event]) do
			if type(callback) == "function" then
				callback(event, ...)
			end
		end
	end
end

function AliasesNamespace.RegisterCallback(event, callback)
	if not callbacks[event] then
		callbacks[event] = {}
	end
	table.insert(callbacks[event], callback)
end

function AliasesNamespace.ResetRG_ALTS_DB()
	RG_ALIASES_SET_ALTS_DB({})
end

local modules = {
}

function AliasesNamespace:NewModule(key, module)
	modules[key] = module
	return module
end

AliasesNamespace.modules = modules
AliasesNamespace.hookedModules = {}
local modulesString = [[

modules:
Blizzard
ShadowedUF
KHM
ShestakUI
MRTNote
MRTCD
Cell
WeakAuras
RFS
]]

local function loadModules()
	if RG_ALTS_SETTINGS.settings["blizzard"] then
		AliasesNamespace.HookBlizzard()
	end

	if RG_ALTS_SETTINGS.settings["khm"] then
		AliasesNamespace.HookKHM()
	end

	if RG_ALTS_SETTINGS.settings["shestakui"] then
		AliasesNamespace.HookShestakUI()
	end

	if RG_ALTS_SETTINGS.settings["mrtnote"] then
		AliasesNamespace.HookMRTNote()
	end

	if RG_ALTS_SETTINGS.settings["mrtcd"] then
		AliasesNamespace.HookMRTCD()
	end

	if RG_ALTS_SETTINGS.settings["cell"] then
		AliasesNamespace.HookCell()
	end

	if RG_ALTS_SETTINGS.settings["weakauras"] then
		AliasesNamespace.HookWeakAuras()
	end

	if RG_ALTS_SETTINGS.settings["rfs"] then
		AliasesNamespace.HookRFS()
	end

	if RG_ALTS_SETTINGS.settings["dandersframes"] then
		AliasesNamespace.HookDandersFrames()
	end

	if RG_ALTS_SETTINGS.settings["mshframes"] then
		AliasesNamespace.HookMshFrames()
	end
end
local addon = CreateFrame("Frame")
addon:RegisterEvent("ADDON_LOADED")
-- addon:RegisterEvent("PLAYER_LOGOUT")
AliasesNamespace.mainFrame = addon
addon:SetScript("OnEvent", function(self,event, ...)
	if event == "ADDON_LOADED" then
		local addonName = ...
		if addonName ~= GlobalAddonName then
			return
		end

		AliasesNamespace.debugPrint("Ready")
		RG_ALIASES_SET_ALTS_DB(RG_ALTS_DB or {})

		local currentVer = tonumber(C_AddOns.GetAddOnMetadata(GlobalAddonName, "Version"))

		RG_ALTS_SETTINGS = _G.RG_ALTS_SETTINGS or {
			version = currentVer,
			settings = {},
		}

		RG_ALTS_SETTINGS.version = RG_ALTS_SETTINGS.version or 0
		-- modernize settings
		if RG_ALTS_SETTINGS.version < 5 then
			local modulesSetings = CopyTable(RG_ALTS_SETTINGS)
			modulesSetings.version = nil -- do not version field
			-- ensure all settings are lowercase
			for module,isOn in pairs(modulesSetings) do
				RG_ALTS_SETTINGS[module] = nil -- remove module keys from old data
				modulesSetings[module] = nil
				modulesSetings[module:lower()] = isOn
			end

			-- remove anything that is not a module
			for key in pairs(modulesSetings) do
				if modules[key] == nil then
					modulesSetings[key] = nil
				end
			end

			-- ensure all modules exist in settings
			for module in pairs(modules) do
				if type(modulesSetings[module]) ~= 'boolean' then
					modulesSetings[module] = false
				end
			end

			RG_ALTS_SETTINGS.settings = modulesSetings
		end

		RG_ALTS_SETTINGS.version = currentVer

		RG_ALTS_SETTINGS.SyncPlayers = RG_ALTS_SETTINGS.SyncPlayers or {}

		loadModules()

		self:UnregisterEvent("ADDON_LOADED")
	end
end)

function AliasesNamespace.enableModule(moduleName)
	moduleName = moduleName:lower()
	if modules[moduleName] then
		RG_ALTS_SETTINGS.settings[moduleName] = true
		AliasesNamespace.print("Enabled", moduleName)
		AliasesNamespace.FireCallback("ModuleEnabled", moduleName)

		StaticPopupDialogs["RGALIAS_RELOADUI"] = {
			text = "|cffee5555[Rak Gaming Aliases]|r\n\n" .. AliasesNamespace.L["Reload UI to apply changes?"],
			button1 = "Reload",
			button2 = CANCEL,
			OnAccept = ReloadUI,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		}
		StaticPopup_Show("RGALIAS_RELOADUI")
	else
		AliasesNamespace.print("No such module", moduleName)
	end
end

function AliasesNamespace.disableModule(moduleName)
	moduleName = moduleName:lower()
	if modules[moduleName] then
		RG_ALTS_SETTINGS.settings[moduleName] = false
		AliasesNamespace.print("Disabled", moduleName)
		AliasesNamespace.FireCallback("ModuleDisabled", moduleName)

		StaticPopupDialogs["RGALIAS_RELOADUI"] = {
			text = "|cffee5555[Rak Gaming Aliases]|r\n\n" .. AliasesNamespace.L["Reload UI to apply changes?"],
			button1 = "Reload",
			button2 = CANCEL,
			OnAccept = ReloadUI,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		}
		StaticPopup_Show("RGALIAS_RELOADUI")
	else
		AliasesNamespace.print("No such module", moduleName)
	end
end

function AliasesNamespace.addCharacter(name, alias)
	if not name or not alias then
		return
	end

	if _G.RGAPIDBc then
		_G.RGAPIDBc[name] = alias
	else
		RG_ALTS_DB[name] = alias
	end
	AliasesNamespace.print("Added", name, "as", alias)
	AliasesNamespace.FireCallback("AliasAdded", name, alias)
	AliasesNamespace.FireCallback("DbUpdated")
end


function AliasesNamespace.removeCharacter(name)
	if not name then
		return
	end

	if _G.RGAPIDBc then
		_G.RGAPIDBc[name] = nil
	else
		RG_ALTS_DB[name] = nil
	end
	AliasesNamespace.print("Removed", name)
	AliasesNamespace.FireCallback("AliasRemoved", name)
	AliasesNamespace.FireCallback("DbUpdated")
end

------------------------------------------------------------------------
-- SLASH COMMANDS
------------------------------------------------------------------------
string_gmatch = string.gmatch

local function handler(msg)
	local arg1, arg2, arg3
	for word in string_gmatch(msg, "[^ ]+") do
		if not arg1 then
			arg1 = word:lower()
		elseif not arg2 then
			arg2 = word
		elseif not arg3 then
			arg3 = word
		end
	end
	if arg1 == "opt" or arg1 == "options" or arg1 == "" or not arg1 then
		AliasesNamespace:ShowOptions()
	elseif arg1 == "default" then
		AliasesNamespace.ResetRG_ALTS_DB()
		AliasesNamespace.print("Reseted Alts Database to Default")
	elseif arg1 == "request" then
		AliasesNamespace.Request()
		AliasesNamespace.print("Requesting")
	elseif arg1 == "send" then
		AliasesNamespace.SendAliasData()
		AliasesNamespace.print("Sending")
	elseif arg1 == "add" then
		if arg2 and arg3 then
			AliasesNamespace.addCharacter(arg2, arg3)
		else
			AliasesNamespace.print("|cff80ff00/rgalias add <name> <alias>|r")
		end
	elseif arg1 == "remove" then
		if arg2 then
			AliasesNamespace.removeCharacter(arg2)
		else
			AliasesNamespace.print("|cff80ff00/rgalias remove <name>|r")
		end
	elseif arg1 == "get" then
		if arg2 then
			AliasesNamespace.print(RG_ALTS_DB[arg2] and (RG_ALTS_DB[arg2]) or ("No alias for " .. arg2))
		end
	elseif arg1 == "disable" then
		if arg2 then
			AliasesNamespace.disableModule(arg2)
		else
			AliasesNamespace.print("|cff80ff00/rgalias disable <module>|r" .. modulesString)
		end
	elseif arg1 == "enable" then
		if arg2 then
			AliasesNamespace.enableModule(arg2)
		else
			AliasesNamespace.print("|cff80ff00/rgalias enable <module>|r" .. modulesString)
		end
	elseif arg1 == "status" then
		AliasesNamespace.print("modules settings:")
		local res = {}
		for module, moduleData in pairs(modules) do
			res[#res+1] = format("%s %s %s", module, (moduleData.alwaysEnabled or RG_ALTS_SETTINGS.settings[module]) and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r", not C_AddOns.IsAddOnLoaded(moduleData.addonName) and "|cff888888Not Loaded|r" or "")
		end
		table.sort(res)
		for i=1,#res do
			print(res[i])
		end
	else
		AliasesNamespace.print(
[[Available slash commands:
|cff80ff00/rgalias|r, |cff80ff00/rgalias opt|r, |cff80ff00/rgalias options|r - Open options
|cff80ff00/rgalias default|r - Reset Alts Database to Default
|cff80ff00/rgalias request|r - Request Alts Database from group leader
|cff80ff00/rgalias send|r - Send Alts Database to group
|cff80ff00/rgalias add <name1> <alias>|r - Add alias
|cff80ff00/rgalias remove <name1>|r - Remove alias
|cff80ff00/rgalias enable <module>|r - Enable module
|cff80ff00/rgalias disable <module>|r - Disable module
|cff80ff00/rgalias status|r]])
	end
end

SLASH_RG_ALIAS1 = "/rgalias"
SlashCmdList["RG_ALIAS"] = handler


--[[
ElvUI: Added custom nameRG tags
Grid2: Added Rak Gaming Alias Status
ShadowedUF: Added Rak Gaming Alias tag
Blizzard: Hooked CompactUnitFrame_UpdateName
KHM: Replaced KHMRaidFrames.SetUpNameInternal
MRTNote: RegisterCallback for "Note_UpdateText" and update note text on that event
MRTCD: RegisterCallback for "RaidCooldowns_Bar_TextName" and update bar text on that event
Cell: Replaced Cell.funcs.GetNickname
WeakAuras: Replaced WeakAuras.GetName, WeakAuras.UnitName, WeakAuras.GetUnitName, WeakAuras.UnitFullName
RaidFrameSettings: Filled RaidFrameSettings.db.profile.Nicknames
]]
