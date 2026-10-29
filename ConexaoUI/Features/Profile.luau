--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local Surface = require(script.Parent.Surface)
local Preferences = require(script.Parent.Preferences)
local image = require(script.Parent.Parent.Gen2.utility.image)
local Profile = {}

function Profile.attach(window, executorInfo, version)
    window.ExecutorInfo = executorInfo
    function window:OpenProfile()
        if self.unloaded then return end
        local player = game:GetService("Players").LocalPlayer
        if not player then return end
        local modal = Surface.new(self, "Seu perfil", "Informações deste cliente", { width = 470, height = 570 })
        local list = self:Create("ScrollingFrame", {
            Parent = modal.content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
            AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollBarThickness = 3, ZIndex = 4012,
        }, { ScrollBarImageColor3 = "AccentColor" })
        self:Create("UIListLayout", { Parent = list, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
        local header = self:Create("Frame", {
            Parent = list, Size = UDim2.new(1, -6, 0, 88), BackgroundTransparency = 1, LayoutOrder = 0, ZIndex = 4013,
        })
        modal.avatar = self:Create("ImageLabel", {
            Parent = header, Position = UDim2.fromOffset(2, 2), Size = UDim2.fromOffset(72, 72),
            BackgroundTransparency = 1, ZIndex = 4014,
            Image = image.avatar(player.UserId, function(uri)
                if not modal.closed and modal.avatar then image.assign(modal.avatar, "Image", uri) end
            end),
        })
        Surface.round(self, modal.avatar, 36)
        modal.playerName = Surface.label(self, header, player.DisplayName, {
            Position = UDim2.fromOffset(90, 8), Size = UDim2.new(1, -96, 0, 28), TextSize = 20,
        })
        Surface.label(self, header, "@" .. player.Name, {
            Position = UDim2.fromOffset(90, 39), Size = UDim2.new(1, -96, 0, 22), TextTransparency = 0.25,
        })
        local storage = Preferences.storage()
        modal.details = {
            { "ID do jogador", tostring(player.UserId) },
            { "Executor", executorInfo.name },
            { "Versão do executor", executorInfo.version or "Não informada" },
            { "Ambiente", executorInfo.environment },
            { "Conexão UI", version },
            { "Armazenamento", storage },
        }
        for index, detail in ipairs(modal.details) do
            local row = self:Create("Frame", {
                Parent = list, Size = UDim2.new(1, -6, 0, 48), BackgroundTransparency = 0.94,
                BorderSizePixel = 0, LayoutOrder = index, ZIndex = 4013,
            }, { BackgroundColor3 = "AccentColor" })
            Surface.round(self, row, 10)
            Surface.label(self, row, detail[1], {
                Position = UDim2.fromOffset(12, 4), Size = UDim2.new(0.45, -12, 1, -8), TextSize = 12, TextTransparency = 0.3,
            })
            Surface.label(self, row, detail[2], {
                Position = UDim2.new(0.45, 0, 0, 4), Size = UDim2.new(0.55, -12, 1, -8),
                TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right,
            })
        end
        return modal
    end
    if window.profile then
        window.ProfileButton = window:Create("TextButton", {
            Name = "OpenProfile", Parent = window.profile, Text = "", AutoButtonColor = false,
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 120,
        })
        window:Connect(window.ProfileButton.MouseButton1Click, function() window:OpenProfile() end)
    end
end

return Profile
