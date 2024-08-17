local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

---@class AliasesLocale
local L = setmetatable({}, {__index = function (t, k)
	t[k] = k
	return k
end})

---@class AliasesLocale
AliasesNamespace.L = L

L["Modules"] = "Modules"
L["Reload UI to apply changes?"] = "Reload UI to apply changes?"
L["(not loaded)"] = "(not loaded)"
L["Always enabled"] = "Always enabled"
L["Characters"] = "Characters"
L["Add new character"] = "Add new character"
L["Senders"] = "Senders"
L["Add new sender"] = "Add new sender"
L["Always accept"] = "Always accept"
L["Always ignore"] = "Always ignore"
L["Send"] = "Send"
L["Request"] = "Request"
L["Reset"] = "Reset"
L["Reset alts"] = "Reset alts"
L["Import"] = "Import"
L["Export"] = "Export"
L["Setup guide:"] = "Setup guide:"
L[ [=[Red addons are disabled,
green addons are enabled,
white addons are always enabled,
grey addons are not loaded.]=] ] =
[=[Red addons are disabled,
green addons are enabled,
white addons are always enabled,
grey addons are not loaded.]=]
L["Click to remove %s from %q"] = "Click to remove %s from %q"
L["Click to add new alt for"] = "Click to add new alt for"
L["Shift click to delete this character"] = "Shift click to delete this character"
L["Request alts from leader"] = "Request alts from leader"
L["Send alts to raid/party"] = "Send alts to raid/party"
L["Changes names on Blizzard Raid Frames"] = "Changes names on Blizzard Raid Frames"
L["Changes names on Cell frames"] = "Changes names on Cell frames"
L["Adds new tags to ElvUI"] = "Adds new tags to ElvUI"
L["Adds new status to Grid2"] = "Adds new status to Grid2"
L["Changes names on KHM Raid Frames"] = "Changes names on KHM Raid Frames"
L["Changes names in MRT Note on screen(not in MRT Options)"] = "Changes names in MRT Note on screen(not in MRT Options)"
L["Changes names on MRT Cooldown bars/icons"] = "Changes names on MRT Cooldown bars/icons"
L["Adds custom tags to Shadowed Unit Frames"] = "Adds custom tags to Shadowed Unit Frames"
L["Changes names on ShestakUI frames"] = "Changes names on ShestakUI frames"
