--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local variables = require(script.Parent.Parent.Gen2.utility.variables)
local constants = require(script.Parent.Parent.Gen2.utility.constants)
local Brand = require(script.Parent.BrandMark)
local Startup = {}
local tweenService = game:GetService("TweenService")

function Startup.new(theme, version)
    theme = type(theme) == "table" and theme or {}
    local accent = theme.AccentColor or Color3.fromRGB(154, 104, 255)
    local base = theme.StatBackground or Color3.fromRGB(19, 18, 30)
    local ink = theme.ContentColor or Color3.new(1, 1, 1)
    local self = { stage = 0, closed = false, finishing = false, connections = {}, tweens = {}, targets = {} }
    local function create(class, props)
        local node = Instance.new(class)
        for key, value in pairs(props or {}) do node[key] = value end
        return node
    end
    local function track(node, property, value) table.insert(self.targets, { node = node, property = property, value = value }) end
    local function tween(node, duration, props, easing)
        if self.closed then return end
        local animation = tweenService:Create(node, TweenInfo.new(duration, easing or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
        table.insert(self.tweens, animation)
        animation:Play()
    end
    local function text(name, value, x, y, width, size, bold)
        local node = create("TextLabel", {
            Name = name, Parent = self.panel, BackgroundTransparency = 1, TextTransparency = 1,
            Text = value, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(width, size + 8),
            FontFace = Font.fromEnum(bold and Enum.Font.GothamBold or Enum.Font.Gotham), TextSize = size,
            TextColor3 = ink, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5,
        })
        track(node, "TextTransparency", 0)
        return node
    end
    self.gui = create("ScreenGui", {
        Name = "ConexaoStudioStartup", IgnoreGuiInset = true, ResetOnSpawn = false,
        DisplayOrder = constants.displayOrder.banner, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    self.panel = create("Frame", {
        Name = "Brand", Parent = self.gui, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 12),
        Size = UDim2.fromOffset(420, 212), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    create("UICorner", { Parent = self.panel, CornerRadius = UDim.new(0, 22) })
    create("UIGradient", { Parent = self.panel, Rotation = 25, Color = ColorSequence.new(base, base:Lerp(accent, 0.16)) })
    local edge = create("UIStroke", { Parent = self.panel, Thickness = 1, Color = accent, Transparency = 1 })
    track(self.panel, "BackgroundTransparency", 0)
    track(edge, "Transparency", 0.4)
    self.scale = create("UIScale", { Parent = self.panel, Scale = 0.92 })
    text("Eyebrow", "CONEXÃO / INTERFACE", 28, 14, 280, 9, true)
    self.version = text("Version", "v" .. tostring(version or "3.7"), 334, 14, 58, 10, false)
    self.version.TextXAlignment = Enum.TextXAlignment.Right
    self.mark = Brand.new(create, self.panel, 64, theme)
    self.mark.root.Position = UDim2.fromOffset(28, 52)
    self.title = text("Title", "Conexão Studio", 110, 52, 282, 26, true)
    self.subtitle = text("Subtitle", "Sua interface, do seu jeito.", 112, 89, 280, 12, false)
    for _, target in ipairs(self.targets) do
        if target.node == self.subtitle or target.node == self.version then target.value = 0.28 end
    end
    local divider = create("Frame", { Parent = self.panel, Position = UDim2.fromOffset(28, 132), Size = UDim2.fromOffset(364, 1), BackgroundColor3 = ink, BackgroundTransparency = 1, BorderSizePixel = 0 })
    track(divider, "BackgroundTransparency", 0.9)
    self.status = text("Status", "Preparando interface", 28, 145, 320, 12, false)
    self.percent = text("ProgressText", "12%", 352, 145, 40, 12, true)
    self.percent.TextXAlignment = Enum.TextXAlignment.Right
    self.track = create("Frame", { Name = "ProgressTrack", Parent = self.panel, Position = UDim2.fromOffset(28, 176), Size = UDim2.fromOffset(364, 4), BackgroundColor3 = ink, BackgroundTransparency = 1, BorderSizePixel = 0 })
    create("UICorner", { Parent = self.track, CornerRadius = UDim.new(1, 0) })
    track(self.track, "BackgroundTransparency", 0.88)
    self.progress = create("Frame", { Name = "ProgressFill", Parent = self.track, Size = UDim2.fromScale(0.12, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0 })
    create("UICorner", { Parent = self.progress, CornerRadius = UDim.new(1, 0) })
    create("UIGradient", { Parent = self.progress, Color = theme.SliderProgress or ColorSequence.new(accent, Color3.fromRGB(75, 173, 255)) })
    track(self.progress, "BackgroundTransparency", 0)
    self.phase = text("Phase", "INICIANDO", 28, 187, 364, 9, true)
    for _, target in ipairs(self.targets) do if target.node == self.phase then target.value = 0.42 end end
    -- The sweep stays inside a padded clipping area, clear of the panel's rounded corners.
    local sweepClip = create("Frame", { Parent = self.panel, Position = UDim2.fromOffset(16, 30), Size = UDim2.fromOffset(388, 100), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 7 })
    self.sweep = create("Frame", { Name = "LightSweep", Parent = sweepClip, Size = UDim2.new(0, 84, 1, 0), Position = UDim2.fromScale(-0.3, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Rotation = 18, ZIndex = 7 })
    create("UIGradient", { Parent = self.sweep, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.88), NumberSequenceKeypoint.new(1, 1) }) })
    function self:Layout()
        if self.closed then return end
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize
        if not viewport or viewport.X < 100 or viewport.Y < 100 then viewport = self.gui.AbsoluteSize end
        if not viewport or viewport.X < 100 or viewport.Y < 100 then viewport = Vector2.new(360, 640) end
        self.fit = math.min(1, math.max(0.1, (viewport.X - 28) / 420), math.max(0.1, (viewport.Y - 28) / 212))
        self.scale.Scale = self.fit
    end
    local function cleanup()
        for _, connection in ipairs(self.connections) do connection:Disconnect() end
        table.clear(self.connections)
        for _, animation in ipairs(self.tweens) do animation:Cancel() end
        table.clear(self.tweens)
    end
    function self:Cancel()
        if self.closed then return end
        self.closed = true
        cleanup()
        self.gui:Destroy()
    end
    function self:Advance(stage, amount, status)
        if self.closed or stage <= self.stage then return end
        self.stage = stage
        self.status.Text, self.percent.Text = status, string.format("%d%%", math.floor(amount * 100 + 0.5))
        tween(self.progress, 0.22, { Size = UDim2.fromScale(amount, 1) })
    end
    function self:Ready() self:Advance(2, 0.78, "Ajustando a janela") end
    -- Gen2 calls this once construction has finished, before showing the window.
    function self:Destroy()
        if self.closed or self.finishing then return end
        self.finishing = true
        self:Advance(3, 1, "Tudo pronto")
        self.phase.Text = "INTERFACE PRONTA"
        task.delay(0.1, function()
            if self.closed then return end
            for _, target in ipairs(self.targets) do tween(target.node, 0.22, { [target.property] = 1 }) end
            self.mark:SetShown(false, TweenInfo.new(0.22))
            tween(self.panel, 0.24, { Position = UDim2.new(0.5, 0, 0.5, -10) })
            tween(self.scale, 0.24, { Scale = self.fit * 1.025 })
            task.delay(0.26, function() self:Cancel() end)
        end)
    end
    table.insert(self.connections, self.gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:Layout() end))
    table.insert(self.connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() self:Layout() end))
    table.insert(self.connections, self.gui.Destroying:Connect(function()
        if not self.closed then self.closed = true cleanup() end
    end))
    self.gui.Parent = variables.guiContainer
    self:Layout()
    self.scale.Scale = self.fit * 0.92
    tween(self.scale, 0.4, { Scale = self.fit }, Enum.EasingStyle.Back)
    tween(self.panel, 0.35, { Position = UDim2.fromScale(0.5, 0.5) })
    for _, target in ipairs(self.targets) do tween(target.node, 0.32, { [target.property] = target.value }) end
    self.mark:SetShown(true, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), true)
    task.delay(0.14, function()
        if self.closed or self.finishing then return end
        self:Advance(1, 0.36, "Construindo a interface")
        self.sweep.BackgroundTransparency = 0
        tween(self.sweep, 0.55, { Position = UDim2.fromScale(1.2, 0) })
    end)
    return self
end

return Startup
