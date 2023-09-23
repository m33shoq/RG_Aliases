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

tNickname = RG_ALTS_SETTINGS and RG_ALTS_SETTINGS["VuhDo"] and RG_ALTS_DB[ tInfo["name"] ] or tInfo["name"];

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
---------------------

TODO: Test all modules, add saved variabled, add comms to sync data 
If there is a numbers in list delete them. Remove redunant spaces.

]]

local addonName, addonTable = ...

local Comm = LibStub:GetLibrary("AceComm-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

------------------------------------------------------------------------
-- RG_ALTS_DB DEFAULTS
------------------------------------------------------------------------
--[[
	CHAT GPT REQUEST:
This is list of Rak Gaming character names, first character in string is alias, others are chracter names.
Create lua table RG_ALTS_DB where character name is key and alias is value.
One character name one table entry.

Список псевдонимов для чаров Рак Гейминга. Первое слово в строке - псевдоним, остальные - имена чаров.

Изначально брал чаров из главной гильдейской таблицы.
Если не хватает какого-то вашего альта, или думаете что чей-то псевдоним не подходит, то пишите сюда.

Нерчо - Нерчодк Нерчо Нерчолинь Нерчоп Нерчохд
Рома - Ромачибрю Кринжелина Ромадесгрип Хедстронгхх Хедстронгх Крусадэс
Володя - Сэнтенза Вовадезкойл Хантеротадоя Чыкъчырык
Кали - Каллиго Калиприст Калитян Калишаман Калиэвокер
Смородина - Смородинкао Смородинуа Смородиная Смородиновая Смородинкова Смородька
Нимб - Нимбмейн Нимбэвокер Нимбальт Нимбтвинк Нимбшаман Нимбсд
Лайт - Лайтпалочка Драгонпупс Сашкастарфол Батлкрабс Крепкийтотем
Ловес - Ловес Аншен Совела Шоквес Нидхогг Ловська
Фейтя - Фейтясд Фейтя Фейтяхдд Фейтяоом Фейтякринж
Омежечка - Омежечкаа Омежадракон Омежаэвокер Омежасэнсэй Омежка Омежечка
Dxb - Dxbd Dxbwarr Dxbmage Mejrenp
Змей - Змейняша Змейняшка Змейсекс Змейнуашо Змейзло Змейснайп
Окриса - Окриса Арурун Лайму Рунрун Сиаро Риккири
Турбо - Турбоглэйв Турбоклык Турбобёрн Турбошайн
Анти - Антилокк Полэвокер Антии Антих Антиидот Антирад
Пикви - Крошкапикви Аувета Япивандополо Крошкамагии Нигайки
Авэ - Авэвокер Авэ Авэвафля Авэмун Авэстихий
Бадито - Батькито Друито Магито Эвокерито Чернокнижито Электрито
Твин - Твиннблейд Твинфлекс Твинпипоклэп Твинбладж
Фриран - Фриэвок Фрираан Фриранлк Фриранк
Пауэл - Пауэл Килкомандер Лейонхэндс Рукадаггер Метеорбласт Дэзэнддикей
Дарклесс - Ракдвакдпс Графчпокало Пернатыйдуб Хисяко Левтрикдпс Брызгни
Фейсмик - Фейсмикх Пошапкинс Фэйсмик Лёгфлесс Фейсмйк Фейсмик
Варсик - Варсикфейс Варсикус Роняюзапад Вэбзик Варсенуз Солеваяняшка
Кройфель - Кройфель Кройфёль Кроифёль Кроифель Папашкинз Триксгеймер
Синхх - Синххже Синхм Снхх Синххдх Синхп Синххводонос
Селфлесс - Селфлессх Селфдк Селфмонк Всталфлесс Секамференс Селфпамп
Мишок - Мишокз Мишокэ Джоджогёрл Мишоксемпай
Сквишех - Сквишех Сквишелол Сквише Метаесть
Мэт - Мэтлокк Мэтдрэйк Ангратар Эгвэйн Мэткоутон Мэтх
Эндьюранс - Эндьюранс Эндьюрансшп Эндьюрансс Эндвокер Задозор Афрография

]]

local RG_ALTS_DB

local RG_ALTS_DB_DEFAULT = {
    ["Нерчодк"] = "Нерчо",
    ["Нерчо"] = "Нерчо",
    ["Нерчолинь"] = "Нерчо",
    ["Нерчоп"] = "Нерчо",
    ["Нерчохд"] = "Нерчо",

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

    ["Смородинкао"] = "Смородина",
    ["Смородинуа"] = "Смородина",
    ["Смородиная"] = "Смородина",
    ["Смородиновая"] = "Смородина",
    ["Смородинкова"] = "Смородина",
    ["Смородька"] = "Смородина",

    ["Нимбмейн"] = "Нимб",
    ["Нимбэвокер"] = "Нимб",
    ["Нимбальт"] = "Нимб",
    ["Нимбтвинк"] = "Нимб",
    ["Нимбшаман"] = "Нимб",
    ["Нимбсд"] = "Нимб",

    ["Лайтпалочка"] = "Лайт",
    ["Драгонпупс"] = "Лайт",
    ["Сашкастарфол"] = "Лайт",
    ["Батлкрабс"] = "Лайт",
    ["Крепкийтотем"] = "Лайт",

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

    ["Омежечкаа"] = "Омежечка",
    ["Омежадракон"] = "Омежечка",
    ["Омежаэвокер"] = "Омежечка",
    ["Омежасэнсэй"] = "Омежечка",
    ["Омежка"] = "Омежечка",

    ["Dxbd"] = "Dxb",
    ["Dxbwarr"] = "Dxb",
    ["Dxbmage"] = "Dxb",
    ["Mejrenp"] = "Dxb",

    ["Змейняша"] = "Змей",
    ["Змейняшка"] = "Змей",
    ["Змейсекс"] = "Змей",
    ["Змейнуашо"] = "Змей",
    ["Змейзло"] = "Змей",
    ["Змейснайп"] = "Змей",

    ["Окриса"] = "Окриса",
    ["Арурун"] = "Окриса",
    ["Лайму"] = "Окриса",
    ["Рунрун"] = "Окриса",
    ["Сиаро"] = "Окриса",
    ["Риккири"] = "Окриса",

    ["Турбоглэйв"] = "Турбо",
    ["Турбоклык"] = "Турбо",
    ["Турбобёрн"] = "Турбо",
    ["Турбошайн"] = "Турбо",

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

    ["Батькито"] = "Бадито",
    ["Друито"] = "Бадито",
    ["Магито"] = "Бадито",
    ["Эвокерито"] = "Бадито",
    ["Чернокнижито"] = "Бадито",
    ["Электрито"] = "Бадито",

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

    ["Варсикфейс"] = "Варсик",
    ["Варсикус"] = "Варсик",
    ["Роняюзапад"] = "Варсик",
    ["Вэбзик"] = "Варсик",
    ["Варсенуз"] = "Варсик",
    ["Солеваяняшка"] = "Варсик",

    ["Кройфель"] = "Кройфель",
    ["Кройфёль"] = "Кройфель",
    ["Кроифёль"] = "Кройфель",
    ["Кроифель"] = "Кройфель",
    ["Папашкинз"] = "Кройфель",
    ["Триксгеймер"] = "Кройфель",

    ["Синххже"] = "Синх",
    ["Синхм"] = "Синх",
    ["Снхх"] = "Синх",
    ["Синххдх"] = "Синх",
    ["Синхп"] = "Синх",
    ["Синххводонос"] = "Синх",

    ["Селфлессх"] = "Селфлесс",
    ["Селфдк"] = "Селфлесс",
    ["Селфмонк"] = "Селфлесс",
    ["Всталфлесс"] = "Селфлесс",
    ["Секамференс"] = "Селфлесс",
    ["Селфпамп"] = "Селфлесс",

    ["Мишокз"] = "Мишок",
    ["Мишокэ"] = "Мишок",
    ["Джоджогёрл"] = "Мишок",
    ["Мишоксемпай"] = "Мишок",

    ["Сквишех"] = "Сквишех",
    ["Сквишелол"] = "Сквишех",
    ["Сквише"] = "Сквишех",
    ["Метаесть"] = "Сквишех",

    ["Мэтлокк"] = "Мэт",
    ["Мэтдрэйк"] = "Мэт",
    ["Ангратар"] = "Мэт",
    ["Эгвэйн"] = "Мэт",
    ["Мэткоутон"] = "Мэт",
    ["Мэтх"] = "Мэт",

    ["Эндьюранс"] = "Эндьюранс",
    ["Эндьюрансшп"] = "Эндьюранс",
    ["Эндьюрансс"] = "Эндьюранс",
    ["Эндвокер"] = "Эндьюранс",
    ["Задозор"] = "Эндьюранс",
    ["Афрография"] = "Эндьюранс"
}

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

addonTable.RG_UnitName = RG_UnitName
addonTable.RG_ClassColorName = RG_ClassColorName
------------------------------------------------------------------------
-- COMMS
------------------------------------------------------------------------

local function SendAliasData()
	local chatType = IsInRaid() and "RAID" or IsInGroup() and "PARTY"
	if not chatType then
		return
	end
	local dataTable = {}
	for char, alias in pairs(RG_ALTS_DB) do
		dataTable[alias] = dataTable[alias] or {}
		tinsert(dataTable[alias], char)
	end

	local dataString = ""
	for alias, chars in pairs(dataTable) do
		dataString = dataString .. alias .. "^"
		for _,char in pairs(chars) do
			dataString = dataString .. char .. "^"
		end
		dataString = dataString:gsub("%^$","") .. "\n"
	end

	local compressed = LibDeflate:CompressDeflate(dataString,{level = 9})
	local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	if encoded then
		Comm:SendCommMessage("RGAliasD", encoded, chatType, nil,"BULK",
		function(arg1,arg2,arg3)
			print(arg1,arg2,arg3)
		end)
	end
end

Comm:RegisterComm("RGAliasD", function(prefix, message, distribution, sender)
	if distribution == "RAID" or distribution == "PARTY" then
		local encoded = LibDeflate:DecodeForWoWAddonChannel(message)
		local decompressed = LibDeflate:DecompressDeflate(encoded)

		local data = {strsplit("\n",decompressed)}
		for i=1,#data do
			local alias, names = strsplit("^",data[i],2)
			if alias and names then
				local chars = {strsplit("^",names)}
				for j=1,#chars do
					RG_ALTS_DB[chars[j]] = alias
					print("Importing", chars[j], "as", alias)
				end
			end
		end
	end
end)



local function Request()
	local chatType = IsInRaid() and "RAID" or IsInGroup() and "PARTY"
	if not chatType then
		return
	end
	Comm:SendCommMessage("RGAliasR", "Request", chatType)
end

Comm:RegisterComm("RGAliasR", function(prefix, message, distribution, sender)
	if distribution == "RAID" or distribution == "PARTY" then
		-- check permissions, only send data if player is group or raid leader 
		if UnitIsGroupLeader('player') then
			SendAliasData()
		end
		
	end
end)



local function ResetRG_ALTS_DB()
	RG_ALTS_DB = RG_ALTS_DB_DEFAULT
end

local addon = CreateFrame("Frame")
addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self)
	print("|cffee5555[Rak Gaming Aliases]|r: Ready")
	RG_ALTS_DB = _G.RG_ALTS_DB or RG_ALTS_DB_DEFAULT
	RG_ALTS_SETTINGS = _G.RG_ALTS_SETTINGS or {
		["Blizzard"] = true,
		["ShadowedUF"] = true,
		-- ["Grid2"] = true,
		-- ["ElvUI"] = true,
		["VuhDo"] = true,
		["KHM"] = true,
		["ShestakUI"] = true,
	}
	addonTable.RG_ALTS_DB = RG_ALTS_DB

	if RG_ALTS_SETTINGS["ShadowedUF"] and addonTable.HookSUF then
		addonTable.HookSUF()
	end

	if RG_ALTS_SETTINGS["Blizzard"] and addonTable.HookBlizzard then
		addonTable.HookBlizzard()
	end

	if RG_ALTS_SETTINGS["KHM"] and addonTable.HookKHM then
		addonTable.HookKHM()
	end

	if RG_ALTS_SETTINGS["ShestakUI"] and addonTable.HookShestakUI then
		addonTable.HookShestakUI()
	end

	self:UnregisterEvent("ADDON_LOADED")
