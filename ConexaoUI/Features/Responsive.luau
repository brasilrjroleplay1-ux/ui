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

local function manualBounds(viewport)
    local width = math.max(1, viewport.X - math.min(24, viewport.X * 0.08))
    local height = math.max(1, viewport.Y - math.min(72, viewport.Y * 0.12))
    return width, height, math.min(320, width), math.min(260, height)
end

-- Express the automatic fit on the same compact-to-full-screen range as the slider.
-- The sidebar is width-led; the top-tab layout is height-led, like the native fit.
function Responsive.percent(viewport, size, mode)
    local width, height, minimumWidth, minimumHeight = manualBounds(viewport)
    local xSpan, ySpan = width - minimumWidth, height - minimumHeight
    local ratio
    if mode == "sidebar" and xSpan > 0 then ratio = (size.X.Offset - minimumWidth) / xSpan
    elseif ySpan > 0 then ratio = (size.Y.Offset - minimumHeight) / ySpan
    elseif xSpan > 0 then ratio = (size.X.Offset - minimumWidth) / xSpan
    else ratio = 1 end
    return math.clamp(math.floor(ratio * 100 + 0.5), 0, 100)
end

function Responsive.fit(viewport, mode, automatic, percent)
    viewport = valid(viewport) and viewport or Vector2.new(1024, 768)
    local fitted = sizing.fit(viewport, mode)
    local width, height = fitted.X.Offset, fitted.Y.Offset
    if automatic == false then
        local availableX, availableY, minimumX, minimumY = manualBounds(viewport)
        local ratio = math.clamp(tonumber(percent) or 75, 0, 100) / 100
        width = minimumX + (availableX - minimumX) * ratio
        height = minimumY + (availableY - minimumY) * ratio
    elseif mode == "sidebar" and viewport.X < 700 and viewport.Y > viewport.X * 1.1 then
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
        if self.WindowSizeSlider and self.WindowSizeSlider.dragging then self._pendingResize = true return end
        local screen = viewport()
        local state = self.UIPreferences
        local size = Responsive.fit(screen, self.layout.mode, state.autoSize, state.sizePercent)
        local changed = size ~= self.size
        local previous = self.SizeInfo
        local percent = state.autoSize == false and (state.sizePercent or 75) or Responsive.percent(screen, size, self.layout.mode)
        self.size = size
        self.SizeInfo = {
            automatic = state.autoSize ~= false, width = size.X.Offset, height = size.Y.Offset,
            screenWidth = screen.X, screenHeight = screen.Y, percent = percent,
        }
        if self.WindowSizeSlider and self.WindowSizeSlider.value ~= percent then
            -- Updating the readout must not fire the manual-size callback or save over it.
            self.WindowSizeSlider:Set(percent, true)
        end
        self:_applyRailWidth()
        if self.RefreshSizeStatus and (changed or not previous or previous.automatic ~= self.SizeInfo.automatic or previous.screenWidth ~= screen.X or previous.screenHeight ~= screen.Y) then
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
