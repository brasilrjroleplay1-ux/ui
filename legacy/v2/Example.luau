--============================================================--
-- CONEXÃO UI | EXEMPLO COMPLETO DA NOSSA API
-- Janela, abas, todos os componentes e atualização de valores.
-- Dashboard do jogador, configurações, temas e perfis já vêm na library.
--============================================================--

--// 1. Carregar a library
-- Studio: importe ConexaoUI em ReplicatedStorage.
-- Outros ambientes: requer loadstring e game:HttpGet.

local ConexaoUI

if game:GetService("RunService"):IsStudio() then
    ConexaoUI = require(game:GetService("ReplicatedStorage"):WaitForChild("ConexaoUI"))
else
    ConexaoUI = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/legacy/v2/dist/ConexaoUI.luau"
    ))()
end

--// 2. Criar janela

local Window = ConexaoUI:CreateWindow({
    Id = "ConexaoExemploCompleto",
    Title = "CONEXÃO UI",
    Subtitle = "Exemplos de todos os componentes",
    Version = "2.1.0",
    Scale = 82,
    ToggleKey = Enum.KeyCode.RightControl,
})

-- Avatar/nome/executor, Configurações e salvamento já vêm prontos.
-- Use Ids estáveis e únicos para restaurar as escolhas entre execuções.

--// 3. Categorias e abas com ícones

Window:CreateCategory("EXEMPLOS")

local Principal = Window:CreateTab({
    Id = "principal",
    Name = "Principal",
    Icon = "house", -- Também aceita ID numérico de imagem.
    Description = "Botões, toggles, sliders e dropdowns",
})

local Campos = Window:CreateTab({
    Id = "campos",
    Name = "Campos",
    Icon = "palette",
    Description = "Texto, atalhos e cores",
})

local Informacoes = Window:CreateTab({
    Id = "informacoes",
    Name = "Informações",
    Icon = "info",
})

-- Grupos visuais: o script escolhe os títulos e a distribuição dos controles.
local Controles = Principal:CreateGroup({Id = "controls", Name = "CONTROLES", Icon = "bolt", Column = 1})
local Escolhas = Principal:CreateGroup({Id = "choices", Name = "ESCOLHAS", Icon = "settings", Column = 2})

--// 4. Seção

Principal:CreateSection({
    Name = "CONTROLES",
    Content = "Os callbacks abaixo mostram os valores no console.",
})

--// 5. Button: normal, secundário e destrutivo

Controles:CreateButton({
    Name = "Botão normal",
    Icon = "bolt",
    Callback = function()
        Window:Notify({Title = "Button", Content = "Você clicou no botão."})
    end,
})

Controles:CreateButton({
    Name = "Botão secundário",
    Variant = "Secondary",
    Callback = function()
        print("Botão secundário clicado")
    end,
})

Controles:CreateButton({
    Name = "Botão destrutivo com confirmação",
    Variant = "Destructive",
    Callback = function()
        Window:Confirm({
            Content = "Confirmar esta ação demonstrativa?",
            Callback = function(confirmed)
                print("Confirmou:", confirmed)
            end,
        })
    end,
})

--// 6. Toggle

local Toggle = Controles:CreateToggle({
    Id = "exemplo/recurso",
    Name = "Ativar recurso",
    Default = false,
    Callback = function(value)
        print("Recurso ativado:", value)
    end,
})

--// 7. Slider

local Slider = Controles:CreateSlider({
    Id = "exemplo/intensidade",
    Name = "Intensidade",
    Min = 0,
    Max = 100,
    Increment = 5,
    Default = 50,
    Suffix = "%",
    Callback = function(value)
        print("Intensidade:", value)
    end,
})

--// 8. Dropdown de seleção única

local Dropdown = Escolhas:CreateDropdown({
    Id = "exemplo/modo",
    Name = "Modo",
    Options = {"Padrão", "Criativo", "Compacto"},
    Default = "Padrão",
    Searchable = true,
    Callback = function(value)
        print("Modo:", value) -- string ou nil ao limpar.
    end,
})

--// 9. Dropdown de seleção múltipla
-- Abre o painel com pesquisa, grade, Padrão, Limpar e Selecionar tudo.

Escolhas:CreateDropdown({
    Id = "exemplo/paineis",
    Name = "Painéis visíveis",
    Multi = true,
    Searchable = true,
    Options = {"Início", "Estatísticas", "Notícias", "Atalhos", "Ajuda", "Perfil"},
    Default = {"Início", "Notícias"},
    Callback = function(values)
        print("Painéis:", table.concat(values, ", "))
    end,
})

--// 10. Textbox com validação

Campos:CreateTextbox({
    Id = "exemplo/apelido",
    Name = "Apelido",
    Placeholder = "Digite seu nome",
    Default = "Visitante",
    MaxLength = 32,
    Validate = function(value)
        return #value > 0, "Digite pelo menos um caractere."
    end,
    Callback = function(value)
        print("Texto confirmado:", value)
    end,
})

--// 11. Keybind

Campos:CreateKeybind({
    Id = "exemplo/atalho",
    Name = "Atalho de notificação",
    Default = "F6",
    Changed = function(key)
        print("Nova tecla:", key.Name)
    end,
    Callback = function(key)
        Window:Notify({Content = "Você pressionou " .. key.Name})
    end,
})

