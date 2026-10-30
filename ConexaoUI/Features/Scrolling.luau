--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Scrolling = {}
local function ready(window)
    return not window.unloaded and not window.hidden and not window.minimised and not window.animating and not window._revealing
        and not (window.WindowSizeSlider and window.WindowSizeSlider.dragging)
end
local function viewportHeight(frame)
    local size = frame.AbsoluteWindowSize
    if typeof(size) == "Vector2" and size.Y > 0 then return size.Y end
    return frame.AbsoluteSize.Y
end

function Scrolling.frame(window, owner, frame, layout)
    local self = { frame = frame, layout = layout, desiredY = 0, height = 0, view = 0, atEnd = false, pending = false, writing = false }
    owner._scrollers = owner._scrollers or {}
    table.insert(owner._scrollers, self)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.None
    frame.Active, frame.ScrollingEnabled = true, true
    frame.ElasticBehavior = Enum.ElasticBehavior.Never
    frame.ScrollBarThickness = 3
    frame.VerticalScrollBarInset = Enum.ScrollBarInset.None
    frame.ScrollingDirection = Enum.ScrollingDirection.Y
    if typeof(frame.CanvasPosition) ~= "Vector2" then frame.CanvasPosition = Vector2.new(0, 0) end
    window.themeProperties[frame] = window.themeProperties[frame] or {}
    window.themeProperties[frame].ScrollBarImageColor3 = "AccentColor"
    frame.ScrollBarImageColor3 = window.theme.AccentColor
    function self:Sync()
        if window.unloaded or not frame.Parent or not ready(window) or self.held then return end
        local view = viewportHeight(frame)
        if view <= 0 then return end
        local content = layout.AbsoluteContentSize
        local height = typeof(content) == "Vector2" and content.Y or 0
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("UIPadding") then
                height += child.PaddingTop.Offset + child.PaddingTop.Scale * view
                    + child.PaddingBottom.Offset + child.PaddingBottom.Scale * view
            end
        end
        height = math.max(0, math.ceil(height))
        local maximum = math.max(0, height - view)
        local desired = self.atEnd and maximum or self.desiredY
        self.writing = true
        frame.CanvasSize = UDim2.fromOffset(0, height)
        frame.CanvasPosition = Vector2.new(0, math.clamp(desired, 0, maximum))
        frame.ScrollBarImageTransparency = maximum > 0 and 0.35 or 1
        self.writing = false
        self.height, self.view = height, view
        self.desiredY = frame.CanvasPosition.Y
        self.atEnd = maximum > 0 and self.desiredY >= maximum - 2
    end
    function self:Queue()
        if self.pending then return end
        self.pending = true
        task.defer(function() self.pending = false self:Sync() end)
    end
    function self:SetHeld(held)
        if held and not self.held then self.wasEnabled = frame.ScrollingEnabled self.held = true frame.ScrollingEnabled = false
        elseif not held and self.held then self.held = false frame.ScrollingEnabled = self.wasEnabled self:Queue() end
    end
    window:ConnectFor(owner, layout:GetPropertyChangedSignal("AbsoluteContentSize"), function() self:Queue() end)
    window:ConnectFor(owner, frame:GetPropertyChangedSignal("AbsoluteWindowSize"), function() self:Queue() end)
    window:ConnectFor(owner, frame:GetPropertyChangedSignal("AbsoluteSize"), function() self:Queue() end)
    window:ConnectFor(owner, frame:GetPropertyChangedSignal("CanvasPosition"), function()
        if self.writing or not ready(window) then return end
        if viewportHeight(frame) ~= self.view then self:Queue() return end
        self.desiredY = math.clamp(frame.CanvasPosition.Y, 0, math.max(0, self.height - self.view))
        self.atEnd = self.height > self.view and self.desiredY >= self.height - self.view - 2
    end)
    self:Queue()
    return self
end

function Scrolling.tab(tab)
    if tab._scrollController then return end
    tab._scrollController = Scrolling.frame(tab.window, tab, tab.tabPage, tab.tabPageLayout)
end

function Scrolling.attachWindow(window)
    local dirty, wasReady = true, false
    local function refresh(owner)
        if type(owner.Layout) == "function" then owner:Layout() end
        if owner.__type == "Slider" and not owner.dragging then owner:_applyLayout() end
        if owner._layoutConexaoControl then owner:_layoutConexaoControl() end
        if owner._layoutConexaoHeader then owner:_layoutConexaoHeader() end
        if owner._scrollers then for _, scroll in ipairs(owner._scrollers) do scroll:Queue() end end
        for _, element in ipairs(owner.elements or {}) do refresh(element) end
    end
    function window:RefreshContentLayouts()
        if not ready(self) then dirty = true return end
        for _, tab in ipairs(self.tabs) do refresh(tab) end
    end
    window:Connect(window.main:GetPropertyChangedSignal("AbsoluteSize"), function() dirty = true end)
    window:Connect(game:GetService("RunService").Heartbeat, function()
        local nowReady = ready(window)
        if nowReady and (dirty or not wasReady) then dirty = false window:RefreshContentLayouts() end
        wasReady = nowReady
    end)
    local function finishSizeGesture()
        if window.WindowSizeSlider.dragging then window.WindowSizeSlider:_endDrag() end
    end
    for _, name in ipairs({ "Hide", "ToggleMinimise" }) do
        local method = window[name]
        window[name] = function(self, ...) finishSizeGesture() return method(self, ...) end
    end
    window:RefreshContentLayouts()
end

return Scrolling
