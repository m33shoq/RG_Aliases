local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

local module = AliasesNamespace:NewModule("mshframes", {
	name = "mshFrames",
	desc = AliasesNamespace.L["Changes names on mshFrames"],
	addonName = "mshFrames",
})

function AliasesNamespace.HookMshFrames()
	if C_AddOns.IsAddOnLoadable(module.addonName) then
		EventUtil.ContinueOnAddOnLoaded(module.addonName, function()

			AliasesNamespace.debugPrint("mshFrames HOOKED")
			AliasesNamespace.hookedModules["mshframes"] = true

			local msh = LibStub("AceAddon-3.0"):GetAddon("mshFrames")

			local RG_UnitName = AliasesNamespace.RG_UnitName

			local function utf8sub(str, start, numChars)
				local startIndex = min(1, start)
				local currentIndex = 1
				local numSubstr = 0
				while currentIndex <= #str and numSubstr < numChars do
					local char = string.byte(str, currentIndex)
					if char > 240 then
						currentIndex = currentIndex + 4
					elseif char > 225 then
						currentIndex = currentIndex + 3
					elseif char > 192 then
						currentIndex = currentIndex + 2
					else
						currentIndex = currentIndex + 1
					end
					numSubstr = numSubstr + 1
				end
				return str:sub(startIndex, currentIndex - 1)
			end

			function msh.GetShortName(unit, maxChars)
				if not unit or not UnitExists(unit) then return "" end
				local name = RG_UnitName(unit)
				if not name then return "" end

				local success, length = pcall(function() return #name end)

				if not success then
					return name
				end

				if maxChars and maxChars > 0 and length > maxChars then
					return utf8sub(name, 1, maxChars)
				end

				return name
			end

		end)
	end
end