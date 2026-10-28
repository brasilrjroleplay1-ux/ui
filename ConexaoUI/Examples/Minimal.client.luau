-- Studio: LocalScript em StarterPlayerScripts.
local UI = require(game:GetService("ReplicatedStorage"):WaitForChild("ConexaoUI"))
local window = UI:CreateWindow({
    name = "Meu Hub", subtitle = "Conexão UI · Gen2", sidebarLayout = true,
})
local tab = window:CreateTab({ name = "Principal", icon = 93364949241311 })
tab:CreateButton({ name = "Olá!", callback = function() window:Toast({ title = "Conectado" }) end })
tab:CreateToggle({ name = "Meu recurso", flag = "meu_recurso", callback = function(value) print(value) end })
tab:CreateSlider({ name = "Intensidade", flag = "intensidade", range = { 0, 100 }, value = 50, suffix = "%" })
tab:CreateDropdown({ name = "Escolha", flag = "escolha", options = { "A", "B", "C" }, value = "A" })
