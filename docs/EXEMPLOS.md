# Como usar a Conexão UI

Este guia mostra **a API da nossa library**, com cada componente separado e um script completo organizado em seções.

- **[Abrir o script completo para copiar](../Example.luau)**
- **[Abrir o código bruto do exemplo](https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/Example.luau)**
- [Instalação no Roblox Studio e documentação de referência](../README.md)

A aba **Configurações** já é criada com a janela. Você não precisa escrever a interface de temas, perfis nem o sistema de salvamento.

## Índice

- [Carregar a library](#carregar)
- [Criar janela](#janela)
- [Criar categorias e abas com ícones](#abas)
- [Criar grupos com linhas compactas e colunas](GRUPOS.md)
- [Criar Section](#secao)
- [Criar Button](#button)
- [Criar Toggle](#toggle)
- [Criar Slider](#slider)
- [Criar Dropdown de seleção única](#dropdown)
- [Criar Dropdown de seleção múltipla](#multi)
- [Criar Textbox](#textbox)
- [Criar Keybind](#keybind)
- [Criar ColorPicker](#colorpicker)
- [Criar Paragraph, Label, Divider, Badge e ProgressBar](#informativos)
- [Atualizar valores](#atualizar)
- [Abrir configurações e salvar](#configuracoes)
- [Criar Dashboard](#dashboard)
- [Destruir a interface](#destruir)
- [Notificações completas e popups](NOTIFICACOES.md)

Os trechos de componentes usam `Window`, `Principal`, `Campos` e `Informacoes`, criados nos três primeiros passos. Para executar todos juntos, copie o arquivo `Example.luau`. O exemplo só demonstra a interface, com callbacks de console e notificações.

As propriedades aceitam a inicial maiúscula ou minúscula (`Name`/`name`, `Callback`/`callback`). Esta API usa `Default`, `Min`, `Max`, `Multi` e `Placeholder`; não usa `CurrentValue`, `Range` ou `CurrentOption`.

<a id="carregar"></a>

## 1. Carregar a library

Em Studio, importe o ModuleScript `ConexaoUI` em `ReplicatedStorage` antes de executar. O carregamento HTTP exige um ambiente que forneça `loadstring` e `game:HttpGet`.

```luau
-- Studio: importe ConexaoUI em ReplicatedStorage.
-- Outros ambientes: requer loadstring e game:HttpGet.

local ConexaoUI

if game:GetService("RunService"):IsStudio() then
    ConexaoUI = require(game:GetService("ReplicatedStorage"):WaitForChild("ConexaoUI"))
else
    ConexaoUI = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/ConexaoUI.luau"
    ))()
end
```

<a id="janela"></a>

## 2. Criar janela

`Id` identifica sua janela/arquivo. O título é livre. As preferências do usuário salvas podem substituir os valores iniciais de tamanho e tema.

```luau
local Window = ConexaoUI:CreateWindow({
    Id = "ConexaoExemploCompleto",
    Title = "CONEXÃO UI",
    Subtitle = "Exemplos de todos os componentes",
    Version = "1.4.0",
    Scale = 82,
    ToggleKey = Enum.KeyCode.RightControl,
})

-- Não precisa criar a aba Configurações nem programar o salvamento.
-- Use Ids estáveis e únicos para restaurar as escolhas entre execuções.
```

<a id="abas"></a>

## 3. Criar categorias e abas com ícones

`Icon` aceita nomes locais como `house`, `settings`, `star`, `palette`, `info`, ou um ID de imagem numérico permitido ao cliente.

```luau
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
```

<a id="secao"></a>

## 4. Criar Section

`CreateSection` cria um título com descrição; adicione os próximos componentes na própria aba.

```luau
Principal:CreateSection({
    Name = "CONTROLES",
    Content = "Os callbacks abaixo mostram os valores no console.",
})
```

<a id="button"></a>

## 5. Criar Button

O botão executa `Callback` ao clicar. `Variant` pode ser omitido, `Secondary` ou `Destructive`. Use `Disabled = true` para iniciar desativado.

```luau
Principal:CreateButton({
    Name = "Botão normal",
    Icon = "bolt",
    Callback = function()
        Window:Notify({Title = "Button", Content = "Você clicou no botão."})
    end,
})

Principal:CreateButton({
    Name = "Botão secundário",
    Variant = "Secondary",
    Callback = function()
        print("Botão secundário clicado")
    end,
})

Principal:CreateButton({
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
```

<a id="toggle"></a>

## 6. Criar Toggle

O callback recebe `true` ou `false`. A escolha é persistida automaticamente quando há armazenamento disponível.

```luau
local Toggle = Principal:CreateToggle({
    Id = "exemplo/recurso",
    Name = "Ativar recurso",
    Default = false,
    Callback = function(value)
        print("Recurso ativado:", value)
    end,
})
```

<a id="slider"></a>

## 7. Criar Slider

Use `Min < Max`, `Increment > 0` e `Default` dentro do intervalo. `Suffix` só muda a exibição. O usuário pode arrastar com mouse/toque ou digitar o valor.

```luau
local Slider = Principal:CreateSlider({
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
```

<a id="dropdown"></a>

## 8. Criar Dropdown de seleção única

O callback recebe uma string, ou `nil` ao limpar a seleção. O dropdown abre um painel com pesquisa e grade de opções.

```luau
local Dropdown = Principal:CreateDropdown({
    Id = "exemplo/modo",
    Name = "Modo",
    Options = {"Padrão", "Criativo", "Compacto"},
    Default = "Padrão",
    Searchable = true,
    Callback = function(value)
        print("Modo:", value) -- string ou nil ao limpar.
    end,
})
```

<a id="multi"></a>

## 9. Criar Dropdown de seleção múltipla

Com `Multi = true`, `Default` e o valor do callback são listas. O painel oferece Padrão, Limpar e Selecionar tudo; todas as escolhas são salvas.

```luau
-- Abre o painel com pesquisa, grade, Padrão, Limpar e Selecionar tudo.

Principal:CreateDropdown({
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
```

<a id="textbox"></a>

## 10. Criar Textbox

O texto é confirmado ao perder foco, inclusive com Enter. `Validate` pode retornar `false, mensagem` para rejeitar o texto. Use `MultiLine = true` para um campo maior com várias linhas.

```luau
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
```

<a id="keybind"></a>

## 11. Criar Keybind

Clique para escolher outra tecla; Esc cancela a captura. `Callback` executa ao pressionar a tecla. `Changed` informa alterações. Atalhos são ignorados enquanto digita ou usa painéis modais da library.

```luau
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
```

<a id="colorpicker"></a>

## 12. Criar ColorPicker

O callback recebe `Color3`. `Default` e `SetValue` aceitam Color3, `#RRGGBB` ou `{R, G, B}` de 0 a 255. `GetValue()` retorna hexadecimal e `.Color` contém Color3.

```luau
Campos:CreateColorPicker({
    Id = "exemplo/cor",
    Name = "Cor demonstrativa",
    Default = "#9070F7",
    Callback = function(color)
        print("Cor:", color:ToHex()) -- Callback recebe Color3.
    end,
})
```

<a id="informativos"></a>

## 13. Criar Paragraph, Label, Divider, Badge e ProgressBar

Componentes informativos não gravam escolhas de usuário. `ProgressBar:SetValue()` atualiza a barra; `Label:SetValue()` atualiza o conteúdo.

```luau
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
```

<a id="atualizar"></a>

## 14. Atualizar valores

Esses botões mostram `GetValue`, `SetValue`, `SetOptions`, `Open` e `SetDisabled`. As mudanças só ocorrem depois do clique, preservando as escolhas restauradas na inicialização.

```luau
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
```

<a id="configuracoes"></a>

## 15. Abrir configurações e salvar

A library detecta suporte a arquivos. `SaveConfig()` retorna `true` se gravou; sem esse suporte, as escolhas ficam em memória. O salvamento manual funciona mesmo com autosave desligado.

```luau
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
```

<a id="dashboard"></a>

## 16. Criar Dashboard

O dashboard é opcional. Você configura seus dados e ações; nenhuma função específica de jogos é adicionada pela library.

```luau
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
```

<a id="destruir"></a>

## 17. Destruir a interface

`Window:Destroy()` salva quando permitido e desconecta os eventos da library. Para eliminar um controle individual, use `controle:Destroy()`.

```luau
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
```

## Notificações, toasts e popups completos

A aba **Avisos e popups** do [script completo](../Example.luau) demonstra os recursos da library: notificações com duração e ações, mensagens persistentes atualizáveis e popup de várias escolhas. Consulte o [guia de notificações](NOTIFICACOES.md) para todos os campos e exemplos.

## Métodos comuns dos controles

```luau
local valor = Toggle:GetValue()
Toggle:SetValue(true)                  -- Salva e chama Callback.
Toggle:SetValue(false, true)           -- Salva sem chamar Callback.
Toggle:Update({Name = "Novo nome", Disabled = false})
Toggle:SetDisabled(true)
-- Toggle:Destroy()                   -- Remove o controle e seus eventos.
```

Cada componente persistente pode receber `Id` único e estável. Sem ele, a chave usa `IdDaAba/NomeDoComponente`. `FireOnInit = false` evita a chamada inicial do callback; por padrão, o valor restaurado é aplicado ao inicializar. Para um controle apenas de sessão, use `Persistent = false`.

## Perfis e personalização já incluídos

O usuário encontra temas, cores, gradiente, transparência, tamanho, tecla de mostrar/esconder, criação/ativação de perfis, salvamento, lixeira e importação/exportação na aba Configurações. Para ajustar por código, a API também oferece:

```luau
Window:SetScale(85)          -- 0 esconde; 100 ocupa a área útil disponível.
Window:SetTransparency(0.2)
Window:SetDim(0.4)
Window:SetVisible(false)
Window:SetVisible(true)
Window:Minimize(true)
Window:Minimize(false)
Window:SelectTab(Principal)
```

## Diferença entre exemplo e biblioteca

`dist/ConexaoUI.luau` retorna a library, sem criar abas de exemplo. `Example.luau` carrega essa library e mostra como usá-la. `dist/Demo.luau` contém a library e uma demo no mesmo arquivo.

A compilação do exemplo é verificada em Luau; não foi executado em Roblox Studio nem em executor real neste ambiente. Para compatibilidade, requisitos e validação manual, veja o [README](../README.md#validação-e-limites).