end)

------------------------------------------------------------------------
-- SLASH COMMANDS
------------------------------------------------------------------------
string_gmatch = string.gmatch
SLASH_RG_ALIAS1 = "/rgalias"
local modules = {
	["Blizzard"] = true,
	["ShadowedUF"] = true,
	-- ["Grid2"] = true,
	-- ["ElvUI"] = true,
	["VuhDo"] = true,
	["KHM"] = true,
	["ShestakUI"] = true,
}
local modulesString = [[

modules:
Blizzard
ShadowedUF
KHM
VuhDo
ShestakUI
]]

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
	if arg1 == "default" then
		ResetRG_ALTS_DB()
		print("|cffee5555[Rak Gaming Aliases]|r: Default")
	elseif arg1 == "request" then
		Request()
		print("|cffee5555[Rak Gaming Aliases]|r: Requesting")
	elseif arg1 == "send" then
		SendAliasData()
		print("|cffee5555[Rak Gaming Aliases]|r: Sending")
	elseif arg1 == "add" then
		if arg2 and arg3 then
			RG_ALTS_DB[arg2] = arg3
			print("|cffee5555[Rak Gaming Aliases]|r: Added", arg2, "as", arg3)
		else
			print("|cffee5555[Rak Gaming Aliases]|r:|cff80ff00 /rgalias add <name1> <alias>|r")
		end
	elseif arg1 == "get" then
		if arg2 then
			print(RG_ALTS_DB[arg2] and ("|cffee5555[Rak Gaming Aliases]|r:" .. RG_ALTS_DB[arg2]) or ("|cffee5555[Rak Gaming Aliases]|r: No alias for " .. arg2))
		end
	elseif arg1 == "disable" then
		if arg2 then
			if modules[arg2] then
				RG_ALTS_SETTINGS[arg2] = false
				print("|cffee5555[Rak Gaming Aliases]|r: Disabled", arg2)
			else
				print("|cffee5555[Rak Gaming Aliases]|r: No such module")
			end
		else
			print("|cffee5555[Rak Gaming Aliases]|r:|cff80ff00 /rgalias disable <module>|r" .. modulesString)
		end
	elseif arg1 == "enable" then
		if arg2 then
			if modules[arg2] then
				RG_ALTS_SETTINGS[arg2] = true
				print("|cffee5555[Rak Gaming Aliases]|r: Enabled", arg2)
			else
				print("|cffee5555[Rak Gaming Aliases]|r: No such module")
			end
		else
			print("|cffee5555[Rak Gaming Aliases]|r:|cff80ff00 /rgalias enable <module>|r" .. modulesString)
		end
	elseif arg1 == "status" then
		print("|cffee5555[Rak Gaming Aliases]|r: modules settings:")
		for k,v in pairs(RG_ALTS_SETTINGS) do
			print(k,v and "Enabled" or "Disabled")
		end
	else
		print("|cffee5555[Rak Gaming Aliases]|r:\n|cff80ff00/rgalias default \n/rgalias request \n/rgalias send \n/rgalias add <name1> <alias> \n/rgalias enable <module>\n/rgalias disable <module>\n/rgalias status|r")
	end
