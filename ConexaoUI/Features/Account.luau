--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- A separate account page in the native panel; the page owns its scroll extent and handlers.
local Surface = require(script.Parent.Surface)
local Preferences = require(script.Parent.Preferences)
local image = require(script.Parent.Parent.Gen2.utility.image)
local BrandIcon = require(script.Parent.BrandIcon)
local Account = {}
local function bold(font) return Font.new(font.Family, Enum.FontWeight.Bold, font.Style) end

local function build(window, player, info, version)
    local tab = window:CreateTab({ name = "Meu perfil", neglectSelector = true, forgetState = true })
    local page = { tab = tab, content = tab.tabPage, fields = {}, details = {} }
    window.ProfileTab, window.ProfilePage = tab, page
    local owner = { window = window, tab = tab, name = "Meu perfil", __type = "AccountPage", connections = {}, targets = {} }
    page.view = owner
    local function track(node, property, value) table.insert(owner.targets, { node = node, property = property, value = value }) end
    local function frame(parent, name, props, themed)
        local p = { Parent = parent, Name = name, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3 }
        for key, value in pairs(props or {}) do p[key] = value end
        return window:Create("Frame", p, themed)
    end
    local function text(parent, name, value, x, y, width, height, size, strong, dim)
        local node = window:Create("TextLabel", {
            Parent = parent, Name = name, Text = value, Position = UDim2.fromOffset(x, y), Size = UDim2.new(width == -1 and 1 or 0, width == -1 and -28 or width, 0, height),
            BackgroundTransparency = 1, TextTransparency = 1, TextSize = size, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6,
        }, { FontFace = strong and { "TitleFont", bold } or "Font", TextColor3 = "ContentColor" })
        track(node, "TextTransparency", dim or 0)
        return node
    end
    local function rim(node, radius, color, alpha)
        Surface.round(window, node, radius)
        local stroke = window:Create("UIStroke", { Parent = node, Thickness = 1, Transparency = 1 }, { Color = color or "SurfaceStroke" })
        track(stroke, "Transparency", alpha or 0.75)
        return stroke
    end
    local function card(parent, name)
        local node = frame(parent, name, { BackgroundColor3 = Color3.new(1, 1, 1) })
        window:Create("UIGradient", { Parent = node, Rotation = 75 }, { Color = { "StatBackground", function(base)
            return ColorSequence.new(base:Lerp(window.theme.AccentColor, 0.07), base)
        end } })
        rim(node, 14, "SurfaceStroke", 0.58)
        track(node, "BackgroundTransparency", function() return window.theme.ElementTransparency end)
        return node
    end
    local function brand(parent, name, x, y, size)
        return BrandIcon.new(window, parent, name, { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(size, size) }, track)
    end
    local function rule(parent, y)
        local node = frame(parent, "Divider", { Position = UDim2.fromOffset(14, y), Size = UDim2.new(1, -28, 0, 1) }, { BackgroundColor3 = "SurfaceStroke" })
        track(node, "BackgroundTransparency", 0.72)
        return node
    end
    local function button(parent, name, value, props)
        local p = { Name = name, Parent = parent, Text = value, TextSize = 11, BackgroundTransparency = 1,
            TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 9 }
        for key, value in pairs(props) do p[key] = value end
        local node = window:Create("TextButton", p, { FontFace = { "Font", bold }, TextColor3 = "ContentColor", BackgroundColor3 = "NeutralButton" })
        local stroke = rim(node, 8, "SurfaceStroke", 0.7)
        local state = { hover = false }
        track(node, "BackgroundTransparency", function() return state.hover and 0.08 or 0.4 end)
        track(node, "TextTransparency", 0.08)
        local function hover(value)
            if window.unloaded or not window:_interactive() then return end
            state.hover = value
            window:_reveal(node, { BackgroundTransparency = value and 0.08 or 0.4 }, true)
            window:_reveal(stroke, { Transparency = value and 0.35 or 0.7 }, true)
        end
        window:ConnectFor(owner, node.MouseEnter, function() hover(true) end)
        window:ConnectFor(owner, node.MouseLeave, function() hover(false) end)
        return node
    end
    local function badge(parent, name, value)
        local node = frame(parent, name, { Size = UDim2.fromOffset(100, 26) }, { BackgroundColor3 = "NeutralButton" })
        rim(node, 7, "SurfaceStroke", 0.82)
        track(node, "BackgroundTransparency", 0.28)
        local icon = brand(node, value, 7, 5, 16)
        local label = text(node, "Label", value == "Roblox Studio" and "Studio" or value, 29, 0, 1, 26, 10, true, 0.08)
        label.Size = UDim2.new(1, -35, 1, 0)
        return node, icon, label
    end

    owner.main = frame(tab.tabPage, "AccountPage", { Size = UDim2.new(1, -24, 0, 430) })
    owner.title = text(owner.main, "Heading", "Meu perfil", 0, 0, 1, 30, 22, true)
    owner.title.Size = UDim2.new(1, -82, 0, 30)
    page.backButton = button(owner.main, "Back", "Voltar", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(70, 30) })
    window:ConnectFor(owner, page.backButton.MouseButton1Click, function() if window:_interactive() then window:CloseProfile() end end)

    owner.identity = card(owner.main, "Identity")
    owner.identity.Position = UDim2.fromOffset(0, 44)
    owner.cover = frame(owner.identity, "ProfileCover", { Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 76), BackgroundColor3 = Color3.new(1, 1, 1) })
    rim(owner.cover, 10, "AccentStroke", 0.6)
    owner.coverGradient = window:Create("UIGradient", { Parent = owner.cover, Rotation = 12 }, { Color = { "StatBackground", function(base)
        local light = window.theme.ContentColor.R + window.theme.ContentColor.G + window.theme.ContentColor.B < 1.5
        local colors = window.theme.SliderProgress.Keypoints
        local accent, secondary = colors[1].Value, colors[#colors].Value
        return ColorSequence.new({ ColorSequenceKeypoint.new(0, base:Lerp(accent, light and 0.1 or 0.18)),
            ColorSequenceKeypoint.new(0.5, base:Lerp(accent, light and 0.2 or 0.42)),
            ColorSequenceKeypoint.new(1, base:Lerp(secondary, light and 0.32 or 0.7)) })
    end } })
    track(owner.cover, "BackgroundTransparency", function() return window.theme.ElementTransparency * 0.5 end)
    owner.eyebrow = text(owner.cover, "Eyebrow", "CONTA ROBLOX", 12, 10, 110, 18, 10, true, 0.1)
    owner.status = frame(owner.cover, "ConnectionStatus", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 9), Size = UDim2.fromOffset(92, 22) }, { BackgroundColor3 = "StatBackground" })
    rim(owner.status, 11, "AccentStroke", 0.7)
    track(owner.status, "BackgroundTransparency", 0.28)
    local dot = frame(owner.status, "Dot", { Position = UDim2.fromOffset(9, 8), Size = UDim2.fromOffset(6, 6), ZIndex = 6 }, { BackgroundColor3 = "AccentColor" })
    Surface.round(window, dot, 3)
    track(dot, "BackgroundTransparency", 0)
    text(owner.status, "Status", "Conectado", 22, 0, 66, 22, 10, true, 0.05)
    -- The decorative rules stay wholly inside the rounded cover, away from its corners.
    owner.coverRules = {}
    for index, length in ipairs({ 100, 72, 44 }) do
        local node = frame(owner.cover, "SignatureRule" .. index, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 42 + (index - 1) * 7), Size = UDim2.fromOffset(length, 2) }, { BackgroundColor3 = "ContentColor" })
        Surface.round(window, node, 1)
        track(node, "BackgroundTransparency", 0.78 + (index - 1) * 0.06)
        table.insert(owner.coverRules, node)
    end
    owner.avatarPlate = frame(owner.identity, "AvatarFrame", { ZIndex = 5 }, { BackgroundColor3 = "StatBackground" })
    owner.avatarRim = rim(owner.avatarPlate, 20, "AccentStroke", 0.12)
    owner.avatarRim.Thickness = 2
    track(owner.avatarPlate, "BackgroundTransparency", 0)
    page.avatar = window:Create("ImageLabel", {
        Parent = owner.avatarPlate, Name = "PlayerAvatar", Position = UDim2.fromOffset(5, 5), Size = UDim2.new(1, -10, 1, -10),
        BackgroundTransparency = 1, ImageTransparency = 1, ScaleType = Enum.ScaleType.Fit, ResampleMode = Enum.ResamplerMode.Default, ZIndex = 6,
        Image = image.avatar(player.UserId, function(uri) if not window.unloaded and window.ProfilePage == page and page.avatar and page.avatar.Parent then image.assign(page.avatar, "Image", uri) end end),
    })
    Surface.round(window, page.avatar, 16)
    track(page.avatar, "ImageTransparency", 0)
    page.playerName = text(owner.identity, "DisplayName", player.DisplayName, 120, 92, 1, 30, 24, true)
    page.playerName.TextScaled = true
    window:Create("UITextSizeConstraint", { Parent = page.playerName, MinTextSize = 13, MaxTextSize = 24 })
    page.username = text(owner.identity, "Username", "@" .. player.Name, 120, 124, 1, 18, 12, false, 0.2)
    owner.badges = frame(owner.identity, "IdentityBadges", {})
    owner.executorBadge, page.executorBadgeIcon = badge(owner.badges, "Executor", info.name)
    owner.platformBadge, page.platformBadgeIcon = badge(owner.badges, "Platform", info.environment)

    owner.cards = frame(owner.main, "AccountDetails", {})
    owner.account, owner.client = card(owner.cards, "Account"), card(owner.cards, "Client")
    local accountMark = frame(owner.account, "AccountMark", { Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(32, 32) }, { BackgroundColor3 = "NeutralButton" })
    rim(accountMark, 9, "SurfaceStroke", 0.85)
    track(accountMark, "BackgroundTransparency", 0.2)
    page.accountIcon = brand(accountMark, "Roblox", 7, 7, 18)
    text(owner.account, "Heading", "Conta Roblox", 56, 13, 1, 19, 14, true).Size = UDim2.new(1, -70, 0, 19)
    text(owner.account, "Subtitle", "Sua identidade", 56, 33, 1, 14, 10, false, 0.28).Size = UDim2.new(1, -70, 0, 14)
    rule(owner.account, 58)
    text(owner.account, "IdCaption", "ID DO JOGADOR", 14, 70, -1, 14, 9, true, 0.3)
    page.userId = text(owner.account, "UserId", tostring(player.UserId), 14, 88, 1, 23, 14, true)
    page.userId.Size = UDim2.new(1, -64, 0, 23)
    page.userId.TextScaled = true
    window:Create("UITextSizeConstraint", { Parent = page.userId, MinTextSize = 11, MaxTextSize = 14 })
    rule(owner.account, 121)
    text(owner.account, "UsernameCaption", "NOME DE USUÁRIO", 14, 133, -1, 14, 9, true, 0.3)
    page.accountName = text(owner.account, "AccountName", "@" .. player.Name, 14, 151, -1, 20, 12, false, 0.05)
    local executorMark = frame(owner.client, "ExecutorMark", { Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(32, 32) }, { BackgroundColor3 = "NeutralButton" })
    rim(executorMark, 9, "AccentStroke", 0.72)
    track(executorMark, "BackgroundTransparency", 0.1)
    page.executorIcon = brand(executorMark, info.name, 5, 5, 22)
    page.executorName = text(owner.client, "ExecutorName", info.name, 56, 13, 1, 19, 15, true)
    page.executorName.Size = UDim2.new(1, -70, 0, 19)
    text(owner.client, "Subtitle", "Executor conectado", 56, 33, 1, 14, 10, false, 0.28).Size = UDim2.new(1, -70, 0, 14)
    rule(owner.client, 58)
    text(owner.client, "VersionCaption", "VERSÃO DO EXECUTOR", 14, 70, -1, 14, 9, true, 0.3)
    page.executorVersion = text(owner.client, "ExecutorVersion", info.version or "Não informada", 14, 88, -1, 23, 12, false, 0.05)
    rule(owner.client, 121)
    text(owner.client, "EnvironmentCaption", "AMBIENTE", 14, 133, -1, 14, 9, true, 0.3)
    page.platformIcon = brand(owner.client, info.environment, 14, 153, 16)
    page.environment = text(owner.client, "Environment", info.environment, 38, 151, 1, 20, 12, false, 0.05)
    page.environment.Size = UDim2.new(1, -52, 0, 20)
    page.copyButton = button(owner.account, "CopyAccountId", "", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 84), Size = UDim2.fromOffset(30, 30) })
    page.copyIcon = brand(page.copyButton, "copy", 7, 7, 16)
    for _, part in ipairs(page.copyIcon.parts) do part.ZIndex = 10 end

    owner.footer = text(owner.main, "LibraryVersion", "Conexão Studio · " .. version, 0, 0, 1, 18, 10, true, 0.22)
    owner.storage = text(owner.main, "Storage", Preferences.storage(), 0, 0, 1, 18, 10, false, 0.3)
    owner.storage.TextXAlignment = Enum.TextXAlignment.Right
    owner.notice = text(owner.main, "Notice", "", 0, 0, 1, 32, 11, false, 0.12)
    owner.notice.Visible, owner.notice.TextWrapped = false, true
    window:ConnectFor(owner, page.copyButton.MouseButton1Click, function()
        if not window:_interactive() then return end
        local env = _G
        if type(getgenv) == "function" then local ok, value = pcall(getgenv) if ok and type(value) == "table" then env = value end end
        local copy = env.setclipboard or env.toclipboard or getfenv().setclipboard or getfenv().toclipboard
        local ok, result = false, nil
        local current = game:GetService("Players").LocalPlayer or player
        if type(copy) == "function" then ok, result = pcall(copy, tostring(current.UserId)) end
        owner.notice.Text, owner.notice.Visible = ok and result ~= false and "ID copiado." or "Copiar não está disponível neste cliente.", true
        owner:Layout()
        window:_reveal(owner.notice, { TextTransparency = 0.12 }, true)
    end)
    function owner:Layout()
        if window.unloaded or not self.main.Parent then return end
        local width = self.main.AbsoluteSize.X
        if width <= 0 then width = math.max(180, window.elements.AbsoluteSize.X - 40) end
        local compact, wide = width < 300, width >= 400
        local photo = compact and 68 or 88
        local identityHeight = compact and 228 or 188
        local nameX, nameY = compact and 16 or 120, compact and 130 or 94
        self.identity.Size = UDim2.fromOffset(width, identityHeight)
        self.avatarPlate.Position, self.avatarPlate.Size = UDim2.fromOffset(16, 46), UDim2.fromOffset(photo, photo)
        page.playerName.Position, page.playerName.Size = UDim2.fromOffset(nameX, nameY), UDim2.fromOffset(width - nameX - 16, 30)
        page.username.Position, page.username.Size = UDim2.fromOffset(nameX, nameY + 31), UDim2.fromOffset(width - nameX - 16, 18)
        self.eyebrow.Visible = width >= 280
        self.status.Position = UDim2.new(1, -10, 0, 9)
        for _, node in ipairs(self.coverRules) do node.Visible = width >= 300 end
        local badgeY = compact and 190 or 150
        self.badges.Position, self.badges.Size = UDim2.fromOffset(16, badgeY), UDim2.fromOffset(width - 32, 26)
        local available = width - 32
        local executorWidth = math.min(118, (available - 6) / 2)
        local platformWidth = math.min(96, available - executorWidth - 6)
        self.executorBadge.Position, self.executorBadge.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(executorWidth, 26)
        self.platformBadge.Position, self.platformBadge.Size = UDim2.fromOffset(executorWidth + 6, 0), UDim2.fromOffset(platformWidth, 26)
        local column, cardHeight = wide and math.floor((width - 12) / 2) or width, 184
        self.account.Position, self.account.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(column, cardHeight)
        self.client.Position, self.client.Size = UDim2.fromOffset(wide and column + 12 or 0, wide and 0 or cardHeight + 12), UDim2.fromOffset(wide and width - column - 12 or width, cardHeight)
        local body = wide and cardHeight or cardHeight * 2 + 12
        local cardsY = 44 + identityHeight + 12
        self.cards.Position, self.cards.Size = UDim2.fromOffset(0, cardsY), UDim2.fromOffset(width, body)
        local footerY, stacked = cardsY + body + 14, width < 400
        self.footer.Position, self.footer.Size = UDim2.fromOffset(0, footerY), UDim2.fromOffset(stacked and width or width * 0.53, 18)
        self.storage.Position, self.storage.Size = UDim2.fromOffset(stacked and 0 or width * 0.53, footerY + (stacked and 21 or 0)), UDim2.fromOffset(stacked and width or width * 0.47, 18)
        self.storage.TextXAlignment = stacked and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
        local bottom = footerY + (stacked and 39 or 18)
        self.notice.Position, self.notice.Size = UDim2.fromOffset(0, bottom + 8), UDim2.fromOffset(width, 34)
        self.main.Size = UDim2.new(1, -24, 0, bottom + (self.notice.Visible and 46 or 4))
    end
    function owner:_setShown(shown, animate)
        for _, target in ipairs(self.targets) do
            local value = shown and (type(target.value) == "function" and target.value() or target.value) or 1
            window:_reveal(target.node, { [target.property] = value }, animate)
        end
    end
    function owner:_refreshTheme() if not window.hidden then self:_setShown(true, false) end end
    function page:Refresh()
        local current = game:GetService("Players").LocalPlayer or player
        self.playerName.Text, self.username.Text = current.DisplayName, "@" .. current.Name
        self.userId.Text, self.accountName.Text = tostring(current.UserId), "@" .. current.Name
        self.details = { { "ID do jogador", tostring(current.UserId) }, { "Executor", info.name }, { "Versão do executor", info.version or "Não informada" }, { "Ambiente", info.environment }, { "Conexão UI", version }, { "Armazenamento", Preferences.storage() } }
        owner.storage.Text, owner.notice.Visible = Preferences.storage(), false
        owner:Layout()
    end
    function page:Close() window:CloseProfile() end
    local remove = tab.Remove
    function tab:Remove()
        if window.ProfileTab == self then window.ProfileTab, window.ProfilePage = nil, nil end
        remove(self)
    end
    window:ConnectFor(owner, owner.main:GetPropertyChangedSignal("AbsoluteSize"), function() owner:Layout() end)
    tab:_register(owner)
    return page
end

function Account.attach(window, info, version)
    function window:OpenProfile()
        if self.unloaded then return end
        local player = game:GetService("Players").LocalPlayer
        if not player then return end
        if self._conexaoPanel then self._conexaoPanel:Close() end
        if self.selectedTab ~= self.ProfileTab then self._profilePreviousTab = self.selectedTab end
        local page = self.ProfilePage or build(self, player, info, version)
        page:Refresh()
        page.tab:Select()
        return page
    end
    function window:CloseProfile()
        if self.unloaded then return end
        if self.selectedTab == self.HomeTab then return self:_closeHome() end
        if not self.ProfileTab or self.selectedTab ~= self.ProfileTab then return end
        local previous = self._profilePreviousTab
        local function valid(tab) return tab and tab ~= self.ProfileTab and tab.tabPage and table.find(self.tabs, tab) end
        if not valid(previous) then
            previous = valid(self.HomeTab) and self.HomeTab or (valid(self.SettingsTab) and self.SettingsTab or nil)
            if not previous then for _, candidate in ipairs(self.tabs) do if valid(candidate) then previous = candidate break end end end
        end
        if previous then previous:Select() end
    end
end
return Account
