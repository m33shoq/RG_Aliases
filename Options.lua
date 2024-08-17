local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

---@class ELib
local ELib = AliasesNamespace.lib

---@class MLib
local MLib = AliasesNamespace.MLib

---@class AliasesLocale
local L = setmetatable({}, {__index = function (t, k)
	t[k] = k
	return k
end})



function AliasesNamespace.ShowOptions()
	if not AliasesNamespace.OptionsInitialized then
		AliasesNamespace.OptionsInitialized = true
		AliasesNamespace.CreateOptions()
	end

	AliasesNamespace.Options:Show()
end
RGALIAS_MinimapClickFunction = AliasesNamespace.ShowOptions

function AliasesNamespace.CreateOptions()
	local OptionsFrame = ELib:Popup("Aliases Options"):Size(400, 300)
	AliasesNamespace.Options = OptionsFrame

	OptionsFrame.GUIDData = {}
	for i=1, GetNumGuildMembers() do
		local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class,
		 achievementPoints, achievementRank, isMobile, canSoR, repStanding, GUID = GetGuildRosterInfo(i)
		name = strsplit("-", name)
		OptionsFrame.GUIDData[name] = GUID
	end

	OptionsFrame.title:SetFont(OptionsFrame.title:GetFont(),14,"OUTLINE")
    OptionsFrame.title:SetPoint("TOP",OptionsFrame,"TOP",0,-5)

	ELib:DecorationLine(OptionsFrame,true,"BACKGROUND",4)
    :Point("TOPLEFT",OptionsFrame,"TOPLEFT",0,0)
    :Point("BOTTOMRIGHT",OptionsFrame,"TOPRIGHT",0,-25):SetVertexColor(0.13,0.13,0.13,0.3)--title background
	ELib:DecorationLine(OptionsFrame,true,"BACKGROUND",5)
    :Point("TOPLEFT",OptionsFrame,"TOPLEFT",0,-25)
    :Point("TOPRIGHT",OptionsFrame,"TOPRIGHT",0,-25)--line between title and frame
    -- ELib:DecorationLine(OptionsFrame,true,"BACKGROUND",5)
    -- :Point("TOPLEFT",OptionsFrame,"TOPLEFT",0,-90)
    -- :Point("TOPRIGHT",OptionsFrame,"TOPRIGHT",0,-90)--line between top part and lists

	-- ELib:DecorationLine(OptionsFrame,true,"BACKGROUND",4)
    -- :Point("TOPLEFT",OptionsFrame,"BOTTOMLEFT",0,34)
    -- :Point("BOTTOMRIGHT",OptionsFrame,"BOTTOMRIGHT",0,0):SetVertexColor(0.13,0.13,0.13,0.3)--save button background
	-- ELib:DecorationLine(OptionsFrame,true,"BACKGROUND",5)
    -- :Point("TOPLEFT",OptionsFrame,"BOTTOMLEFT",0,34)
    -- :Point("TOPRIGHT",OptionsFrame,"BOTTOMRIGHT",0,34)--line between send button and frame


	OptionsFrame.Close.NormalTexture:SetVertexColor(1,0,0,1)
	OptionsFrame.border:Hide()
	ELib:Border(OptionsFrame,1,.24,.25,.30,1,nil,3)


	local modulesTooltip =
