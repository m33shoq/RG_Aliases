local GlobalAddonName = ...
---@class AliasesNamespace
local AliasesNamespace = select(2, ...)

local function hookGrid2()
	local Grid2 = _G.Grid2

	if not Grid2 then
		return
	end
	AliasesNamespace.debugPrint("Grid2 STATUS LOADED")
	local TAGNAME = "Rak Gaming Alias"
	local Name = Grid2.statusPrototype:new(TAGNAME)

	local RG_UnitName = _G.RG_UnitName

	Name.IsActive = Grid2.statusLibrary.IsActive

	function Name:GetText(unit)
		return RG_UnitName(unit) --or UnitName(unit) or  (defaultName==1 and unit) or defaultName
	end

	function Name:UNIT_NAME_UPDATE(_, unit)
		self:UpdateIndicators(unit)
	end

	function Name:OnEnable()
		self:RegisterEvent("UNIT_NAME_UPDATE")
	end

	function Name:OnDisable()
		self:UnregisterEvent("UNIT_NAME_UPDATE")
	end

	local function Create(baseKey, dbx)
		Grid2:RegisterStatus(Name, {"text"}, baseKey, dbx)
		return Name
	end

	Grid2.setupFunc[TAGNAME] = Create

	Grid2:DbSetStatusDefaultValue( TAGNAME, {type = TAGNAME, color1 = {r=0,g=.6,b=1,a=.6}})
end

function AliasesNamespace.AddGrid2Status()
	if C_AddOns.IsAddOnLoadable("Grid2") then
		EventUtil.ContinueOnAddOnLoaded("Grid2", hookGrid2)
	end
end
AliasesNamespace.AddGrid2Status()
