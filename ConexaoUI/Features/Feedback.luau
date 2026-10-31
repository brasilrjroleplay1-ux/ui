--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Conexão's notification presentation. Native Notify/Toast properties remain accepted.
local variables = require(script.Parent.Parent.Gen2.utility.variables)
local metrics = require(script.Parent.Parent.Gen2.utility.textMetrics)
local image = require(script.Parent.Parent.Gen2.utility.image)
local haptics = require(script.Parent.Parent.Gen2.utility.HapticEngine)
local Feedback, Message = {}, {}
Message.__index = Message
local function finite(value) return type(value) == "number" and value == value and value >= 0 and value < math.huge end
local function bold(font) return Font.new(font.Family, Enum.FontWeight.Bold, font.Style) end
local tones = { success = Color3.fromRGB(52, 211, 153), warning = Color3.fromRGB(250, 184, 62), error = Color3.fromRGB(251, 99, 126) }
local captions = { info = "NOTIFICAÇÃO", success = "CONCLUÍDO", warning = "ATENÇÃO", error = "ERRO" }
local function tone(window, kind)
    local color = tones[kind] or window.theme.AccentColor
    local ink = window.theme.ContentColor
    return ink.R + ink.G + ink.B < 1.5 and color:Lerp(ink, 0.3) or color
end
local function prop(properties, key) return properties[key] or properties[key:sub(1, 1):upper() .. key:sub(2)] end
local function vector(value) return typeof(value) == "Vector2" and finite(value.X) and finite(value.Y) and value.X > 1 and value.Y > 1 end

