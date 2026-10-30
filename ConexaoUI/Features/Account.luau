--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Account information is a separate native content page, opened from the sidebar player card.
local Surface = require(script.Parent.Surface)
local Preferences = require(script.Parent.Preferences)
local image = require(script.Parent.Parent.Gen2.utility.image)
local BrandIcon = require(script.Parent.BrandIcon)
local Account = {}

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
    local function text(parent, value, x, y, width, height, size, bold, dim)
        local node = window:Create("TextLabel", {
            Parent = parent, Text = value, Position = UDim2.fromOffset(x, y), Size = UDim2.new(width == -1 and 1 or 0, width == -1 and -24 or width, 0, height),
            BackgroundTransparency = 1, TextTransparency = 1, TextSize = size, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6,
        }, { FontFace = bold and "TitleFont" or "Font", TextColor3 = "ContentColor" })
        track(node, "TextTransparency", dim or 0)
        return node
    end
    local function card(parent, name)
        local node = frame(parent, name, { BackgroundColor3 = Color3.new(1, 1, 1) }, { BackgroundTransparency = "ElementTransparency" })
        Surface.round(window, node, 9)
        window:Create("UIGradient", { Parent = node, Rotation = 35 }, { Color = "ElementGradient" })
        local rim = window:Create("UIStroke", { Parent = node, Thickness = 1, Transparency = 1 }, { Color = "SurfaceStroke" })
        track(node, "BackgroundTransparency", function() return window.theme.ElementTransparency end)
        track(rim, "Transparency", 0.75)
        return node
    end
    local function brand(parent, name, x, y, size)
        return BrandIcon.new(window, parent, name, { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(size, size) }, track)
    end
    owner.main = frame(tab.tabPage, "AccountPage", { Size = UDim2.new(1, -24, 0, 350) })
    owner.title = text(owner.main, "Meu perfil", 0, 0, -1, 28, 20, true)
    owner.title.Size = UDim2.new(1, -76, 0, 28)
    page.backButton = Surface.button(window, owner.main, "Voltar", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(64, 28), TextSize = 11, ZIndex = 9, BackgroundTransparency = 1, TextTransparency = 1 })
    track(page.backButton, "BackgroundTransparency", 0.3)
    track(page.backButton, "TextTransparency", 0)
    for _, child in ipairs(page.backButton:GetChildren()) do if child:IsA("UIStroke") then child.Transparency = 1 track(child, "Transparency", 0.75) end end
    window:ConnectFor(owner, page.backButton.MouseButton1Click, function() if window:_interactive() then window:CloseProfile() end end)
    owner.identity = card(owner.main, "Identity")
    owner.identity.Position, owner.identity.Size = UDim2.fromOffset(0, 40), UDim2.new(1, 0, 0, 96)
    page.avatar = window:Create("ImageLabel", {
        Parent = owner.identity, Position = UDim2.fromOffset(16, 16), Size = UDim2.fromOffset(64, 64),
        BackgroundTransparency = 1, ImageTransparency = 1, ScaleType = Enum.ScaleType.Fit, ResampleMode = Enum.ResamplerMode.Default, ZIndex = 6,
        Image = image.avatar(player.UserId, function(uri) if not window.unloaded and window.ProfilePage == page and page.avatar and page.avatar.Parent then image.assign(page.avatar, "Image", uri) end end),
    })
    Surface.round(window, page.avatar, 8)
    track(page.avatar, "ImageTransparency", 0)
    page.playerName = text(owner.identity, player.DisplayName, 96, 19, 1, 28, 20, true)
    page.playerName.Size, page.playerName.TextScaled = UDim2.new(1, -112, 0, 28), true
    window:Create("UITextSizeConstraint", { Parent = page.playerName, MinTextSize = 12, MaxTextSize = 20 })
    page.username = text(owner.identity, "@" .. player.Name, 96, 53, 1, 18, 12, false, 0.22)
    page.username.Size = UDim2.new(1, -112, 0, 18)
    owner.cards = frame(owner.main, "AccountDetails", { Position = UDim2.fromOffset(0, 148) })
    owner.account, owner.client = card(owner.cards, "Account"), card(owner.cards, "Client")
    local accountTitle = text(owner.account, "Conta", 12, 10, -1, 22, 14, true)
    accountTitle.Size = UDim2.new(1, -80, 0, 22)
    text(owner.account, "ID do jogador", 12, 48, -1, 14, 10, false, 0.25)
    page.userId = text(owner.account, tostring(player.UserId), 12, 65, -1, 22, 14, true)
    text(owner.account, "Nome de usuário", 12, 101, -1, 14, 10, false, 0.25)
    page.accountName = text(owner.account, "@" .. player.Name, 12, 120, -1, 22, 13, false)
    page.executorIcon = brand(owner.client, info.name, 12, 12, 22)
    page.executorName = text(owner.client, info.name, 44, 10, 1, 24, 16, true)
    page.executorName.Size = UDim2.new(1, -56, 0, 24)
    text(owner.client, "Versão do executor", 12, 48, -1, 14, 10, false, 0.25)
    page.executorVersion = text(owner.client, info.version or "Não informada", 12, 67, -1, 20, 12, false)
    text(owner.client, "Ambiente", 12, 101, -1, 14, 10, false, 0.25)
    page.platformIcon = brand(owner.client, info.environment, 12, 120, 20)
    page.environment = text(owner.client, info.environment, 40, 120, 1, 22, 12, false)
    page.environment.Size = UDim2.new(1, -52, 0, 22)
    owner.footer = text(owner.main, "", 0, 326, 1, 18, 10, false, 0.3)
    owner.footer.Size = UDim2.new(1, 0, 0, 18)
    owner.notice = text(owner.main, "", 0, 350, 1, 28, 11, false, 0.2)
    owner.notice.Size, owner.notice.Visible, owner.notice.TextWrapped = UDim2.new(1, 0, 0, 28), false, true
    page.copyButton = window:Create("TextButton", { Parent = owner.account, Text = "Copiar", TextSize = 10, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(44, 24), BackgroundTransparency = 1, TextTransparency = 1, AutoButtonColor = false, ZIndex = 9 }, { FontFace = "Font", TextColor3 = "ContentColor" })
    track(page.copyButton, "TextTransparency", 0.2)
    window:ConnectFor(owner, page.copyButton.MouseButton1Click, function()
        if not window:_interactive() then return end
        local env = _G
        if type(getgenv) == "function" then local ok, value = pcall(getgenv) if ok and type(value) == "table" then env = value end end
        local copy = env.setclipboard or env.toclipboard or getfenv().setclipboard or getfenv().toclipboard
        local ok, result = false, nil
        if type(copy) == "function" then ok, result = pcall(copy, tostring(player.UserId)) end
        owner.notice.Text, owner.notice.Visible = ok and result ~= false and "ID copiado." or "Copiar não está disponível neste cliente.", true
        owner:Layout()
        window:_reveal(owner.notice, { TextTransparency = 0.2 }, true)
    end)
    function owner:Layout()
        local width = self.main.AbsoluteSize.X
        if width <= 0 then width = math.max(180, window.elements.AbsoluteSize.X - 40) end
        local wide = width >= 400
        local column = wide and (width - 10) / 2 or width
        self.account.Size, self.account.Position = UDim2.fromOffset(column, 164), UDim2.fromOffset(0, 0)
        self.client.Size, self.client.Position = UDim2.fromOffset(column, 164), UDim2.fromOffset(wide and column + 10 or 0, wide and 0 or 174)
        local body = wide and 164 or 338
        self.cards.Size = UDim2.new(1, 0, 0, body)
        self.footer.Position, self.notice.Position = UDim2.fromOffset(0, 160 + body), UDim2.fromOffset(0, 184 + body)
        self.main.Size = UDim2.new(1, -24, 0, 184 + body + (self.notice.Visible and 32 or 0))
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
        owner.footer.Text, owner.notice.Visible = "Conexão Studio " .. version .. " · " .. Preferences.storage(), false
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
