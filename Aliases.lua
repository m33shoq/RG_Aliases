-- 14.08.2024
local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)


local realmKey = GetRealmName() or ""
local charName = UnitName'player' or ""
realmKey = realmKey:gsub(" ","")
AliasesNamespace.realmKey = realmKey
AliasesNamespace.charKey = charName .. "-" .. realmKey
AliasesNamespace.charName = charName

function AliasesNamespace.print(...)
	print("|cffee5555[Rak Gaming Aliases]|r", ...)
end

-- /run RG_ALTS_SETTINGS.debug = true
function AliasesNamespace.debugPrint(...)
	if RG_ALTS_SETTINGS and RG_ALTS_SETTINGS.debug then
		AliasesNamespace.print("Debug:",...)
	end
end

function AliasesNamespace.convertToTable(selectedText)
	local alts_db = {}
	for line in selectedText:gmatch("[^\r\n]+") do
	  	local alias, names = line:match("^(%S+)%s*-%s*(.+)$")
	  	if alias and names then
			for name in names:gmatch("%S+") do
				alts_db[name] = alias
			end
	  	end
	end
	return alts_db
end

local db = {}
function AliasesNamespace.UpdateDB()
	db = RG_ALTS_DB
	AliasesNamespace.db = db
end

local function RG_UnitName(unit)
	local name, realm = UnitName(unit)
	return RG_ALTS_DB[name] or name, realm
end

local function RG_ClassColorName(unit)
	if unit and UnitExists(unit) then
		local name = RG_UnitName(unit)
		local _, class = UnitClass(unit)
		if not class then
			return name
		else
			local classData = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
			local coloredName = ("|c%s%s|r"):format(classData.colorStr, name)
			return coloredName
		end
	else
	  	return "" -- ¯\_(ツ)_/¯
	end
  end

_G.RG_UnitName = RG_UnitName
_G.RG_ClassColorName = RG_ClassColorName

AliasesNamespace.RG_UnitName = RG_UnitName
AliasesNamespace.RG_ClassColorName = RG_ClassColorName


function AliasesNamespace.ResetRG_ALTS_DB()
	RG_ALTS_DB = {}
	AliasesNamespace.UpdateDB()
end

local modules = {
}

function AliasesNamespace:NewModule(key,module)
	modules[key] = module
	return module
end

AliasesNamespace.modules = modules
AliasesNamespace.hookedModules = {}
local modulesString = [[

modules:
Blizzard
ShadowedUF
KHM
VuhDo
ShestakUI
MRTNote
MRTCD
Cell
]]

local function loadModules()
	if RG_ALTS_SETTINGS.settings["shadoweduf"] then
		AliasesNamespace.HookSUF()
	end

	if RG_ALTS_SETTINGS.settings["blizzard"] then
		AliasesNamespace.HookBlizzard()
	end

	if RG_ALTS_SETTINGS.settings["khm"] then
		AliasesNamespace.HookKHM()
	end

	if RG_ALTS_SETTINGS.settings["shestakui"] then
		AliasesNamespace.HookShestakUI()
	end

	if RG_ALTS_SETTINGS.settings["mrtnote"] then
		AliasesNamespace.HookMRTNote()
	end

	if RG_ALTS_SETTINGS.settings["mrtcd"] then
		AliasesNamespace.HookMRTCD()
	end

	if RG_ALTS_SETTINGS.settings["cell"] then
		AliasesNamespace.HookCell()
	end
end