function Message:_alive() return self.state ~= "destroyed" and not self.window.unloaded and self.main.Parent ~= nil end
function Message:_track(node, property, value) table.insert(self.targets, { node = node, property = property, value = value }) end
function Message:_tween(node, props, seconds)
    local active = self.tweens[node] or {}
    self.tweens[node] = active
    for key in pairs(props) do if active[key] then active[key]:Cancel() end end
    local tween = variables.tweenService:Create(node, TweenInfo.new(seconds, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    for key in pairs(props) do active[key] = tween end
    tween:Play()
end
function Message:_paint(shown, animate)
    for _, target in ipairs(self.targets) do
        local value = shown and target.value or 1
        if animate then self:_tween(target.node, { [target.property] = value }, shown and 0.28 or 0.18)
        else target.node[target.property] = value end
    end
end
function Message:_destroy()
    if self.state == "destroyed" then return end
    self.state, self._dismissed = "destroyed", true
    for _, properties in pairs(self.tweens) do for _, tween in pairs(properties) do tween:Cancel() end end
    table.clear(self.tweens)
    self.window:DisconnectMany(self, table.clone(self.connections))
    for _, list in ipairs({ self.manager.messages, self.stack.live }) do
        local index = table.find(list, self)
        if index then table.remove(list, index) end
    end
    self.window:DestroySubtree(self.main)
end
function Message:_dismiss(immediate)
    if self._dismissed or self.state == "destroyed" then return end
    self._dismissed = true
    if immediate or not self:_alive() then self:_destroy() return end
    self.state, self.age = "exiting", 0
    self:_paint(false, true)
    self:_tween(self.scale, { Scale = 0.97 }, 0.22)
    self:_tween(self.body, { Position = self.rest + UDim2.fromOffset(self.kind == "Notification" and 16 or 0, self.kind == "Toast" and 8 or 0) }, 0.22)
    self:_tween(self.main, { Size = UDim2.fromOffset(self.width, 0) }, 0.3)
end
function Message:Close() self:_dismiss() end

function Message:Layout()
    if not self:_alive() or self.state == "exiting" then return end
    self._layoutToken = (self._layoutToken or 0) + 1
    local token, bounds = self._layoutToken, self.manager.bounds
    local window, toast = self.window, self.kind == "Toast"
    local maximum = math.min(toast and 320 or 360, bounds.width)
    local width = maximum
    if toast then
        local extent = metrics.textWidth(bold(window.theme.TitleFont), 15, self.title)
        if self.content ~= "" then extent = math.max(extent, metrics.textWidth(window.theme.Font, 12, self.content)) end
        width = math.clamp(extent + 104, math.min(self.minWidth, maximum), maximum)
    end
    local small = width < 280
    local iconSize, left = small and 32 or (toast and 36 or 42), small and 56 or (toast and 62 or 72)
    local column = math.max(1, width - left - 44)
    local textWidth = math.max(1, column - 6) -- reserve the scrollbar before measuring wrapped text
    local titleSize, contentSize = toast and 15 or 16, toast and 13 or 14
    local titleHeight = math.max(titleSize + 4, metrics.textHeight(bold(window.theme.TitleFont), titleSize, self.title, textWidth))
    local contentHeight = self.content ~= "" and math.max(contentSize + 4, metrics.textHeight(window.theme.Font, contentSize, self.content, textWidth)) or 0
    local textHeight = titleHeight + (contentHeight > 0 and contentHeight + 5 or 0)
    local top, bottom = toast and 15 or 34, 18
    local wanted = math.max(toast and 66 or 94, top + textHeight + bottom)
    local height = math.max(1, math.min(wanted, bounds.height - 8, toast and 180 or 320))
    if not self:_alive() or token ~= self._layoutToken then return end -- font measurement can yield
    self.width, self.height = math.floor(width), math.ceil(height)
    self.body.Size = UDim2.fromOffset(self.width, self.height)
    self.iconPlate.Position, self.iconPlate.Size = UDim2.fromOffset(14, toast and 15 or 18), UDim2.fromOffset(iconSize, iconSize)
    self.closeButton.Position, self.closeButton.Size = UDim2.new(1, -10, 0, 10), UDim2.fromOffset(32, 32)
    if self.caption then self.caption.Position, self.caption.Size = UDim2.fromOffset(left, 13), UDim2.fromOffset(math.max(1, column), 14) end
    local viewHeight = math.max(1, self.height - top - bottom)
    self.scrollable = textHeight > viewHeight
    self.container.Position, self.container.Size = UDim2.fromOffset(left, top), UDim2.fromOffset(column, viewHeight)
    self.container.ScrollingEnabled = self.scrollable
    self.container.ScrollBarImageTransparency = self.scrollable and 0.45 or 1
    self.titleLabel.TextSize, self.titleLabel.Size = titleSize, UDim2.fromOffset(textWidth, titleHeight)
    self.titleLabel.Position = UDim2.fromOffset(0, self.subtitleAbove and contentHeight > 0 and contentHeight + 5 or 0)
    if self.descriptionLabel then
        self.descriptionLabel.TextSize, self.descriptionLabel.Size = contentSize, UDim2.fromOffset(textWidth, contentHeight)
        self.descriptionLabel.Position = UDim2.fromOffset(0, self.subtitleAbove and 0 or titleHeight + 5)
    end
    self.container.CanvasSize = UDim2.fromOffset(0, textHeight)
    self.container.CanvasPosition = Vector2.new(0, math.clamp(self.container.CanvasPosition.Y, 0, math.max(0, textHeight - viewHeight)))
    if self.state == "building" then self.main.Size = UDim2.fromOffset(self.width, 0)
    else self:_tween(self.main, { Size = UDim2.fromOffset(self.width, self.height + 8) }, 0.2) end
end

local function make(manager, properties, kind, stack)
    if manager.destroyed or manager.window.unloaded then return end
    properties = type(properties) == "table" and properties or {}
    local window = manager.window
    local flavor = tostring(prop(properties, "type") or "info"):lower()
    if not captions[flavor] then flavor = "info" end
    local self = setmetatable({ manager = manager, window = window, stack = stack, kind = kind, __type = kind,
        title = tostring(prop(properties, "title") or ""),
        content = tostring(prop(properties, kind == "Toast" and "subtitle" or "content") or ""),
        icon = prop(properties, "icon"), avatar = prop(properties, "avatar"), flavor = flavor,
        minWidth = finite(prop(properties, "minWidth")) and prop(properties, "minWidth") or 150,
        subtitleAbove = prop(properties, "subtitleAbove") == true, duration = prop(properties, "duration"),
        elapsed = 0, age = 0, state = "building", targets = {}, tweens = {}, connections = {}, _hovered = false, _dismissed = false,
    }, Message)
    if not finite(self.duration) then self.duration = math.clamp(#(self.title .. self.content) * 0.05 + 3, 3, 9) end
    local z = kind == "Toast" and 2000 or 1500
    local function create(class, props, theme) return window:Create(class, props, theme) end
    local function frame(parent, name, props, theme)
        local p = { Parent = parent, Name = name, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = z + 1 }
        for key, value in pairs(props or {}) do p[key] = value end
        return create("Frame", p, theme)
    end
    local function round(node, radius) create("UICorner", { Parent = node, CornerRadius = UDim.new(0, radius) }) end
    local function track(node, property, value) self:_track(node, property, value) end
    local function accent() return { "AccentColor", function() return tone(window, flavor) end } end
    local function label(parent, name, value, size, strong, dim)
        local node = create("TextLabel", { Parent = parent, Name = name, Text = value, BackgroundTransparency = 1, TextTransparency = 1,
            TextSize = size, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.None, ZIndex = z + 4,
        }, { TextColor3 = "ContentColor", FontFace = strong and { "TitleFont", bold } or "Font" })
        track(node, "TextTransparency", dim or 0)
        return node
    end
    manager.count += 1
    self.main = frame(stack.root, kind, { Size = UDim2.fromOffset(0, 0), LayoutOrder = kind == "Toast" and -manager.count or manager.count, ZIndex = z })
    table.insert(manager.messages, self)
    table.insert(stack.live, self)
    self.rest = UDim2.new(0.5, 0, 0, 8)
    self.body = frame(self.main, "MessageCard", { AnchorPoint = Vector2.new(0.5, 0), Position = self.rest + UDim2.fromOffset(kind == "Notification" and 28 or 0, kind == "Toast" and (stack.top and -14 or 14) or 0), BackgroundColor3 = Color3.new(1, 1, 1), Active = true })
    round(self.body, 14)
    self.scale = create("UIScale", { Parent = self.body, Scale = 0.96 })
    self.gradient = create("UIGradient", { Parent = self.body, Rotation = 18 }, { Color = { "StatBackground", function(base)
        local color = tone(window, flavor)
        return ColorSequence.new(base:Lerp(color, 0.14), base:Lerp(color, 0.025))
    end } })
    track(self.body, "BackgroundTransparency", 0.02)
    self.stroke = create("UIStroke", { Parent = self.body, Thickness = 1, Transparency = 1 }, { Color = "SurfaceStroke" })
    track(self.stroke, "Transparency", 0.5)
    self.signal = frame(self.body, "MessageAccent", { Position = UDim2.fromOffset(3, 14), Size = UDim2.new(0, 3, 1, -28), ZIndex = z + 2 }, { BackgroundColor3 = accent() })
    round(self.signal, 2)
    track(self.signal, "BackgroundTransparency", 0.08)
    self.iconPlate = frame(self.body, "IconPlate", nil, { BackgroundColor3 = accent() })
    round(self.iconPlate, 11)
    track(self.iconPlate, "BackgroundTransparency", 0.78)
    local iconRim = create("UIStroke", { Parent = self.iconPlate, Thickness = 1, Transparency = 1 }, { Color = accent() })
    track(iconRim, "Transparency", 0.63)
    local hasAvatar = kind == "Toast" and finite(self.avatar) and self.avatar > 0
    if hasAvatar or (self.icon ~= nil and self.icon ~= "" and self.icon ~= 0) then
        self.iconLabel = create("ImageLabel", { Name = "MessageIcon", Parent = self.iconPlate, Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(1, hasAvatar and -4 or -16, 1, hasAvatar and -4 or -16), BackgroundTransparency = 1, ImageTransparency = 1,
            ScaleType = Enum.ScaleType.Fit, ResampleMode = Enum.ResamplerMode.Default, ZIndex = z + 4,
        }, not hasAvatar and { ImageColor3 = accent() } or nil)
        round(self.iconLabel, hasAvatar and 9 or 0)
        track(self.iconLabel, "ImageTransparency", 0)
    else
        local glyph = frame(self.iconPlate, "StatusGlyph", { Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(20, 20), ZIndex = z + 4 })
        local function line(x, y, width, angle)
            local node = frame(glyph, "Stroke", { Position = UDim2.fromOffset(x, y), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(width, 2), Rotation = angle, ZIndex = z + 4 }, { BackgroundColor3 = accent() })
            round(node, 1) track(node, "BackgroundTransparency", 0)
        end
        if flavor == "success" then line(6, 12, 8, 45) line(13, 10, 13, -48)
        elseif flavor == "error" then line(10, 10, 15, 45) line(10, 10, 15, -45)
        else
            local glyphText = label(glyph, "Symbol", flavor == "warning" and "!" or "i", 20, true)
            glyphText.TextXAlignment, glyphText.TextYAlignment, glyphText.Size = Enum.TextXAlignment.Center, Enum.TextYAlignment.Center, UDim2.fromScale(1, 1)
            window.themeProperties[glyphText].TextColor3 = accent()
            glyphText.TextColor3 = tone(window, flavor)
        end
    end
    self.closeButton = create("TextButton", { Name = "DismissMessage", Parent = self.body, AnchorPoint = Vector2.new(1, 0), Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = z + 6 }, { BackgroundColor3 = "NeutralButton" })
    round(self.closeButton, 7)
    track(self.closeButton, "BackgroundTransparency", 0.45)
    for _, angle in ipairs({ 45, -45 }) do
        local mark = frame(self.closeButton, "CloseMark", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(10, 1.5), Rotation = angle, ZIndex = z + 7 }, { BackgroundColor3 = "ContentColor" })
        track(mark, "BackgroundTransparency", 0.22)
    end
    if kind == "Notification" then self.caption = label(self.body, "Category", captions[flavor], 10, true, 0.18) end
    self.container = create("ScrollingFrame", { Name = "MessageText", Parent = self.body, BackgroundTransparency = 1, BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.None, CanvasSize = UDim2.new(), CanvasPosition = Vector2.new(0, 0),
        ClipsDescendants = true, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 3, ScrollBarImageTransparency = 1,
        Active = true, ElasticBehavior = Enum.ElasticBehavior.Never, ZIndex = z + 3,
    }, { ScrollBarImageColor3 = accent() })
    self.titleLabel = label(self.container, "Title", self.title, kind == "Toast" and 15 or 16, true)
    if self.content ~= "" then self.descriptionLabel = label(self.container, "Description", self.content, kind == "Toast" and 12 or 13, false, 0.16) end
    self.subtitleLabel = kind == "Toast" and self.descriptionLabel or nil
    self.progressTrack = frame(self.body, "LifetimeTrack", { Position = UDim2.new(0, 14, 1, -7), Size = UDim2.new(1, -28, 0, 2) }, { BackgroundColor3 = "SurfaceStroke" })
    round(self.progressTrack, 1) track(self.progressTrack, "BackgroundTransparency", 0.82)
    self.progress = frame(self.progressTrack, "LifetimeRemaining", { Size = UDim2.fromScale(1, 1), ZIndex = z + 2 }, { BackgroundColor3 = accent() })
    round(self.progress, 1) track(self.progress, "BackgroundTransparency", 0.06)
    window:ConnectFor(self, self.body.MouseEnter, function() self._hovered = true end)
    window:ConnectFor(self, self.body.MouseLeave, function() self._hovered = false end)
    window:ConnectFor(self, self.body.InputBegan, function(input)
        if not self.scrollable and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then self:Close() end
    end)
    window:ConnectFor(self, self.closeButton.MouseButton1Click, function() self:Close() end)
    if self.iconLabel then
        local uri = hasAvatar and image.avatar(self.avatar, function(value)
            if self:_alive() and self.iconLabel.Parent then image.assign(self.iconLabel, "Image", value) end
        end) or self.icon
        if not self:_alive() then return self end
        image.assign(self.iconLabel, "Image", uri)
    end
    self:Layout()
    if not self:_alive() then return self end
    self.state = "entering"
    self:_paint(true, true)
    self:_tween(self.main, { Size = UDim2.fromOffset(self.width, self.height + 8) }, 0.32)
    self:_tween(self.body, { Position = self.rest }, 0.32)
    self:_tween(self.scale, { Scale = 1 }, 0.32)
    haptics.notify()
    manager:Trim(stack)
    return self
end

function Feedback.attach(window)
    local self = { window = window, messages = {}, stacks = {}, count = 0, connections = {} }
    window.Feedback = self
    function self:Geometry(force)
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize
        if not vector(viewport) then viewport = vector(window.screenGui.AbsoluteSize) and window.screenGui.AbsoluteSize or Vector2.new(1024, 768) end
        local top, bottom = Vector2.new(), Vector2.new()
        local ok, a, b = pcall(variables.guiService.GetGuiInset, variables.guiService)
        if ok then if typeof(a) == "Vector2" then top = a end if typeof(b) == "Vector2" then bottom = b end end
        local margin = math.min(16, viewport.X * 0.04)
        local upper = math.max(12, top.Y + 8)
        if window._collapsedShown then upper = math.max(upper, 94) end
        local bounds = { width = math.max(1, viewport.X - top.X - bottom.X - margin * 2), height = math.max(1, viewport.Y - upper - math.max(12, bottom.Y + 8)), margin = margin, top = upper, bottom = math.max(12, bottom.Y + 8), center = (top.X - bottom.X) / 2, right = margin + bottom.X }
        local old = self.bounds
        if not force and old and old.width == bounds.width and old.height == bounds.height and old.top == bounds.top and old.bottom == bounds.bottom and old.center == bounds.center and old.right == bounds.right then return end
        self.bounds = bounds
        for _, stack in pairs(self.stacks) do
            local width = math.min(stack.toast and 320 or 360, bounds.width)
            stack.root.Size = UDim2.fromOffset(width, bounds.height)
            stack.root.Position = stack.toast and (stack.top and UDim2.new(0.5, bounds.center, 0, bounds.top) or UDim2.new(0.5, bounds.center, 1, -bounds.bottom)) or UDim2.new(1, -bounds.right, 1, -bounds.bottom)
        end
        for _, message in ipairs(table.clone(self.messages)) do if message.state ~= "building" then message:Layout() end end
        for _, stack in pairs(self.stacks) do self:Trim(stack) end
    end
    function self:Trim(stack)
        local total = 0
        for _, item in ipairs(stack.live) do total += (item.height or 0) + 8 end
        while #stack.live > 1 and (#stack.live > 6 or total > self.bounds.height) do
            local oldest = stack.live[1]
            total -= (oldest.height or 0) + 8
            oldest:_dismiss(true)
            if oldest.state ~= "destroyed" then oldest:_destroy() end
        end
    end
    function self:Stack(kind, top)
        local key = kind == "Notification" and "notifications" or (top and "_toastsTop" or "_toastsBottom")
        local stack = self.stacks[key]
        if stack then self:Geometry() return stack end
        local root = window:Create("Frame", { Name = kind == "Notification" and "Notifications" or "Toasts", Parent = window.screenGui, BackgroundTransparency = 1, BorderSizePixel = 0,
            AnchorPoint = kind == "Notification" and Vector2.new(1, 1) or Vector2.new(0.5, top and 0 or 1),
            ClipsDescendants = true, ZIndex = kind == "Notification" and 1500 or 2000,
        })
        window:Create("UIListLayout", { Parent = root, FillDirection = Enum.FillDirection.Vertical, VerticalAlignment = top and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) })
        stack = { root = root, live = {}, toast = kind == "Toast", top = top }
        self.stacks[key], window[key] = stack, root
        if kind == "Notification" then window._liveNotifications = stack.live
        else window._liveToasts = window._liveToasts or {} window._liveToasts[root] = stack.live end
        self:Geometry(true)
        return stack
    end
    function self:RefreshTheme() self:Geometry(true) end
    function self:Destroy()
        if self.destroyed then return end
        self.destroyed = true
        for _, message in ipairs(table.clone(self.messages)) do message:_destroy() end
        window:DisconnectMany(self, table.clone(self.connections))
        for _, stack in pairs(self.stacks) do window:DestroySubtree(stack.root) end
        table.clear(self.stacks)
    end
    function window:Notify(props)
        if self.unloaded or self.Feedback.destroyed then return end
        props = type(props) == "table" and props or {}
        local title = prop(props, "title")
        assert(type(title) == "string" and title:match("%S"), "Notify requires a non-empty title")
        local stack = self.Feedback:Stack("Notification", false)
        return make(self.Feedback, props, "Notification", stack)
    end
    function window:Toast(props)
        if self.unloaded or self.Feedback.destroyed then return end
        props = type(props) == "table" and props or {}
        local top = tostring(prop(props, "position") or "Top"):lower() ~= "bottom"
        local stack = self.Feedback:Stack("Toast", top)
        return make(self.Feedback, props, "Toast", stack)
    end
    window:ConnectFor(self, variables.runService.Heartbeat, function(dt)
        if self.destroyed or not finite(dt) or #self.messages == 0 then return end
        self:Geometry()
        for _, message in ipairs(table.clone(self.messages)) do
            if not message:_alive() then message:_destroy()
            elseif message.state == "entering" then
                message.age += dt
                if message.age >= 0.32 then message.state, message.age = "visible", 0 end
            elseif message.state == "exiting" then
                message.age += dt
                if message.age >= 0.3 then message:_destroy() end
            elseif message.state == "visible" and not message._hovered then
                message.elapsed = math.min(message.duration, message.elapsed + dt)
                message.progress.Size = UDim2.fromScale(message.duration > 0 and math.max(0, 1 - message.elapsed / message.duration) or 0, 1)
                if message.elapsed >= message.duration then message:Close() end
            end
        end
    end)
    local unload = window.Unload
    function window:Unload(...) self.Feedback:Destroy() return unload(self, ...) end
    self:Geometry(true)
end
return Feedback
