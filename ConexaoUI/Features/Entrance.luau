--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- The native Show path still owns configuration loading, cursor and restore behavior.
-- First-open choreography uses the Gen2 surface, navigation and element reveal helpers.
-- Those helpers and the welcome toast originate in Rayfield Gen2 (c) 2026 Corridon Capital.
local variables = require(script.Parent.Parent.Gen2.utility.variables)
local chrome = require(script.Parent.Parent.Gen2.components.chrome)
local locale = require(script.Parent.Parent.Gen2.utility.locale)
local Entrance = {}

function Entrance.attach(window)
    function window:_firstShow()
        local token = (self._entranceToken or 0) + 1
        self._entranceToken = token
        local function live() return not self.unloaded and not self.hidden and self._entranceToken == token end
        local function after(delay, callback) task.delay(delay, function() if live() then callback() end end) end
        local fade = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local target = self.main.Position
        if self.BrandHeader then self.BrandHeader:Layout() end
        self:_setContentVisible(false)
        self.topbar.Visible, self.drag.drag.Visible, self.main.Visible = false, false, true
        self.main.Size = UDim2.fromOffset(math.floor(self.size.X.Offset * 0.92), math.floor(self.size.Y.Offset * 0.9))
        self.main.Position, self.main.BackgroundTransparency = target + UDim2.fromOffset(0, 14), 1
        variables.tweenService:Create(self.main, TweenInfo.new(0.58, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = self.size, Position = target, BackgroundTransparency = 0 }):Play()
        after(0.12, function()
            self.topbar.Visible = true
            self:_fadeSurfaces(true, fade)
            if self.BrandHeader then self.BrandHeader:SetShown(true, fade, true) end
            if self.title then variables.tweenService:Create(self.title, fade, { TextTransparency = 0 }):Play() end
            if self.subtitle then variables.tweenService:Create(self.subtitle, fade, { TextTransparency = 0.18 }):Play() end
            if self.topbarIcon then variables.tweenService:Create(self.topbarIcon, fade, { ImageTransparency = 0 }):Play() end
            for _, action in ipairs(self.actionContainer:GetChildren()) do
                if action:IsA("Frame") and action:FindFirstChild("ImageLabel") then variables.tweenService:Create(action.ImageLabel, fade, { ImageTransparency = 0.35 }):Play() end
            end
            if self.settingsAction and self.selectedTab == self.rfSettings then self.settingsAction.iconLabel.ImageTransparency = 0.2 end
            for _, tag in ipairs(self.tags) do tag:_setShown(true, fade) end
        end)
        after(0.24, function()
            self:_setContentVisible(true)
            self:_setTabSectionsVisible(true)
            self:_setTabSectionsShown(true, fade)
            for _, tab in ipairs(self.tabs) do
                if not tab.neglectSelector then
                    tab.topbarItem.Visible = true
                    tab:_applyVisual(self.selectedTab == tab and "selected" or "unselected", fade)
                    tab:_spinGradients()
                end
            end
            self:_revealElements(0.035, 0.45)
        end)
        after(0.76, function()
            self.animating, self._revealing = false, false
            self:_applyWindowSize()
            self:_syncDragBar()
            self.drag.drag.Visible = true
            variables.tweenService:Create(self.drag.dragCosmetic, fade, { Size = UDim2.fromOffset(100, 4), BackgroundTransparency = 0.7 }):Play()
            if self.BrandHeader then self.BrandHeader:Layout() end
            local player = variables.localPlayer
            if player and self.settings.welcomeToast and chrome.isNewUser() then
                self:Toast({ title = player.DisplayName, subtitle = locale.resolve("Signed in as"), subtitleAbove = true, avatar = player.UserId, minWidth = 220 })
            end
        end)
    end
end

return Entrance
