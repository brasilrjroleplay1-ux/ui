--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
local variables = require(script.Parent.Parent.Gen2.utility.variables)
local constants = require(script.Parent.Parent.Gen2.utility.constants)
local Startup = {}

function Startup.new()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ConexaoStudioStartup"
    gui.IgnoreGuiInset, gui.ResetOnSpawn = true, false
    gui.DisplayOrder = constants.displayOrder.banner
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local panel = Instance.new("Frame")
    panel.Name, panel.Parent = "Brand", gui
    panel.AnchorPoint, panel.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
    panel.Size, panel.BackgroundColor3, panel.BorderSizePixel = UDim2.fromOffset(356, 100), Color3.fromRGB(16, 14, 27), 0
    local corner = Instance.new("UICorner") corner.CornerRadius, corner.Parent = UDim.new(0, 18), panel
    local edge = Instance.new("UIStroke") edge.Color, edge.Transparency, edge.Parent = Color3.fromRGB(154, 104, 255), 0.4, panel
    for index = 1, 2 do
        local mark = Instance.new("Frame")
        mark.Size, mark.Position, mark.Rotation = UDim2.fromOffset(24, 24), UDim2.fromOffset(25 + (index - 1) * 12, 29 + (index - 1) * 12), 45
        mark.BackgroundTransparency, mark.Parent = 1, panel
        local rim = Instance.new("UIStroke") rim.Thickness, rim.Color, rim.Parent = 3, Color3.fromRGB(173, 126, 255), mark
        local radius = Instance.new("UICorner") radius.CornerRadius, radius.Parent = UDim.new(0, 6), mark
    end
    local title = Instance.new("TextLabel")
    title.Name, title.Parent = "Title", panel
    title.BackgroundTransparency, title.Position, title.Size = 1, UDim2.fromOffset(86, 20), UDim2.new(1, -102, 0, 30)
    title.Text, title.TextSize, title.TextColor3 = "Conexão Studio", 23, Color3.new(1, 1, 1)
    title.TextXAlignment, title.FontFace = Enum.TextXAlignment.Left, Font.fromEnum(Enum.Font.GothamBold)
    local subtitle = Instance.new("TextLabel")
    subtitle.Parent, subtitle.BackgroundTransparency = panel, 1
    subtitle.Position, subtitle.Size = UDim2.fromOffset(86, 51), UDim2.new(1, -102, 0, 20)
    subtitle.Text, subtitle.TextSize, subtitle.TextColor3 = "Carregando interface", 12, Color3.fromRGB(184, 177, 205)
    subtitle.TextXAlignment, subtitle.FontFace = Enum.TextXAlignment.Left, Font.fromEnum(Enum.Font.Gotham)
    local track = Instance.new("Frame")
    track.Parent, track.Position, track.Size = panel, UDim2.new(0, 18, 1, -12), UDim2.new(1, -36, 0, 3)
    track.BackgroundColor3, track.BorderSizePixel = Color3.fromRGB(47, 37, 68), 0
    local progress = Instance.new("Frame")
    progress.Parent, progress.Size, progress.BorderSizePixel = track, UDim2.fromScale(0, 1), 0
    progress.BackgroundColor3 = Color3.fromRGB(173, 111, 255)
    gui.Parent = variables.guiContainer
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize
    if not viewport or viewport.X < 100 then viewport = gui.AbsoluteSize end
    if not viewport or viewport.X < 100 then viewport = Vector2.new(360, 640) end
    local scale = Instance.new("UIScale")
    scale.Parent, scale.Scale = panel, viewport and math.min(1, math.max(0.3, (viewport.X - 24) / 356)) or 1
    game:GetService("TweenService"):Create(progress, TweenInfo.new(0.45), { Size = UDim2.fromScale(1, 1) }):Play()
    return gui
end

return Startup
