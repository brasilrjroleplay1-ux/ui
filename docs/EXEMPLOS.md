# Exemplos da Conexão UI 3.8 · API Gen2

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
local slider = tab:CreateSlider({ name = "Volume", flag = "volume", range = { 0, 100 }, increment = 0.25, value = 50, format = "percent", callback = function(value, dragging) print(value, dragging) end })
slider:Set(75)
local preciso = tab:CreateSlider({ name = "Valor preciso", flag = "preciso", range = { -100, 1000 }, increment = 0.01, value = 25.5, format = "number" })
```

Clique ou toque no valor para editar. Enter ou tocar fora confirma; Escape cancela. Ponto e vírgula decimal são aceitos, incluindo texto colado com o sufixo, como `73,5 %`. O valor é limitado pela `range` e alinhado ao `increment`. Para duas casas decimais, use `increment = 0.01`. Entradas vazias ou inválidas mantêm o valor anterior.

O formato `percent` mostra o valor seguido de `%`; os limites, o callback e o arquivo salvo usam o número da `range`. Por exemplo, `75` representa `75 %` quando a faixa é `{ 0, 100 }`. `suffix` continua disponível para unidades próprias, como `ms`, quando `format` não é informado. `editable = false` desativa a digitação. Sliders `minimal = true` mantêm apenas o trilho.

A confirmação chama o callback uma vez, com `dragging = false`, e usa o salvamento nativo. Durante a digitação, o texto é um rascunho; digitar o mesmo valor novamente não repete o callback. A edição também funciona em grupos e nos sliders incluídos em Configurações.

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
local aviso = window:Notify({ title = "Salvo", content = "Configuração atualizada.", type = "success", duration = 5 })
window:Toast({ title = "Conectado", subtitle = "Meu projeto", type = "info", duration = 4 })
window:Popup({ title = "Continuar?", content = "Escolha uma ação.", options = {
    { text = "Cancelar" },
    { text = "Continuar", style = "primary", callback = function() print("Confirmado") end },
} })
```

`Notify` aparece no canto inferior direito; `Toast` é um aviso compacto centralizado, com `position = "Top"` ou `"Bottom"`. Os dois incluem ícone, botão de fechar e barra de tempo restante. `type` aceita `info` (padrão e cor do tema), `success`, `warning` e `error`. `icon` continua aceitando um ID numérico ou URI para usar seu próprio ícone. O toast também aceita `avatar`, `minWidth` e `subtitleAbove`.

