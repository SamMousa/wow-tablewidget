local Factory, _ = LibStub:NewLibrary("TableWidget", 1)

local Table = LibStub("EventSourcing/Table")
local Util = LibStub("EventSourcing/Util")

print("Table widget loaded")

local widget = CreateFrame("Frame", "TableWidget", UIParent, nil)
tableWidget = widget
widget:Hide()
widget:SetMovable(true)
widget:EnableMouse(true)
widget:RegisterForDrag("LeftButton")
widget:SetScript("OnDragStart", widget.StartMoving)
widget:SetScript("OnDragStop", widget.StopMovingOrSizing)
widget:SetResizable(true)

widget:SetUserPlaced(false)
widget:SetPoint("CENTER",100,0)
widget:SetWidth(300)

widget:SetHeight(350 + 12 + 9)

Mixin(widget, BackdropTemplateMixin)
local backdrop = {

    bgFile = "Interface\\FrameGeneral\\UI-Background-Rock", -- "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 9, },
}

widget:SetScript("OnSizeChanged", function(self)
    self:OnBackdropSizeChanged(self)
end)
-- widget:OnBackdropLoaded(widget)
widget:SetBackdrop(backdrop)

local rowHeight = 15
local numLines = 10

widget:SetClipsChildren(false)
widget:Show();


local data = {}
local classes = {"mage", "lock"}
for i = 1, 100 do
data[i] = {
 a = math.random(100),
 class = classes[math.random(2)],
 b = math.random(100),
}

end

-- create a table of items


local table = Table.new({
    a = Util.CreateFieldSorter('a'),
    subject = Util.CreateFieldSorter('subject'),
    inverse_a = Util.InvertSorter(Util.CreateFieldSorter('a')),
})
local specialRow
for i = 1, 10000 do
    if i == 1 then
        specialRow = {
            a = i,
            subject = string.format("Subject %06d", i)
        }
        table.addRow(specialRow)
    else
        table.addRow({
            a = i,
            subject = string.format("Subject %06d", i)
        })
    end
end
local counter = 0
C_Timer.NewTicker(1, function()
    table.updateRow(specialRow, function()
        specialRow.subject = string.format("Subject %06d - special", counter)
    end)

counter = counter + 1
end
)
-- create the hybrid scroll frame
local hsf = CreateFrame("ScrollFrame", nil, widget, "BasicHybridScrollFrameTemplate")
-- create the buttons first
-- hsf:SetWidth(300)
-- hsf:SetHeight(500)
-- hsf:SetAllPoints()
print(hsf:GetHeight())
HybridScrollFrame_CreateButtons(hsf, "TableWidgetRow", 0, 0, "TOP", "TOP", 0, 0, "TOP", "BOTTOM")


hsf:SetPoint("TOPRIGHT", -28, -12)
hsf:SetPoint("BOTTOMRIGHT", -28, 9)
hsf:SetPoint("TOPLEFT", 12, -12)

hsf:SetPoint("BOTTOMLEFT", 12, 12)
-- local bg = hsf:CreateTexture("BACKGROUND")
-- bg:SetAllPoints()
-- bg:SetColorTexture(1, 0, 0, 0.4)


-- add a scroll bar
-- hsf.ScrollBar = CreateFrame("Slider", "$parentScrollBar", hsf, "HybridScrollBarTemplate")
-- hsf.ScrollBar:SetPoint("TOPLEFT", hsf, "TOPRIGHT", 1, -16)
-- hsf.ScrollBar:SetPoint("BOTTOMLEFT", hsf, "BOTTOMRIGHT", 1, 12)



-- create a watch
local buttonHeight = hsf.buttons[1]:GetHeight();

local watch = table.watchIndexRange('subject', function(iterator, reason, totalCount)
    print("Watch triggered:", reason)
    local buttonIndex = 1
    local rows = HybridScrollFrame_GetButtons(hsf)
    for _, item in iterator do
        local cells = {rows[buttonIndex]:GetChildren()}
        cells[1]:SetText(item.subject)
        buttonIndex = buttonIndex + 1
    end
    HybridScrollFrame_Update(hsf, totalCount * buttonHeight, hsf:GetHeight())
end, 1, #hsf.buttons)


-- this is the update function, this will be called by the HybridScrollFrameTemplate, all that needs doing here is mapping your data to the buttons
hsf.update = function()
    local offset = HybridScrollFrame_GetOffset(hsf)
    watch.updateOffset(offset + 1)




end
local width = hsf:GetWidth()
-- initialize cells
local columnCount = 3
for _, row in ipairs(HybridScrollFrame_GetButtons(hsf)) do
    row:SetPoint("LEFT", 0)
    row:SetPoint("RIGHT", 24)

    local firstCell = CreateFrame("Button", nil, row);
    firstCell:SetClipsChildren(true)
    firstCell:SetText('test' .. 1)
    firstCell:SetWidth(200)
    firstCell:SetNormalFontObject("GameFontNormalSmall")
    firstCell:SetPoint("BOTTOMLEFT", row)
    firstCell:SetPoint("TOPLEFT", row)
    firstCell:Show()

    local t = firstCell:CreateTexture("BACKGROUND")
    -- Add child buttons here.

    t:SetAllPoints()
    t:SetColorTexture(1.0, 0, 0, 0.1)

    local previous = firstCell
    for column = 2, columnCount do
        local c = CreateFrame("Button", nil, row);
        c:SetText('test' .. column)
        c:SetWidth(100)
        c:SetNormalFontObject("GameFontNormalSmall")
        c:SetPoint("TOPLEFT", previous, "TOPRIGHT")
        c:SetPoint("BOTTOMLEFT", row, "BOTTOMRIGHT")
        c:Show()

        local t = c:CreateTexture("BACKGROUND")
        t:SetAllPoints()
        t:SetColorTexture(0, column * 0.2, 0, 0.2)
        previous = c

    end


end
hsf.update()

local resizeButton = CreateFrame("Button", nil, widget)
resizeButton:SetSize(16, 16)
resizeButton:SetPoint("BOTTOMRIGHT")
resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

resizeButton:SetScript("OnMouseDown", function(self, button)
    print(self)
    local frame = self:GetParent()
    frame:StartSizing("BOTTOMRIGHT")
    frame:SetUserPlaced(true)
end)

resizeButton:SetScript("OnMouseUp", function(self, button)
    local frame = self:GetParent()
    frame:StopMovingOrSizing()
    print(frame:GetHeight())
end)
print(#hsf.buttons)

