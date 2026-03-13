local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

AliasesNamespace:NewModule("blizzard", {
	name = "Blizzard Raid Frames",
	desc = AliasesNamespace.L["Changes names on Blizzard Raid Frames"],
	addonName = "Blizzard_CompactRaidFrames"
})

local RG_UnitName = AliasesNamespace.RG_UnitName

-- Thanks KHM
local function IterateCompactFrames(groupType)
    local index = 0
    local groupIndex = 1
    local frame, doneRaid, doneParty, doneOldStyle

    if groupType then
        if groupType == "raid" then
            doneParty = true
        else
            doneRaid = true
        end
    end

    return function()
        while not doneRaid do
            index = index + 1

            if index > 5 then
                index = 1
                groupIndex = groupIndex + 1
            end

            frame = _G["CompactRaidGroup"..groupIndex.."Member"..index]

            if frame then
                return frame
            else
                if groupIndex >= 8 then
                    doneRaid = true
                    index = 0
                    break
                end
            end
        end

        while not doneParty do
            index = index + 1

            frame = _G["CompactPartyFrameMember"..index]

            if frame then
                return frame
            else
                index = 0
                doneParty = true
                break
            end
        end

        while not doneOldStyle do
            index = index + 1

            frame = _G["CompactRaidFrame"..index]

            if frame then
                return frame
            else
                doneOldStyle = true
                break
            end
        end
    end
end


local function UpdateNameOverride(self)
	local unit_name = RG_UnitName(self.displayedUnit)
	self.name:SetText(unit_name)
	return true
end

local MODULE_DISABLED = false
function AliasesNamespace:DisableBlizzardHook()
	MODULE_DISABLED = true
	AliasesNamespace.debugPrint("Blizzard frames UNHOOKED")
end

local function CUF_UpdateNameHook(frame)
	if not MODULE_DISABLED and frame and not frame:IsForbidden() then
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
		if MODULE_DISABLED then
			AliasesNamespace.debugPrint("Blizzard frames HOOKED but module is disabled, not applying hooks")
			return
		end

		hooksecurefunc("CompactUnitFrame_UpdateName", CUF_UpdateNameHook)
		local function fullUpdate()
			for frame in IterateCompactFrames() do
				if frame.unit then
					CUF_UpdateNameHook(frame)
				end
			end
		end

		fullUpdate()
		AliasesNamespace.RegisterCallback("DbUpdated", function()
			if not MODULE_DISABLED then
				fullUpdate()
			end
		end)
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