`duration` usa segundos; quando omitido, o tempo é calculado pelo tamanho do texto, entre 3 e 9 segundos. Passar o mouse pausa o contador. É possível fechar pelo X, tocar em um aviso curto ou usar `aviso:Close()`. Textos que excedem a altura disponível usam rolagem interna e são fechados pelo X. Cada pilha mantém até seis avisos e retira os mais antigos quando falta espaço na tela. Avisos ativos mudam de cor com o tema e são liberados ao descarregar a janela.

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
window:OpenSettings("saving") -- appearance, themes, saving ou controls
window:OpenHome() -- painel de conta, cliente e sessão
window:OpenProfile() -- página Meu perfil: identidade, executor, versão e ambiente
window:CloseProfile() -- volta à aba que estava aberta
window:OpenThemes()
```

Configurações já aparece na sidebar e inclui transparência do fundo, tamanho manual e ajuste automático. Essas preferências são salvas sem controles extras no script. `window:RefreshSize()` permite solicitar uma atualização imediata, mas não é necessário chamá-lo para ativar o ajuste.

As categorias são Aparência, Temas, Salvamento e Controles. Elas mantêm os controles nativos na mesma página e ocultam também suas descrições quando estão inativas. A barra de categorias rola horizontalmente em telas estreitas.

Os arquivos são individuais por ID da conta, inclusive presets nomeados e preferências da janela. Ativar Compartilhar entre contas em Salvamento seleciona um perfil compartilhado para a próxima execução. Cada conta precisa ativar sua própria opção; voltar ao modo individual restaura o perfil privado preservado. Um perfil compartilhado novo começa com os valores iniciais do script, sem copiar automaticamente o perfil privado. Os arquivos antigos sem conta identificada permanecem no disco e não são carregados automaticamente.

```lua
local salvo = window:SetSharedConfiguration(true) -- preferência desta conta; aplica na próxima execução
print(salvo, window.ConfigurationScope.shared, window.ConfigurationScope.nextShared)
```

`configuration.shareAcrossAccounts` define somente o padrão inicial. A escolha já lembrada da conta prevalece. Veja [Configurações por conta](CONFIGURACOES.md).

O cabeçalho e a abertura também vêm prontos em `CreateWindow`. `name`, `subtitle` e `icon` continuam personalizando os dados do cabeçalho. Sem `icon`, ele usa a marca vetorial da Conexão; nomes e subtítulos longos permanecem dentro do espaço disponível antes dos botões. As cores da marca, bordas e versão acompanham o tema. Na 3.6.1, o topo tem 44 px, usa uma linha e contém a busca. A lateral mostra ícones e nomes; abaixo de 480 px de janela, usa o modo compacto. Seções criadas com `window:CreateSection` mantêm seus nomes na lateral expandida.

`OpenHome` e `OpenProfile` abrem páginas distintas. Clicar no cartão do jogador abre Meu perfil; Voltar retorna à aba anterior. Nenhuma dessas ações recria os controles do seu script ou reaplica seus callbacks. As duas páginas acompanham o tema e a rolagem do painel.

Janelas chamadas `Conexão Studio` usam a marca tipográfica da Conexão no cabeçalho: CONEXÃO em negrito e STUDIO em um selo. Outros nomes permanecem como o título do seu projeto. Alterar o texto do título continua funcionando, e a versão acompanha o subtítulo definido pelo script.

No slider de tamanho, a janela fica parada durante o arraste e aplica o valor ao soltar. Nos seus próprios sliders, o callback nativo recebe `(value, dragging)`: `dragging` é `true` durante o movimento e `false` na confirmação.

Os controles em largura total ajustam título, valor e campo à largura real. Textos longos de toggles e botões quebram em linhas; sliders, inputs e teclas podem empilhar seu conteúdo. Sliders `minimal = true` continuam sem título/valor e com altura compacta. Os callbacks e os valores continuam sendo gerenciados pela base Gen2.

O perfil usa os dados reais de `LocalPlayer` e a identificação disponível do executor. Ele abre como página interna, com banner no gradiente do tema, avatar, nome, usuário e cartões de executor/versão e ID. Os botões permitem copiar o ID e voltar à aba anterior. Copiar depende da API do cliente. A galeria também usa uma página interna, com [60 temas](TEMAS.md), busca e filtros por família. As miniaturas são GuiObjects com as cores de cada tema. A escolha fica salva por janela. `rememberTheme = false` em `CreateWindow` mantém o tema definido pelo script a cada execução.

A Home 3.6 usa avatar e saudação separados, servidor/salvamento à esquerda e executor/amigos à direita; em conteúdo abaixo de 400 px, os cartões ficam em uma coluna. Configurações, Temas e Copiar servidor não aparecem como atalhos no perfil. `window:GetSessionStats()` retorna valores numéricos e textos formatados da sessão. `window:GetFriendStats()` retorna `inServerText`, `offlineText`, `onlineText` e `allText`; eles mostram `—` enquanto não há dados disponíveis. A consulta não bloqueia a janela e usa cache de um minuto. `window:RefreshFriends(true)` solicita uma atualização imediata.

A identificação usa o [catálogo de logos](../assets/README.md). O suporte continua restrito a Delta, Wave, Xeno e Solara, além do Studio para desenvolvimento. `UI:RegisterExecutorIcon(nome, assetIdOuUriLocal, aliases)` personaliza imagens; não altera a lista de permitidos.

Os destaques de temas têm altura limitada e rolagem própria. A lista completa mantém busca/filtros fora da área rolável; não estica a janela para mostrar as 60 opções de uma vez.

As propriedades nativas aceitam camelCase e PascalCase. Para novos scripts, use a API Gen2 documentada aqui. A API anterior, seus exemplos e suas distribuições estão em [legacy/v2](../legacy/v2).