end
SlashCmdList["RG_ALIAS"] = handler

--[[
GUIDELINES
## ElvUI
	1. Заходим в ElvUI -> Рамки юнитов -> Одиночные/Груповые юниты -> Выбираем нужный фрейм(например Рейд 1).
	2. Находим нужную вкладку с тектом, обычно это или "Имя" или "Свой текст".
	3. Заменяем старый тег на новый.
	В основном нужно заменить "name" на "nameRG", например [name:short] -> [nameRG:short] 
	Полный список новых тегов можно посмотреть во вкладке "Доступные теги" - Rak Gaming Health/Names/Target

	Повторить для всех фреймов, которые нужно изменить.
	
## Shadowed Unit Frames
	1. SUF -> нужный фрейм -> Текст/Теги
	2. Находим поле где у вас было [name] или [( )name] или что-то в таком стиле.
	3. Заменяем 
		либо через интерфейс тагов: пролистать вниз, снять галочку с "Имя объекта" и 
		поставить на "RG Alias" или RG Alias(Class colored)
		
		либо вручную: [( )name] -> [( )RG_Name] или [( )RG_Name_ClassColored]

	Повторить для всех фреймов, которые нужно изменить.

## Blizzard
	Все работает автоматически:
	
	Для включения/выключения использовать:
	/rgalias enable Blizzard
	/rgalias disable Blizzard

## VuhDo
	Для работы с вуду нужно поставить отедльную версию VuhDo.

	Все работает автоматически:

	Для включения/выключения использовать:
	/rgalias enable VuhDo
	/rgalias disable VuhDo

## KHM
	Все работает автоматически:

	Для включения/выключения использовать:
	/rgalias enable KHM
	/rgalias disable KHM

## Grid2
	1. /grid2 -> Индикаторы
	2. Находим индикатор к которому прикреплено состояние "название", выключаем его
	3. Внизу находим состояние Rak Gaming Alias, включаем его
	4. Убедиться что состояние Rak Gaming Alias находится выше других состояний по приоритету 

## ShestakUI
	Все работает автоматически:

	Для включения/выключения использовать:
	/rgalias enable ShestakUI
	/rgalias disable ShestakUI
	
**После использования комманда /rgalias enable/disable нужно перезапустить интерфейс что бы изменения вступили в силу.**


	
]]