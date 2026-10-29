--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Surface = require(script.Parent.Surface)
local Preferences = require(script.Parent.Preferences)
local image = require(script.Parent.Parent.Gen2.utility.image)
local Profile = {}

local function buildPage(window, player, executorInfo, version)
    -- A native content page, like Settings: it is clipped/scrolled by the main panel.
    local tab = window:CreateTab({ name = "Perfil", neglectSelector = true, forgetState = true })
    local page = { tab = tab, content = tab.tabPage, details = {}, fields = {} }
    window.ProfileTab, window.ProfilePage = tab, page
    tab:CreateSection({ name = "Seu perfil" })

    local hero = { window = window, name = "Perfil do jogador", __type = "ProfileHeader" }
    hero.main = window:Create("Frame", {
        Name = "PlayerProfile", Parent = tab.tabPage, Size = UDim2.new(1, -20, 0, 114),
        BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
    }, { BackgroundTransparency = "ElementTransparency" })
    hero.stroke = window:StyleElementBody(hero.main)
    local plate = window:Create("Frame", {
        Parent = hero.main, Position = UDim2.fromOffset(12, 18), Size = UDim2.fromOffset(72, 72),
        BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 4,
    }, { BackgroundColor3 = "AccentColor" })
    Surface.round(window, plate, 36)
    local plateStroke = window:Create("UIStroke", { Parent = plate, Thickness = 1, Transparency = 1 }, { Color = "AccentStroke" })
    page.avatar = window:Create("ImageLabel", {
        Parent = hero.main, Position = UDim2.fromOffset(16, 22), Size = UDim2.fromOffset(64, 64),
        BackgroundTransparency = 1, ImageTransparency = 1, ZIndex = 5,
        Image = image.avatar(player.UserId, function(uri)
            if not window.unloaded and window.ProfilePage == page and page.avatar and page.avatar.Parent then
                image.assign(page.avatar, "Image", uri)
            end
        end),
    })
    Surface.round(window, page.avatar, 32)
    page.playerName = Surface.label(window, hero.main, player.DisplayName, {
        Position = UDim2.fromOffset(96, 18), Size = UDim2.new(1, -114, 0, 44),
        TextSize = 20, TextTransparency = 1, ZIndex = 5,
    })
    page.username = Surface.label(window, hero.main, "@" .. player.Name, {
        Position = UDim2.fromOffset(96, 64), Size = UDim2.new(1, -114, 0, 28),
        TextSize = 13, TextTransparency = 1, TextWrapped = false,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5,
    })
    page.playerName.FontFace = window.theme.TitleFont
    window.themeProperties[page.playerName].FontFace = "TitleFont"
    hero.title, hero.iconLabel = page.playerName, page.avatar
    function hero:_setShown(shown, animate)
        if shown then window:_revealCommon(self, animate) else window:_hideCommon(self, animate) end
        window:_reveal(page.username, { TextTransparency = shown and 0.3 or 1 }, animate)
        window:_reveal(plate, { BackgroundTransparency = shown and 0.83 or 1 }, animate)
        window:_reveal(plateStroke, { Transparency = shown and 0.35 or 1 }, animate)
    end
    tab:_register(hero)
    page.backButton = tab:CreateButton({ name = "Voltar para a aba anterior", callback = function() window:CloseProfile() end })
    tab:CreateSection({ name = "Conta e executor" })

    function page:Refresh()
        player = game:GetService("Players").LocalPlayer or player
        self.playerName.Text = player.DisplayName
        self.username.Text = "@" .. player.Name
        local storage = Preferences.storage()
        self.details = {
            { "ID do jogador", tostring(player.UserId) },
            { "Executor", executorInfo.name },
            { "Versão do executor", executorInfo.version or "Não informada" },
            { "Ambiente", executorInfo.environment },
            { "Conexão UI", version },
            { "Armazenamento", storage },
        }
        local shown = {
            { "Executor", executorInfo.name .. (executorInfo.version and (" · " .. executorInfo.version) or "") },
            self.details[1],
        }
        for index, detail in ipairs(shown) do
            if self.fields[index] then self.fields[index]:Set(detail[2])
            else self.fields[index] = tab:CreateText({ name = detail[1], text = detail[2] }) end
        end
    end
    function page:Close() window:CloseProfile() end
    -- An application may remove the page through the public Tab API. Rebuild safely next time.
    local remove = tab.Remove
    function tab:Remove()
        if window.ProfileTab == self then window.ProfileTab, window.ProfilePage = nil, nil end
        remove(self)
    end
    return page
end

function Profile.attach(window, executorInfo, version)
    window.ExecutorInfo = executorInfo
    function window:CloseProfile()
        if self.unloaded or not self.ProfileTab or self.selectedTab ~= self.ProfileTab then return end
        local previous = self._profilePreviousTab
        if not previous or not previous.tabPage or not table.find(self.tabs, previous) then
            previous = self.SettingsTab
            for _, candidate in ipairs(self.tabs) do
                if candidate ~= self.SettingsTab and not candidate.neglectSelector and candidate.tabPage then previous = candidate break end
            end
        end
        if previous then previous:Select() end
    end
    function window:OpenProfile()
        if self.unloaded then return end
        local player = game:GetService("Players").LocalPlayer
        if not player then return end
        if self._conexaoPanel then self._conexaoPanel:Close() end
        if self.selectedTab ~= self.ProfileTab then self._profilePreviousTab = self.selectedTab end
        local page = self.ProfilePage or buildPage(self, player, executorInfo, version)
        page:Refresh()
        page.tab:Select()
        return page
    end
    if window.profile then
        window.profileAvatar.Size = UDim2.fromOffset(40, 40)
        window.profileAvatar.ZIndex = 123
        window.profileContainer.ZIndex, window.profileLabels.ZIndex = 121, 121
        window.profileLabels.AutomaticSize = Enum.AutomaticSize.None
        window.profileLabels.Size = UDim2.new(1, -60, 0, 40)
        window.profileName.Size = UDim2.new(1, 0, 0, 20)
        window.profileName.AutomaticSize = Enum.AutomaticSize.None
        window.profileName.TextSize, window.profileName.ZIndex = 16, 123
        window.profileName.FontFace = window.theme.TitleFont
        window.themeProperties[window.profileName].FontFace = "TitleFont"
        window.profileName.TextWrapped, window.profileName.TextTruncate = false, Enum.TextTruncate.AtEnd
        window.profileSubtitle.Size = UDim2.new(1, 0, 0, 16)
        window.profileSubtitle.AutomaticSize = Enum.AutomaticSize.None
        window.profileSubtitle.TextSize, window.profileSubtitle.ZIndex = 12, 123
        window.profileSubtitle.TextWrapped, window.profileSubtitle.TextTruncate = false, Enum.TextTruncate.AtEnd
        window.ProfileCard = window:Create("Frame", {
            Name = "PlayerCard", Parent = window.profile, BorderSizePixel = 0,
            BackgroundTransparency = 0.9, Position = UDim2.fromOffset(8, 4), Size = UDim2.new(1, -16, 1, -8), ZIndex = 120,
        }, { BackgroundColor3 = "AccentColor" })
        Surface.round(window, window.ProfileCard, 12)
        window:Create("UIStroke", { Parent = window.ProfileCard, Transparency = 0.7, Thickness = 1 }, { Color = "AccentStroke" })
        window.ProfileButton = window:Create("TextButton", {
            Name = "OpenProfile", Parent = window.ProfileCard, Text = "", AutoButtonColor = false,
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 125,
        })
        window:Connect(window.ProfileButton.MouseButton1Click, function() window:OpenProfile() end)
    end
end

return Profile
