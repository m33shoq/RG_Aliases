local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

local module = AliasesNamespace:NewModule("unhaltedunitframes", {
	name = "Unhalted Unit Frames",
	desc = AliasesNamespace.L["Adds new tag for Unhalted Unit Frames: [RGNickName]"],
	addonName = "UnhaltedUnitFrames",
	alwaysEnabled = true,
})


if C_AddOns.IsAddOnLoadable(module.addonName) then
	EventUtil.ContinueOnAddOnLoaded(module.addonName, function()
		if not _G.UUFG then
			AliasesNamespace.debugPrint("Unhalted Unit Frames failt to find UUFG global")
			return
		end
		AliasesNamespace.debugPrint("Unhalted Unit Frames HOOKED")
		AliasesNamespace.hookedModules["unhaltedunitframes"] = true

		local RG_UnitName = AliasesNamespace.RG_UnitName

		UUFG:AddTag("RGNickName", "UNIT_NAME_UPDATE", RG_UnitName, "Name", "|cffee5555Rak Gaming Aliases|r Nickname")
	end)
end