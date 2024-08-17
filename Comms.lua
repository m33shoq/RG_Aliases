local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

---@class ELib
local ELib = AliasesNamespace.lib

---@class MLib
local MLib = AliasesNamespace.MLib

local Comm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

------------------------------------------------------------------------
-- COMMS
------------------------------------------------------------------------

function AliasesNamespace.SendAliasData(callback, target)
	local chatType = target and "WHISPER" or IsInRaid() and "RAID" or IsInGroup() and "PARTY"
	if not chatType then
		return
	end
	local dataTable = {}
	for char, alias in pairs(RG_ALTS_DB) do
		dataTable[alias] = dataTable[alias] or {}
		tinsert(dataTable[alias], char)
	end

	local dataString = ""
	for alias, chars in pairs(dataTable) do
		dataString = dataString .. alias .. "^"
		for _,char in pairs(chars) do
			dataString = dataString .. char .. "^"
		end
		dataString = dataString:gsub("%^$","") .. "\n"
	end

	local compressed = LibDeflate:CompressDeflate(dataString,{level = 9})
	local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	if encoded then
		Comm:SendCommMessage("RGAliasD", encoded, chatType, target, "BULK", callback)
	end
end

Comm:RegisterComm("RGAliasD", function(prefix, message, distribution, sender)
	AliasesNamespace.popup:Popup(sender,function()
		local encoded = LibDeflate:DecodeForWoWAddonChannel(message)
		local decompressed = LibDeflate:DecompressDeflate(encoded)

		AliasesNamespace.print("Importing data from", sender)
		local data = {strsplit("\n",decompressed)}
		for i=1,#data do
			local alias, names = strsplit("^",data[i],2)
			if alias and names then
				local chars = {strsplit("^",names)}
				for j=1,#chars do
					RG_ALTS_DB[chars[j]] = alias
					AliasesNamespace.debugPrint("Importing", chars[j], "as", alias)
				end
			end
		end
	end)
end)

function AliasesNamespace.Request()
	local chatType = IsInRaid() and "RAID" or IsInGroup() and "PARTY"
	if not chatType then
		return
	end
	Comm:SendCommMessage("RGAliasR", "Request", chatType)
end

Comm:RegisterComm("RGAliasR", function(prefix, message, distribution, sender)
	if distribution == "RAID" or distribution == "PARTY" then
		-- only send data if player is group or raid leader
		if UnitIsGroupLeader('player') then
			AliasesNamespace.SendAliasData(nil, sender)
		end
	end
end)

