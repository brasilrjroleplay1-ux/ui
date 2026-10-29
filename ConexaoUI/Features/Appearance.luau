--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Appearance = {}
local tweens = game:GetService("TweenService")
local instant = TweenInfo.new(0)

function Appearance.attach(window)
    function window:ApplyTransparency()
        if self.unloaded then return end
        local alpha = math.clamp(tonumber(self.UIPreferences.transparency) or 0, 0, 100) / 100
        self.theme.ElementTransparency = alpha
        -- Preserve readable text/icons; change the window and control backgrounds only.
        for instance, bindings in pairs(self.themeProperties) do
            if bindings.BackgroundTransparency == "ElementTransparency" then
                -- Replace an in-flight reveal/theme tween for this property as well.
                tweens:Create(instance, instant, { BackgroundTransparency = alpha }):Play()
            end
        end
        -- Alpha on the gradients composes with Gen2's reveal tweens, rather than fighting
        -- the main frame's combined size/background animation during a restore.
        self.windowGradient.Transparency = NumberSequence.new(alpha)
        local points = {}
        for _, point in ipairs(self.layout.fadeTransparency.Keypoints) do
            table.insert(points, NumberSequenceKeypoint.new(point.Time, 1 - (1 - point.Value) * (1 - alpha), point.Envelope * (1 - alpha)))
        end
        self.bottomFadeGradient.Transparency = NumberSequence.new(points)
    end
    local fade = window._fadeSurfaces
    function window:_fadeSurfaces(shown, info)
        fade(self, shown, info)
        if shown and self.profile and self.profile.Visible then
            tweens:Create(self.profileSubtitle, info or instant, { TextTransparency = 0.25 }):Play()
        end
    end
    local show = window.Show
    function window:Show(...)
        local result = show(self, ...)
        self:ApplyTransparency()
        return result
    end
    window:ApplyTransparency()
end

return Appearance
