--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Composition follows the supplied Luna Home reference, using owned native GuiObjects.
local Surface = require(script.Parent.Surface)
local image = require(script.Parent.Parent.Gen2.utility.image)
local BrandIcon = require(script.Parent.BrandIcon)
local Dashboard = {}

function Dashboard.new(window, tab, page, player, executorInfo)
    local self = { window = window, tab = tab, name = "Início", __type = "ProfileDashboard", connections = {}, targets = {}, targetIndex = {} }
    function self:Track(node, property, value)
        self.targetIndex[node] = self.targetIndex[node] or {}
        local target = self.targetIndex[node][property]
        if target then target.value = value
        else target = { node = node, property = property, value = value } self.targetIndex[node][property] = target table.insert(self.targets, target) end
    end
    local function frame(parent, name, props, themed)
        local p = { Parent = parent, Name = name, BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 3 }
        for key, value in pairs(props or {}) do p[key] = value end
        return window:Create("Frame", p, themed)
    end
    local function label(parent, name, text, props, bold, transparency)
        local p = { Parent = parent, Name = name, Text = text, BackgroundTransparency = 1, TextTransparency = 1, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BorderSizePixel = 0, ZIndex = 6 }
        for key, value in pairs(props or {}) do p[key] = value end
        local node = window:Create("TextLabel", p, { TextColor3 = "ContentColor", FontFace = bold and "TitleFont" or "Font" })
        self:Track(node, "TextTransparency", transparency or 0)
        return node
    end
    local function surface(parent, name, color, strong)
        local node = frame(parent, name, { BackgroundColor3 = Color3.new(1, 1, 1) }, { BackgroundTransparency = "ElementTransparency" })
        Surface.round(window, node, 12)
        window:Create("UIGradient", { Parent = node, Rotation = 135 }, { Color = { "StatBackground", function(base)
            local light = window.theme.ContentColor.R + window.theme.ContentColor.G + window.theme.ContentColor.B < 1.5
            local neutral = base:Lerp(light and Color3.new(1, 1, 1) or Color3.new(0, 0, 0), light and 0.65 or 0.86)
            local tint = color:Lerp(window.theme.AccentColor, 0.12)
            return ColorSequence.new({ ColorSequenceKeypoint.new(0, neutral), ColorSequenceKeypoint.new(strong and 0.25 or 0.58, neutral), ColorSequenceKeypoint.new(1, neutral:Lerp(tint, light and 0.12 or (strong and 0.65 or 0.42))) })
        end } })
        local stroke = window:Create("UIStroke", { Parent = node, Thickness = 1, Transparency = 1 }, { Color = "SurfaceStroke" })
        self:Track(node, "BackgroundTransparency", function() return window.theme.ElementTransparency end)
        self:Track(stroke, "Transparency", 0.65)
        return node
    end
    local function brand(parent, name, props)
        return BrandIcon.new(window, parent, name, props, function(node, property, value) self:Track(node, property, value) end)
    end
    self.main = frame(tab.tabPage, "ProfileDashboard", { Size = UDim2.new(1, -24, 0, 392) })
    self.hero = frame(self.main, "WelcomeRow", { Size = UDim2.new(1, 0, 0, 72) })
    self.plate = frame(self.hero, "Avatar", { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(72, 72) }, { BackgroundColor3 = "StatBackground" })
    Surface.round(window, self.plate, 8)
    local avatarRim = window:Create("UIStroke", { Parent = self.plate, Thickness = 1, Transparency = 1 }, { Color = "SurfaceStroke" })
    self:Track(self.plate, "BackgroundTransparency", 0.3)
    self:Track(avatarRim, "Transparency", 0.6)
    page.avatar = window:Create("ImageLabel", {
        Parent = self.plate, Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, -4), BackgroundTransparency = 1, ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit, ResampleMode = Enum.ResamplerMode.Default, ZIndex = 6,
        Image = image.avatar(player.UserId, function(uri)
            if not window.unloaded and window.HomePage == page and page.avatar and page.avatar.Parent then image.assign(page.avatar, "Image", uri) end
        end),
    })
    Surface.round(window, page.avatar, 6)
    self:Track(page.avatar, "ImageTransparency", 0)
    self.banner = frame(self.hero, "Greeting", { Position = UDim2.fromOffset(84, 6), Size = UDim2.new(1, -84, 0, 60) }, { BackgroundColor3 = "StatBackground" })
    Surface.round(window, self.banner, 8)
    local greetingRim = window:Create("UIStroke", { Parent = self.banner, Thickness = 1, Transparency = 1 }, { Color = "SurfaceStroke" })
    self:Track(greetingRim, "Transparency", 0.5)
    window.themeProperties[self.banner].BackgroundColor3 = nil
    self.banner.BackgroundColor3 = Color3.new(1, 1, 1)
    window:Create("UIGradient", { Parent = self.banner, Rotation = 15 }, { Color = { "StatBackground", function(base) return window.theme.HeroGradient or ColorSequence.new(base) end } })
    self:Track(self.banner, "BackgroundTransparency", 0.06)
    page.playerName = label(self.banner, "PlayerName", "Olá, " .. player.DisplayName, { Position = UDim2.fromOffset(12, 9), Size = UDim2.new(1, -24, 0, 22), TextSize = 19, TextScaled = true }, true)
    window:Create("UITextSizeConstraint", { Parent = page.playerName, MinTextSize = 12, MaxTextSize = 19 })
    page.username = label(self.banner, "Username", "@" .. player.Name .. " · " .. window.name, { Position = UDim2.fromOffset(12, 34), Size = UDim2.new(1, -24, 0, 16), TextSize = 11 }, false, 0.25)
    self.cards = frame(self.main, "HomeCards", {})
    self.session = surface(self.cards, "ServerCard", Color3.fromRGB(39, 211, 154))
    self.sessionTitle = label(self.session, "Heading", "Servidor", { Position = UDim2.fromOffset(12, 9), Size = UDim2.new(1, -24, 0, 18), TextSize = 14 }, true)
    label(self.session, "Description", "Informações desta sessão", { Position = UDim2.fromOffset(12, 27), Size = UDim2.new(1, -24, 0, 14), TextSize = 10 }, false, 0.25)
    local function tiles(parent, definitions)
        local out = {}
        for _, definition in ipairs(definitions) do
            local tile = frame(parent, definition[1], {}, { BackgroundColor3 = "StatBackground" })
            Surface.round(window, tile, 8)
            self:Track(tile, "BackgroundTransparency", 0.05)
            local caption = label(tile, "Caption", definition[2], { Position = UDim2.fromOffset(9, 5), Size = UDim2.new(1, -18, 0, 14), TextSize = 11 }, true, 0.08)
            local value = label(tile, "Value", "—", { Position = UDim2.fromOffset(9, 20), Size = UDim2.new(1, -18, 0, 17), TextSize = 14, TextScaled = true }, true, 0.05)
            window:Create("UITextSizeConstraint", { Parent = value, MinTextSize = 10, MaxTextSize = 14 })
            table.insert(out, { key = definition[1], main = tile, caption = caption, value = value })
        end
        return out
    end
    self.stats = tiles(self.session, { { "countText", "Jogadores" }, { "maximumText", "Capacidade" }, { "pingText", "Latência" }, { "fpsText", "FPS" }, { "timeText", "Tempo de sessão" }, { "saveText", "Salvamento" } })
    local client = surface(self.cards, "ClientCard", Color3.fromRGB(219, 64, 82), true)
    local clientIcon = brand(client, executorInfo.name, { Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(24, 24) })
    local executorLabel = label(client, "Executor", executorInfo.name, { Position = UDim2.fromOffset(46, 9), Size = UDim2.new(1, -58, 0, 22), TextSize = 16 }, true)
    local executorVersion = label(client, "Version", "", { Position = UDim2.fromOffset(46, 32), Size = UDim2.new(1, -58, 0, 15), TextSize = 10 }, false, 0.2)
    page.fields[1] = { main = client, valueLabel = executorLabel, subtitle = executorVersion, heading = executorLabel, icon = clientIcon, Set = function(c, text) c.valueLabel.Text = tostring(text) end }
    page.executorBadge, page.executorIcon = executorLabel, clientIcon
    self.clientNote = label(client, "Support", "Permitido nesta library", { Position = UDim2.fromOffset(12, 54), Size = UDim2.new(1, -104, 0, 16), TextSize = 10 }, false, 0.12)
    self.platformPill = frame(client, "Platform", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 52), Size = UDim2.fromOffset(76, 20) })
    page.platformIcon = brand(self.platformPill, executorInfo.environment, { Position = UDim2.fromOffset(0, 2), Size = UDim2.fromOffset(16, 16) })
    page.platformBadge = label(self.platformPill, "PlatformName", executorInfo.environment == "Roblox Studio" and "Studio" or "Roblox", { Position = UDim2.fromOffset(22, 0), Size = UDim2.fromOffset(54, 20), TextSize = 10 })
    self.friends = surface(self.cards, "FriendsCard", Color3.fromRGB(231, 185, 65))
    label(self.friends, "Heading", "Amigos", { Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -24, 0, 20), TextSize = 15 }, true)
    self.friendSubtitle = label(self.friends, "Description", "Seus amigos no Roblox", { Position = UDim2.fromOffset(12, 31), Size = UDim2.new(1, -24, 0, 16), TextSize = 10 }, false, 0.2)
    self.friendStats = tiles(self.friends, { { "inServerText", "No servidor" }, { "offlineText", "Offline" }, { "onlineText", "Online" }, { "allText", "Todos" } })
    self.save = surface(self.cards, "SaveCard", Color3.fromRGB(83, 99, 255), true)
    self.saveTitle = label(self.save, "Heading", "Salvamento automático", { Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -24, 0, 24), TextSize = 16, TextScaled = true }, true)
    window:Create("UITextSizeConstraint", { Parent = self.saveTitle, MinTextSize = 12, MaxTextSize = 16 })
    self.saveSubtitle = label(self.save, "Description", "Suas escolhas são lembradas neste dispositivo", { Position = UDim2.fromOffset(12, 37), Size = UDim2.new(1, -24, 0, 24), TextSize = 11, TextWrapped = true }, false, 0.2)
    local account = frame(self.main, "AccountFooter", { Size = UDim2.new(1, 0, 0, 34) })
    local accountIcon = brand(account, "Roblox", { Position = UDim2.fromOffset(0, 9), Size = UDim2.fromOffset(16, 16) })
    local accountId = label(account, "AccountId", tostring(player.UserId), { Position = UDim2.fromOffset(24, 6), Size = UDim2.new(1, -84, 0, 22), TextSize = 11 }, false, 0.3)
    self.accountVersion = label(account, "LibraryVersion", "", { Size = UDim2.fromOffset(1, 1), Visible = false })
    self.accountSave = label(account, "SaveState", "", { Size = UDim2.fromOffset(1, 1), Visible = false })
    page.fields[2] = { main = account, valueLabel = accountId, subtitle = self.accountVersion, heading = accountId, icon = accountIcon, Set = function(c, text) c.valueLabel.Text = tostring(text) end }
    page.copyButton = window:Create("TextButton", { Name = "CopyAccountId", Parent = account, Text = "Copiar ID", TextSize = 10, BackgroundTransparency = 1, TextTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 5), Size = UDim2.fromOffset(54, 24), AutoButtonColor = false, ZIndex = 9 }, { FontFace = "Font", TextColor3 = "ContentColor" })
    self:Track(page.copyButton, "TextTransparency", 0.25)
    window:ConnectFor(self, page.copyButton.MouseButton1Click, function()
        if not window:_interactive() then return end
        local env = _G
        if type(getgenv) == "function" then local success, value = pcall(getgenv) if success and type(value) == "table" then env = value end end
        local copy = env.setclipboard or env.toclipboard or getfenv().setclipboard or getfenv().toclipboard
        local ok, result = false, nil
        if type(copy) == "function" then ok, result = pcall(copy, tostring(player.UserId)) end
        self.notice.Text, self.notice.Visible = ok and result ~= false and "ID copiado." or "Copiar não está disponível neste cliente.", true
        self:Layout()
        window:_reveal(self.notice, { TextTransparency = 0.2 }, true)
    end)
    self.notice = label(self.main, "Notice", "", { TextSize = 11, TextWrapped = true, Visible = false })
    function self:Layout()
        local width = self.main.AbsoluteSize.X
        if width <= 0 then width = math.max(180, window.elements.AbsoluteSize.X - 40) end
        local wide = width >= 400
        self.narrow = not wide
        local photo = width < 300 and 52 or 72
        self.plate.Size, self.plate.Position = UDim2.fromOffset(photo, photo), UDim2.fromOffset(0, (72 - photo) / 2)
        self.banner.Position, self.banner.Size = UDim2.fromOffset(photo + 12, 6), UDim2.new(1, -photo - 12, 0, 60)
        local left = wide and math.floor((width - 10) * 0.51) or width
        local right = wide and width - left - 10 or width
        local function grid(items, hostWidth, top, height)
            local columns = hostWidth >= 180 and 2 or 1
            local rows = math.ceil(#items / columns)
            local cellWidth = (hostWidth - 24 - (columns - 1) * 6) / columns
            for i, item in ipairs(items) do
                item.main.Position = UDim2.fromOffset(12 + ((i - 1) % columns) * (cellWidth + 6), top + math.floor((i - 1) / columns) * (height + 6))
                item.main.Size = UDim2.fromOffset(cellWidth, height)
            end
            return top + rows * height + (rows - 1) * 6 + 10
        end
        local serverHeight = grid(self.stats, left, 44, 40)
        local friendHeight = grid(self.friendStats, right, 52, 52)
        self.session.Position, self.session.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(left, serverHeight)
        self.save.Position, self.save.Size = UDim2.fromOffset(0, serverHeight + 10), UDim2.fromOffset(left, 70)
        local leftHeight = serverHeight + 80
        client.Position, client.Size = UDim2.fromOffset(wide and left + 10 or 0, wide and 0 or leftHeight + 10), UDim2.fromOffset(right, 78)
        self.clientNote.Text = right < 240 and "Permitido" or "Permitido nesta library"
        self.friends.Position, self.friends.Size = UDim2.fromOffset(wide and left + 10 or 0, wide and 88 or leftHeight + 98), UDim2.fromOffset(right, friendHeight)
        local bodyHeight = wide and math.max(leftHeight, 88 + friendHeight) or leftHeight + 98 + friendHeight
        self.cards.Position, self.cards.Size = UDim2.fromOffset(0, 84), UDim2.new(1, 0, 0, bodyHeight)
        account.Position, account.Size = UDim2.fromOffset(0, 84 + bodyHeight + 10), UDim2.fromOffset(width, 34)
        self.notice.Position, self.notice.Size = UDim2.fromOffset(0, 84 + bodyHeight + 48), UDim2.fromOffset(width, 30)
        self.main.Size = UDim2.new(1, -24, 0, 84 + bodyHeight + (self.notice.Visible and 82 or 48))
    end
    function self:_setShown(shown, animate)
        for _, target in ipairs(self.targets) do
            local value = shown and (type(target.value) == "function" and target.value() or target.value) or 1
            window:_reveal(target.node, { [target.property] = value }, animate)
        end
    end
    function self:_refreshTheme() if not window.hidden then self:_setShown(true, false) end end
    window:ConnectFor(self, self.main:GetPropertyChangedSignal("AbsoluteSize"), function() self:Layout() end)
    self:Layout()
    return self
end
return Dashboard
