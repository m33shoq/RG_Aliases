local addonName, addonTable = ...
local GMRT = _G.GMRT

if not GMRT then return end

local function RaidCooldowns_Bar_TextName(eventName,bar,gsub_data,barData)
	-- DevTool:AddData(barData)
    --actual name is barData.fullName or barData.name [w/o server]

	local barParent = bar.parent
	local name = barData.name
	local customName = RG_ALTS_DB[name] or name

	if barParent.textShowTargetName and barData.targetName then
		local time = (bar.curr_end or 0) - GetTime() + 1
		if time >=1 then
			customName = customName .. " > " .. barData.targetName
		end
	end
	if barData.specialAddText then
		customName = customName .. (barData.specialAddText() or "")
	end


	--local realm = barData.fullName:match("^.-%-(.-)$")
	if customName ~= gsub_data.name then
		gsub_data.name = customName
	end
end
addonTable.HookMRTCD = function()
	print("|cffee5555[Rak Gaming Aliases]|r MRT CD HOOKED")
	GMRT.F:RegisterCallback("RaidCooldowns_Bar_TextName", RaidCooldowns_Bar_TextName)
end


local function Note_UpdateText(eventName,noteFrame)
    local text = noteFrame.text:GetText()
	if not text then return end
	local words = {}
	for  colorCode, word in text:gmatch("|c(%x%x%x%x%x%x%x%x)(.-)|r") do -- match all color coded phrases
		if not words[word] then
			words[word] = {
				colorCode = colorCode,
				translatedWord = RG_ALTS_DB[word] or word
			}
		end
		if words[word].translatedWord ~= word then
			text = text:gsub("|c%x%x%x%x%x%x%x%x"..word.."|r", "|c"..words[word].colorCode..words[word].translatedWord.."|r")
		end
	end
	if text ~= noteFrame.text:GetText() then
   		noteFrame.text:SetText(text)
	end
end

addonTable.HookMRTNote = function()
	print("|cffee5555[Rak Gaming Aliases]|r MRT Note HOOKED")
	GMRT.F:RegisterCallback("Note_UpdateText", Note_UpdateText)
end