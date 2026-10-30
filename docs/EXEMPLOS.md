# Exemplos da Conexão UI 3.3 · API Gen2

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

Ao clicar no dropdown, a Conexão abre o seletor na própria área de conteúdo, com a sidebar acessível: busca, cartões em duas colunas (uma no celular) e botões Padrão/Limpar. Dropdown múltiplo também tem Selecionar todos; essa ação seleciona a lista inteira, inclusive se houver filtro. Padrão restaura o `value` inicial definido pelo script. Seleção única volta à aba de origem ao escolher; seleção múltipla mantém o seletor aberto. Os valores são salvos automaticamente.

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
window:OpenHome() -- painel de conta, cliente e sessão
window:OpenProfile()
window:CloseProfile() -- volta à aba que estava aberta
window:OpenThemes()
```

Configurações já aparece na sidebar e inclui transparência do fundo, tamanho manual e ajuste automático. Essas preferências são salvas sem controles extras no script. `window:RefreshSize()` permite solicitar uma atualização imediata, mas não é necessário chamá-lo para ativar o ajuste.

No slider de tamanho, a janela fica parada durante o arraste e aplica o valor ao soltar. Nos seus próprios sliders, o callback nativo recebe `(value, dragging)`: `dragging` é `true` durante o movimento e `false` na confirmação.

Os controles em largura total ajustam título, valor e campo à largura real. Textos longos de toggles e botões quebram em linhas; sliders, inputs e teclas podem empilhar seu conteúdo. Sliders `minimal = true` continuam sem título/valor e com altura compacta. Os callbacks e os valores continuam sendo gerenciados pela base Gen2.

O perfil usa os dados reais de `LocalPlayer` e a identificação disponível do executor. Ele abre como página interna, com banner no gradiente do tema, avatar, nome, usuário e cartões de executor/versão e ID. Os botões permitem copiar o ID, abrir Configurações/Temas e voltar. Copiar depende da API do cliente. A galeria também usa uma página interna, com [60 temas](TEMAS.md), busca e filtros por família. As miniaturas são GuiObjects com as cores de cada tema. A escolha fica salva por janela. `rememberTheme = false` em `CreateWindow` mantém o tema definido pelo script a cada execução.

A partir da 3.5, esse painel inclui cartões de sessão atualizados e identificação automática por [catálogo de logos](../assets/README.md). Na 3.5.3, a Home usa boas-vindas compactas, sessão à esquerda e cliente/conta à direita; em conteúdo abaixo de 420 px, os cartões ficam em uma coluna. Configurações, Temas e Copiar servidor não aparecem mais como atalhos no perfil. `window:GetSessionStats()` retorna valores numéricos quando disponíveis e textos formatados usados nos cartões. Na 3.5.1, o suporte é restrito a Delta, Wave, Xeno e Solara, além do Studio para desenvolvimento. `UI:RegisterExecutorIcon(nome, assetIdOuUriLocal, aliases)` personaliza imagens; não altera a lista de permitidos.

Os destaques de temas têm altura limitada e rolagem própria. A lista completa mantém busca/filtros fora da área rolável; não estica a janela para mostrar as 60 opções de uma vez.

As propriedades nativas aceitam camelCase e PascalCase. Para novos scripts, use a API Gen2 documentada aqui. A API anterior, seus exemplos e suas distribuições estão em [legacy/v2](../legacy/v2).
