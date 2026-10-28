-- Exemplo separado da library. Studio: LocalScript em StarterPlayerScripts.
local UI = require(game:GetService("ReplicatedStorage"):WaitForChild("ConexaoUI"))
local window = UI:CreateWindow({
    Id = "ConexaoDemo", Title = "CONEXÃO UI", Version = "1.7.0",
    Subtitle = "Sua conexão. Seu estilo.", Scale = 82,
})

-- Início, avatar, nome e executor já são fornecidos pela library.
local home = window.HomeTab
local tab = window:CreateTab({Name = "Componentes", Icon = "star", Description = "Controles criados pelo script de demonstração"})
local controls = tab:CreateGroup({Id = "controls", Name = "CONTROLES", Icon = "bolt", Column = 1})
local choices = tab:CreateGroup({Id = "choices", Name = "ESCOLHAS", Icon = "settings", Column = 2})

controls:CreateButton({Name = "Mostrar notificação", Icon = "info", Callback = function()
    window:Notify({Title = "Tudo conectado", Content = "Callback executado.", Kind = "Success"})
end})
controls:CreateToggle({Id = "demo/notifications", Name = "Notificações", Default = true, Callback = function(value)
    home:SetStat("status", value and "Ativo" or "Pausado")
end})
controls:CreateSlider({Id = "demo/volume", Name = "Volume demonstrativo", Min = 0, Max = 100, Increment = 5, Default = 50, Suffix = "%", Callback = function(value)
    print("Volume", value)
end})
controls:CreateTextbox({Id = "demo/nickname", Name = "Apelido", Default = "Visitante", MaxLength = 32,
    Validate = function(value) return #value > 0, "Digite um nome." end,
    Callback = function(value) home:SetWelcome({Username = value}) end,
})
choices:CreateDropdown({Id = "demo/profile", Name = "Perfil", Options = {"Padrão", "Criativo", "Compacto"}, Default = "Padrão", Callback = function(value)
    home:SetStat("profile", value or "Nenhum")
end})
choices:CreateDropdown({Id = "demo/modules", Name = "Módulos visíveis", Multi = true,
    Options = {"Painel", "Estatísticas", "Novidades", "Atalhos", "Notificações", "Aparência", "Perfis", "Ajuda"}, Default = {"Painel"},
    Callback = function(values) print(table.concat(values, ", ")) end,
})
choices:CreateKeybind({Id = "demo/key", Name = "Atalho de notificação", Default = "F6", Callback = function()
    window:Notify({Content = "Você pressionou o atalho."})
end})
choices:CreateColorPicker({Id = "demo/color", Name = "Cor demonstrativa", Default = "#9070F7", Callback = function(color)
    print("Cor escolhida", color:ToHex())
end})
choices:CreateProgressBar({Name = "Progresso demonstrativo", Value = 68})

local feedback = window:CreateTab({Name = "Avisos e popups", Icon = "info"})
local notices = feedback:CreateGroup({Name = "NOTIFICAÇÕES", Icon = "info", Column = 1})
local dialogs = feedback:CreateGroup({Name = "POPUPS", Icon = "star", Column = 2})
notices:CreateButton({Name = "Notificação de sucesso", Callback = function()
    window:Notify({Title = "Perfil salvo", Content = "Seu próximo projeto pode usar esse mesmo sistema.", Kind = "Success", Duration = 6})
end})
notices:CreateButton({Name = "Aviso com ação", Callback = function()
    window:Notify({Title = "Personalizar interface", Content = "Abra as configurações ou deixe o aviso expirar.", Duration = 8,
        Actions = {{Name = "Abrir configurações", Callback = function() window:SelectTab(window.SettingsTab) end}},
    })
end})
dialogs:CreateButton({Name = "Popup com escolhas", Callback = function()
    window:Popup({Title = "Escolha uma opção", Content = "Um popup criado pelo script de exemplo.",
        Options = {{Name = "Criativo", Value = "criativo"}, {Name = "Compacto", Value = "compacto"}, {Name = "Voltar", Value = false, Variant = "Secondary"}},
        Callback = function(value) if value then window:Notify({Content = "Escolha: " .. value}) end end,
    })
end})
dialogs:CreateButton({Name = "Abrir confirmação", Variant = "Destructive", Callback = function()
    window:Confirm({Content = "Executar esta ação demonstrativa?", Callback = function(confirmed)
        window:Notify({Content = confirmed and "Ação confirmada." or "Cancelada."})
    end})
end})
window:SelectTab(home)
