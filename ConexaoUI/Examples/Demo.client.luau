-- A library fornece o painel inicial e Configurações, sem controles de jogos.
local UI = require(game:GetService("ReplicatedStorage"):WaitForChild("ConexaoUI"))
local previousDemo = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ConexaoDemo")
if previousDemo and previousDemo:IsA("ScreenGui") then previousDemo:Destroy() end
local window = UI:CreateWindow({
    Id = "ConexaoDemo3", name = "CONEXÃO STUDIO", subtitle = "3.8.0",
    theme = "default", configuration = { fileName = "conexao_demo_studio36" },
})
window:OpenHome()
