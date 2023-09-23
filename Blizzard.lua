local addonName, addonTable = ...
local precise = 0

local RG_UnitName = addonTable.RG_UnitName

local function UpdateNameOverride(self)
	local unit_name = RG_UnitName(self.displayedUnit)
	local old_name = self.name:GetText()
	if unit_name ~= old_name then
		self.name:SetText(unit_name)
	end
	return true
end

function addonTable.HookBlizzard()
	print("|cffee5555[Rak Gaming Aliases]|r Blizzard frames HOOKED")
	hooksecurefunc("CompactUnitFrame_UpdateName",function(frame)
		if frame and not frame.UpdateNameOverride and not frame:IsForbidden() then
			local frame_name = frame:GetName()
			
			if frame_name and
							(
							frame_name:find("^CompactRaidGroup%dMember%d")
							or frame_name:find("^CompactPartyFrameMember%d")
							-- or frame_name:find("^PartyMemberFrame%d")
							-- or frame_name:find("^CompactRaidFrame%d")
							)
							and
							frame.unit and frame.name
			then
				local m = frame_name and 
				(
				frame_name:match("^CompactRaidGroup%dMember%d")
				or frame_name:match("^CompactPartyFrameMember%d")
				-- or frame_name:match("^PartyMemberFrame%d")
				-- or frame_name:match("^CompactRaidFrame%d")
				)
				
				local unit_name = RG_UnitName(frame.unit)
				if unit_name then
					frame.name:SetText(unit_name)
				end
				frame.UpdateNameOverride = UpdateNameOverride
			end
		end
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