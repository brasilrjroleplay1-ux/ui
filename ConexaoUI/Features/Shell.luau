--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Compact window geometry. Each window owns its layout; Gen2's shared presets stay intact.
local sidebar = require(script.Parent.Parent.Gen2.components.sidebar)
local Shell = {}
function Shell.attach(window)
    local layout = table.clone(window.layout)
    window.layout, window.StudioShell = layout, true
    local delta = layout.topbarHeight - 44
    layout.topbarHeight, layout.chromeHeight = 44, layout.chromeHeight - delta
    layout.fadeSize = UDim2.new(1, 0, 0, 20)
    layout.fadeTransparency = NumberSequence.new(1)
    window.topbar.Size = UDim2.new(1, 0, 0, 44)
    window.elements.Size = UDim2.new(1, 0, 1, -layout.chromeHeight)
    if window.elementsCorner then window.elementsCorner.CornerRadius = UDim.new(0, 8) end
    window.windowCorner.CornerRadius, window.theme.CornerRoundness = UDim.new(0, 10), UDim.new(0, 10)
    if window.elementsStroke then window.elementsStroke.Enabled = false end
    if layout.mode == "sidebar" then
        layout.railWidth, layout.railCollapsedWidth, layout.railCollapseBelow = 60, 52, math.huge
        layout.rowInset, layout.rowHeight, layout.rowCornerRadius, layout.rowSpacing = 6, 38, 8, 6
        layout.rowPadding, layout.rowIconSize, layout.footerHeight, layout.railPadding = 0, 20, 48, 8
        layout.cardTransparency = 1
        window.tabListLayout.Padding = UDim.new(0, 6)
        for _, child in ipairs(window.tabList:GetChildren()) do
            if child:IsA("UIPadding") then child.PaddingTop, child.PaddingBottom = UDim.new(0, 8), UDim.new(0, 8) end
        end
        if window.profile then window.profile.Size = UDim2.new(1, 0, 0, 48) end
        sidebar.applyWidth(window, 52)
        sidebar.reflowProfile(window)
        if window.searchAction then
            local action = window.searchAction.action
            action.Parent, action.LayoutOrder, action.Size = window.tabList, 900, UDim2.fromOffset(38, 38)
            action.BackgroundTransparency = 1
            window:Create("UICorner", { Parent = action, CornerRadius = UDim.new(0, 8) })
            local fade = window._fadeSurfaces
            function window:_fadeSurfaces(shown, info)
                fade(self, shown, info)
                self:_reveal(self.searchAction.iconLabel, { ImageTransparency = shown and 0.25 or 1 }, info ~= nil, info)
            end
        end
        window.settingsAction.action.Visible = false -- The settings selector remains in the icon rail.
        local createSection = window.CreateSection
        function window:CreateSection(...)
            local section = createSection(self, ...)
            if not section.main then return section end
            section.main.AutomaticSize, section.main.Size = Enum.AutomaticSize.None, UDim2.new(1, -20, 0, 8)
            section.title.Visible = false
            if section.iconLabel then section.iconLabel.Visible = false end
            local storage = self:Create("Frame", { Parent = section.main, Name = "PreservedSectionLayout", Visible = false, Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 })
            for _, child in ipairs(section.main:GetChildren()) do
                if child:IsA("UIListLayout") then child.Parent = storage
                elseif child:IsA("UIPadding") then
                    child.PaddingTop, child.PaddingBottom, child.PaddingLeft, child.PaddingRight = UDim.new(0, 0), UDim.new(0, 0), UDim.new(0, 0), UDim.new(0, 0)
                end
            end
            local line = self:Create("Frame", { Parent = section.main, Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 1 }, { BackgroundColor3 = "SurfaceStroke" })
            local shown = section._setShown
            function section:_setShown(value, animate)
                shown(self, value, animate)
                self.window:_reveal(line, { BackgroundTransparency = value and 0.75 or 1 }, animate ~= nil and animate ~= false, typeof(animate) == "TweenInfo" and animate or nil)
            end
            if not self.hidden and not self.minimised then section:_setShown(true, false) end
            return section
        end
    else
        layout.tabStripTop = layout.tabStripTop - delta
        window.tabList.Position = UDim2.new(0.5, 0, 0, layout.tabStripTop)
        window.bottomFade.Size = UDim2.new(1, 0, 0, 20)
    end
    if window.searchPill then
        local position = window.searchPill.Position
        window.searchPill.Position = UDim2.new(position.X.Scale, position.X.Offset, 0, layout.mode == "sidebar" and layout.chromeHeight + 8 or layout.tabStripTop + 1)
    end
    local fade = window._fadeSurfaces
    function window:_fadeSurfaces(shown, info)
        fade(self, shown, info)
        local visible = shown or (self.minimised and not self.hidden)
        self:_reveal(self.windowStroke, { Transparency = visible and 0.75 or 1 }, info ~= nil, info)
    end
    function window:RefreshShellTheme()
        self.theme.CornerRoundness = UDim.new(0, 10)
        if not self.hidden and not self.minimised then self.windowCorner.CornerRadius = self.theme.CornerRoundness end
    end
end
return Shell
