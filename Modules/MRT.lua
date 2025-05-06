local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

AliasesNamespace:NewModule("mrtnote", {
	name = "MRT Note",
	desc = AliasesNamespace.L["Changes names in MRT Note on screen(not in MRT Options)"],
	addonName = "MRT"
})

AliasesNamespace:NewModule("mrtcd", {
	name = "MRT Cooldowns",
	desc = AliasesNamespace.L["Changes names on MRT Cooldown bars/icons"],
	addonName = "MRT"
})

local function RaidCooldowns_Bar_TextName(eventName,bar,gsub_data,barData)
	-- DevTool:AddData(barData)
    --actual name is barData.fullName or barData.name [w/o server]

	local barParent = bar.parent
	local name = barData.name
	local customName = RG_ALTS_DB[name] or name

	if barParent.textShowTargetName and barData.targetName then
		local targetName = RG_ALTS_DB[strsplit("-",barData.targetName)] or barData.targetName
		local time = (bar.curr_end or 0) - GetTime() + 1
		if barParent.methodsTextIgnoreActive then
			time = (bar.curr_end_cd or 0) - GetTime() + 1
		end
		if time >=1 then
			customName = customName .. " > " .. targetName
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

local SEP = " ,\n\r:%{%}%(%)%+%[%]\"%@%!%$%_%#%&"
local PAT_SEP =  "[" .. SEP .. "]"
local PAT_SEP_INVERSE = "[^" .. SEP .. "]+"
local PAT_SEP_CAPTURE = "(" .. PAT_SEP .. ")"

local function Note_UpdateText(eventName,noteFrame)
    local text = noteFrame.text:GetText()
	if not text then return end
	local words = {}
	for w in text:gmatch(PAT_SEP_INVERSE) do -- match all separate words
		local colorCode = w:match("|c(%x%x%x%x%x%x%x%x)")
		local word = w:gsub("||", "|"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|", "")
		if RG_ALTS_DB[word] and not words[w] then
			words[w] = true
			if not colorCode then
				local class = UnitClassBase(word)
				if class then
					colorCode = RAID_CLASS_COLORS[class].colorStr
				end
			end
			text = text:gsub(w, colorCode and ("|c" .. colorCode  .. RG_ALTS_DB[word] .. "|r") or RG_ALTS_DB[word])
		end
	end
	if text ~= noteFrame.text:GetText() then
   		noteFrame.text:SetText(text)
	end
end

AliasesNamespace.HookMRTCD = function()
	AliasesNamespace.debugPrint("MRT CD HOOKED")
	AliasesNamespace.hookedModules["mrtcd"] = true
	if C_AddOns.IsAddOnLoadable("MRT") then
		EventUtil.ContinueOnAddOnLoaded("MRT", function ()
			GMRT.F:RegisterCallback("RaidCooldowns_Bar_TextName", RaidCooldowns_Bar_TextName)
		end)
	end
end

AliasesNamespace.HookMRTNote = function()
	AliasesNamespace.debugPrint("MRT Note HOOKED")
	AliasesNamespace.hookedModules["mrtnote"] = true
	if C_AddOns.IsAddOnLoadable("MRT") then
		EventUtil.ContinueOnAddOnLoaded("MRT", function()
			GMRT.F:RegisterCallback("Note_UpdateText", Note_UpdateText)
			GMRT.A.Note.frame:UpdateText()
		end)
	end
end