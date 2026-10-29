--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Surface = require(script.Parent.Surface)
local image = require(script.Parent.Parent.Gen2.utility.image)
local Dashboard = {}

function Dashboard.new(window, tab, page, player, executorInfo)
    local self = { window = window, tab = tab, name = "Perfil", __type = "ProfileDashboard", connections = {}, targets = {}, targetIndex = {} }
    function self:Track(node, property, value)
        local entries = self.targetIndex[node]
        if not entries then entries = {} self.targetIndex[node] = entries end
        if entries[property] then entries[property].value = value
        else
            local target = { node = node, property = property, value = value }
            entries[property] = target
            table.insert(self.targets, target)
        end
        return node
    end
    function self:Connect(signal, callback) return window:ConnectFor(self, signal, callback) end
    local function label(parent, text, props, white, title)
        local p = {
            Parent = parent, Text = text, BackgroundTransparency = 1, TextTransparency = 1,
            TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = false,
            TextTruncate = Enum.TextTruncate.AtEnd, BorderSizePixel = 0, ZIndex = 6,
        }
        for k, v in pairs(props or {}) do p[k] = v end
        local themed = { FontFace = title and "TitleFont" or "Font" }
        if white then p.TextColor3 = Color3.new(1, 1, 1) else themed.TextColor3 = "ContentColor" end
        local node = window:Create("TextLabel", p, themed)
        self:Track(node, "TextTransparency", 0)
        return node
    end
    local function frame(parent, name, props, themed)
        local p = { Parent = parent, Name = name, BorderSizePixel = 0, ZIndex = 3 }
        for k, v in pairs(props or {}) do p[k] = v end
        return window:Create("Frame", p, themed)
    end
    local function surface(parent, name)
        local node = frame(parent, name, { BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1 }, { BackgroundTransparency = "ElementTransparency" })
        Surface.round(window, node, 16)
        window:Create("UIGradient", { Parent = node, Rotation = 35 }, { Color = "ElementGradient" })
        local rim = window:Create("UIStroke", { Parent = node, Thickness = 1, Transparency = 1 }, { Color = "ElementStrokeHover" })
        self:Track(node, "BackgroundTransparency", function() return window.theme.ElementTransparency end)
        self:Track(rim, "Transparency", 0.35)
        return node
    end
    local function action(parent, text, primary, callback)
        local button = Surface.button(window, parent, text, { ZIndex = 9, TextSize = 13, BackgroundTransparency = 1, TextTransparency = 1 }, primary)
        self:Track(button, "BackgroundTransparency", 0)
        self:Track(button, "TextTransparency", 0)
        for _, child in ipairs(button:GetChildren()) do
            if child:IsA("UIStroke") then
                child.Transparency = 1
                self:Track(child, "Transparency", 0.55)
                self:Connect(button.MouseEnter, function()
                    if window:_interactive() then game:GetService("TweenService"):Create(child, TweenInfo.new(0.15), { Transparency = 0.15 }):Play() end
                end)
                self:Connect(button.MouseLeave, function()
                    game:GetService("TweenService"):Create(child, TweenInfo.new(0.15), { Transparency = window.hidden and 1 or 0.55 }):Play()
                end)
            end
        end
        self:Connect(button.MouseButton1Click, function() if window:_interactive() then callback() end end)
        return button
    end

    self.main = frame(tab.tabPage, "ProfileDashboard", { Size = UDim2.new(1, -20, 0, 398), BackgroundTransparency = 1 })
    local title = label(self.main, "Meu perfil", { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -90, 0, 24), TextSize = 20 }, false, true)
    local subtitle = label(self.main, "Conta e preferências", { Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, -90, 0, 16), TextSize = 12 })
    self:Track(subtitle, "TextTransparency", 0.3)
    local back = action(self.main, "Voltar", false, function() window:CloseProfile() end)
    back.AnchorPoint, back.Position, back.Size = Vector2.new(1, 0), UDim2.new(1, 0, 0, 2), UDim2.fromOffset(74, 32)
    page.backButton = { interact = back }

    self.banner = frame(self.main, "ProfileBanner", {
        Position = UDim2.fromOffset(0, 54), Size = UDim2.new(1, 0, 0, 172),
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, ClipsDescendants = true,
    }, { BackgroundTransparency = "ElementTransparency" })
    Surface.round(window, self.banner, 18)
    self.bannerGradient = window:Create("UIGradient", { Parent = self.banner, Rotation = 20 }, {
        Color = { "SliderProgress", function(sequence)
            local keys = sequence.Keypoints
            return ColorSequence.new(keys[1].Value:Lerp(Color3.new(0, 0, 0), 0.18), keys[#keys].Value:Lerp(Color3.new(0, 0, 0), 0.05))
        end },
    })
    self:Track(self.banner, "BackgroundTransparency", function() return window.theme.ElementTransparency end)
    local shade = frame(self.banner, "Shading", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 4 }, { BackgroundTransparency = "ElementTransparency" })
    window:Create("UIGradient", { Parent = shade, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) }) })
    self:Track(shade, "BackgroundTransparency", function() return window.theme.ElementTransparency end)
    local border = window:Create("UIStroke", { Parent = self.banner, Color = Color3.new(1, 1, 1), Transparency = 1, Thickness = 1 })
    self:Track(border, "Transparency", 0.6)
    self.rings = {}
    for index, diameter in ipairs({ 152, 220, 294 }) do
        local ring = frame(self.banner, "Orbit", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 8, 0.2, 0),
            Size = UDim2.fromOffset(diameter, diameter), BackgroundTransparency = 1, ZIndex = 4,
        })
        Surface.round(window, ring, diameter / 2)
        local edge = window:Create("UIStroke", { Parent = ring, Color = Color3.new(1, 1, 1), Transparency = 1, Thickness = index == 1 and 2 or 1 })
        self:Track(edge, "Transparency", index == 1 and 0.78 or 0.88)
        table.insert(self.rings, ring)
    end
    self.plate = frame(self.banner, "AvatarRing", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(78, 86), Size = UDim2.fromOffset(100, 100),
        BackgroundColor3 = Color3.fromRGB(14, 16, 27), BackgroundTransparency = 1, ZIndex = 5,
    })
    Surface.round(window, self.plate, 50)
    self:Track(self.plate, "BackgroundTransparency", 0.18)
    local avatarRim = window:Create("UIStroke", { Parent = self.plate, Color = Color3.new(1, 1, 1), Transparency = 1, Thickness = 2 })
    self:Track(avatarRim, "Transparency", 0.45)
    page.avatar = window:Create("ImageLabel", {
        Parent = self.plate, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(88, 88),
        BackgroundTransparency = 1, ImageTransparency = 1, ZIndex = 6,
        Image = image.avatar(player.UserId, function(uri)
            if not window.unloaded and window.ProfilePage == page and page.avatar and page.avatar.Parent then image.assign(page.avatar, "Image", uri) end
        end),
    })
    Surface.round(window, page.avatar, 44)
    self:Track(page.avatar, "ImageTransparency", 0)
    self.connected = label(self.banner, "CONECTADO", { TextSize = 10 }, true, true)
    self:Track(self.connected, "TextTransparency", 0.12)
    page.playerName = label(self.banner, player.DisplayName, { TextSize = 28, TextScaled = true }, true, true)
    window:Create("UITextSizeConstraint", { Parent = page.playerName, MaxTextSize = 28, MinTextSize = 16 })
    page.username = label(self.banner, "@" .. player.Name, { TextSize = 14 }, true)
    self:Track(page.username, "TextTransparency", 0.15)
    self.badges = frame(self.banner, "Badges", { BackgroundTransparency = 1, ZIndex = 5 })
    local function badge(name, text)
        local host = frame(self.badges, name, { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 5 })
        Surface.round(window, host, 12)
        self:Track(host, "BackgroundTransparency", 0.72)
        local caption = label(host, text, { Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -16, 1, 0), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center }, true, true)
        return host, caption
    end
    self.executorPill, page.executorBadge = badge("Executor", executorInfo.name)
    self.platformPill = badge("Platform", executorInfo.environment == "Roblox Studio" and "Studio" or "Roblox")

    self.cards = frame(self.main, "AccountCards", { BackgroundTransparency = 1 })
    local function card(name, glyph, hasCopy)
        local host = surface(self.cards, name)
        local icon = frame(host, "Icon", { Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(26, 26), BackgroundTransparency = 1, ZIndex = 4 }, { BackgroundColor3 = "AccentColor" })
        Surface.round(window, icon, 8)
        self:Track(icon, "BackgroundTransparency", 0.82)
        label(icon, glyph, { Size = UDim2.fromScale(1, 1), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center }, false, true)
        local heading = label(host, name, { Position = UDim2.fromOffset(48, 15), Size = UDim2.new(1, hasCopy and -108 or -60, 0, 18), TextSize = 10 }, false, true)
        self:Track(heading, "TextTransparency", 0.2)
        local value = label(host, "", { Position = UDim2.fromOffset(14, 46), Size = UDim2.new(1, -28, 0, 27), TextSize = 20 }, false, true)
        local caption = label(host, "", { Position = UDim2.fromOffset(14, 78), Size = UDim2.new(1, -28, 0, 17), TextSize = 11 })
        self:Track(caption, "TextTransparency", 0.25)
        local data = { main = host, valueLabel = value, subtitle = caption }
        function data:Set(text) self.valueLabel.Text = tostring(text) end
        return data
    end
    page.fields[1] = card("EXECUTOR", ">_", false)
    page.fields[2] = card("ID DA CONTA", "#", true)
    page.fields[2].subtitle.Text = "Identificador do jogador"
    page.copyButton = action(page.fields[2].main, "Copiar", false, function()
        local env = _G
        if type(getgenv) == "function" then local ok, value = pcall(getgenv) if ok and type(value) == "table" then env = value end end
        local copy = env.setclipboard or env.toclipboard or getfenv().setclipboard or getfenv().toclipboard
        local ok, result
        if type(copy) == "function" then ok, result = pcall(copy, tostring(player.UserId)) end
        ok = ok and result ~= false
        self.notice.Text = ok and "ID copiado." or "Copiar não está disponível neste cliente."
        self.notice.Visible = true
        self:Layout()
        window:_reveal(self.notice, { TextTransparency = 0.2 }, true)
    end)
    page.copyButton.AnchorPoint, page.copyButton.Position, page.copyButton.Size = Vector2.new(1, 0), UDim2.new(1, -10, 0, 10), UDim2.fromOffset(44, 24)
    page.copyButton.TextSize = 10
    self.actions = frame(self.main, "ProfileActions", { BackgroundTransparency = 1 })
    page.settingsButton = action(self.actions, "Configurações", true, function() window:OpenSettings() end)
    page.themesButton = action(self.actions, "Temas", false, function() window:OpenThemes() end)
    self.notice = label(self.main, "", { TextSize = 11, Size = UDim2.new(1, 0, 0, 24), Visible = false })

    function self:Layout()
        local width = self.main.AbsoluteSize.X
        if width <= 0 then width = math.max(180, window.elements.AbsoluteSize.X - 40) end
        local narrow = width < 420
        self.narrow = narrow
        local bannerHeight = narrow and 252 or 172
        self.banner.Size = UDim2.new(1, 0, 0, bannerHeight)
        self.plate.Position = narrow and UDim2.new(0.5, 0, 0, 80) or UDim2.fromOffset(78, 86)
        self.plate.Size = UDim2.fromOffset(narrow and 92 or 100, narrow and 92 or 100)
        page.avatar.Size = UDim2.fromOffset(narrow and 80 or 88, narrow and 80 or 88)
        self.connected.Position = narrow and UDim2.fromOffset(12, 12) or UDim2.fromOffset(152, 22)
        self.connected.Size = narrow and UDim2.new(1, -24, 0, 14) or UDim2.new(1, -174, 0, 14)
        self.connected.TextXAlignment = narrow and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
        page.playerName.Position = narrow and UDim2.fromOffset(14, 136) or UDim2.fromOffset(152, 46)
        page.playerName.Size = narrow and UDim2.new(1, -28, 0, 34) or UDim2.new(1, -174, 0, 40)
        page.playerName.TextXAlignment = narrow and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
        page.username.Position = narrow and UDim2.fromOffset(14, 176) or UDim2.fromOffset(152, 90)
        page.username.Size = narrow and UDim2.new(1, -28, 0, 20) or UDim2.new(1, -174, 0, 22)
        page.username.TextXAlignment = narrow and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
        self.badges.Position = narrow and UDim2.fromOffset(12, 210) or UDim2.fromOffset(152, 126)
        self.badges.Size = narrow and UDim2.new(1, -24, 0, 26) or UDim2.new(1, -174, 0, 26)
        local badgeSpace = narrow and width - 24 or width - 174
        local executorWidth = math.min(120, math.max(50, badgeSpace - 76))
        local badgeStart = narrow and math.max(0, (badgeSpace - executorWidth - 76) / 2) or 0
        self.executorPill.Position, self.executorPill.Size = UDim2.fromOffset(badgeStart, 0), UDim2.fromOffset(executorWidth, 26)
        self.platformPill.Position, self.platformPill.Size = UDim2.fromOffset(badgeStart + executorWidth + 8, 0), UDim2.fromOffset(68, 26)
        local cardTop = 54 + bannerHeight + 14
        self.cards.Position = UDim2.fromOffset(0, cardTop)
        self.cards.Size = UDim2.new(1, 0, 0, narrow and 220 or 104)
        for index, field in ipairs(page.fields) do
            field.main.Position = narrow and UDim2.fromOffset(0, (index - 1) * 116) or UDim2.new((index - 1) * 0.5, (index - 1) * 6, 0, 0)
            field.main.Size = narrow and UDim2.new(1, 0, 0, 104) or UDim2.new(0.5, -6, 0, 104)
        end
        local actionsTop = cardTop + (narrow and 220 or 104) + 14
        self.actions.Position, self.actions.Size = UDim2.fromOffset(0, actionsTop), UDim2.new(1, 0, 0, 40)
        page.settingsButton.Position, page.settingsButton.Size = UDim2.fromOffset(0, 0), UDim2.new(0.5, -5, 1, 0)
        page.themesButton.Position, page.themesButton.Size = UDim2.new(0.5, 5, 0, 0), UDim2.new(0.5, -5, 1, 0)
        self.notice.Position = UDim2.fromOffset(0, actionsTop + 46)
        self.main.Size = UDim2.new(1, -20, 0, actionsTop + (self.notice.Visible and 78 or 52))
    end
    function self:_setShown(shown, animate)
        for _, target in ipairs(self.targets) do
            local value = shown and (type(target.value) == "function" and target.value() or target.value) or 1
            window:_reveal(target.node, { [target.property] = value }, animate)
        end
    end
    function self:_refreshTheme() if not window.hidden then self:_setShown(true, false) end end
    self:Connect(self.main:GetPropertyChangedSignal("AbsoluteSize"), function() self:Layout() end)
    self:Layout()
    return self
end

return Dashboard
