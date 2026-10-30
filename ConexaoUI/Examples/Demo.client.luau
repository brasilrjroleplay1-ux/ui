-- A library fornece o painel inicial e Configurações, sem controles de jogos.
local UI = require(game:GetService("ReplicatedStorage"):WaitForChild("ConexaoUI"))
local previousDemo = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ConexaoDemo")
if previousDemo and previousDemo:IsA("ScreenGui") then previousDemo:Destroy() end
local window = UI:CreateWindow({
    Id = "ConexaoDemo3", name = "CONEXÃO STUDIO", subtitle = "3.5.3",
    theme = "conexao", configuration = { fileName = "conexao_demo_gen2_v3" },
})
window:OpenHome()