--// 12. ColorPicker

Campos:CreateColorPicker({
    Id = "exemplo/cor",
    Name = "Cor demonstrativa",
    Default = "#9070F7",
    Callback = function(color)
        print("Cor:", color:ToHex()) -- Callback recebe Color3.
    end,
})

--// 13. Paragraph, Label, Divider, Badge e ProgressBar

Informacoes:CreateParagraph({
    Name = "Sobre este exemplo",
    Content = "Esta página usa os componentes reais da Conexão UI.",
})

local Label = Informacoes:CreateLabel({
    Name = "Estado",
    Text = "Pronto",
})

Informacoes:CreateDivider({})

Informacoes:CreateBadge({
    Name = "Conexão UI",
    Content = "Exemplo da API",
    Color = "Primary",
})

local Progress = Informacoes:CreateProgressBar({
    Name = "Progresso demonstrativo",
    Min = 0,
    Max = 100,
    Value = 40,
})

--// 14. Atualizar componentes por código
-- Alterações ocorrem apenas quando o usuário clica nestes botões.

Informacoes:CreateButton({
    Name = "Atualizar valores de exemplo",
    Callback = function()
        Toggle:SetValue(not Toggle:GetValue())
        Slider:SetValue(75)
        Dropdown:SetValue("Criativo")
        Label:SetValue("Valores atualizados")
        Progress:SetValue(80)
    end,
})

Informacoes:CreateButton({
    Name = "Atualizar opções do dropdown",
    Callback = function()
        Dropdown:SetOptions({"Padrão", "Criativo", "Compacto", "Personalizado"})
        Dropdown:Open()
    end,
})

Informacoes:CreateButton({
    Name = "Ativar / desativar slider",
    Variant = "Secondary",
    Callback = function()
        Slider:SetDisabled(not Slider.Disabled)
    end,
})

--// 15. Acessar as configurações prontas e salvar manualmente

Informacoes:CreateButton({
    Name = "Abrir configurações da library",
    Icon = "settings",
    Callback = function()
        Window:SelectTab(Window.SettingsTab)
    end,
})

Informacoes:CreateButton({
    Name = "Salvar perfil agora",
    Callback = function()
        Window:Notify({
            Title = "Perfil",
            Content = Window:SaveConfig()
                and "Perfil salvo."
                or "Armazenamento em arquivo indisponível neste ambiente.",
        })
    end,
})

--// 16. Dashboard opcional

Window:CreateDashboard({
    Id = "dashboard",
    Name = "Dashboard",
    Username = game:GetService("Players").LocalPlayer.DisplayName,
    Stats = {
        {Id = "version", Name = "VERSÃO", Value = ConexaoUI.Version, Icon = "star"},
        {Id = "status", Name = "ESTADO", Value = "Pronto", Icon = "bolt"},
    },
    News = {{Title = "Exemplo completo", Content = "Cada componente tem seu próprio bloco de código."}},
})

--// 17. Encerrar e limpar eventos

Informacoes:CreateButton({
    Name = "Destruir interface",
    Variant = "Destructive",
    Callback = function()
        Window:Confirm({
            Content = "Fechar e destruir esta interface?",
            Callback = function(confirmed)
                if confirmed then Window:Destroy() end
            end,
        })
    end,
})

--// 18. Notificações completas e popup de escolhas

local Avisos = Window:CreateTab({Name = "Avisos e popups", Icon = "info"})

Avisos:CreateButton({
    Name = "Sucesso com ação",
    Callback = function()
        Window:Notify({
            Title = "Tudo salvo",
            Content = "Aviso com duração, progresso e botão de ação.",
            Kind = "Success",
            Duration = 8,
            PauseOnHover = true,
            Actions = {{
                Name = "Abrir configurações",
                Callback = function() Window:SelectTab(Window.SettingsTab) end,
            }},
            OnClose = function(reason) print("Notificação encerrada:", reason) end,
        })
    end,
})

Avisos:CreateButton({
    Name = "Aviso persistente e atualizável",
    Callback = function()
        local notice = Window:Notify({
            Title = "Aviso persistente",
            Content = "Este aviso fica aberto até ser fechado.",
            Kind = "Info",
            Duration = 0,
        })
        notice:Update({
            Actions = {{
                Name = "Atualizar mensagem",
                Close = false,
                Callback = function(handle)
                    handle:Update({Content = "Atualizado sem recriar a janela.", Kind = "Success"})
                end,
            }},
        })
    end,
})

Avisos:CreateButton({
    Name = "Popup de escolhas",
    Callback = function()
        Window:Popup({
            Title = "O que deseja abrir?",
            Content = "As escolhas são definidas pelo autor do script.",
            Options = {
                {Name = "Configurações", Value = "settings"},
                {Name = "Principal", Value = "home"},
                {Name = "Cancelar", Value = false, Variant = "Secondary"},
            },
            Callback = function(value)
                if value == "settings" then Window:SelectTab(Window.SettingsTab)
                elseif value == "home" then Window:SelectTab(Principal) end
            end,
        })
    end,
})

Window:SelectTab(Principal)
