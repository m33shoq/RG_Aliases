local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

AliasesNamespace:NewModule("elvui", {
	name = "ElvUI",
	desc = "Adds new tags to ElvUI",
	addonName = "ElvUI",
	alwaysEnabled = true,
})

local function hookElvUI()
	local ElvUI = _G.ElvUI
	if not ElvUI then
		return
	end
	AliasesNamespace.debugPrint("ElvUI TAGS LOADED")
	AliasesNamespace.hookedModules["elvui"] = true
	local E, L = unpack(ElvUI)

	local Translit = E.Libs.Translit
	local translitMark = '!'

	local utf8lower, utf8sub, utf8len = string.utf8lower, string.utf8sub, string.utf8len

	local RG_UnitName = AliasesNamespace.RG_UnitName

	------------------------------------------------------------------------
	--	Tag Functions
	------------------------------------------------------------------------

	local function UnitName(unit)
		local name, realm = RG_UnitName(unit)

		if name == UNKNOWN and E.myclass == 'MONK' and UnitIsUnit(unit, 'pet') then
			name = format(UNITNAME_SUMMON_TITLE17, RG_UnitName('player'))
		end

		if realm and realm ~= '' then
			return name, realm
		else
			return name
		end
	end
	-- E.TagFunctions.UnitName = UnitName

	local function Abbrev(name)
		local letters, lastWord = '', strmatch(name, '.+%s(.+)$')
		if lastWord then
			for word in gmatch(name, '.-%s') do
				local firstLetter = utf8sub(gsub(word, '^[%s%p]*', ''), 1, 1)
				if firstLetter ~= utf8lower(firstLetter) then
					letters = format('%s%s. ', letters, firstLetter)
				end
			end
			name = format('%s%s', letters, lastWord)
		end
		return name
	end
	E.TagFunctions.Abbrev = Abbrev

	------------------------------------------------------------------------
	--	New Rak Gaming Name Tags
	------------------------------------------------------------------------

	E:AddTag("nameRG", "UNIT_NAME_UPDATE", function(unit)
		return UnitName(unit)
	end)

	for textFormat, length in pairs({ veryshort = 5, short = 10, medium = 15, long = 20 }) do
		E:AddTag(format('health:deficit-percent:nameRG-%s', textFormat), 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE', function(unit)
			local cur, max = UnitHealth(unit), UnitHealthMax(unit)
			local deficit = max - cur

			if deficit > 0 and cur > 0 then
				return _TAGS['health:deficit-percent:nostatus'](unit)
			else
				return _TAGS[format('nameRG:%s', textFormat)](unit)
			end
		end)

		E:AddTag(format('nameRG:abbrev:%s', textFormat), 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
			local name = UnitName(unit)
			if name and strfind(name, '%s') then
				name = Abbrev(name)
			end

			if name then
				return E:ShortenString(name, length)
			end
		end)

		E:AddTag(format('nameRG:%s', textFormat), 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
			local name = UnitName(unit)
			if name then
				return E:ShortenString(name, length)
			end
		end)

		E:AddTag(format('nameRG:%s:status', textFormat), 'UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_HEALTH INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
			local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
			local name = UnitName(unit)
			if status then
				return status
			elseif name then
				return E:ShortenString(name, length)
			end
		end)

		E:AddTag(format('nameRG:%s:translit', textFormat), 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
			local name = Translit:Transliterate(UnitName(unit), translitMark)
			if name then
				return E:ShortenString(name, length)
			end
		end)

		E:AddTag(format('targetRG:%s', textFormat), 'UNIT_TARGET', function(unit)
			local targetName = UnitName(unit..'target')
			if targetName then
				return E:ShortenString(targetName, length)
			end
		end)

		E:AddTag(format('targetRG:%s:translit', textFormat), 'UNIT_TARGET', function(unit)
			local targetName = Translit:Transliterate(UnitName(unit..'target'), translitMark)
			if targetName then
				return E:ShortenString(targetName, length)
			end
		end)
	end



	E:AddTag('nameRG:abbrev', 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local name = UnitName(unit)
		if name and strfind(name, '%s') then
			name = Abbrev(name)
		end

		return name
	end)

	E:AddTag('nameRG:last', 'UNIT_NAME_UPDATE INSTANCE_ENCOUNTER_ENGAGE_UNIT', function(unit)
		local name = UnitName(unit)
		if name and strfind(name, '%s') then
			name = strmatch(name, '([%S]+)$')
		end

		return name
	end)

	do
		local function NameHealthColor(tags,hex,unit,default)
			if hex == 'class' or hex == 'reaction' then
				return tags.classcolor(unit) or default
			elseif hex and strmatch(hex, '^%x%x%x%x%x%x$') then
				return '|cFF'..hex
			end

			return default
		end
		E.TagFunctions.NameHealthColor = NameHealthColor

		-- the third arg here is added from the user as like [name:health{ff00ff:00ff00}] or [name:health{class:00ff00}]
		E:AddTag('nameRG:health', 'UNIT_NAME_UPDATE UNIT_FACTION UNIT_HEALTH UNIT_MAXHEALTH', function(unit, _, args)
			local name = UnitName(unit)
			if not name then return '' end

			local min, max, bco, fco = UnitHealth(unit), UnitHealthMax(unit), strsplit(':', args or '')
			local to = ceil(utf8len(name) * (min / max))

			local fill = NameHealthColor(_TAGS, fco, unit, '|cFFff3333')
			local base = NameHealthColor(_TAGS, bco, unit, '|cFFffffff')

			return to > 0 and (base..utf8sub(name, 0, to)..fill..utf8sub(name, to+1, -1)) or fill..name
		end)
	end

	--[[
		this is all new ElvUI tags:
			[health:deficit-percent:nameRG-long]
			[health:deficit-percent:nameRG-medium]
			[health:deficit-percent:nameRG-short]
			[health:deficit-percent:nameRG-veryshort]
			[nameRG:abbrev:long]
			[nameRG:abbrev:medium]
			[nameRG:abbrev:short]
			[nameRG:abbrev:veryshort]
			[nameRG:abbrev]
			[nameRG:health]
			[nameRG:last]
			[nameRG:long:status]
			[nameRG:long:translit]
			[nameRG:long]
			[nameRG:medium:status]
			[nameRG:medium:translit]
			[nameRG:medium]
			[nameRG:short:status]
			[nameRG:short:translit]
			[nameRG:short]
			[nameRG:veryshort:status]
			[nameRG:veryshort:translit]
			[nameRG:veryshort]
			[nameRG]
			[targetRG:long:translit]
			[targetRG:long]
			[targetRG:medium:translit]
			[targetRG:medium]
			[targetRG:short:translit]
			[targetRG:short]
			[targetRG:veryshort:translit]
			[targetRG:veryshort]
	]]

	E:AddTagInfo('nameRG:abbrev:long', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit with abbreviation (limited to 20 letters)")
	E:AddTagInfo('nameRG:abbrev:medium', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit with abbreviation (limited to 15 letters)")
	E:AddTagInfo('nameRG:abbrev:short', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit with abbreviation (limited to 10 letters)")
	E:AddTagInfo('nameRG:abbrev:veryshort', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit with abbreviation (limited to 5 letters)")
	E:AddTagInfo('nameRG:abbrev', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit with abbreviation (e.g. 'Shadowfury Witch Doctor' becomes 'S. W. Doctor')")
	E:AddTagInfo('nameRG:health', '|cffee5555Rak Gaming Names|r', "", nil, true)
	E:AddTagInfo('nameRG:last', '|cffee5555Rak Gaming Names|r', "Displays the last word of the unit's name")
	E:AddTagInfo('nameRG:long:status', '|cffee5555Rak Gaming Names|r', "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 20 letters)")
	E:AddTagInfo('nameRG:long:translit', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit with transliteration for cyrillic letters (limited to 20 letters)")
	E:AddTagInfo('nameRG:long', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit (limited to 20 letters)")
	E:AddTagInfo('nameRG:medium:status', '|cffee5555Rak Gaming Names|r', "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 15 letters)")
	E:AddTagInfo('nameRG:medium:translit', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit with transliteration for cyrillic letters (limited to 15 letters)")
	E:AddTagInfo('nameRG:medium', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit (limited to 15 letters)")
	E:AddTagInfo('nameRG:short:status', '|cffee5555Rak Gaming Names|r', "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 10 letters)")
	E:AddTagInfo('nameRG:short:translit', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit with transliteration for cyrillic letters (limited to 10 letters)")
	E:AddTagInfo('nameRG:short', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit (limited to 10 letters)")
	E:AddTagInfo('nameRG:veryshort:status', '|cffee5555Rak Gaming Names|r', "Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 5 letters)")
	E:AddTagInfo('nameRG:veryshort:translit', 'Rak Gaming Names', "Displays the name of the unit with transliteration for cyrillic letters (limited to 5 letters)")
	E:AddTagInfo('nameRG:veryshort', '|cffee5555Rak Gaming Names|r', "Displays the name of the unit (limited to 5 letters)")
	E:AddTagInfo('nameRG', '|cffee5555Rak Gaming Names|r', "Displays the full name of the unit without any letter limitation")


	E:AddTagInfo('targetRG:long:translit', '|cffee5555Rak Gaming Target|r', "Displays the current target of the unit with transliteration for cyrillic letters (limited to 20 letters)")
	E:AddTagInfo('targetRG:long', '|cffee5555Rak Gaming Target|r', "Displays the current target of the unit (limited to 20 letters)")
	E:AddTagInfo('targetRG:medium:translit', '|cffee5555Rak Gaming Target|r', "Displays the current target of the unit with transliteration for cyrillic letters (limited to 15 letters)")
	E:AddTagInfo('targetRG:medium', '|cffee5555Rak Gaming Target|r', "Displays the current target of the unit (limited to 15 letters)")
	E:AddTagInfo('targetRG:short:translit', '|cffee5555Rak Gaming Target|r', "Displays the current target of the unit with transliteration for cyrillic letters (limited to 10 letters)")
	E:AddTagInfo('targetRG:short', '|cffee5555Rak Gaming Target|r', "Displays the current target of the unit (limited to 10 letters)")
	E:AddTagInfo('targetRG:veryshort:translit', '|cffee5555Rak Gaming Target|r', "Displays the current target of the unit with transliteration for cyrillic letters (limited to 5 letters)")
	E:AddTagInfo('targetRG:veryshort', '|cffee5555Rak Gaming Target|r', "Displays the current target of the unit (limited to 5 letters)")
	E:AddTagInfo('targetRG', '|cffee5555Rak Gaming Target|r', "Displays the current target of the unit")
	E:AddTagInfo('targetRG:translit', '|cffee5555Rak Gaming Target|r', "Displays the current target of the unit with transliteration for cyrillic letters")


	E:AddTagInfo('health:deficit-percent:nameRG-long', '|cffee5555Rak Gaming Health|r', "Displays the health deficit as a percentage and the name of the unit (limited to 20 letters)")
	E:AddTagInfo('health:deficit-percent:nameRG-medium', '|cffee5555Rak Gaming Health|r', "Displays the health deficit as a percentage and the name of the unit (limited to 15 letters)")
	E:AddTagInfo('health:deficit-percent:nameRG-short', '|cffee5555Rak Gaming Health|r', "Displays the health deficit as a percentage and the name of the unit (limited to 10 letters)")
	E:AddTagInfo('health:deficit-percent:nameRG-veryshort', '|cffee5555Rak Gaming Health|r', "Displays the health deficit as a percentage and the name of the unit (limited to 5 letters)")
end

function AliasesNamespace.AddElvUITags()
	if C_AddOns.IsAddOnLoadable("ElvUI") then
		EventUtil.ContinueOnAddOnLoaded("ElvUI", hookElvUI)
	end
end
AliasesNamespace.AddElvUITags()