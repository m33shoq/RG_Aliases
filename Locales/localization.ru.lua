local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

if GetLocale() ~= "ruRU" then return end

---@class AliasesLocale
local L = AliasesNamespace.L

L["Modules"] = "Модули"
L["Reload UI to apply changes?"] = "Перезагрузить интерфейс для применения изменений?"
L["(not loaded)"] = "(не загружено)"
L["Always enabled"] = "Всегда включено"
L["Characters"] = "Персонажи"
L["Add new character"] = "Добавить нового персонажа"
L["Senders"] = "Отправители"
L["Add new sender"] = "Добавить нового отправителя"
L["Always accept"] = "Всегда принимать"
L["Always ignore"] = "Всегда игнорировать"
L["Send"] = "Отправить"
L["Request"] = "Запрос"
L["Reset"] = "Сброс"
L["Reset alts"] = "Сбросить альтов"
L["Import"] = "Импорт"
L["Export"] = "Экспорт"
L["Setup guide:"] = "Инструкция по настройке:"
L[ [=[Red addons are disabled,
green addons are enabled,
white addons are always enabled,
grey addons are not loaded.]=] ] =
[=[Замена ников для красныех аддонов отключена,
для зеленых аддонов включена,
для белых аддонов всегда включена,
серые аддоны не загружены.]=]
L["Click to remove %s from %q"] = "Нажмите, чтобы удалить %s из %q"
L["Click to add new alt for"] = "Нажмите, чтобы добавить нового альта для"
L["Shift click to delete this character"] = "Shift+клик для удаления этого персонажа"
L["Request alts from leader"] = "Запросить альтов у лидера"
L["Send alts to raid/party"] = "Отправить альтов в рейд/группу"
L["Changes names on Blizzard Raid Frames"] = "Замена ников на рейдфреймах Blizzard"
L["Changes names on Cell frames"] = "Замена ников на фреймах Cell"
L["Adds new tags to ElvUI"] = "Добавляет новые теги в ElvUI"
L["Adds new status to Grid2"] = "Добавляет новое состояние в Grid2"
L["Changes names on KHM Raid Frames"] = "Замена ников на рейдфреймах KHM"
L["Changes names in MRT Note on screen(not in MRT Options)"] = "Замена ников в MRT Заметке на экране(не в настройках MRT)"
L["Changes names on MRT Cooldown bars/icons"] = "Замена ников на полосах/иконках MRT Рейд кулданов"
L["Adds custom tags to Shadowed Unit Frames"] = "Добавляет пользовательские теги в Shadowed Unit Frames"
L["Changes names on ShestakUI frames"] = "Замена ников на фреймах ShestakUI"