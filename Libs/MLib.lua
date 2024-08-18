-- local GlobalAddonName = ...
---@class AliasesNamespace
local AddonDB = select(2, ...)

---@class MLib
AddonDB.MLib = {}

---@class Locale
local LR = AddonDB.LR

---@class ELib
local ELib = AliasesNamespace.lib

---@class MLib
local MLib = AddonDB.MLib

local defaultFont = GameFontNormal:GetFont()

local btn_clr1, btn_clr2 = CreateColor(0.12,0.12,0.12,1), CreateColor(0.14,0.14,0.14,1)

---@param parent Frame The parent frame to which the button will be added
---@param text string The text to display on the button
---@param textSize number? text size, will default to 13 if not provided
---@return EButton
function MLib:Button(parent,text,textSize)
    if not textSize then textSize = 13 end
    local button = ELib:Button(parent,text)
    button.Texture:SetGradient("VERTICAL",btn_clr1, btn_clr2)
    local fontObject = button:GetFontString()
    if fontObject then
        fontObject:SetFont(defaultFont, textSize, "OUTLINE")
    end
    return button
end

local function TabFrameUpdateTabs(self)
    for i = 1, #self.tabs do
        if i == self.selected then
            self.tabs[i].button.Select(self.tabs[i].button)
            self.tabs[i].button:GetFontString():SetFont(defaultFont, 13, "OUTLINE")
        else
            self.tabs[i].button.Deselect(self.tabs[i].button)
            self.tabs[i].button:GetFontString():SetFont(defaultFont, 13)
        end
        self.tabs[i]:Hide()

        if self.tabs[i].disabled then
            PanelTemplates_SetDisabledTabState(self.tabs[i].button)
        end
    end
    if self.selected and self.tabs[self.selected] then
        self.tabs[self.selected]:Show()
    end
    if self.navigation then
        if self.disabled then
            self.navigation:SetEnabled(nil)
        else
            self.navigation:SetEnabled(true)
        end
    end
end

--- Create a tabs frame
---@param parent Frame The parent frame to which the tabs will be added
---@param template string The template to use for the tabs
---@param ... string Tab names
---@return Tabs
function MLib:Tabs(parent, template, ...)
	local newTabs = ELib:Tabs(parent, template, ...)

	-- Init for new tabs
	newTabs.totalPlaced = 0
	newTabs.TabByName = {}
	for i = 1, #newTabs.tabs do
		if newTabs.tabs[i].button.ButtonState then
			newTabs.tabs[i].button:GetFontString():SetFont(defaultFont, 13, "OUTLINE")
			newTabs.resizeFunc(newTabs.tabs[i].button, 0, nil, nil,
            newTabs.tabs[i].button:GetFontString():GetStringWidth(),
            newTabs.tabs[i].button:GetFontString():GetStringWidth())
		else
			newTabs.tabs[i].button:GetFontString():SetFont(defaultFont, 13)
			newTabs.resizeFunc(newTabs.tabs[i].button, 0, nil, nil,
            newTabs.tabs[i].button:GetFontString():GetStringWidth(),
            newTabs.tabs[i].button:GetFontString():GetStringWidth())
		end
	end

	-- Replacing Update Tabs function to match new style

	newTabs.UpdateTabs = TabFrameUpdateTabs

    for i=1,newTabs.tabCount do
        newTabs.tabs[i].button:Hide()
    end

	local function SetupTab(text)
		newTabs.totalPlaced = newTabs.totalPlaced + 1
		local currentTabNum = newTabs.totalPlaced
		local tab = newTabs.tabs[currentTabNum]
		newTabs.TabByName[text] = tab

        tab.button:Show()
		tab.button:SetText(text)
		tab.button:Resize(0,nil,nil,tab.button:GetFontString():GetStringWidth(),tab.button:GetFontString():GetStringWidth())
        -- tab:SetAllPoints(parent,true)
        tab:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",0,0)
        return tab
	end
	newTabs.SetupTab = SetupTab

	newTabs:SetBackdropBorderColor(0, 0, 0, 0)
	newTabs:SetBackdropColor(0, 0, 0, 0)
	return newTabs
end

--- Create a tabs frame
---@param parent Frame The parent frame to which the tabs will be added
---@param template string The template to use for the tabs
---@param ... string Tab names
---@return Tabs
function MLib:Tabs2(parent,template,...)
    local newTabs = ELib:Tabs(parent,template,...) --(self, padding, absoluteSize, minWidth, maxWidth, absoluteTextSize)

    for i=1,#newTabs.tabs do
        if newTabs.tabs[i].button.ButtonState then
            newTabs.tabs[i].button:GetFontString():SetFont(defaultFont, 13, "OUTLINE")
            newTabs.resizeFunc(newTabs.tabs[i].button, 0, nil, nil, newTabs.tabs[i].button:GetFontString():GetStringWidth(), newTabs.tabs[i].button:GetFontString():GetStringWidth())
        else
            newTabs.tabs[i].button:GetFontString():SetFont(defaultFont, 13)
            newTabs.resizeFunc(newTabs.tabs[i].button, 0, nil, nil, newTabs.tabs[i].button:GetFontString():GetStringWidth(), newTabs.tabs[i].button:GetFontString():GetStringWidth())
        end
    end

    newTabs.UpdateTabs = TabFrameUpdateTabs

    newTabs:SetBackdropBorderColor(0,0,0,0)
    newTabs:SetBackdropColor(0,0,0,0)
    return newTabs
