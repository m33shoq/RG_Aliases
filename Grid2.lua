local Grid2 = _G.Grid2

if not Grid2 then
	return
end
-- print("|cffee5555[Rak Gaming Aliases]|r Grid2 STATUS LOADED")
local TAGNAME = "Rak Gaming Alias"
local Name = Grid2.statusPrototype:new(TAGNAME)

-- local UnitName = UnitName
-- local UnitHasVehicleUI = UnitHasVehicleUI or Grid2.Dummy
-- local strCyr2Lat = Grid2.strCyr2Lat
-- local owner_of_unit = Grid2.owner_of_unit

local RG_UnitName = _G.RG_UnitName

Name.IsActive = Grid2.statusLibrary.IsActive

-- Name.GetColor = Grid2.statusLibrary.GetColor

-- local defaultName
-- local displayPetOwner
-- local displayVehicleOwner
-- local GetTextNoPet

function Name:GetText(unit)
	return RG_UnitName(unit) --or UnitName(unit) or  (defaultName==1 and unit) or defaultName
end

-- local function GetText2(self, unit)
-- 	local name = RG_UnitName(unit) or UnitName(unit)
-- 	return (name and strCyr2Lat(name)) or (defaultName==1 and unit) or defaultName
-- end

-- local function GetText3(self,unit)
-- 	local owner = owner_of_unit[unit]
-- 	if owner and (displayPetOwner or (displayVehicleOwner and UnitHasVehicleUI(owner))) then
-- 		unit = owner
-- 	end
-- 	return GetTextNoPet(self,unit)
-- end

function Name:UNIT_NAME_UPDATE(_, unit)
	self:UpdateIndicators(unit)
end

function Name:OnEnable()
	self:RegisterEvent("UNIT_NAME_UPDATE")
end

function Name:OnDisable()
	self:UnregisterEvent("UNIT_NAME_UPDATE")
end

-- function Name:GetTooltip(unit,tip)
-- 	tip:SetUnit(unit)
-- end

-- function Name:UpdateDB()
-- 	local dbx = self.dbx
-- 	defaultName = dbx.defaultName
-- 	GetTextNoPet = dbx.enableTransliterate and GetText2 or GetText1
-- 	displayPetOwner = dbx.displayPetOwner
-- 	displayVehicleOwner = dbx.displayVehicleOwner
-- 	Name.GetText = (displayPetOwner or displayVehicleOwner) and GetText3 or GetTextNoPet
-- end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Name, {"text"}, baseKey, dbx)
	return Name
end

Grid2.setupFunc[TAGNAME] = Create

Grid2:DbSetStatusDefaultValue( TAGNAME, {type = TAGNAME, color1 = {r=0,g=.6,b=1,a=.6}})


