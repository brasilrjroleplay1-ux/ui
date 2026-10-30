--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Surface = require(script.Parent.Surface)
local Preferences = require(script.Parent.Preferences)
local Dashboard = require(script.Parent.ProfileDashboard)
local Profile = {}

local function buildPage(window, player, executorInfo, version)
    -- A native content page, like Settings: it is clipped/scrolled by the main panel.
    local tab = window:CreateTab({ name = "Início", icon = 93364949241311, customOrder = -1000, forgetState = true })
    local page = { tab = tab, content = tab.tabPage, details = {}, fields = {} }
    window.HomeTab, window.HomePage = tab, page
    page.dashboard = Dashboard.new(window, tab, page, player, executorInfo)
    tab:_register(page.dashboard)

    function page:RefreshStats()
        if not window.GetSessionStats then return end
        local snapshot = window:GetSessionStats()
        for _, item in ipairs(self.dashboard.stats) do item.value.Text = snapshot[item.key] or "—" end
        self.dashboard.accountSave.Text = "Salvamento: " .. snapshot.saveText
        self.dashboard.saveTitle.Text = snapshot.saveText == "Ativado" and "Salvamento automático" or "Salvamento desativado"
        self.dashboard.saveSubtitle.Text = snapshot.saveText == "Ativado" and "Suas escolhas são lembradas neste dispositivo" or "Ative o salvamento na página de configurações"
        if window.GetFriendStats then
            local friends = window:GetFriendStats()
            for _, item in ipairs(self.dashboard.friendStats) do item.value.Text = friends[item.key] or "—" end
            self.dashboard.friendSubtitle.Text = friends.unavailable and "Dados indisponíveis neste cliente" or "Seus amigos no Roblox"
        end
    end

    function page:Refresh()
        player = game:GetService("Players").LocalPlayer or player
        self.playerName.Text = "Olá, " .. player.DisplayName
        self.username.Text = "@" .. player.Name .. " · " .. window.name
        local storage = Preferences.storage()
        self.details = {
            { "ID do jogador", tostring(player.UserId) },
            { "Executor", executorInfo.name },
            { "Versão do executor", executorInfo.version or "Não informada" },
            { "Ambiente", executorInfo.environment },
            { "Conexão UI", version },
            { "Armazenamento", storage },
        }
        self.executorBadge.Text = executorInfo.name
        self.fields[1]:Set(executorInfo.name)
        self.fields[1].subtitle.Text = executorInfo.version and ("Versão " .. executorInfo.version) or "Versão não informada"
        self.fields[2]:Set(tostring(player.UserId))
        self.dashboard.accountVersion.Text = "Conexão Studio " .. version
        self:RefreshStats()
        self.dashboard.notice.Visible = false
        self.dashboard:Layout()
        if window.RefreshFriends then window:RefreshFriends() end
    end
    function page:Close() window:_closeHome() end
    -- An application may remove the page through the public Tab API. Rebuild safely next time.
    local remove = tab.Remove
    function tab:Remove()
        if window.HomeTab == self then window.HomeTab, window.HomePage = nil, nil end
        remove(self)
    end
    return page
end

function Profile.attach(window, executorInfo, version)
    window.ExecutorInfo = executorInfo
    function window:_closeHome()
        if self.unloaded or not self.HomeTab or self.selectedTab ~= self.HomeTab then return end
        local previous = self._homePreviousTab
        if not previous or not previous.tabPage or not table.find(self.tabs, previous) then
            previous = self.SettingsTab
            for _, candidate in ipairs(self.tabs) do
                if candidate ~= self.SettingsTab and candidate ~= self.HomeTab and not candidate.neglectSelector and candidate.tabPage then previous = candidate break end
            end
        end
        if previous then previous:Select() end
    end
    function window:OpenHome()
        if self.unloaded then return end
        local player = game:GetService("Players").LocalPlayer
        if not player then return end
        if self._conexaoPanel then self._conexaoPanel:Close() end
        if self.selectedTab ~= self.HomeTab then self._homePreviousTab = self.selectedTab end
        local page = self.HomePage or buildPage(self, player, executorInfo, version)
        page:Refresh()
        page.tab:Select()
        return page
    end
    require(script.Parent.Account).attach(window, executorInfo, version)
    if window.profile then
        window.profileAvatar.Size = UDim2.fromOffset(36, 36)
        window.profileAvatar.ZIndex = 123
        window.profileAvatar.ScaleType, window.profileAvatar.ResampleMode = Enum.ScaleType.Fit, Enum.ResamplerMode.Default
        window.profileContainer.ZIndex, window.profileLabels.ZIndex = 121, 121
        window.profileLabels.AutomaticSize = Enum.AutomaticSize.None
        window.profileLabels.Size = UDim2.new(1, -64, 0, 40)
        window.profileName.Size = UDim2.new(1, 0, 0, 20)
        window.profileName.AutomaticSize = Enum.AutomaticSize.None
        window.profileName.TextSize, window.profileName.ZIndex = 14, 123
        window.profileName.FontFace = window.theme.TitleFont
        window.themeProperties[window.profileName].FontFace = "TitleFont"
        window.profileName.TextWrapped, window.profileName.TextTruncate = false, Enum.TextTruncate.AtEnd
        window.profileSubtitle.Size = UDim2.new(1, 0, 0, 16)
        window.profileSubtitle.AutomaticSize = Enum.AutomaticSize.None
        window.profileSubtitle.TextSize, window.profileSubtitle.ZIndex = 11, 123
        window.profileSubtitle.TextWrapped, window.profileSubtitle.TextTruncate = false, Enum.TextTruncate.AtEnd
        window.ProfileCard = window:Create("Frame", {
            Name = "PlayerCard", Parent = window.profile, BorderSizePixel = 0,
            BackgroundTransparency = 0.9, Position = UDim2.fromOffset(8, 6), Size = UDim2.new(1, -16, 0, 48), ZIndex = 120,
        }, { BackgroundColor3 = "StatBackground" })
        Surface.round(window, window.ProfileCard, 8)
        window.ProfileCardStroke = window:Create("UIStroke", { Parent = window.ProfileCard, Transparency = 0.7, Thickness = 1 }, { Color = "AccentStroke" })
        window.ProfileButton = window:Create("TextButton", {
            Name = "OpenProfile", Parent = window.ProfileCard, Text = "", AutoButtonColor = false,
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 125,
        })
        window:Connect(window.ProfileButton.MouseButton1Click, function() window:OpenProfile() end)
        function window:_refreshProfileCard()
            if self.unloaded then return end
            local selected = self.ProfileTab ~= nil and self.selectedTab == self.ProfileTab
            self.ProfileCard.BackgroundTransparency = selected and 0.8 or 0.9
            self.ProfileCardStroke.Transparency = selected and 0.25 or 0.7
        end
    end
end

return Profile
