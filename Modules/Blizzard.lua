local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

AliasesNamespace:NewModule("blizzard", {
	name = "Blizzard Raid Frames",
	desc = AliasesNamespace.L["Changes names on Blizzard Raid Frames"],
	addonName = "Blizzard_CompactRaidFrames"
})

local RG_UnitName = AliasesNamespace.RG_UnitName

local function IsValidFrame(frame)
    if not frame or (frame.IsForbidden and frame:IsForbidden()) then return false end

    local name = frame:GetName()
    local unit = frame.unit or frame.displayedUnit

    -- 1. Block by Frame Name Patterns
    if name and (string.find(name, "NamePlate") or string.find(name, "ClassNameplate")) then
        return false
    end

    -- 2. Block by Parent Name Patterns
    local parent = frame:GetParent()
    if parent then
        local pName = parent:GetName()
        if pName and (string.find(pName, "NamePlate") or string.find(pName, "ClassNameplate")) then
            return false
        end
    end

    -- 3. Block by Unit ID
    if unit and string.find(string.lower(unit), "nameplate") then
        return false
    end

    -- 4. Whitelist Check (The most secure method)
    -- Only allow known CompactRaid/Party frames.
    -- If we are in EditMode, we might need to be more lenient, but for normal play:
    if name and (string.find(name, "CompactRaidFrame") or string.find(name, "CompactPartyFrame")) then
        return true
    end

    -- If frame has no name or doesn't match our whitelist, assume it's unsafe (likely a nameplate or other compact frame usage)
    return false
end

-- Utility to iterate over all active compact frames (Party/Raid)
local function IterateCompactFrames(callback)
    local processed = {}

    local function tryProcess(frame)
        if type(frame) ~= "table" or not frame.IsVisible or not frame:IsVisible() then return end
        if frame.IsForbidden and frame:IsForbidden() then return end

        -- Critical Check: IsValidFrame
        if not IsValidFrame(frame) then return end

        if not frame.healthBar or not frame.optionTable then return end
        if processed[frame] then return end

        if (frame.unit) or (EditModeManagerFrame and EditModeManagerFrame:IsShown()) then
            callback(frame)
            processed[frame] = true
        end
    end

    -- CompactRaidFrameContainer iteration (modern raid frames)
    if CompactRaidFrameContainer and CompactRaidFrameContainer.flowFrames then
        for _, frame in pairs(CompactRaidFrameContainer.flowFrames) do tryProcess(frame) end
    end
    if CompactRaidFrameContainer then
        local children = {CompactRaidFrameContainer:GetChildren()}
        for _, child in ipairs(children) do
            tryProcess(child)
            if child.GetChildren then
                 local members = {child:GetChildren()}
                 for _, member in ipairs(members) do tryProcess(member) end
            end
        end
    end

    -- CompactPartyFrame iteration
    for i = 1, 5 do tryProcess(_G["CompactPartyFrameMember" .. i]) end

    -- Legacy/Explicit Raid Frame iteration
    if CompactRaidFrame1 and CompactRaidFrame1:IsVisible() then
         local i = 1
         while _G["CompactRaidFrame"..i] do
            tryProcess(_G["CompactRaidFrame"..i])
            i = i + 1
         end
    end
end


local function UpdateNameOverride(self)
	local unit_name = RG_UnitName(self.displayedUnit)
	self.name:SetText(unit_name)
	return true
end

local function CUF_UpdateNameHook(frame)
	if frame and not frame:IsForbidden() then
		local frame_name = frame:GetName()

		if frame_name and
			(
			frame_name:find("^CompactRaidGroup%dMember%d") or
			frame_name:find("^CompactPartyFrameMember%d") or
			frame_name:find("^CompactRaidFrame%d") or
			frame_name:find("^PartyMemberFrame%d")
			)
		then
			local unit_name = RG_UnitName(frame.unit)
			if unit_name then
				frame.name:SetText(unit_name)
			end
		end
	end
end

function AliasesNamespace.HookBlizzard()
	-- Delay to ensure UF addons that use Blizzard frames already loaded
	C_Timer.After(2, function()
		AliasesNamespace.debugPrint("Blizzard frames HOOKED")
		AliasesNamespace.hookedModules["blizzard"] = true

		hooksecurefunc("CompactUnitFrame_UpdateName", CUF_UpdateNameHook)
		IterateCompactFrames(CUF_UpdateNameHook)
	end)
end

--[[
blizzard code https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/CompactUnitFrame.lua

function CompactUnitFrame_UpdateName(frame)
	if frame.UpdateNameOverride and frame:UpdateNameOverride() then
		return;
	end

	if ( not ShouldShowName(frame) ) then
		frame.name:Hide();
	else
		local name = GetUnitName(frame.unit, true);
		if ( C_Commentator.IsSpectating() and name ) then
			local overrideName = C_Commentator.GetPlayerOverrideName(name);
			if overrideName then
				name = overrideName;
			end
		end

		frame.name:SetText(name);

		if ( CompactUnitFrame_IsTapDenied(frame) or (UnitIsDead(frame.unit) and not UnitIsPlayer(frame.unit)) ) then
			-- Use grey if not a player and can't get tap on unit
			frame.name:SetVertexColor(0.5, 0.5, 0.5);
		elseif ( frame.optionTable.colorNameBySelection ) then
			if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit)  and not UnitIsFriend("player", frame.unit)  ) then
				frame.name:SetVertexColor(1.0, 0.0, 0.0);
			else
				frame.name:SetVertexColor(UnitSelectionColor(frame.unit, frame.optionTable.colorNameWithExtendedColors));
			end
		else
			frame.name:SetVertexColor(1.0, 1.0, 1.0);
		end

		frame.name:Show();
	end
end

]]