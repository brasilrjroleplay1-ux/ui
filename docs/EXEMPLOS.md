# Exemplos da Conexão UI 3.1 · API Gen2

Veja o [script completo](../Example.luau). Em cada exemplo abaixo, `window` é sua janela e `tab` é uma aba criada por ela.

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/ConexaoUI.luau"))()
local window = UI:CreateWindow({ name = "Meu Hub", subtitle = "Conexão UI", sidebarLayout = true, theme = "conexao" })
local tab = window:CreateTab({ name = "Principal", icon = 93364949241311 })
```

## Button

```lua
tab:CreateButton({ name = "Executar", icon = 125823673784681, callback = function()
    window:Notify({ title = "Pronto", content = "Callback executado." })
end })
```

## Toggle e Slider

```lua
local toggle = tab:CreateToggle({ name = "Ativar", flag = "ativo", value = false, callback = function(value) print(value) end })
toggle:Set(true)
local slider = tab:CreateSlider({ name = "Volume", flag = "volume", range = { 0, 100 }, increment = 5, value = 50, suffix = "%", callback = function(value, dragging) print(value, dragging) end })
slider:Set(75)
```

## Dropdown único e múltiplo

```lua
local single = tab:CreateDropdown({ name = "Modo", flag = "modo", options = { "Normal", "Compacto" }, value = "Normal", callback = function(value) print(value) end })
single:Set("Compacto")
single:Refresh({ "Normal", "Compacto", "Novo" })
local multi = tab:CreateDropdown({ name = "Painéis", flag = "paineis", multiSelect = true, options = { "Perfil", "Atalhos", "Dados" }, value = { "Perfil" }, callback = function(values) print(table.concat(values, ", ")) end })
multi:Set({ "Perfil", "Dados" })
```

Ao clicar no dropdown, a Conexão abre um painel sobre a janela: busca, cartões em duas colunas (uma no celular) e botões Padrão/Limpar. Dropdown múltiplo também tem Selecionar todos; essa ação seleciona a lista inteira, inclusive se houver filtro. Padrão restaura o `value` inicial definido pelo script. Seleção única fecha o painel ao escolher; seleção múltipla mantém o painel aberto. Os valores são salvos automaticamente.

```lua
multi:Open()  -- opcional; clicar no controle faz o mesmo
multi:Close()
```

## Input, Keybind e ColorPicker

```lua
local input = tab:CreateInput({ name = "Apelido", flag = "apelido", placeholder = "Seu nome", value = "Visitante", callback = function(text) print(text) end })
input:Set("Criador")
tab:CreateKeybind({ name = "Atalho", flag = "atalho", value = Enum.KeyCode.F6, callback = function(key) print(key) end })
tab:CreateColorPicker({ name = "Cor", color = Color3.fromRGB(160, 100, 255), callback = function(color, alpha) print(color, alpha) end })
```

## Grupos, texto, estatísticas, progresso e console

```lua
tab:CreateSection({ name = "Minha seção" })
tab:CreateText({ name = "Sobre", text = "Texto do seu projeto." })
tab:CreateDivider({ text = "Mais opções" })
local row = tab:CreateGroup()
local left = row:CreateGroup({ direction = "column" })
local right = row:CreateGroup({ direction = "column" })
left:CreateToggle({ name = "Esquerda", flag = "esquerda" })
right:CreateToggle({ name = "Direita", flag = "direita" })
tab:CreateStat({ name = "Contagem", value = 100 })
local progress = tab:CreateProgress({ name = "Progresso", range = { 0, 100 }, value = 65 })
progress:Set(80)
local console = tab:CreateConsole({ name = "Saída", height = 120, maxLines = 30 })
console:Append("Olá!")
```

Grupos em linha recebem os componentes compactos compatíveis; grupos em coluna recebem também dropdowns, texto e seções. A API Gen2 oferece grupos aninhados.

## Notificação, toast e popup

```lua
window:Notify({ title = "Salvo", content = "Configuração atualizada.", duration = 5 })
window:Toast({ title = "Conectado", subtitle = "Meu projeto", duration = 4 })
window:Popup({ title = "Continuar?", content = "Escolha uma ação.", options = {
    { text = "Cancelar" },
    { text = "Continuar", style = "primary", callback = function() print("Confirmado") end },
} })
```

## Atualizar tema, navegar e encerrar

```lua
window:ChangeTheme("aurora")
tab:Select()
window:Save()
window:Load()
window:Hide()
window:Show()
window:Unload()
```

## Configurações, perfil e galeria prontos

Eles já existem depois de `CreateWindow`. Não é necessário recriar a aba nem os controles de configuração no seu script. Para fornecer atalhos adicionais:

```lua
window:OpenSettings()
window:OpenProfile()
window:CloseProfile() -- volta à aba que estava aberta
window:OpenThemes()
```

O tamanho também é automático: a library acompanha a tela e a orientação. As configurações mostram as medidas atuais. `window:RefreshSize()` permite solicitar uma atualização imediata, mas não é necessário chamá-lo para ativar o ajuste.

O perfil usa os dados reais de `LocalPlayer` e a identificação disponível do executor. Ele abre como página interna na área de conteúdo da janela, com rolagem e botão Voltar. A sidebar continua acessível. A galeria apresenta seis temas novos e seis temas originais, com miniaturas feitas de GuiObjects que usam as cores de cada tema. A escolha fica salva por janela. `rememberTheme = false` em `CreateWindow` mantém o tema definido pelo script a cada execução.

As propriedades nativas aceitam camelCase e PascalCase. Para novos scripts, use a API Gen2 documentada aqui. A API anterior, seus exemplos e suas distribuições estão em [legacy/v2](../legacy/v2).