local addon = CreateFrame("Frame")
addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self,event, ...)
	local addonName = ...
	if addonName ~= GlobalAddonName then
		return
	end
	AliasesNamespace.debugPrint("Ready")
	RG_ALTS_DB = RG_ALTS_DB or {}
	AliasesNamespace.UpdateDB()

	local currentVer = tonumber(C_AddOns.GetAddOnMetadata(GlobalAddonName, "Version"))

	RG_ALTS_SETTINGS = _G.RG_ALTS_SETTINGS or {
		version = currentVer,
		settings = {},
	}

	RG_ALTS_SETTINGS.version = RG_ALTS_SETTINGS.version or 0
	-- modernize settings
	if RG_ALTS_SETTINGS.version < 5 then
		local modulesSetings = CopyTable(RG_ALTS_SETTINGS)
		modulesSetings.version = nil -- do not version field
		-- ensure all settings are lowercase
		for module,isOn in pairs(modulesSetings) do
			RG_ALTS_SETTINGS[module] = nil -- remove module keys from old data
			modulesSetings[module] = nil
			modulesSetings[module:lower()] = isOn
		end

		-- remove anything that is not a module
		for key in pairs(modulesSetings) do
			if modules[key] == nil then
				modulesSetings[key] = nil
			end
		end

		-- ensure all modules exist in settings
		for module in pairs(modules) do
			if not type(modulesSetings[module]) == 'boolean' then
				modulesSetings[module] = false
			end
		end

		RG_ALTS_SETTINGS.settings = modulesSetings
	end
	RG_ALTS_SETTINGS.version = currentVer

	RG_ALTS_SETTINGS.SyncPlayers = RG_ALTS_SETTINGS.SyncPlayers or {}

	loadModules()

	self:UnregisterEvent("ADDON_LOADED")
end)

------------------------------------------------------------------------
-- SLASH COMMANDS
------------------------------------------------------------------------
string_gmatch = string.gmatch

