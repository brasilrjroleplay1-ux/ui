--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Surface = require(script.Parent.Surface)
local image = require(script.Parent.Parent.Gen2.utility.image)
local BrandIcon = require(script.Parent.BrandIcon)
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
    local title = label(self.main, "Visão geral", { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -90, 0, 24), TextSize = 20 }, false, true)
    local subtitle = label(self.main, "Conta, cliente e sessão", { Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, -90, 0, 16), TextSize = 12 })
    self:Track(subtitle, "TextTransparency", 0.3)
    local back = action(self.main, "Voltar", false, function() window:CloseProfile() end)
    back.AnchorPoint, back.Position, back.Size = Vector2.new(1, 0), UDim2.new(1, 0, 0, 2), UDim2.fromOffset(74, 32)
    page.backButton = { interact = back }

    self.hero = frame(self.main, "WelcomeRow", { Position = UDim2.fromOffset(0, 58), Size = UDim2.new(1, 0, 0, 156), BackgroundTransparency = 1 })
    self.banner = frame(self.hero, "ProfileBanner", {
        Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 156),
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
    }, { BackgroundTransparency = "ElementTransparency" })
    Surface.round(window, self.banner, 18)
    self.bannerGradient = window:Create("UIGradient", { Parent = self.banner, Rotation = 20 }, {
        Color = { "SliderProgress", function(sequence)
            local keys = sequence.Keypoints
            local black = Color3.new(0, 0, 0)
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, keys[1].Value:Lerp(black, 0.78)),
                ColorSequenceKeypoint.new(0.65, keys[1].Value:Lerp(black, 0.55)),
                ColorSequenceKeypoint.new(1, keys[#keys].Value:Lerp(black, 0.55)),
            })
        end },
    })
    self:Track(self.banner, "BackgroundTransparency", function() return window.theme.ElementTransparency end)
    -- One rounded surface only: UICorner does not mask child Frames in Roblox.
    -- A rectangular shade or off-canvas ornaments would leak through its corners.
    local border = window:Create("UIStroke", { Parent = self.banner, Color = Color3.new(1, 1, 1), Transparency = 1, Thickness = 1 })
    self:Track(border, "Transparency", 0.6)
    self.plate = frame(self.banner, "AvatarRing", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(84, 99), Size = UDim2.fromOffset(112, 112),
        BackgroundColor3 = Color3.fromRGB(14, 16, 27), BackgroundTransparency = 1, ZIndex = 5,
    })
    Surface.round(window, self.plate, 18)
    self:Track(self.plate, "BackgroundTransparency", 0.18)
    local avatarRim = window:Create("UIStroke", { Parent = self.plate, Color = Color3.new(1, 1, 1), Transparency = 1, Thickness = 2 })
    self:Track(avatarRim, "Transparency", 0.45)
    page.avatar = window:Create("ImageLabel", {
        Parent = self.plate, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(100, 100),
        BackgroundTransparency = 1, ImageTransparency = 1, ZIndex = 6,
        ScaleType = Enum.ScaleType.Fit, ResampleMode = Enum.ResamplerMode.Default,
        Image = image.avatar(player.UserId, function(uri)
            if not window.unloaded and window.ProfilePage == page and page.avatar and page.avatar.Parent then image.assign(page.avatar, "Image", uri) end
        end),
    })
    Surface.round(window, page.avatar, 14)
    self:Track(page.avatar, "ImageTransparency", 0)
    self.connected = label(self.banner, "BEM-VINDO DE VOLTA", { TextSize = 10 }, true, true)
    self:Track(self.connected, "TextTransparency", 0.12)
    page.playerName = label(self.banner, player.DisplayName, { TextSize = 28, TextScaled = true }, true, true)
    window:Create("UITextSizeConstraint", { Parent = page.playerName, MaxTextSize = 28, MinTextSize = 12 })
    page.username = label(self.banner, "@" .. player.Name, { TextSize = 14 }, true)
    self:Track(page.username, "TextTransparency", 0.15)
    self.badges = frame(self.banner, "Badges", { BackgroundTransparency = 1, ZIndex = 5 })
    local function badge(name, text, brand)
        local host = frame(self.badges, name, { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 5 })
        Surface.round(window, host, 10)
        self:Track(host, "BackgroundTransparency", 0.6)
        local logo = BrandIcon.new(window, host, brand, {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.fromOffset(18, 18),
        }, function(node, property, value) self:Track(node, property, value) end, true)
        local caption = label(host, text, { Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -46, 1, 0), TextSize = 12 }, true, true)
        return host, caption, logo
    end
    self.executorPill, page.executorBadge, page.executorIcon = badge("Executor", executorInfo.name, executorInfo.name)
    self.platformPill, page.platformBadge, page.platformIcon = badge("Platform", executorInfo.environment == "Roblox Studio" and "Studio" or "Roblox", executorInfo.environment)

    self.cards = frame(self.main, "SessionAndAccount", { BackgroundTransparency = 1 })
    local function card(parent, name, brand, hasCopy)
        local host = surface(parent, name)
        local icon = frame(host, "Icon", { Position = UDim2.fromOffset(16, 16), Size = UDim2.fromOffset(32, 32), BackgroundTransparency = 1, ZIndex = 4 }, { BackgroundColor3 = "AccentColor" })
        Surface.round(window, icon, 9)
        self:Track(icon, "BackgroundTransparency", 0.82)
        local logo = BrandIcon.new(window, icon, brand, {
            Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(20, 20),
        }, function(node, property, value) self:Track(node, property, value) end)
        local heading = label(host, name, { Position = UDim2.fromOffset(60, 22), Size = UDim2.new(1, hasCopy and -138 or -76, 0, 16), TextSize = 10 }, false, true)
        self:Track(heading, "TextTransparency", 0.2)
        local value = label(host, "", { Position = UDim2.fromOffset(18, 58), Size = UDim2.new(1, -36, 0, 28), TextSize = 22, TextScaled = true }, false, true)
        window:Create("UITextSizeConstraint", { Parent = value, MinTextSize = 14, MaxTextSize = 22 })
        local caption = label(host, "", { Position = UDim2.fromOffset(18, 92), Size = UDim2.new(1, -36, 0, 18), TextSize = 12 })
        self:Track(caption, "TextTransparency", 0.25)
        local data = { main = host, valueLabel = value, subtitle = caption, heading = heading, icon = logo }
        function data:Set(text) self.valueLabel.Text = tostring(text) end
        return data
    end
    page.fields[1] = card(self.hero, "CLIENTE", executorInfo.name, false)
    page.fields[2] = card(self.cards, "ID DA CONTA", "Roblox", true)
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
    page.copyButton.AnchorPoint, page.copyButton.Position, page.copyButton.Size = Vector2.new(1, 0), UDim2.new(1, -14, 0, 16), UDim2.fromOffset(50, 28)
    page.copyButton.TextSize = 11
    self.clientNote = label(page.fields[1].main, executorInfo.name == "Não identificado" and "Identificação indisponível" or "Identificado neste dispositivo", { Position = UDim2.fromOffset(18, 120), Size = UDim2.new(1, -36, 0, 18), TextSize = 11 })
    self:Track(self.clientNote, "TextTransparency", 0.3)
    self.accountVersion = label(page.fields[2].main, "Conexão Studio", { Position = UDim2.fromOffset(18, 132), Size = UDim2.new(1, -36, 0, 18), TextSize = 12 }, false, true)
    self.accountSave = label(page.fields[2].main, "", { Position = UDim2.fromOffset(18, 158), Size = UDim2.new(1, -36, 0, 18), TextSize = 11 })
    self:Track(self.accountSave, "TextTransparency", 0.3)
    self.accountClient = label(page.fields[2].main, executorInfo.name .. (executorInfo.version and (" · " .. executorInfo.version) or ""), { Position = UDim2.fromOffset(18, 184), Size = UDim2.new(1, -36, 0, 18), TextSize = 11 })
    self.session = surface(self.cards, "SessionPanel")
    label(self.session, "SESSÃO", { Position = UDim2.fromOffset(16, 14), Size = UDim2.new(1, -32, 0, 20), TextSize = 12 }, false, true)
    self.stats = {}
    for _, definition in ipairs({ { "playerText", "Jogadores" }, { "pingText", "Latência" }, { "fpsText", "FPS" }, { "timeText", "Tempo no painel" }, { "placeText", "Place ID" }, { "saveText", "Salvamento" } }) do
        local tile = frame(self.session, definition[1], { BackgroundTransparency = 1, ZIndex = 4 }, { BackgroundColor3 = "StatBackground" })
        Surface.round(window, tile, 10)
        self:Track(tile, "BackgroundTransparency", 0.15)
        local caption = label(tile, definition[2], { Position = UDim2.fromOffset(10, 9), Size = UDim2.new(1, -20, 0, 15), TextSize = 10 }, false, true)
        self:Track(caption, "TextTransparency", 0.28)
        local value = label(tile, "—", { Position = UDim2.fromOffset(10, 29), Size = UDim2.new(1, -20, 0, 24), TextSize = 18, TextScaled = true }, false, true)
        window:Create("UITextSizeConstraint", { Parent = value, MinTextSize = 10, MaxTextSize = 18 })
        table.insert(self.stats, { key = definition[1], main = tile, value = value })
    end
    self.actions = frame(self.main, "ProfileActions", { BackgroundTransparency = 1 })
    page.settingsButton = action(self.actions, "Configurações", false, function() window:OpenSettings() end)
    page.themesButton = action(self.actions, "Temas", false, function() window:OpenThemes() end)
    page.copyServerButton = action(self.actions, "Copiar servidor", false, function()
        local id = type(game.JobId) == "string" and game.JobId or ""
        local env = _G
        if type(getgenv) == "function" then local ok, value = pcall(getgenv) if ok and type(value) == "table" then env = value end end
        local copy = env.setclipboard or env.toclipboard or getfenv().setclipboard or getfenv().toclipboard
        local ok, result
        if id ~= "" and type(copy) == "function" then ok, result = pcall(copy, id) end
        self.notice.Text = id == "" and "Este ambiente não informou um ID de servidor." or (ok and result ~= false and "ID do servidor copiado." or "Copiar não está disponível neste cliente.")
        self.notice.Visible = true
        self:Layout()
        window:_reveal(self.notice, { TextTransparency = 0.2 }, true)
    end)
    self.actionIcons = {}
    for _, definition in ipairs({ { page.settingsButton, "settings" }, { page.themesButton, "themes" }, { page.copyServerButton, "copy" } }) do
        local button, name = definition[1], definition[2]
        local icon = BrandIcon.new(window, button, name, { Position = UDim2.new(0, 10, 0.5, -9), Size = UDim2.fromOffset(18, 18), ZIndex = 10 }, function(node, property, value) self:Track(node, property, value) end)
        local padding = window:Create("UIPadding", { Parent = button, PaddingLeft = UDim.new(0, 24), PaddingRight = UDim.new(0, 4) })
        table.insert(self.actionIcons, { icon = icon.root, padding = padding, button = button })
    end
    self.notice = label(self.main, "", { TextSize = 11, Size = UDim2.new(1, 0, 0, 24), Visible = false })

    function self:Layout()
        local width = self.main.AbsoluteSize.X
        if width <= 0 then width = math.max(180, window.elements.AbsoluteSize.X - 40) end
        local wide = width >= 600
        local left = wide and math.floor((width - 12) * 0.64) or width
        local right = width - left - 12
        local centered = left < 340
        self.narrow = not wide
        local backWidth = width < 260 and 60 or 74
        back.Size = UDim2.fromOffset(backWidth, 32)
        title.Size, title.TextSize = UDim2.new(1, -backWidth - 12, 0, 24), width < 260 and 18 or 20
        subtitle.Position, subtitle.Size = UDim2.fromOffset(0, 34), UDim2.new(1, 0, 0, 16)
        local photo = centered and 64 or 76
        self.plate.Position = centered and UDim2.new(0.5, 0, 0, 66) or UDim2.fromOffset(54, 78)
        self.plate.Size = UDim2.fromOffset(photo, photo)
        page.avatar.Size = UDim2.fromOffset(photo - 10, photo - 10)
        local textLeft = centered and 16 or 108
        local textWidth = centered and left - 32 or left - 124
        self.connected.Position, self.connected.Size = UDim2.fromOffset(textLeft, centered and 12 or 18), UDim2.fromOffset(textWidth, 14)
        page.playerName.Position, page.playerName.Size = UDim2.fromOffset(textLeft, centered and 110 or 42), UDim2.fromOffset(textWidth, 32)
        page.username.Position, page.username.Size = UDim2.fromOffset(textLeft, centered and 146 or 80), UDim2.fromOffset(textWidth, 20)
        for _, node in ipairs({ self.connected, page.playerName, page.username }) do node.TextXAlignment = centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left end
        local badgeSpace = textWidth
        local platformWidth = page.platformBadge.Text == "Studio" and 88 or 94
        local wrap = badgeSpace < 80 + 8 + platformWidth
        local wanted = math.clamp(46 + utf8.len(page.executorBadge.Text) * 6, 80, 160)
        local executorWidth = math.min(wanted, wrap and badgeSpace or badgeSpace - 8 - platformWidth)
        local badgeHeight = wrap and 64 or 28
        local badgeTop = centered and 178 or 112
        self.badges.Position, self.badges.Size = UDim2.fromOffset(textLeft, badgeTop), UDim2.fromOffset(badgeSpace, badgeHeight)
        local start = centered and math.max(0, (badgeSpace - executorWidth - platformWidth - 8) / 2) or 0
        self.executorPill.Position = UDim2.fromOffset(wrap and (badgeSpace - executorWidth) / 2 or start, 0)
        self.executorPill.Size = UDim2.fromOffset(executorWidth, 28)
        self.platformPill.Position = UDim2.fromOffset(wrap and (badgeSpace - platformWidth) / 2 or start + executorWidth + 8, wrap and 36 or 0)
        self.platformPill.Size = UDim2.fromOffset(platformWidth, 28)
        local bannerHeight = math.max(156, badgeTop + badgeHeight + 16)
        self.hero.Size = UDim2.new(1, 0, 0, bannerHeight)
        self.banner.Size = UDim2.fromOffset(left, bannerHeight)
        page.fields[1].main.Visible = wide
        page.fields[1].main.Position = wide and UDim2.fromOffset(left + 12, 0) or UDim2.fromOffset(0, 0)
        page.fields[1].main.Size = UDim2.fromOffset(wide and right or width, bannerHeight)
        self.clientNote.Visible = wide
        self.accountClient.Visible = not wide
        local actionColumns = width < 340 and 1 or (width < 620 and 2 or 3)
        local actionRows = math.ceil(3 / actionColumns)
        local actionHeight = actionRows * 42 + (actionRows - 1) * 8
        local actionsTop = 58 + bannerHeight + 12
        self.actions.Position, self.actions.Size = UDim2.fromOffset(0, actionsTop), UDim2.new(1, 0, 0, actionHeight)
        local actionWidth = (width - (actionColumns - 1) * 8) / actionColumns
        for index, item in ipairs(self.actionIcons) do
            item.button.Position = UDim2.fromOffset(((index - 1) % actionColumns) * (actionWidth + 8), math.floor((index - 1) / actionColumns) * 50)
            item.button.Size = UDim2.fromOffset(actionWidth, 42)
            item.icon.Visible = actionWidth >= 140
            item.padding.PaddingLeft = UDim.new(0, actionWidth >= 140 and 24 or 4)
        end
        local statsWidth = wide and left or width
        local statColumns = statsWidth >= 330 and 3 or (statsWidth >= 230 and 2 or 1)
        local statWidth = (statsWidth - 32 - (statColumns - 1) * 8) / statColumns
        local statRows = math.ceil(#self.stats / statColumns)
        local sessionHeight = 44 + statRows * 68 + (statRows - 1) * 8 + 12
        local accountHeight = math.max(220, wide and sessionHeight or 220)
        self.session.Position, self.session.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(statsWidth, sessionHeight)
        for index, item in ipairs(self.stats) do
            item.main.Position = UDim2.fromOffset(16 + ((index - 1) % statColumns) * (statWidth + 8), 44 + math.floor((index - 1) / statColumns) * 76)
            item.main.Size = UDim2.fromOffset(statWidth, 68)
        end
        page.fields[2].main.Position = wide and UDim2.fromOffset(left + 12, 0) or UDim2.fromOffset(0, sessionHeight + 12)
        page.fields[2].main.Size = UDim2.fromOffset(wide and right or width, accountHeight)
        page.fields[2].heading.Text = (wide and right or width) < 240 and "ID" or "ID DA CONTA"
        local detailsHeight = wide and math.max(sessionHeight, accountHeight) or sessionHeight + 12 + accountHeight
        local detailsTop = actionsTop + actionHeight + 16
        self.cards.Position, self.cards.Size = UDim2.fromOffset(0, detailsTop), UDim2.new(1, 0, 0, detailsHeight)
        self.notice.Position, self.notice.Size = UDim2.fromOffset(0, detailsTop + detailsHeight + 8), UDim2.new(1, 0, 0, 36)
        self.notice.TextWrapped = true
        self.main.Size = UDim2.new(1, -20, 0, detailsTop + detailsHeight + (self.notice.Visible and 56 or 12))
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
