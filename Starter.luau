-- Este é o SEU script. A library fornece a interface; você escolhe os controles.
local ConexaoUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/ConexaoUI.luau"
))()

local Window = ConexaoUI:CreateWindow({
    Id = "MeuHub",
    Title = "Meu Hub",
    Subtitle = "Feito com Conexão UI",
})

local Tab = Window:CreateTab({Name = "Principal", Icon = "house"})

local Recursos = Tab:CreateGroup({Name = "RECURSOS", Icon = "bolt", Column = 1})
local Opcoes = Tab:CreateGroup({Name = "OPÇÕES", Icon = "settings", Column = 2})

Recursos:CreateButton({
    Name = "Minha ação",
    Callback = function()
        Window:Notify({Title = "Meu Hub", Content = "Coloque sua função neste callback."})
    end,
})

Recursos:CreateToggle({
    Id = "meu_recurso",
    Name = "Ativar recurso",
    Default = false,
    Callback = function(value) print("Ativado:", value) end,
})

Opcoes:CreateSlider({
    Id = "minha_intensidade",
    Name = "Intensidade",
    Min = 0, Max = 100, Default = 50,
    Callback = function(value) print("Intensidade:", value) end,
})

Opcoes:CreateDropdown({
    Id = "minhas_escolhas",
    Name = "Escolhas",
    Options = {"Opção A", "Opção B", "Opção C"},
    Multi = true,
    Default = {"Opção A"},
    Callback = function(values) print(table.concat(values, ", ")) end,
})

-- A aba Configurações e o salvamento já são criados pela library.
-- Este arquivo não faz parte do código interno da library.
