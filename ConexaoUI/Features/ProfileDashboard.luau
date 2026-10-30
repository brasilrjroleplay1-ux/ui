--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Native Home content: a compact greeting above session/client/account cards.
local Surface = require(script.Parent.Surface)
local image = require(script.Parent.Parent.Gen2.utility.image)
local BrandIcon = require(script.Parent.BrandIcon)
local Dashboard = {}

function Dashboard.new(window, tab, page, player, executorInfo)
    local self = { window = window, tab = tab, name = "Início", __type = "ProfileDashboard", connections = {}, targets = {}, targetIndex = {} }
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
    local function label(parent, text, props, title)
        local p = {
            Parent = parent, Text = text, BackgroundTransparency = 1, TextTransparency = 1,
            TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = false,
            TextTruncate = Enum.TextTruncate.AtEnd, BorderSizePixel = 0, ZIndex = 6,
        }
        for key, value in pairs(props or {}) do p[key] = value end
        local node = window:Create("TextLabel", p, { FontFace = title and "TitleFont" or "Font", TextColor3 = "ContentColor" })
        self:Track(node, "TextTransparency", 0)
        return node
    end
    local function frame(parent, name, props, themed)
        local p = { Parent = parent, Name = name, BorderSizePixel = 0, ZIndex = 3 }
        for key, value in pairs(props or {}) do p[key] = value end
        return window:Create("Frame", p, themed)
    end
    local function surface(parent, name, tint)
        local node = frame(parent, name, { BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1 }, { BackgroundTransparency = "ElementTransparency" })
        Surface.round(window, node, 14)
        window:Create("UIGradient", { Parent = node, Rotation = 35 }, {
            Color = { "StatBackground", function(base)
                local edge = base:Lerp(window.theme.AccentColor, tint or 0.1)
                return ColorSequence.new(base:Lerp(Color3.new(0, 0, 0), 0.12), edge)
            end },
        })
        local rim = window:Create("UIStroke", { Parent = node, Thickness = 1, Transparency = 1 }, { Color = "SurfaceStroke" })
        self:Track(node, "BackgroundTransparency", function() return window.theme.ElementTransparency end)
        self:Track(rim, "Transparency", 0.65)
        return node
    end
    local function action(parent, name, text, callback)
        local button = Surface.button(window, parent, text, {
            Name = name, ZIndex = 9, TextSize = 11, BackgroundTransparency = 1, TextTransparency = 1,
        }, false)
        self:Track(button, "BackgroundTransparency", 0.2)
        self:Track(button, "TextTransparency", 0)
        for _, child in ipairs(button:GetChildren()) do
            if child:IsA("UIStroke") then child.Transparency = 1 self:Track(child, "Transparency", 0.65) end
        end
        self:Connect(button.MouseButton1Click, function() if window:_interactive() then callback() end end)
        return button
    end
    local function brand(parent, name, props)
        return BrandIcon.new(window, parent, name, props, function(node, property, value) self:Track(node, property, value) end)
    end

    self.main = frame(tab.tabPage, "ProfileDashboard", { Size = UDim2.new(1, -20, 0, 380), BackgroundTransparency = 1 })
    self.title = label(self.main, "Início", { Size = UDim2.new(1, -84, 0, 28), TextSize = 21 }, true)
    local back = action(self.main, "Back", "Voltar", function() window:CloseProfile() end)
    back.AnchorPoint, back.Position, back.Size = Vector2.new(1, 0), UDim2.new(1, 0, 0, 0), UDim2.fromOffset(64, 28)
    page.backButton = { interact = back }

    self.hero = frame(self.main, "WelcomeRow", { Position = UDim2.fromOffset(0, 36), Size = UDim2.new(1, 0, 0, 84), BackgroundTransparency = 1 })
    self.banner = surface(self.hero, "WelcomeCard", 0.14)
    self.banner.Size = UDim2.fromScale(1, 1)
    self.plate = frame(self.banner, "AvatarRing", {
        Position = UDim2.fromOffset(12, 10), Size = UDim2.fromOffset(64, 64), BackgroundTransparency = 1, ZIndex = 5,
    }, { BackgroundColor3 = "StatBackground" })
    Surface.round(window, self.plate, 12)
    self:Track(self.plate, "BackgroundTransparency", 0)
    local avatarRim = window:Create("UIStroke", { Parent = self.plate, Thickness = 1, Transparency = 1 }, { Color = "SurfaceStroke" })
    self:Track(avatarRim, "Transparency", 0.3)
    page.avatar = window:Create("ImageLabel", {
        Parent = self.plate, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ImageTransparency = 1, ZIndex = 6,
        ScaleType = Enum.ScaleType.Fit, ResampleMode = Enum.ResamplerMode.Default,
        Image = image.avatar(player.UserId, function(uri)
            if not window.unloaded and window.ProfilePage == page and page.avatar and page.avatar.Parent then image.assign(page.avatar, "Image", uri) end
        end),
    })
    Surface.round(window, page.avatar, 12)
    self:Track(page.avatar, "ImageTransparency", 0)
    self.connected = label(self.banner, "BEM-VINDO DE VOLTA", { TextSize = 10 })
    self:Track(self.connected, "TextTransparency", 0.28)
    page.playerName = label(self.banner, player.DisplayName, { TextSize = 24, TextScaled = true }, true)
    window:Create("UITextSizeConstraint", { Parent = page.playerName, MaxTextSize = 24, MinTextSize = 12 })
    page.username = label(self.banner, "@" .. player.Name, { TextSize = 12 })
    self:Track(page.username, "TextTransparency", 0.25)

    self.cards = frame(self.main, "SessionAndAccount", { BackgroundTransparency = 1 })
    self.session = surface(self.cards, "SessionPanel", 0.07)
    self.sessionTitle = label(self.session, "Sessão", { Position = UDim2.fromOffset(14, 10), Size = UDim2.new(1, -92, 0, 22), TextSize = 16 }, true)
    self.live = label(self.session, "AO VIVO", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 15), Size = UDim2.fromOffset(48, 12), TextSize = 9, TextXAlignment = Enum.TextXAlignment.Right }, true)
    self:Track(self.live, "TextTransparency", 0.25)
    self.stats = {}
    for _, definition in ipairs({ { "playerText", "Jogadores" }, { "pingText", "Latência" }, { "fpsText", "FPS" }, { "timeText", "Tempo de sessão" }, { "placeText", "Place ID" }, { "saveText", "Salvamento" } }) do
        local tile = frame(self.session, definition[1], { BackgroundTransparency = 1, ZIndex = 4 }, { BackgroundColor3 = "StatBackground" })
        Surface.round(window, tile, 9)
        self:Track(tile, "BackgroundTransparency", 0)
        local caption = label(tile, definition[2], { Position = UDim2.fromOffset(10, 7), Size = UDim2.new(1, -20, 0, 15), TextSize = 10 })
        self:Track(caption, "TextTransparency", 0.22)
        local value = label(tile, "—", { Position = UDim2.fromOffset(10, 25), Size = UDim2.new(1, -20, 0, 24), TextSize = 20, TextScaled = true }, true)
        window:Create("UITextSizeConstraint", { Parent = value, MinTextSize = 10, MaxTextSize = 20 })
        table.insert(self.stats, { key = definition[1], main = tile, caption = caption, value = value })
    end
    local function card(name, brandName, copy)
        local host = surface(self.cards, name, name == "ClientCard" and 0.18 or 0.06)
        local logo = brand(host, brandName, { Position = UDim2.fromOffset(14, 12), Size = UDim2.fromOffset(22, 22) })
        local heading = label(host, copy and "CONTA" or "CLIENTE", { Position = UDim2.fromOffset(44, 15), Size = UDim2.new(1, copy and -110 or -58, 0, 16), TextSize = 10 }, true)
        self:Track(heading, "TextTransparency", 0.22)
        local value = label(host, "", { Position = UDim2.fromOffset(14, 40), Size = UDim2.new(1, -28, 0, 24), TextSize = copy and 18 or 22, TextScaled = true }, true)
        window:Create("UITextSizeConstraint", { Parent = value, MinTextSize = 10, MaxTextSize = copy and 18 or 22 })
        local caption = label(host, "", { Position = UDim2.fromOffset(14, copy and 66 or 68), Size = UDim2.new(1, -28, 0, 15), TextSize = 11 })
        self:Track(caption, "TextTransparency", 0.25)
        local data = { main = host, valueLabel = value, subtitle = caption, heading = heading, icon = logo }
        function data:Set(text) self.valueLabel.Text = tostring(text) end
        return data
    end
    page.fields[1], page.fields[2] = card("ClientCard", executorInfo.name, false), card("AccountCard", "Roblox", true)
    page.executorBadge, page.executorIcon = page.fields[1].valueLabel, page.fields[1].icon
    self.platformPill = frame(page.fields[1].main, "Platform", {
        Position = UDim2.fromOffset(14, 92), Size = UDim2.fromOffset(86, 22), BackgroundTransparency = 1, ZIndex = 5,
    }, { BackgroundColor3 = "StatBackground" })
    Surface.round(window, self.platformPill, 7)
    self:Track(self.platformPill, "BackgroundTransparency", 0)
    page.platformIcon = brand(self.platformPill, executorInfo.environment, { Position = UDim2.fromOffset(7, 4), Size = UDim2.fromOffset(14, 14) })
    page.platformBadge = label(self.platformPill, executorInfo.environment == "Roblox Studio" and "Studio" or "Roblox", { Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -32, 1, 0), TextSize = 11 })
    self.clientNote = label(page.fields[1].main, "Permitido", { Position = UDim2.fromOffset(108, 92), Size = UDim2.new(1, -122, 0, 22), TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right })
    self:Track(self.clientNote, "TextTransparency", 0.15)
    self.accountVersion = page.fields[2].subtitle
    self.accountSave = label(page.fields[2].main, "", { Position = UDim2.fromOffset(14, 84), Size = UDim2.new(1, -28, 0, 15), TextSize = 11 })
    self:Track(self.accountSave, "TextTransparency", 0.2)
    page.copyButton = action(page.fields[2].main, "CopyAccountId", "Copiar", function()
        local env = _G
        if type(getgenv) == "function" then local ok, value = pcall(getgenv) if ok and type(value) == "table" then env = value end end
        local copy = env.setclipboard or env.toclipboard or getfenv().setclipboard or getfenv().toclipboard
        local ok, result
        if type(copy) == "function" then ok, result = pcall(copy, tostring(player.UserId)) end
        self.notice.Text = ok and result ~= false and "ID copiado." or "Copiar não está disponível neste cliente."
        self.notice.Visible = true
        self:Layout()
        window:_reveal(self.notice, { TextTransparency = 0.2 }, true)
    end)
    page.copyButton.AnchorPoint, page.copyButton.Position, page.copyButton.Size = Vector2.new(1, 0), UDim2.new(1, -12, 0, 10), UDim2.fromOffset(46, 26)
    self.notice = label(self.main, "", { TextSize = 11, TextWrapped = true, Visible = false })

    function self:Layout()
        local width = self.main.AbsoluteSize.X
        if width <= 0 then width = math.max(180, window.elements.AbsoluteSize.X - 40) end
        local wide = width >= 420
        self.narrow = not wide
        local photo = width < 260 and 48 or 64
        local textLeft = 12 + photo + 14
        self.plate.Size, self.plate.Position = UDim2.fromOffset(photo, photo), UDim2.fromOffset(12, (84 - photo) / 2)
        self.connected.Position, self.connected.Size = UDim2.fromOffset(textLeft, 10), UDim2.new(1, -textLeft - 12, 0, 12)
        self.connected.Text = width < 320 and "OLÁ!" or "BEM-VINDO DE VOLTA"
        page.playerName.Position, page.playerName.Size = UDim2.fromOffset(textLeft, 25), UDim2.new(1, -textLeft - 12, 0, 28)
        page.username.Position, page.username.Size = UDim2.fromOffset(textLeft, 56), UDim2.new(1, -textLeft - 12, 0, 18)
        local left = wide and math.floor((width - 12) * 0.56) or width
        local right = wide and width - left - 12 or width
        local columns = left >= 450 and 3 or (left >= 220 and 2 or 1)
        local rows = math.ceil(#self.stats / columns)
        local tileWidth = (left - 28 - (columns - 1) * 8) / columns
        local sessionHeight = math.max(240, 40 + rows * 56 + (rows - 1) * 8 + 12)
        local tileHeight = (sessionHeight - 52 - (rows - 1) * 8) / rows
        self.session.Position, self.session.Size = UDim2.fromOffset(0, wide and 0 or 136), UDim2.fromOffset(left, sessionHeight)
        for index, item in ipairs(self.stats) do
            item.main.Position = UDim2.fromOffset(14 + ((index - 1) % columns) * (tileWidth + 8), 40 + math.floor((index - 1) / columns) * (tileHeight + 8))
            item.main.Size = UDim2.fromOffset(tileWidth, tileHeight)
            local textTop = math.floor((tileHeight - 42) / 2)
            item.caption.Position = UDim2.fromOffset(10, textTop)
            item.value.Position = UDim2.fromOffset(10, textTop + 18)
        end
        local rightX = wide and left + 12 or 0
        page.fields[1].main.Position, page.fields[1].main.Size = UDim2.fromOffset(rightX, 0), UDim2.fromOffset(right, 124)
        page.fields[2].main.Position, page.fields[2].main.Size = UDim2.fromOffset(rightX, wide and 136 or 148 + sessionHeight), UDim2.fromOffset(right, 104)
        local height = wide and math.max(sessionHeight, 240) or 252 + sessionHeight
        self.cards.Position, self.cards.Size = UDim2.fromOffset(0, 132), UDim2.new(1, 0, 0, height)
        self.notice.Position, self.notice.Size = UDim2.fromOffset(0, 132 + height + 8), UDim2.new(1, 0, 0, 36)
        self.main.Size = UDim2.new(1, -20, 0, 132 + height + (self.notice.Visible and 52 or 8))
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
