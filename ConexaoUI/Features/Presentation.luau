--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Visual hierarchy only. Native tabs, controls, values and callbacks remain their owners.
local selectors = require(script.Parent.Parent.Gen2.components.tabSelector)
local Buttons = require(script.Parent.ActionButton)
local Presentation = {}
local function strong(font) return Font.new(font.Family, Enum.FontWeight.SemiBold, font.Style) end
local function bind(window, node, property, value)
    window.themeProperties[node] = window.themeProperties[node] or {}
    window.themeProperties[node][property] = value
    node[property] = type(value) == "table" and value[2](window.theme[value[1]]) or window.theme[value]
end

local function toggle(control)
    local window, shown = control.window, not control.window.hidden
    control.functionContainer.Size = UDim2.fromOffset(50, 26)
    control.indicator.Size = UDim2.fromOffset(20, 20)
    if window.themeProperties[control.overlay] then window.themeProperties[control.overlay].Visible = nil end
    control.overlay.Visible = false
    bind(window, control.functionContainer, "BackgroundColor3", { "ToggleTrack", function(color) return control.value and window.theme.AccentColor or color end })
    local function paint(animate)
        if window.unloaded or not control.main.Parent then return end
        local info = TweenInfo.new(animate and 0.18 or 0, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local fill = control.value and window.theme.AccentColor or window.theme.ToggleTrack
        local knob = control.value and Buttons.readableColor(Color3.new(1, 1, 1), fill, 2.2) or window.theme.ToggleKnobOff
        window:_reveal(control.functionContainer, { BackgroundColor3 = fill, BackgroundTransparency = shown and 0 or 1 }, true, info)
        window:_reveal(control.indicator, { Position = UDim2.new(0, control.value and 27 or 3, 0.5, 0), BackgroundColor3 = knob,
            BackgroundTransparency = shown and 0 or 1 }, true, info)
        window:_reveal(control.containerStroke, { Transparency = shown and 0.5 or 1 }, true, info)
        window:_reveal(control.indicatorStroke, { Transparency = 1 }, true, info)
        window:_reveal(control.indicatorGlow, { Transparency = 1 }, true, info)
        control.overlay.Visible = false
    end
    local show, refresh = control._setShown, control._refreshTheme
    function control:_setShown(value, animate) shown = value show(self, value, animate) paint(animate) end
    function control:_refreshTheme(...) refresh(self, ...) paint(false) end
    control._animateIndicator = function() paint(true) end
    paint(false)
end

function Presentation.control(control)
    if not control or control._presentation then return end
    control._presentation = true
    if control.__type == "Group" then
        for _, child in ipairs(control.elements or {}) do Presentation.control(child) end
        return
    end
    local window, kind = control.window, control.__type
    if kind == "Toggle" then toggle(control) end
    if kind == "Slider" then
        control.handle.Size = UDim2.fromOffset(20, 20)
        local held = control._setHeld
        function control:_setHeld(value)
            held(self, value)
            if window.unloaded or not self.main.Parent then return end
            local size = value and 22 or 20
            self._handleWidth = size
            window:_reveal(self.handle, { Size = UDim2.fromOffset(size, size) }, true, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
        end
    end
    local readable = kind == "Descriptor" and control.titleLabel or (kind == "Text" and control.body or (kind == "Section" and control.title))
    if control.title and ({ Button = true, Dropdown = true, Text = true, Section = true })[kind] then
        bind(window, control.title, "FontFace", { "Font", strong })
    end
    if kind == "Section" then control.title.TextSize = 14 end
    local captions = {}
    if readable then table.insert(captions, readable) end
    if control.descriptor then table.insert(captions, control.descriptor.titleLabel) end
    if #captions > 0 then
        for _, caption in ipairs(captions) do
            bind(window, caption, "TextColor3", { "ContentColor", function(color) return window.theme.MutedContent or color end })
        end
        local show = control._setShown or function() end
        function control:_setShown(shown, animate)
            self._presentationShown = shown
            show(self, shown, animate)
            if window.unloaded or not self.main.Parent then return end
            for _, caption in ipairs(captions) do window:_reveal(caption, { TextTransparency = shown and 0 or 1 }, animate) end
        end
        control:_setShown(not window.hidden, false)
    end
    if kind == "Button" then
        for _, node in ipairs(control.main:GetChildren()) do
            if node:IsA("UIGradient") then
                bind(window, node, "Color", { "ElementGradient", function(sequence) return window.theme.ButtonGradient or sequence end })
            end
        end
    end
    if control.descriptor then Presentation.control(control.descriptor) end
end

function Presentation.tab(tab)
    if tab._presentationTab then return end
    tab._presentationTab = true
    local window = tab.window
    if tab.tabPageLayout then tab.tabPageLayout.Padding = UDim.new(0, 10) end
    if not tab.topbarItem then return end
    for _, node in ipairs(tab.topbarItem:GetDescendants()) do
        if node:IsA("GuiObject") and node.ZIndex < 2 then node.ZIndex = 2 end
    end
    tab.topbarItem.ZIndex = 2
    local marker = window:Create("Frame", { Name = "ActiveTab", Parent = tab.topbarItem, BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0, 3, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(3, 18), ZIndex = 4,
    }, { BackgroundColor3 = "AccentColor" })
    window:Create("UICorner", { Parent = marker, CornerRadius = UDim.new(1, 0) })
    tab.activeMarker = marker
    if tab.topbarItemTitle then
        tab.topbarItemTitle.TextSize = 15
        bind(window, tab.topbarItemTitle, "FontFace", { "Font", function(font)
            return Font.new(font.Family, tab._presentationState == "selected" and Enum.FontWeight.SemiBold or Enum.FontWeight.Medium, font.Style)
        end })
    end
    if tab.topbarItemShadow then bind(window, tab.topbarItemShadow, "Color", "AccentColor") end
    function tab:_applyVisual(state, info)
        if not self.topbarItem or window.unloaded then return end
        self._presentationState = state
        local sidebar = window.layout.mode == "sidebar"
        local states = {
            selected = { background = sidebar and 0.02 or 0, stroke = 0.4, content = 0, shadow = 0.88 },
            hover = { background = 0.55, stroke = 0.72, content = 0.08, shadow = 1 },
            unselected = { background = 1, stroke = 1, content = 0.18, shadow = 1 },
            hidden = { background = 1, stroke = 1, content = 1, shadow = 1 },
        }
        local target = states[state]
        if not target then return end
        selectors.applyVisual(self, target, info)
        window:_reveal(marker, { BackgroundTransparency = state == "selected" and 0 or 1 }, info ~= nil, info)
        if self.topbarItemTitle then
            self.topbarItemTitle.FontFace = Font.new(window.theme.Font.Family, state == "selected" and Enum.FontWeight.SemiBold or Enum.FontWeight.Medium, window.theme.Font.Style)
        end
    end
    -- The new selected fill is deliberately still; selection already has a short settle.
    tab._spinGradients = function() end
    tab:_applyVisual(window.hidden and "hidden" or (window.selectedTab == tab and "selected" or "unselected"))
end

function Presentation.attach(window)
    local self = { window = window, surfaces = {} }
    window.Presentation = self
    for _, root in ipairs(window.sidebar and { window.topbar, window.sidebar } or { window.topbar }) do
        for _, node in ipairs(root:GetDescendants()) do
            if node:IsA("GuiObject") and node.ZIndex < 2 then node.ZIndex = 2 end
        end
    end
    local function surface(parent, name, props, key)
        props.Name, props.Parent = name, parent
        props.BackgroundTransparency, props.BackgroundColor3, props.BorderSizePixel, props.ZIndex = 1, Color3.new(1, 1, 1), 0, 1
        props.Active, props.Selectable = false, false
        local node = window:Create("Frame", props)
        window:Create("UICorner", { Parent = node, CornerRadius = UDim.new(0, 12) })
        local gradient = window:Create("UIGradient", { Parent = node, Rotation = 15 })
        bind(window, gradient, "Color", { "WindowColor", function(sequence) return window.theme[key] or sequence end })
        table.insert(self.surfaces, node)
        return node
    end
    self.header = surface(window.topbar, "HeaderSurface", { Position = UDim2.fromOffset(6, 4), Size = UDim2.new(1, -12, 1, -8) }, "HeaderGradient")
    if window.sidebar then
        self.rail = surface(window.sidebar, "NavigationSurface", { Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 1, -12) }, "RailGradient")
    end
    function self:SetShown(shown, animate, info)
        local alpha = math.clamp(tonumber(window.UIPreferences.transparency) or 0, 0, 100) / 100
        for _, node in ipairs(self.surfaces) do
            window:_reveal(node, { BackgroundTransparency = shown and alpha or 1 }, animate, info)
        end
    end
    local fade = window._fadeSurfaces
    function window:_fadeSurfaces(shown, info)
        fade(self, shown, info)
        self.Presentation:SetShown(shown or (self.minimised and not self.hidden), info ~= nil, info)
    end
    local transparency = window.ApplyTransparency
    function window:ApplyTransparency(...)
        local result = transparency(self, ...)
        self.Presentation:SetShown(not self.hidden, false)
        return result
    end
    self:SetShown(not window.hidden, false)
end

return Presentation