end

local function MultiEdit_TooltipRechek(self)
    self = self.Parent or self
    if not self:IsMouseOver(0, 0, -2, 2) then
        GameTooltip_Hide()
        self:SetScript("OnUpdate",nil)
        self.hookForTip = nil
    end
end

local function Widget_Tooltip_OnEnter(self)
    self = self.Parent or self
    if self.lockTooltipText then
        return
    end
    if type(self.tooltipText) == "function" then
        local text = self.tooltipText(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(text)
        GameTooltip:Show()
    elseif type(self.tooltipText) == "string" then
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(self.tooltipText)
        GameTooltip:Show()
    end
    if not self.hookForTip then
        self.hookForTip = true
        self:SetScript("OnUpdate",MultiEdit_TooltipRechek)
    end
end

local function MultiEdit_Tooltip(self,text)

    self.C.Parent = self
    self.ScrollBar.Parent = self
    self.ScrollBar.buttonUP.Parent = self
    self.ScrollBar.buttonDown.Parent = self

    self:SetScript("OnEnter",Widget_Tooltip_OnEnter)
    self.EditBox:SetScript("OnEnter",Widget_Tooltip_OnEnter)
    self.C:SetScript("OnEnter",Widget_Tooltip_OnEnter)
    self.ScrollBar:SetScript("OnEnter",Widget_Tooltip_OnEnter)
    self.ScrollBar.buttonUP:SetScript("OnEnter",Widget_Tooltip_OnEnter)
    self.ScrollBar.buttonDown:SetScript("OnEnter",Widget_Tooltip_OnEnter)

    self:SetScript("OnLeave",MultiEdit_TooltipRechek)
    self.EditBox:SetScript("OnLeave",MultiEdit_TooltipRechek)
    self.C:SetScript("OnLeave",MultiEdit_TooltipRechek)
    self.ScrollBar:SetScript("OnLeave",MultiEdit_TooltipRechek)
    self.ScrollBar.buttonUP:SetScript("OnLeave",MultiEdit_TooltipRechek)
    self.ScrollBar.buttonDown:SetScript("OnLeave",MultiEdit_TooltipRechek)

    self.tooltipText = text

    return self
end

local function MultiEdit_ColorBorder(self,r,g,b,a)
    if type(r) == 'boolean' then
        if r then
            r,g,b,a = 1,0,0,1
        else
            r,g,b,a = 0.24,0.25,0.30,1
        end
    elseif not r then
        r,g,b,a = 0.24,0.25,0.30,1
    end
    ELib:Border(self,1,r,g,b,a)
end

local function MultilineEditBoxOnTextChanged(self,...)
    local parent = self.Parent
    local height = self:GetHeight()

    local prevMin,prevMax = parent.ScrollBar:GetMinMaxValues()
    local changeToMax = parent.ScrollBar:GetValue() >= prevMax

    parent:SetNewHeight( max( height,parent:GetHeight() ) )
    if changeToMax then
        local min,max = parent.ScrollBar:GetMinMaxValues()
        parent.ScrollBar:SetValue(max)
    end

    -- toogle mouse wheel
    if parent.ScrollBar:IsVisible() then
        parent:EnableMouseWheel(true)
    else
        parent:EnableMouseWheel(false)
    end

    if parent.OnTextChanged then
        parent.OnTextChanged(self,...)
    elseif self.OnTextChanged then
        self:OnTextChanged(...)
    end

    if parent.SyntaxOnEdit then
        parent:SyntaxOnEdit()
    end

    -- auto resize
    if parent.minSize and parent.maxSize then
        local current_text_height = self:GetHeight()
        local lastCharIsNewLine = self:GetText():sub(-1) == "\n"
        local _, fontsize = self:GetFont()
        parent:SetHeight(math.min(math.max(parent.minSize, current_text_height + (lastCharIsNewLine and (fontsize or 14) or 0)), parent.maxSize))
    end
end

local function MultiEditFontSize(self,fontSize)
    local font,_,fontStyle = self.EditBox:GetFont()
    self.EditBox:SetFont(font,fontSize,fontStyle)
    return self
end

function MLib:MultiEdit(parent,minSize,maxSize)
    local newMultiEdit = ELib:MultiEdit(parent)
    newMultiEdit.EditBox:OnChange(MultilineEditBoxOnTextChanged)
    newMultiEdit.Tooltip = MultiEdit_Tooltip
    newMultiEdit.ColorBorder = MultiEdit_ColorBorder
    newMultiEdit.FontSize = MultiEditFontSize

    if minSize and maxSize then
        newMultiEdit.minSize = minSize
        newMultiEdit.maxSize = maxSize
        newMultiEdit.ScrollBar:Size(12,0)
        newMultiEdit.ScrollBar.thumb:SetHeight(20)
    end
    newMultiEdit:EnableMouseWheel(false)

    newMultiEdit.Background = newMultiEdit:CreateTexture(nil,"BACKGROUND")
    newMultiEdit.Background:SetColorTexture(0,0,0,.3)
    newMultiEdit.Background:SetPoint("TOPLEFT")
    newMultiEdit.Background:SetPoint("BOTTOMRIGHT")

    ELib:Border(newMultiEdit,1,.24,.25,.30,1)
    return newMultiEdit
end

do
    local function AlertIcon_OnEnter(self)
		if not self.tooltip then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		if self.tooltipTitle then
			GameTooltip:AddLine(self.tooltipTitle)
		end
        if type(self.tooltip) == "table" then
            for i=1,#self.tooltip do
                local line = self.tooltip[i]
                if type(line) == "table" then
                   if line.isDouble then
                        GameTooltip:AddDoubleLine(unpack(line))
                    else
                        GameTooltip:AddLine(unpack(line))
                    end
                else
                    GameTooltip:AddLine(line,1,1,1,true)
                end
            end
        else
            GameTooltip:AddLine(self.tooltip,1,1,1,true)
        end
		GameTooltip:Show()
	end
	local function AlertIcon_OnLeave(self)
		GameTooltip_Hide()
	end
	local function AlertIcon_SetType(self,typeNum)
		if typeNum == 1 then
			self.outterCircle:SetVertexColor(.7,.15,.08,1)
			self.innerCircle:SetVertexColor(.9,0,.24,1)
			self.tooltip = LR.AlertFieldReq
		elseif typeNum == 2 then
			self.outterCircle:SetVertexColor(.75,.6,0,1)
			self.innerCircle:SetVertexColor(.95,.8,.1,1)
			self.tooltip = LR.AlertFieldSome
		elseif typeNum == 3 then
			self.outterCircle:SetVertexColor(.5,.7,.7,1)
			self.innerCircle:SetVertexColor(.7,.9,.9,1)
			self.text:SetText("?")
		end
	end

	function MLib:CreateAlertIcon(parent,tooltip,tooltipTitle,posRight,isButton)
		local self = CreateFrame(isButton and "Button" or "Frame",nil,parent)
		self:SetSize(20,20)

		local outterCircle = self:CreateTexture(nil,"BACKGROUND",nil,1)
		outterCircle:SetPoint("TOPLEFT")
		outterCircle:SetPoint("BOTTOMRIGHT")
		outterCircle:SetTexture([[Interface\AddOns\MRT\media\circle256]])
		outterCircle:SetVertexColor(.7,.15,.08,1)
		self.outterCircle = outterCircle

		local innerCircle = self:CreateTexture(nil,"BACKGROUND",nil,2)
		innerCircle:SetPoint("TOPLEFT",3,-3)
		innerCircle:SetPoint("BOTTOMRIGHT",-3,3)
		innerCircle:SetTexture([[Interface\AddOns\MRT\media\circle256]])
		innerCircle:SetVertexColor(.9,0,.24,1)
		self.innerCircle = innerCircle

		local text = self:CreateFontString(nil,"BACKGROUND","GameFontWhite",3)
		text:SetPoint("CENTER")
		text:SetFont(MRT.F.defFont,14, "")
		text:SetText("!")
		text:SetShadowColor(0,0,0)
		text:SetShadowOffset(1,-1)
		self.text = text

		self:SetScript("OnEnter",AlertIcon_OnEnter)
		self:SetScript("OnLeave",AlertIcon_OnLeave)

		self.SetType = AlertIcon_SetType

		self.tooltip = tooltip
		self.tooltipTitle = tooltipTitle
		if posRight then
			self:SetPoint("LEFT",parent,"RIGHT",3,0)
		end

		self:Hide()

		return self
	end
end


-- do
--     local function handleForList(owner,rootDescription,list)
--         for i=1,#list do
--            local item = list[i]
--            if item.isTitle then
--               rootDescription:CreateTitle(item.text)
--            elseif item.text == " " then
--               rootDescription:CreateDivider()
--            elseif item.func then
--               rootDescription:CreateButton(item.text,item.func,item.arg1)
--            elseif item.subMenu then
--               local subMenu = rootDescription:CreateButton(item.text)
--               handleForList(subMenu,subMenu,item.subMenu)
--            end
--         end
--      end

--     function MLib:EasyMenu(parent,list)
--         MenuUtil.CreateContextMenu(parent,handleForList,list)
--     end
-- end
