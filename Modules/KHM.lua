local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

AliasesNamespace:NewModule("khm", {
	name = "KHM Raid Frames",
	desc = AliasesNamespace.L["Changes names on KHM Raid Frames"],
	addonName = "KHMRaidFrames",
})

local function hookKHM()
	local KHMRaidFrames = LibStub("AceAddon-3.0"):GetAddon("KHMRaidFrames")
	local RG_UnitName = AliasesNamespace.RG_UnitName
	AliasesNamespace.debugPrint("KHM HOOKED")
	AliasesNamespace.hookedModules["khm"] = true
	function KHMRaidFrames.SetUpNameInternal(frame, groupType)
		if not frame.name then return end

		local db = KHMRaidFrames.db.profile[groupType].nameAndIcons.name

		if not db.enabled then
			return
		end

		if not frame.unit then return end
		if not UnitExists(frame.displayedUnit) then return end
		if not ShouldShowName(frame) then return end

		local name = frame.name

		local _name

		if db.showServer then-- change here to catch either RG_UnitName or GetUnitName
			_name = RG_UnitName(frame.unit) or GetUnitName(frame.unit, true)
		else
			_name = RG_UnitName(frame.unit) or GetUnitName(frame.unit, false)
			-- _name = _name and _name:gsub("%p", "") or _name
		end

		local oldName = name:GetText()
		if _name ~= nil and _name:len() > 0 and _name ~= "" and (oldName ~= _name) then
			name:SetText(_name)
		end

		if db.classColoredNames then
			local classColor = KHMRaidFrames.ColorByClass(frame.unit)

			if classColor then
				name:SetTextColor(classColor.r, classColor.g, classColor.b)
			end
		else
			if KHMRaidFrames.CompactUnitFrame_IsTapDenied(frame) then
				name:SetVertexColor(0.5, 0.5, 0.5)
			else
				name:SetVertexColor(1.0, 1.0, 1.0)
			end
		end
	end
end

function AliasesNamespace.HookKHM()
	if C_AddOns.IsAddOnLoadable("KHMRaidFrames") then
		EventUtil.ContinueOnAddOnLoaded("KHMRaidFrames", hookKHM)
	end
end