do
	local queue = {}

	local frame = CreateFrame("Frame",nil,UIParent,BackdropTemplateMixin and "BackdropTemplate")
	AliasesNamespace.popup = frame

	function frame:NextQueue()
		frame:Hide()
		tremove(queue, 1)
		tremove(queue, 1)
		C_Timer.After(0.2,function()
			frame:PopupNext()
		end)
	end

	frame:Hide()
	frame:SetBackdrop({bgFile="Interface\\Addons\\" .. GlobalAddonName .."\\media\\White"})
	frame:SetBackdropColor(0.05,0.05,0.07,0.98)
	frame:SetSize(250,65)
	frame:SetPoint("RIGHT",UIParent,"CENTER",-200,0)
	frame:SetFrameStrata("DIALOG")
	frame:SetClampedToScreen(true)

	frame.border = ELib:Shadow(frame,20)

	frame.label = frame:CreateFontString(nil,"OVERLAY","GameFontWhiteSmall")
	frame.label:SetFont(frame.label:GetFont(),10,"")
	frame.label:SetPoint("TOP",0,-4)
	frame.label:SetTextColor(1,1,1,1)
	frame.label:SetText("|cffee5555Rak Gaming Aliases|r")

	frame.player = frame:CreateFontString(nil,"OVERLAY","GameFontWhiteSmall")
	frame.player:SetFont(frame.player:GetFont(),10,"")
	frame.player:SetPoint("TOP",0,-16)
	frame.player:SetTextColor(1,1,1,1)
	frame.player:SetText("MyName-MyRealm")

	local function OnUpdate_HoverCheck(self)
		if not frame:IsShown() then
			self:SetScript("OnUpdate",nil)
			self.subButton:Hide()
			return
		end
		local extraSpace = 10
		local x,y = GetCursorPosition()
		local rect1x,rect1y,rect1w,rect1h = self:GetScaledRect()
		local rect2x,rect2y,rect2w,rect2h = self.subButton:GetScaledRect()
		if not (x >= rect1x-extraSpace and x <= rect1x+rect1w+extraSpace and y >= rect1y-extraSpace and y <= rect1y+rect1h+extraSpace) and
			not (x >= rect2x-extraSpace and x <= rect2x+rect2w+extraSpace and y >= rect2y-extraSpace and y <= rect2y+rect2h+extraSpace) then
			self:SetScript("OnUpdate",nil)
			self.subButton:Hide()
		end
	end

	frame.b1 = ELib:Button(frame,DECLINE):Point("BOTTOMLEFT",5,5):Size(100,20):OnClick(function()
		frame:NextQueue()
	end):OnEnter(function(self)
		frame.b1always:Show()
		self:SetScript("OnUpdate",OnUpdate_HoverCheck)
	end)

	frame.b3 = ELib:Button(frame,ACCEPT):Point("BOTTOMRIGHT",-5,5):Size(100,20):OnClick(function()
		queue[2]()
		frame:NextQueue()
	end):OnEnter(function(self)
		frame.b3always:Show()
		self:SetScript("OnUpdate",OnUpdate_HoverCheck)
	end)

	frame.b1always = ELib:Button(frame,ALWAYS.." "..DECLINE):Point("TOPLEFT",frame.b1,"BOTTOMLEFT",0,-10):Size(140,20):OnClick(function()
		StaticPopupDialogs["RGALIAS_SYNC_PLAYER"] = {
            text = "Do you want to always |cffff0000decline|r nicknames from |cffff0000"..frame.playerRaw.."|r?",
            button1 = YES,
            button2 = NO,
            OnAccept = function()
                RG_ALTS_SETTINGS.SyncPlayers[frame.playerRaw] = -1
                frame:NextQueue()
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
            preferredIndex = 3,
        }
        StaticPopup_Show("RGALIAS_SYNC_PLAYER")
	end):Shown(false)
	frame.b3always = ELib:Button(frame,ALWAYS.." "..ACCEPT):Point("TOPRIGHT",frame.b3,"BOTTOMRIGHT",0,-10):Size(140,20):OnClick(function()
		StaticPopupDialogs["RGALIAS_SYNC_PLAYER"] = {
            text = "Do you want to always |cff00ff00accept|r nicknames from |cff00ff00"..frame.playerRaw.."|r?",
            button1 = YES,
            button2 = NO,
            OnAccept = function()
                RG_ALTS_SETTINGS.SyncPlayers[frame.playerRaw] = 1
                if type(queue[2]) == 'function' then
                    queue[2]()
                end
                frame:NextQueue()
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
            preferredIndex = 3,
        }
        StaticPopup_Show("RGALIAS_SYNC_PLAYER")
	end):Shown(false)

	frame.b1.subButton = frame.b1always
	frame.b3.subButton = frame.b3always

	for _,btn in pairs({frame.b1,frame.b1always,frame.b3,frame.b3always}) do
		btn.icon = btn:CreateTexture(nil,"ARTWORK")
		btn.icon:SetPoint("RIGHT",btn:GetTextObj(),"LEFT")
		btn.icon:SetSize(18,18)
		btn.icon:SetTexture("Interface\\AddOns\\" .. GlobalAddonName .. "\\media\\DiesalGUIcons16x256x128")
		btn.icon:SetTexCoord(0.125+(0.1875 - 0.125)*6,0.1875+(0.1875 - 0.125)*6,0.5,0.625)
		btn.icon:SetVertexColor(1,0,0,1)
	end

	frame.b3.icon:SetTexCoord(0.125+(0.1875 - 0.125)*7,0.1875+(0.1875 - 0.125)*7,0.5,0.625)
	frame.b3.icon:SetVertexColor(0,1,0,1)
	frame.b3always.icon:SetTexCoord(0.125+(0.1875 - 0.125)*7,0.1875+(0.1875 - 0.125)*7,0.5,0.625)
	frame.b3always.icon:SetVertexColor(0,1,0,1)

	function frame:PopupNext()
		-- if VMRT and VMRT.Reminder and VMRT.Reminder.disablePopups then
		-- 	return
		-- end
		local player = queue[1]
		if not player then
			return
		end
		if (player == AliasesNamespace.charKey or player == AliasesNamespace.charName) and false then -- test
			queue[2]()
			frame:NextQueue()
			return
		elseif RG_ALTS_SETTINGS.SyncPlayers[player] == -1 then
            AliasesNamespace.print(format("|cffff0000%s trying to send nicknames(always ignored)",player))
			frame:NextQueue()
			return
		elseif RG_ALTS_SETTINGS.SyncPlayers[player] == 1 then
			queue[2]()
			frame:NextQueue()
			return
		end
		frame.playerRaw = player
		frame.player:SetText(player)
		frame:Show()
	end

	function frame:Popup(player,func)
		queue[#queue+1] = player
		queue[#queue+1] = func

		frame:PopupNext()
	end
end
	--C_Timer.After(2,function() frame:Popup("Myself",function()end) end)