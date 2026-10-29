--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- The resize/reveal coordination follows Rayfield Gen2 (c) 2026 Corridon Capital.
local sizing = require(script.Parent.Parent.Gen2.utility.windowSizing)
local Responsive = {}

local function valid(viewport)
    return typeof(viewport) == "Vector2"
        and viewport.X > 1 and viewport.Y > 1
        and viewport.X < math.huge and viewport.Y < math.huge
end

function Responsive.fit(viewport, mode)
    viewport = valid(viewport) and viewport or Vector2.new(1024, 768)
    local fitted = sizing.fit(viewport, mode)
    local width, height = fitted.X.Offset, fitted.Y.Offset
    if mode == "sidebar" and viewport.X < 700 and viewport.Y > viewport.X * 1.1 then
        -- A phone held upright can use its height instead of being forced into a letterbox.
        width = math.min(viewport.X * 0.92, viewport.X - 24)
        height = math.min(640, viewport.Y * 0.88, viewport.Y - 72)
    end
    -- Even an unusually small split-screen must fit; the native minimum is only an ideal.
    width = math.max(1, math.floor(math.min(width, viewport.X - math.min(24, viewport.X * 0.08))))
    height = math.max(1, math.floor(math.min(height, viewport.Y - math.min(72, viewport.Y * 0.12))))
    return UDim2.fromOffset(width, height)
end

function Responsive.attach(window)
    local function viewport()
        local camera = workspace.CurrentCamera
        local size = camera and camera.ViewportSize
        if not valid(size) then size = window.screenGui.AbsoluteSize end
        if not valid(size) then size = window._lastViewport end
        if not valid(size) then size = Vector2.new(1024, 768) end
        window._lastViewport = size
        return size
    end

    -- Gen2's existing viewport and CurrentCamera listeners dispatch to this method, including
    -- their two-second backstop. No additional polling loop is needed.
    function window:_applyWindowSize()
        if self.unloaded then return end
        local screen = viewport()
        local size = Responsive.fit(screen, self.layout.mode)
        local changed = size ~= self.size
        local previous = self.SizeInfo
        self.size = size
        self.SizeInfo = {
            automatic = true, width = size.X.Offset, height = size.Y.Offset,
            screenWidth = screen.X, screenHeight = screen.Y,
        }
        self:_applyRailWidth()
        if self.RefreshSizeStatus and (changed or not previous or previous.screenWidth ~= screen.X or previous.screenHeight ~= screen.Y) then
            self:RefreshSizeStatus()
        end
        if self.hidden or self.minimised or self.animating or self._revealing then
            self._pendingResize = self._pendingResize or changed
            return
        end
        if not changed and not self._pendingResize then return end
        self._pendingResize = false
        self.main.Size = size
        self:_clampToScreen()
        self:_syncDragBar()
    end
    function window:RefreshSize()
        self:_applyWindowSize()
        return self.size
    end
    window:Connect(window.screenGui:GetPropertyChangedSignal("AbsoluteSize"), function() window:_applyWindowSize() end)
    window:_applyWindowSize()
end

return Responsive
