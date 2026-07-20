local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

local module = AliasesNamespace:NewModule("ellesmereui", {
	name = "EllesmereUI",
	desc = AliasesNamespace.L["Changes names on EllesmereUI frames"],
	addonName = "EllesmereUI",
	noReload = true,
})

-- hook logic is handled inside EllesmereUIRaidFrames/EllesmereUIRaidFrames.lua, this file is required to expose setting