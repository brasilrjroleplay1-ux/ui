--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Compact chrome with a labelled sidebar whenever the window has room for it.
local sidebar = require(script.Parent.Parent.Gen2.components.sidebar)
local Shell = {}
function Shell.attach(window)
    local layout = table.clone(window.layout)
    window.layout, window.StudioShell = layout, true
    local delta = layout.topbarHeight - 44
    layout.topbarHeight, layout.chromeHeight = 44, layout.chromeHeight - delta
    layout.fadeSize, layout.fadeTransparency = UDim2.new(1, 0, 0, 20), NumberSequence.new(1)
    window.topbar.Size = UDim2.new(1, 0, 0, 44)
    window.elements.Size = UDim2.new(1, 0, 1, -layout.chromeHeight)
    if window.elementsCorner then window.elementsCorner.CornerRadius = UDim.new(0, 8) end
    window.windowCorner.CornerRadius, window.theme.CornerRoundness = UDim.new(0, 10), UDim.new(0, 10)
    if window.elementsStroke then window.elementsStroke.Enabled = false end
    if layout.mode == "sidebar" then
        layout.railWidth, layout.railCollapsedWidth, layout.railCollapseBelow = 196, 64, 480
        layout.rowInset, layout.rowHeight, layout.rowCornerRadius, layout.rowSpacing = 8, 38, 8, 4
        layout.rowPadding, layout.rowIconSize, layout.footerHeight, layout.railPadding = 10, 20, 60, 10
        layout.cardTransparency = 1
        window.tabListLayout.Padding = UDim.new(0, 4)
        for _, child in ipairs(window.tabList:GetChildren()) do
            if child:IsA("UIPadding") then child.PaddingTop, child.PaddingBottom = UDim.new(0, 10), UDim.new(0, 10) end
        end
        if window.profile then window.profile.Size = UDim2.new(1, 0, 0, 60) end
        window:_applyRailWidth()
        sidebar.reflowProfile(window)
        window.settingsAction.action.Visible = false -- Settings remains directly available in the sidebar.
        local applyWidth = window._applyRailWidth
        function window:_applyRailWidth()
            applyWidth(self)
            for _, tab in ipairs(self.tabs) do
                if tab.topbarItemTitle then
                    tab.topbarItemTitle.AutomaticSize, tab.topbarItemTitle.TextWrapped = Enum.AutomaticSize.None, false
                    tab.topbarItemTitle.TextTruncate = Enum.TextTruncate.AtEnd
                    tab.topbarItemTitle.Size = UDim2.new(1, tab.topbarItemIcon and -26 or 0, 0, 20)
                end
            end
            for _, section in ipairs(self.tabSections) do section:_setVisible(not self.hidden and not self.minimised and not self._searching) end
        end
        local createSection = window.CreateSection
        function window:CreateSection(...)
            local section = createSection(self, ...)
            local visible = section._setVisible
            function section:_setVisible(value)
                visible(self, value and window.sidebar.Size.X.Offset >= window.layout.railWidth)
            end
            section:_setVisible(not self.hidden and not self.minimised and not self._searching)
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
