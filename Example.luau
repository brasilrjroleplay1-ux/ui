-- Demonstração da Conexão UI 3.1 usando os componentes reais do Rayfield Gen2.
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/ConexaoUI.luau"))()
local previousDemo = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ConexaoDemo")
if previousDemo and previousDemo:IsA("ScreenGui") then previousDemo:Destroy() end
local window = UI:CreateWindow({
    Id = "ConexaoDemo3",
    name = "CONEXÃO UI", subtitle = "Gen2 · 3.1.0", sidebarLayout = true,
    theme = "conexao",
    configuration = { fileName = "conexao_demo_gen2_v3" },
})

window:CreateSection({ name = "PRINCIPAL" })
local home = window:CreateTab({ name = "Início", icon = 93364949241311 })
home:CreateText({ name = "Conexão UI · Gen2", text = "Esta versão usa a base real do Rayfield Gen2. O perfil e as configurações já vêm com a janela." })
home:CreateSection({ name = "Controles" })
home:CreateToggle({ name = "Ativar recurso", flag = "demo/ativo", value = true, callback = function(value) print("Ativo", value) end })
home:CreateSlider({ name = "Intensidade", flag = "demo/intensidade", range = { 0, 100 }, increment = 1, value = 50, suffix = "%" })
home:CreateDropdown({ name = "Modo", flag = "demo/modo", options = { "Padrão", "Criativo", "Compacto" }, value = "Padrão" })
home:CreateDropdown({ name = "Painéis", flag = "demo/paineis", multiSelect = true, options = { "Perfil", "Atalhos", "Estatísticas", "Novidades" }, value = { "Perfil", "Atalhos" } })
home:CreateDropdown({ name = "Locais", flag = "demo/locais", multiSelect = true, options = { "Floresta", "Templo", "Cosmos", "Oceano", "Neve", "Deserto", "Jardim", "Montanha", "Vulcão", "Selva", "Lago", "Praia" }, value = { "Floresta", "Oceano" } })
home:CreateButton({ name = "Mostrar notificação", icon = 125823673784681, callback = function()
    window:Notify({ title = "Conectado", content = "Notificação nativa do Gen2.", icon = 125823673784681 })
end })

local fields = window:CreateTab({ name = "Campos", icon = 100604009889706 })
fields:CreateInput({ name = "Apelido", flag = "demo/apelido", placeholder = "Digite aqui", value = "Visitante" })
fields:CreateKeybind({ name = "Atalho", flag = "demo/atalho", value = Enum.KeyCode.F6, callback = function()
    window:Toast({ title = "Atalho acionado", icon = 93364949241311 })
end })
fields:CreateColorPicker({ name = "Cor", flag = "demo/cor", color = Color3.fromRGB(166, 112, 255), callback = function(color, alpha) print(color, alpha) end })
fields:CreateSection({ name = "Temas com prévia" })
fields:CreateButton({ name = "Escolher tema", callback = function() window:OpenThemes() end })

local feedback = window:CreateTab({ name = "Avisos", icon = 125823673784681 })
feedback:CreateButton({ name = "Toast", callback = function() window:Toast({ title = "Tudo pronto", subtitle = "Conexão UI", duration = 4 }) end })
feedback:CreateButton({ name = "Popup", callback = function()
    window:Popup({ title = "Escolha uma ação", content = "Popup nativo do Gen2.", options = {
        { text = "Cancelar" },
        { text = "Continuar", style = "primary", callback = function() window:Toast({ title = "Confirmado" }) end },
    } })
end })
feedback:CreateProgress({ name = "Progresso", range = { 0, 100 }, value = 65 })
local console = feedback:CreateConsole({ name = "Console", height = 110, text = "Conexão UI pronta.", maxLines = 30 })
feedback:CreateButton({ name = "Escrever no console", callback = function() console:Append("Callback executado.") end })

window:CreateSection({ name = "LAYOUT" })
local layout = window:CreateTab({ name = "Grupos", icon = 84750991656135 })
local row = layout:CreateGroup()
local left = row:CreateGroup({ direction = "column" })
local right = row:CreateGroup({ direction = "column" })
left:CreateToggle({ name = "Painel esquerdo", flag = "demo/esquerdo", value = true })
right:CreateToggle({ name = "Painel direito", flag = "demo/direito", value = true })
layout:CreateStat({ name = "Controles de exemplo", value = 18 })
home:Select()