local function handler(msg)
	local arg1, arg2, arg3
	for word in string_gmatch(msg, "[^ ]+") do
		if not arg1 then
			arg1 = word:lower()
		elseif not arg2 then
			arg2 = word
		elseif not arg3 then
			arg3 = word
		end
	end
	if arg1 == "opt" or arg1 == "options" then
		AliasesNamespace:ShowOptions()
	elseif arg1 == "default" then
		AliasesNamespace.ResetRG_ALTS_DB()
		AliasesNamespace.print("Reseted Alts Database to Default")
	elseif arg1 == "request" then
		AliasesNamespace.Request()
		AliasesNamespace.print("Requesting")
	elseif arg1 == "send" then
		AliasesNamespace.SendAliasData()
		AliasesNamespace.print("Sending")
	elseif arg1 == "add" then
		if arg2 and arg3 then
			if _G.RGAPIDBc then
				_G.RGAPIDBc[arg2] = arg3
			else
				RG_ALTS_DB[arg2] = arg3
			end
			AliasesNamespace.print("Added", arg2, "as", arg3)
		else
			AliasesNamespace.print("|cff80ff00/rgalias add <name> <alias>|r")
		end
	elseif arg1 == "remove" then
		if arg2 then
			if _G.RGAPIDBc then
				_G.RGAPIDBc[arg2] = nil
			else
				RG_ALTS_DB[arg2] = nil
			end
			AliasesNamespace.print("Removed", arg2)
		else
			AliasesNamespace.print("|cff80ff00/rgalias remove <name>|r")
		end
	elseif arg1 == "get" then
		if arg2 then
			AliasesNamespace.print(RG_ALTS_DB[arg2] and (RG_ALTS_DB[arg2]) or ("No alias for " .. arg2))
		end
	elseif arg1 == "disable" then
		if arg2 then
			if modules[arg2:lower()] then
				RG_ALTS_SETTINGS.settings[arg2:lower()] = false
				AliasesNamespace.print("Disabled", arg2)
			else
				AliasesNamespace.print("No such module")
			end
		else
			AliasesNamespace.print("|cff80ff00/rgalias disable <module>|r" .. modulesString)
		end
	elseif arg1 == "enable" then
		if arg2 then
			if modules[arg2:lower()] then
				RG_ALTS_SETTINGS.settings[arg2:lower()] = true
				AliasesNamespace.print("Enabled", arg2)
			else
				AliasesNamespace.print("No such module")
			end
		else
			AliasesNamespace.print("|cff80ff00/rgalias enable <module>|r" .. modulesString)
		end
	elseif arg1 == "status" then
		AliasesNamespace.print("modules settings:")
		local res = {}
		for module in pairs(modules) do
			res[#res+1] = module .. " " .. (RG_ALTS_SETTINGS.settings[module] and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r")
		end
		table.sort(res)
		for i=1,#res do
			print(res[i])
		end
	else
		AliasesNamespace.print(
[[Available slash commands:
|cff80ff00/rgalias opt|r, |cff80ff00/rgalias options|r - Open options
|cff80ff00/rgalias default|r - Reset Alts Database to Default
|cff80ff00/rgalias request|r - Request Alts Database from group leader
|cff80ff00/rgalias send|r - Send Alts Database to group
|cff80ff00/rgalias add <name1> <alias>|r - Add alias
|cff80ff00/rgalias remove <name1>|r - Remove alias
|cff80ff00/rgalias enable <module>|r - Enable module
|cff80ff00/rgalias disable <module>|r - Disable module
|cff80ff00/rgalias status|r]])
	end
end

SLASH_RG_ALIAS1 = "/rgalias"
SlashCmdList["RG_ALIAS"] = handler

--[[
# Rak Gaming Aliases GUIDELINES
## ElvUI
В ElvUI нужно выставить новые теги там где хотите видеть псевдонимы вместо ников.

1. Заходим в ElvUI -> Рамки юнитов -> Одиночные/Груповые юниты -> Выбираем нужный фрейм(например Рейд 1).
2. Находим нужную вкладку с тектом, обычно это или "Имя" или "Свой текст".
3. Заменяем старый тег на новый.
В основном нужно заменить "name" на "nameRG", например [name:short] -> [nameRG:short]
Полный список новых тегов можно посмотреть во вкладке "Доступные теги" - Rak Gaming Health/Names/Target

Повторить для всех фреймов, которые нужно изменить.
## Shadowed Unit Frames
В SUF нужно выставить новые теги там где хотите видеть псевдонимы вместо ников.

1. SUF -> нужный фрейм -> Текст/Теги
2. Находим поле где у вас было [name] или [( )name] или что-то в таком стиле.
3. Заменяем
	либо через интерфейс тагов: пролистать вниз, снять галочку с "Имя объекта" и
	поставить на "RG Alias" или RG Alias(Class colored)

	либо вручную: [( )name] -> [( )RG_Name] или [( )RG_Name_ClassColored]

Повторить для всех фреймов, которые нужно изменить.

При создании нового профиля в SUF, таги появиться только после /reload
## Blizzard(только рейдфреймы)
Для включения/выключения использовать:
/rgalias enable Blizzard
/rgalias disable Blizzard

## VuhDo
Для работы с вуду нужно поставить отедльную версию VuhDo.

Для включения/выключения использовать:
/rgalias enable VuhDo
/rgalias disable VuhDo
## KHM
Работает только если в KHM включено изменение имен на фреймах. В остальных случаях использовать Blizzard.

Для включения/выключения использовать:
/rgalias enable KHM
/rgalias disable KHM
## Grid2
1. /grid2 -> Индикаторы
2. Находим индикатор к которому прикреплено состояние "название", выключаем его
3. Внизу находим состояние Rak Gaming Alias, включаем его
4. Убедиться что состояние Rak Gaming Alias находится выше других состояний по приоритету
## ShestakUI(только рейдфреймы вроде...) ¯\_(ツ)_/¯
Для включения/выключения использовать:
/rgalias enable ShestakUI
/rgalias disable ShestakUI

***После использования комманд /rgalias enable/disable нужно перезапустить интерфейс что бы изменения вступили в силу.***
## MRT Рейд кулдауны
Для включения/выключения использовать:
/rgalias enable MRTCD
/rgalias disable MRTCD

***После использования комманд /rgalias enable/disable нужно перезапустить интерфейс что бы изменения вступили в силу.***
## MRT Заметка(только визуал, хз зачем сделал но пусть будет)
Для включения/выключения использовать:
/rgalias enable MRTNote
/rgalias disable MRTNote

***После использования комманд /rgalias enable/disable нужно перезапустить интерфейс что бы изменения вступили в силу.***
]]




--[[
DEV COMMENTS


--try to initialize with all addons off. LibStub required?

ElvUI: Ready - Added custom nameRG tags
Grid2: Ready - Added Rak Gaming Alias Status
ShadowedUF: Ready - Added Rak Gaming Alias tag
Blizzard: Ready - Hooked CompactUnitFrame_UpdateName
KHM: Ready -  Replaced KHMRaidFrames.SetUpNameInternal
VuhDo: Ready - Made VuhDo Addon version with Support for RG_UnitName

------------------------------------------------------------------------
------------------------------------------------------------------------
VuhDo Implementation:

@VuhDoBarCustomizerHealth.lua line 32-33

local RG_ALTS_SETTINGS =  _G.RG_ALTS_SETTINGS
local RG_ALTS_DB = _G.RG_ALTS_DB

@VuhDoBarCustomizerHealth.lua line 643

tNickname = RG_ALTS_SETTINGS and RG_ALTS_SETTINGS.settings["VuhDo"] and RG_ALTS_DB[ tInfo["name"] ] or tInfo["name"];

------------------------------------------------------------------------
------------------------------------------------------------------------

Caligo KHM Texture request:

suspect - KHMRaidFrames.lua line 103

error at SetUpAddon.lua line 444 - CompactPartyFrame_RefreshMembers() changed with CompactPartyFrame:RefreshMembers()

@KHMRaidFrames.lua 414 changed UnitIsConnected nil check
	function KHMRaidFrames.HideStatusText(frame)
    	if not frame.unit or not UnitIsConnected(frame.unit) then

probably the most important
@SetUpAddon.lua line 239 - added DefaultCompactUnitFrameSetup hook

	if true and not KHMRaidFrames:IsHooked("DefaultCompactUnitFrameSetup")then
		KHMRaidFrames:SecureHook(
			"DefaultCompactUnitFrameSetup",
			function(frame)
				if KHMRaidFrames.SkipFrame(frame) then return end

				local groupType = IsInRaid() and "raid" or "party"

				local isInCombatLockDown = InCombatLockdown()

				if groupType ~= KHMRaidFrames.currentGroup then
					KHMRaidFrames:RefreshProfileSettings()
				end

				local name = frame and frame:GetName()
				if not name then return end

				if not UnitExists(frame.displayedUnit) then return end
				KHMRaidFrames:LayoutFrame(frame, groupType, isInCombatLockDown)

			end)
	end
------------------------------------------------------------------------

]]

--[[{
    ["Нерчодк"] = "Нерчо",
    ["Нерчо"] = "Нерчо",
    ["Нерчолинь"] = "Нерчо",
    ["Нерчоп"] = "Нерчо",
    ["Нерчохд"] = "Нерчо",
    ["Нерчодуду"] = "Нерчо",

    ["Ромачибрю"] = "Рома",
    ["Кринжелина"] = "Рома",
    ["Ромадесгрип"] = "Рома",
    ["Хедстронгхх"] = "Рома",
    ["Хедстронгх"] = "Рома",
    ["Крусадэс"] = "Рома",

    ["Сэнтенза"] = "Володя",
    ["Вовадезкойл"] = "Володя",
    ["Хантеротадоя"] = "Володя",
    ["Чыкъчырык"] = "Володя",

    ["Каллиго"] = "Кали",
    ["Калиприст"] = "Кали",
    ["Калитян"] = "Кали",
    ["Калишаман"] = "Кали",
    ["Калиэвокер"] = "Кали",

    ["Нимбмейн"] = "Нимб",
    ["Нимбэвокер"] = "Нимб",
    ["Нимбальт"] = "Нимб",
    ["Нимбтвинк"] = "Нимб",
    ["Нимбшаман"] = "Нимб",
    ["Нимбсд"] = "Нимб",
    ["Нимбрестор"] = "Нимб",
    ["Нимбпал"] = "Нимб",
    ["Нимбшам"] = "Нимб",

    ["Лайтпалочка"] = "Лайт",
    ["Драгонпупс"] = "Лайт",
    ["Сашкастарфол"] = "Лайт",
    ["Батлкрабс"] = "Лайт",
    ["Крепкийтотем"] = "Лайt",

    ["Ловес"] = "Ловес",
    ["Аншен"] = "Ловес",
    ["Совела"] = "Ловес",
    ["Шоквес"] = "Ловес",
    ["Нидхогг"] = "Ловес",
    ["Ловська"] = "Ловес",

    ["Фейтясд"] = "Фейтя",
    ["Фейтя"] = "Фейтя",
    ["Фейтяхдд"] = "Фейтя",
    ["Фейтяоом"] = "Фейтя",
    ["Фейтякринж"] = "Фейтя",

    ["Омежечкаа"] = "Омежа",
    ["Омежадракон"] = "Омежа",
    ["Омежаэвокер"] = "Омежа",
    ["Омежасэнсэй"] = "Омежа",
    ["Омежка"] = "Омежа",
    ["Омежечка"] = "Омежа",
    ["Омежечкачсв"] = "Омежа",

    ["Dxbd"] = "Муни",
    ["Dxbwarr"] = "Муни",
    ["Dxbmage"] = "Муни",
    ["Mejrenp"] = "Муни",

    ["Змейняша"] = "Змей",
    ["Змейняшка"] = "Змей",
    ["Змейсекс"] = "Змей",
    ["Змейнуашо"] = "Змей",
    ["Змейзло"] = "Змей",
    ["Змейснайп"] = "Змей",
    ["Змейкраш"] = "Змей",
    ["Змеймвп"] = "Змей",

    ["Окриса"] = "Эмпрайз",
    ["Арурун"] = "Эмпрайз",
    ["Лайму"] = "Эмпрайз",
    ["Рунрун"] = "Эмпрайз",
    ["Сиаро"] = "Эмпрайз",
    ["Риккири"] = "Эмпрайз",

    ["Турбоглэйв"] = "Турба",
    ["Турбоклык"] = "Турба",
    ["Турбобёрн"] = "Турба",
    ["Турбошайн"] = "Турба",

    ["Антилокк"] = "Анти",
    ["Полэвокер"] = "Анти",
    ["Антии"] = "Анти",
    ["Антих"] = "Анти",
    ["Антиидот"] = "Анти",
    ["Антирад"] = "Анти",

    ["Крошкапикви"] = "Пикви",
    ["Аувета"] = "Пикви",
    ["Япивандополо"] = "Пикви",
    ["Крошкамагии"] = "Пикви",
    ["Нигайки"] = "Пикви",

    ["Авэвокер"] = "Авэ",
    ["Авэ"] = "Авэ",
    ["Авэвафля"] = "Авэ",
    ["Авэмун"] = "Авэ",
    ["Авэстихий"] = "Авэ",
    ["Авэрейдж"] = "Авэ",

    ["Батькито"] = "Бадито",
    ["Друито"] = "Бадито",
    ["Магито"] = "Бадито",
    ["Эвокерито"] = "Бадито",
    ["Чернокнижито"] = "Бадито",
    ["Электрито"] = "Бадито",
    ["Рогито"] = "Бадито",

    ["Твиннблейд"] = "Твин",
    ["Твинфлекс"] = "Твин",
    ["Твинпипоклэп"] = "Твин",
    ["Твинбладж"] = "Твин",

    ["Фриэвок"] = "Фриран",
    ["Фрираан"] = "Фриран",
    ["Фриранлк"] = "Фриран",
    ["Фриранк"] = "Фриран",

    ["Пауэл"] = "Пауэл",
    ["Килкомандер"] = "Пауэл",
    ["Лейонхэндс"] = "Пауэл",
    ["Рукадаггер"] = "Пауэл",
    ["Метеорбласт"] = "Пауэл",
    ["Дэзэнддикей"] = "Пауэл",
    ["Пятьдесять"] = "Пауэл",

    ["Ракдвакдпс"] = "Дарклесс",
    ["Графчпокало"] = "Дарклесс",
    ["Пернатыйдуб"] = "Дарклесс",
    ["Хисяко"] = "Дарклесс",
    ["Левтрикдпс"] = "Дарклесс",
    ["Брызгни"] = "Дарклесс",

    ["Фейсмикх"] = "Фейсмик",
    ["Пошапкинс"] = "Фейсмик",
    ["Фэйсмик"] = "Фейсмик",
    ["Лёгфлесс"] = "Фейсмик",
    ["Фейсмйк"] = "Фейсмик",
    ["Фейсмик"] = "Фейсмик",
    ["Фейсмикхх"] = "Фейсмик",

    ["Варсикфейс"] = "Варсик",
    ["Варсикус"] = "Варсик",
    ["Роняюзапад"] = "Варсик",
    ["Вэбзик"] = "Варсик",
    ["Варсенуз"] = "Варсик",
    ["Солеваяняшка"] = "Варсик",
    ["Варсикдауби"] = "Варсик",

    ["Кройфель"] = "Кройфель",
    ["Кройфёль"] = "Кройфель",
    ["Кроифёль"] = "Кройфель",
    ["Кроифель"] = "Кройфель",
    ["Папашкинз"] = "Кройфель",
    ["Триксгеймер"] = "Кройфель",
    ["Кроймонк"] = "Кройфель",

    ["Синххже"] = "Синхх",
    ["Синхм"] = "Синхх",
    ["Снхх"] = "Синхх",
    ["Синххдх"] = "Синхх",
    ["Синхп"] = "Синхх",
    ["Синххводонос"] = "Синхх",

    ["Селфлессх"] = "Селфлесс",
    ["Селфдк"] = "Селфлесс",
    ["Селфмонк"] = "Селфлесс",
    ["Всталфлесс"] = "Селфлесс",
    ["Секамференс"] = "Селфлесс",
    ["Селфпамп"] = "Селфлесс",
    ["Вонючиймусор"] = "Селфлесс",

    ["Мишокз"] = "Мишок",
    ["Мишокэ"] = "Мишок",
    ["Мишокдк"] = "Мишок",
    ["Мишоксемпай"] = "Мишок",
    ["Мишокбык"] = "Мишок",

    ["Сквишех"] = "Сквишех",
    ["Сквишелол"] = "Сквишех",
    ["Сквише"] = "Сквишех",
    ["Метаесть"] = "Сквишех",
    ["Сквишехд"] = "Сквишех",
    ["Шипшейп"] = "Сквишех",

    ["Мэтлокк"] = "Мэт",
    ["Мэтдрэйк"] = "Мэт",
    ["Ангратар"] = "Мэт",
    ["Эгвэйн"] = "Мэт",
    ["Мэткоутон"] = "Мэт",
    ["Мэтх"] = "Мэт",
    ["Мэталлика"] = "Мэт",
    ["Мэтхх"] = "Мэт",
    ["Мэтшок"] = "Мэт",

    ["Эндьюранс"] = "Эндьюранс",
    ["Эндьюрансшп"] = "Эндьюранс",
    ["Эндьюрансс"] = "Эндьюранс",
    ["Эндвокер"] = "Эндьюранс",
    ["Задозор"] = "Эндьюранс",
    ["Афрография"] = "Эндьюранс",
}
]]