[[Red addons are disabled,
green addons are enabled,
white addons are always enabled,
grey addons are not loaded.]]
	-- modules
	OptionsFrame.ModulesDropdown = ELib:DropDown(OptionsFrame, 200, -1):Point("TOPLEFT", OptionsFrame, "TOPLEFT", 10, -35):Size(200):SetText(L["Modules"]):Tooltip(modulesTooltip)

	function OptionsFrame.ModulesDropdown:SetValue(key)
		RG_ALTS_SETTINGS.settings[key] = not RG_ALTS_SETTINGS.settings[key]

		OptionsFrame.ModulesDropdown:PreUpdate()
		ELib.ScrollDropDown:Reload()

		StaticPopupDialogs["RGALIAS_RELOADUI"] = {
			text = L["Reload UI to apply changes?"],
			button1 = "Reload",
			button2 = "Cancel",
			OnAccept = ReloadUI,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		}
		StaticPopup_Show("RGALIAS_RELOADUI")
	end

	local icons = {
		cross = {"interface/lfgframe/uilfgprompts", {0.87939453125,0.97705078125,0.00048828125,0.09814453125}},
		check = {"interface/lfgframe/uilfgprompts", {0.85205078125,0.94970703125,0.12646484375,0.22412109375}},
		flag = {"interface/lfgframe/uilfgprompts", {0.12646484375,0.25146484375,0.62939453125,0.75439453125}},
		yellowcheck = {"interface/common/commonicons", {0.12646484375,0.25146484375,0.0009765625,0.2509765625}},
	}

	-- from TextureAtlasViewer/Data_Mainline.lua
	local raceIcons = {
		["raceicon128-bloodelf-female"] = {0.06396484375,0.12646484375,0.7626953125,0.8876953125},
		["raceicon128-bloodelf-male"] = {0.12744140625,0.18994140625,0.0009765625,0.1259765625},
		["raceicon128-darkirondwarf-female"] = {0.12744140625,0.18994140625,0.1279296875,0.2529296875},
		["raceicon128-darkirondwarf-male"] = {0.12744140625,0.18994140625,0.2548828125,0.3798828125},
		["raceicon128-dracthyr-female"] = {0.12744140625,0.18994140625,0.3818359375,0.5068359375},
		["raceicon128-dracthyr-male"] = {0.12744140625,0.18994140625,0.5087890625,0.6337890625},
		["raceicon128-dracthyrvisage-female"] = {0.12744140625,0.18994140625,0.6357421875,0.7607421875},
		["raceicon128-dracthyrvisage-male"] = {0.12744140625,0.18994140625,0.7626953125,0.8876953125},
		["raceicon128-draenei-female"] = {0.19091796875,0.25341796875,0.0009765625,0.1259765625},
		["raceicon128-draenei-male"] = {0.19091796875,0.25341796875,0.1279296875,0.2529296875},
		["raceicon128-dwarf-female"] = {0.19091796875,0.25341796875,0.2548828125,0.3798828125},
		["raceicon128-dwarf-male"] = {0.19091796875,0.25341796875,0.3818359375,0.5068359375},
		["raceicon128-earthen-female"] = {0.19091796875,0.25341796875,0.5087890625,0.6337890625},
		["raceicon128-earthen-male"] = {0.19091796875,0.25341796875,0.6357421875,0.7607421875},
		["raceicon128-gnome-female"] = {0.19091796875,0.25341796875,0.7626953125,0.8876953125},
		["raceicon128-gnome-male"] = {0.25439453125,0.31689453125,0.0009765625,0.1259765625},
		["raceicon128-goblin-female"] = {0.25439453125,0.31689453125,0.1279296875,0.2529296875},
		["raceicon128-goblin-male"] = {0.25439453125,0.31689453125,0.2548828125,0.3798828125},
		["raceicon128-highmountaintauren-female"] = {0.25439453125,0.31689453125,0.3818359375,0.5068359375},
		["raceicon128-highmountaintauren-male"] = {0.25439453125,0.31689453125,0.5087890625,0.6337890625},
		["raceicon128-human-female"] = {0.25439453125,0.31689453125,0.6357421875,0.7607421875},
		["raceicon128-human-male"] = {0.25439453125,0.31689453125,0.7626953125,0.8876953125},
		["raceicon128-kultiran-female"] = {0.31787109375,0.38037109375,0.0009765625,0.1259765625},
		["raceicon128-kultiran-male"] = {0.31787109375,0.38037109375,0.1279296875,0.2529296875},
		["raceicon128-lightforged-female"] = {0.31787109375,0.38037109375,0.2548828125,0.3798828125},
		["raceicon128-lightforged-male"] = {0.31787109375,0.38037109375,0.3818359375,0.5068359375},
		["raceicon128-magharorc-female"] = {0.31787109375,0.38037109375,0.5087890625,0.6337890625},
		["raceicon128-magharorc-male"] = {0.31787109375,0.38037109375,0.6357421875,0.7607421875},
		["raceicon128-mechagnome-female"] = {0.31787109375,0.38037109375,0.7626953125,0.8876953125},
		["raceicon128-mechagnome-male"] = {0.38134765625,0.44384765625,0.0009765625,0.1259765625},
		["raceicon128-nightborne-female"] = {0.38134765625,0.44384765625,0.1279296875,0.2529296875},
		["raceicon128-nightborne-male"] = {0.38134765625,0.44384765625,0.2548828125,0.3798828125},
		["raceicon128-nightelf-female"] = {0.38134765625,0.44384765625,0.3818359375,0.5068359375},
		["raceicon128-nightelf-male"] = {0.38134765625,0.44384765625,0.5087890625,0.6337890625},
		["raceicon128-orc-female"] = {0.38134765625,0.44384765625,0.6357421875,0.7607421875},
		["raceicon128-orc-male"] = {0.38134765625,0.44384765625,0.7626953125,0.8876953125},
		["raceicon128-pandaren-female"] = {0.44482421875,0.50732421875,0.0009765625,0.1259765625},
		["raceicon128-pandaren-male"] = {0.44482421875,0.50732421875,0.1279296875,0.2529296875},
		["raceicon128-tauren-female"] = {0.44482421875,0.50732421875,0.2548828125,0.3798828125},
		["raceicon128-tauren-male"] = {0.44482421875,0.50732421875,0.3818359375,0.5068359375},
		["raceicon128-troll-female"] = {0.44482421875,0.50732421875,0.5087890625,0.6337890625},
		["raceicon128-troll-male"] = {0.44482421875,0.50732421875,0.6357421875,0.7607421875},
		["raceicon128-undead-female"] = {0.44482421875,0.50732421875,0.7626953125,0.8876953125},
		["raceicon128-undead-male"] = {0.50830078125,0.57080078125,0.0009765625,0.1259765625},
		["raceicon128-visage-female"] = {0.57177734375,0.63427734375,0.0009765625,0.1259765625},
		["raceicon128-visage-male"] = {0.63525390625,0.69775390625,0.0009765625,0.1259765625},
		["raceicon128-voidelf-female"] = {0.69873046875,0.76123046875,0.0009765625,0.1259765625},
		["raceicon128-voidelf-male"] = {0.76220703125,0.82470703125,0.0009765625,0.1259765625},
		["raceicon128-vulpera-female"] = {0.82568359375,0.88818359375,0.0009765625,0.1259765625},
		["raceicon128-vulpera-male"] = {0.88916015625,0.95166015625,0.0009765625,0.1259765625},
		["raceicon128-worgen-female"] = {0.50830078125,0.57080078125,0.1279296875,0.2529296875},
		["raceicon128-worgen-male"] = {0.50830078125,0.57080078125,0.2548828125,0.3798828125},
		["raceicon128-zandalaritroll-female"] = {0.50830078125,0.57080078125,0.3818359375,0.5068359375},
		["raceicon128-zandalaritroll-male"] = {0.50830078125,0.57080078125,0.5087890625,0.6337890625},
	}

	function OptionsFrame.ModulesDropdown:PreUpdate()
		local List = self.List
		wipe(List)
		for moduleKey,moduleData in pairs(AliasesNamespace.modules) do

			local IsAddOnLoadable = C_AddOns.IsAddOnLoadable(moduleData.addonName, UnitName("player"))
			local isEnabled = RG_ALTS_SETTINGS.settings[moduleKey]
			local isHooked = AliasesNamespace.hookedModules[moduleKey]
			local icon = not IsAddOnLoadable and icons["flag"] or moduleData.alwaysEnabled and icons["yellowcheck"] or isEnabled and icons["check"] or icons["cross"]

			List[#List+1] = {
				text = moduleData.name .. (not IsAddOnLoadable and L["(not loaded)"] or ""),
				arg1 = moduleKey,
				func = not moduleData.alwaysEnabled and OptionsFrame.ModulesDropdown.SetValue,
				isTitle = not IsAddOnLoadable, -- usese color code "|cff888888"
				colorCode = not moduleData.alwaysEnabled and (IsAddOnLoadable and (isEnabled and "|cff00ff00" or "|cffff0000")),
				icon = icon[1],
				iconcoord = icon[2],
				tooltip = moduleData.desc .. (moduleData.alwaysEnabled and "\n" .. L["Always enabled"] or ""),
			}
			sort(List, function(a,b) return a.text < b.text end)
		end
	end


	-- alts_db with add/delete

	OptionsFrame.Characters = ELib:DropDown(OptionsFrame, 200, 15):Point("TOPLEFT", OptionsFrame.ModulesDropdown, "BOTTOMLEFT", 0, -10):Size(200):SetText(L["Characters"]):Tooltip("Select character to manage alts")

	function OptionsFrame.Characters.SetValue(_,alias)
		-- show a popup with edit box to add new alt for arg1
		StaticPopupDialogs["RGALIAS_ADD_NEW_CHARACTER"] = {
			text = "Enter new alt for " .. alias,
			button1 = "Add",
			button2 = "Cancel",
			hasEditBox = 1,
			OnAccept = function(self)
				local text = self.editBox:GetText():trim()
				if text and text ~= "" then
					RG_ALTS_DB[text] = alias
					if RGAPIDBc then
						RGAPIDBc[text] = alias
					end
				end
				OptionsFrame.Characters:PreUpdate()
				ELib.ScrollDropDown:Reload(2)
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		}
		StaticPopup_Show("RGALIAS_ADD_NEW_CHARACTER")
	end

	local addNew = {
		text = L["Add new character"],
		colorCode = "|cff00ff80",
		func = function ()
			StaticPopupDialogs["RGALIAS_ADD_NEW_CHARACTER"] = {
				text = "Enter character name",
				button1 = "Ready",
				button2 = "Cancel",
				hasEditBox = 1,
				OnAccept = function(self)
					local nick = self.editBox:GetText():trim()
					StaticPopupDialogs["RGALIAS_ADD_NEW_CHARACTER2"] = {
						text = "Enter alias for " .. nick,
						button1 = "Add",
						button2 = "Cancel",
						hasEditBox = 1,
						OnAccept = function(self)
							local alias = self.editBox:GetText():trim()
							if nick and nick ~= "" and alias and alias ~= "" then
								RG_ALTS_DB[nick] = alias
								if RGAPIDBc then
									RGAPIDBc[nick] = alias
								end
							end
							OptionsFrame.Characters:PreUpdate()
							ELib.ScrollDropDown:Reload()
						end,
						timeout = 0,
						whileDead = 1,
						hideOnEscape = 1,
					}
					StaticPopup_Show("RGALIAS_ADD_NEW_CHARACTER2")
				end,
				timeout = 0,
				whileDead = 1,
				hideOnEscape = 1,
			}
			StaticPopup_Show("RGALIAS_ADD_NEW_CHARACTER")
		end
	}

	function OptionsFrame.Characters.SubMenuSetValue(_,nick)
		if IsShiftKeyDown() then
			RG_ALTS_DB[nick] = nil
			if RGAPIDBc then
				RGAPIDBc[nick] = nil
			end
			OptionsFrame.Characters:PreUpdate()
			ELib.ScrollDropDown:Reload(2)
			ELib.ScrollDropDown:Reload(1)
		end
	end

	OptionsFrame.Characters.aliasToSubMenu = {}
	function OptionsFrame.Characters:PreUpdate()
		local List = self.List
		local aliasToSubMenu = self.aliasToSubMenu

		wipe(List)
		wipe(aliasToSubMenu)

		for character,alias in pairs(RG_ALTS_DB) do
			local aliasSubMenu = aliasToSubMenu[alias] or {}
			aliasToSubMenu[alias] = aliasSubMenu

			local guid = OptionsFrame.GUIDData[character]
			local colorCode, icon, iconcoord
			local text = character

			if guid then
				local _, class, _, race, sex, name, realmName = GetPlayerInfoByGUID(guid)
				-- print(format("guid: %q, class: %q, race: %q, sex: %q", guid or "---", class or "---", race or "---", sex or "---"))
				if class then
					local classColor = RAID_CLASS_COLORS[class]
					colorCode = ("|c%s"):format(classColor.colorStr)
					icon = "interface/glues/charactercreate/charactercreateicons"
					local coordKey = "raceicon128-" .. race:lower() .. "-" .. (sex == 3 and "female" or "male")
					iconcoord = raceIcons[coordKey]
				end
			end

			aliasSubMenu[#aliasSubMenu+1] = {
				text = text,
				arg1 = character,
				func = OptionsFrame.Characters.SubMenuSetValue,
				icon = icon,
				iconcoord = iconcoord,
				colorCode = colorCode,
				tooltip = "Shift click to delete this character",
			}
		end

		for alias,subMenu in pairs(aliasToSubMenu) do
			sort(subMenu, function(a,b) return a.text < b.text end)
			List[#List+1] = {
				text = alias,
				arg1 = alias,
				func = OptionsFrame.Characters.SetValue,
				subMenu = subMenu,
				tooltip = "Click to add new alt for " .. alias,
				icon = "interface/guildframe/communities",
				iconcoord = {0.2216796875,0.2529296875,0.880859375,0.943359375},
			}
		end
		sort(List, function(a,b) return a.text < b.text end)
		tinsert(List, 1, addNew)
	end

	OptionsFrame.Senders = ELib:DropDown(OptionsFrame, 200, 2):Point("TOPLEFT", OptionsFrame.Characters, "BOTTOMLEFT", 0, -5):Size(200):SetText(L["Senders"]):Tooltip(L["Select trusted sender to manage"])

	function OptionsFrame.Senders.SetValue(_, sender)
		RG_ALTS_SETTINGS.SyncPlayers[sender] = nil
		ELib:DropDownClose()
	end

	function OptionsFrame.Senders:PreUpdate()
		local List = self.List
		wipe(List)

		local alwaysAccept = {}
		local alwaysIgnore = {}
		for sender, value in pairs(RG_ALTS_SETTINGS.SyncPlayers) do
			local subMenu = value == 1 and alwaysAccept or alwaysIgnore
			subMenu[#subMenu+1] = {
				text = sender,
				arg1 = sender,
				func = OptionsFrame.Senders.SetValue,
				tooltip = format("Click to remove %s from %q", sender, (value == 1 and L["Always accept"] or L["Always ignore"])),
			}
		end

		sort(alwaysAccept, function(a,b) return a.text < b.text end)
		sort(alwaysIgnore, function(a,b) return a.text < b.text end)


		List[#List+1] = {
			text = L["Always accept"],
			subMenu = alwaysAccept,
			-- icon = "Interface\\AddOns\\".. GlobalAddonName .."\\media\\trusted_sender1.png",
			Lines = #alwaysAccept > 10 and 10 or #alwaysAccept,
		}
		List[#List+1] = {
			text = L["Always ignore"],
			subMenu = alwaysIgnore,
			-- icon = "Interface\\AddOns\\".. GlobalAddonName .."\\media\\trusted_sender2.png",
			Lines = #alwaysIgnore > 10 and 10 or #alwaysIgnore,
		}
	end


	-- send
	OptionsFrame.Send = MLib:Button(OptionsFrame,L["Send"]):Size(123,20):Point("BOTTOMLEFT", OptionsFrame, "BOTTOMLEFT", 10, 7):Tooltip("Send alts to raid/party"):OnClick(function(self)
		self:Disable()
		C_Timer.After(5, function()
			self:Enable()
		end)
		AliasesNamespace.SendAliasData(function (arg1, current, total)
			self:SetText(L["Sending"] .. " " .. current .. "/" .. total)
			if current == total then
				C_Timer.After(2, function()
					self:SetText(L["Send"])
				end)
			end
		end)
	end)

	-- request from leader
	OptionsFrame.Request = MLib:Button(OptionsFrame,L["Request"]):Size(123,20):Point("LEFT", OptionsFrame.Send, "RIGHT", 5, 0):Tooltip("Request alts from leader"):OnClick(function()
		AliasesNamespace.Request()
	end)

	-- reset
	OptionsFrame.Reset = MLib:Button(OptionsFrame,L["Reset"]):Size(123,20):Point("LEFT", OptionsFrame.Request, "RIGHT", 5, 0):Tooltip("Reset alts to default"):OnClick(function()
		StaticPopupDialogs["RGALIAS_RESET_ALTS_DB"] = {
			text = L["Reset alts to default?"],
			button1 = "Reset",
			button2 = "Cancel",
			OnAccept = function()
				AliasesNamespace.ResetRG_ALTS_DB()
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		}
		StaticPopup_Show("RGALIAS_RESET_ALTS_DB")
	end)

	-- import/export
	local function ImportOnUpdate(self, elapsed)
		self.tmr = self.tmr + elapsed
		if self.tmr >= 0.1 then
			self.tmr = 0
			self:SetScript("OnUpdate",nil)
			local str = table.concat(self.buff):trim()
			self.parent:Hide()

			self.buff = {}
			self.buffPos = 0

			if self.parent.ImportFunc then
				self.parent:ImportFunc(str)
			end
		end
	end

	local importWindow = ELib:Popup(L["Import"]):Size(650,100)
	importWindow.Edit = ELib:MultiEdit(importWindow):Point("TOP",0,-20):Size(640,75)
	importWindow:SetScript("OnHide",function(self)
		self.Edit:SetText("")
	end)
	importWindow:SetScript("OnShow",function(self)
		self.Edit.EditBox.buffPos = 0
		self.Edit.EditBox.tmr = 0
		self.Edit.EditBox.buff = {}
		self.Edit.EditBox:SetFocus()
	end)
	importWindow.Edit.EditBox:SetMaxBytes(1)
	importWindow.Edit.EditBox:SetScript("OnChar", function(self, c)
		self.buffPos = self.buffPos + 1
		self.buff[self.buffPos] = c
		self:SetScript("OnUpdate",ImportOnUpdate)
	end)
	importWindow.Edit.EditBox.parent = importWindow


	local exportWindow = ELib:Popup(L["Export"]):Size(650,50)
	exportWindow.Edit = ELib:Edit(exportWindow):Point("TOP",0,-20):Size(640,25)
	exportWindow:SetScript("OnHide",function(self)
		self.Edit:SetText("")
	end)
	exportWindow.Edit:SetScript("OnEditFocusGained", function(self)
		self:HighlightText()
	end)
	exportWindow.Edit:SetScript("OnMouseUp", function(self, button)
		self:HighlightText()
		if button == "RightButton" then
			self:GetParent():Hide()
		end
	end)
	exportWindow.Edit:SetScript("OnKeyUp", function(self, c)
		if (c == "c" or c == "C") and IsControlKeyDown() then
			self:GetParent():Hide()
		end
	end)
	function exportWindow:OnShow()
		self.Edit:SetFocus()
	end


	function importWindow:ImportFunc(str)
		if not str or #str < 50 then
			AliasesNamespace.print("Import string is too short, need at least 50 characters")
			return
		end

		AliasesNamespace.print("Importing alts from string")

		local def = AliasesNamespace.convertToTable(str)
		RG_ALTS_DB = def
		AliasesNamespace.UpdateDB()

		for k,v in pairs(def) do
			if RGAPIDBc then
				RGAPIDBc[k] = v
			end
		end

	end

	OptionsFrame.Import = MLib:Button(OptionsFrame,L["Import"]):Size(187,20):Point("BOTTOMLEFT", OptionsFrame, "BOTTOMLEFT", 10, 35):Tooltip("Import alts from string"):OnClick(function()
		importWindow:Show()
	end)

	OptionsFrame.Export = MLib:Button(OptionsFrame,L["Export"]):Size(188,20):Point("LEFT", OptionsFrame.Import, "RIGHT", 5, 0):Tooltip("Export alts to string"):OnClick(function()
		local lines = {}

		local NickToChars = {}
		for nick, alias in pairs(RG_ALTS_DB) do
			local chars = NickToChars[alias] or {}
			NickToChars[alias] = chars
			chars[nick] = true
		end

        for nick, chars in pairs(NickToChars) do
            local charNames = {}
            for name, _ in pairs(chars) do
                table.insert(charNames, name)
            end
            table.sort(charNames) -- Sort the character names
            local str = nick .. " - " .. table.concat(charNames, " ")
            table.insert(lines, str)
        end

        table.sort(lines) -- Sort the lines
        local str = table.concat(lines, "\n")


		exportWindow.Edit:SetText(str)
		exportWindow:Show()
	end)

	-- link to github readme
	local url = "https://github.com/WeakAuras/WeakAuras2"
	OptionsFrame.Github = ELib:Edit(OptionsFrame):Size(380,20):Point("BOTTOMLEFT", OptionsFrame, "BOTTOMLEFT", 10, 65):Text(url):OnChange(function(self)
		self:SetText(url)
	end)
	OptionsFrame.Github:SetScript("OnKeyDown", function(self, key)
		self:SetText(url)
		self:HighlightText()
		if key == "C" and IsControlKeyDown() then
			C_Timer.After(0.1, function()
				self:HighlightText(0,0)
				self:ClearFocus()
			end)
		end
	end)
	ELib:Text(OptionsFrame,L["Setup guide:"]):Point("BOTTOMLEFT",OptionsFrame.Github,"TOPLEFT",0,5):SetFont("Fonts\\FRIZQT__.TTF",12,"OUTLINE")

end