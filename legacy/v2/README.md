> Versão 2.1 arquivada. A versão atual baseada em Gen2 está no [README principal](../../README.md).

# Conexão UI · 2.1.0

Biblioteca de interface Roblox em Luau, com módulos locais e versão em arquivo único. Visual inspirado nas referências fornecidas: janela escura, navegação lateral com ícones, cards com bordas finas, botões com gradiente, destaque violeta e bordas luminosas. O Dashboard mostra o jogador e o estado da própria interface. Não inclui funcionalidades específicas de jogos.

[Veja as prévias e as mudanças visuais da 2.1](docs/VISUAL.md). As imagens são representações aproximadas das propriedades do código, não capturas do Roblox.

## Library e script: o que executar

- **Library:** `dist/ConexaoUI.luau` retorna a API. Não abre janela nem cria controles de exemplo ao carregar.
- **Seu script:** [Starter.luau](Starter.luau) carrega a library e cria sua própria janela, abas e grupos. Use como base.
- **Demonstração:** `dist/Demo.luau` contém a library com um script separado que cria o dashboard e os controles de exemplo.

`CreateWindow` inclui o Dashboard do jogador (avatar, nome, usuário e executor identificado) e o sistema de configurações pronto. Os controles do seu hub são definidos pelas chamadas do seu script.

## Visual 2.1 e perfil automático

Ao criar uma janela, a library já mostra um Dashboard com avatar real do Roblox, DisplayName, `@username`, executor identificado e perfil ativo. O mesmo avatar aparece no rodapé da sidebar. Nenhuma linha de código adicional é necessária no script para montar esse painel.

A identificação do executor usa `identifyexecutor` ou `getexecutorname`, quando fornecidos pelo ambiente. Em Studio, mostra Roblox Studio; sem uma identificação confiável, mostra Não identificado. A biblioteca não inventa o nome. O avatar usa a miniatura oficial do Roblox e pode ser substituído por `Avatar` na criação da janela.

`Home = false` desativa explicitamente o Dashboard automático; `ShowProfile = false` oculta o rodapé. Os controles e funções do jogo continuam sendo criados pelo seu script.

A 2.1 aumenta o contraste dos oito temas, usa rótulos maiores e títulos em negrito, acrescenta gradientes aos cards e troca os ícones internos por desenhos com alinhamento comum. Os campos têm larguras limitadas por tipo. Botões comuns e `Variant = "Primary"` usam preenchimento de destaque com brilho suave; `Variant = "Secondary"` usa fundo neutro e contorno. Switches compactos mostram apenas a cápsula e o marcador azul claro. Sliders usam trilho fino e valor editável. O seletor de cor mostra uma amostra pequena e abre seu editor em um painel separado. Grupos e colunas calculam altura pelo `UIListLayout.AbsoluteContentSize`; a grade de temas reserva espaço para todas as suas linhas.

Sem `Scale` explícito nem tamanho salvo, a janela escolhe um tamanho inicial limitado a aproximadamente 1120 × 740 px em monitores grandes. O controle de 0–100% continua disponível nas configurações. O demo 2.1 usa o arquivo de preferências `conexao_demo_visual_v21` para que temas e tamanhos salvos no demo antigo não escondam as mudanças. Preferências dos seus outros scripts continuam no arquivo de cada projeto. Se um projeto existente restaurar as cores anteriores, use **Restaurar aparência padrão** na aba Interface; isso preserva as escolhas dos controles do aplicativo.

## Exemplos: comece aqui

- **[Grupos e layout no estilo das referências](docs/GRUPOS.md)** — cards recolhíveis, linhas compactas e colunas adaptáveis.

- **[Guia passo a passo de todos os componentes](docs/EXEMPLOS.md)** — janela, abas, Button, Toggle, Slider, Dropdown, Textbox, Keybind, ColorPicker e componentes informativos.
- **[Notificações, toasts, popups e confirmação](docs/NOTIFICACOES.md)** — fila, duração, ações e exemplos.
- **[Script completo organizado em Luau](Example.luau)** — carregue nossa library e veja cada criação em uma seção separada, pronta para copiar.
- **[Código bruto do exemplo](https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/legacy/v2/Example.luau)** — somente o código, sem a página do GitHub.

O exemplo inclui seleção única/múltipla, callbacks, atualização de valores, notificações, confirmação, dashboard e limpeza da interface. A aba Configurações e o salvamento automático já vêm na library.

## Links e carregamento

- [Biblioteca em Luau](https://github.com/brasilrjroleplay1-ux/ui/blob/main/dist/ConexaoUI.luau)
- [Demo completa](https://github.com/brasilrjroleplay1-ux/ui/blob/main/dist/Demo.luau)
- [Baixar projeto completo em ZIP](https://github.com/brasilrjroleplay1-ux/ui/raw/refs/heads/main/ConexaoUI.zip)

Em um ambiente que forneça `loadstring` e `game:HttpGet`, a demo pode ser carregada assim:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/legacy/v2/dist/Demo.luau"))()
```

Para criar suas próprias abas, carregue a biblioteca:

```lua
local ConexaoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/legacy/v2/dist/ConexaoUI.luau"))()
local Window = ConexaoUI:CreateWindow({Title = "Meu Hub"})
local Tab = Window:CreateTab({Name = "Principal", Icon = "house"})
Tab:CreateToggle({Name = "Meu recurso", Callback = function(value) print(value) end})
```

No Roblox Studio, use a instalação por ModuleScript descrita abaixo.

## Configurações prontas, sem código adicional

`CreateWindow` já cria a aba **Configurações**, com navegação **Interface / Config**. Não é necessário criar uma aba de aparência nem declarar `Config` para ter salvamento automático.

```lua
local UI = require(game:GetService('ReplicatedStorage'):WaitForChild('ConexaoUI'))
local window = UI:CreateWindow({Title = 'Meu Hub'})
local tab = window:CreateTab({Name = 'Principal', Icon = 'house'})
tab:CreateToggle({Name = 'Meu recurso', Callback = function(value) print(value) end})
```

A área **Interface** já contém oito temas em cartões com prévias e borda de seleção (Conexão Dark, Violeta, Dourado, Aurora, Oceano, Rosa, Noite e Monocromático), tamanho 0–100%, transparência, cor de destaque/fundo, escurecimento do jogo atrás da janela, gradiente com cores e ângulo, efeitos de luz, tecla de abrir/fechar e restauração da aparência com confirmação. A área **Config** possui gerenciamento de perfis: criar, escolher o ativo, salvar, excluir com confirmação, restaurar da lixeira e importar/exportar JSON, além dos controles de carregamento e salvamento automáticos. O painel usa duas colunas em telas largas e uma em telas menores. As preferências são aplicadas antes de `CreateWindow` retornar.

`window.SettingsTab` expõe a aba pronta. Ela aparece no final da navegação; o Dashboard automático é a página inicial. Com `Home = false`, a primeira aba do autor passa a ser a inicial. Use `window:SelectTab(tab)` para escolher outra página. Na área Config, o card da esquerda concentra seleção, ativação e salvamento; o da direita contém criação, exclusão, restauração e transferência de perfis. A biblioteca não cria ações específicas de jogos, webhook, server hop ou otimização de gráficos: essas funções pertencem às abas/callbacks do aplicativo que usa a library.

O nome do arquivo de armazenamento é gerado a partir de `Id` (ou `Title`) e `game.PlaceId`, com caracteres seguros. Dentro desse arquivo, o perfil inicial se chama `Default`. Para um mesmo script compartilhar o arquivo entre lugares ou para separar projetos com nomes iguais, use `Config.Name` explicitamente. Use nomes/IDs estáveis para restaurar os controles. O backend de arquivos continua dependendo das capacidades do ambiente.

## Começar

- `dist/ConexaoUI.rbxmx`: modelo nativo com todos os ModuleScripts para importar no Studio.
- `dist/ConexaoUI.luau`: biblioteca inteira em um arquivo; retorna a tabela `UI`.
- `dist/Minimal.luau`: exemplo mínimo independente; configurações já incluídas.
- `dist/Demo.luau`: exemplo completo independente; cria a interface ao executar.
- `ConexaoUI/Examples/Demo.client.luau`: exemplo usando `require` no Studio.

### Roblox Studio

1. Importe `dist/ConexaoUI.rbxmx` (Insert from File / inserir de arquivo no Explorer) para `ReplicatedStorage`. O objeto principal deve ser um **ModuleScript** chamado `ConexaoUI`, com pastas `Core`, `Components` e `Pages` dentro.
2. Crie um **LocalScript** em `StarterPlayer > StarterPlayerScripts` e cole o conteúdo de `ConexaoUI/Examples/Demo.client.luau`.
3. Execute **Play**. Esta biblioteca roda no cliente; não use um Script de servidor.

Alternativamente, coloque todo o conteúdo de `dist/ConexaoUI.luau` em um ModuleScript `ReplicatedStorage.ConexaoUI`. Esta versão não precisa das pastas de módulos. Não é necessário habilitar HTTP para usar a biblioteca.

### Arquivo único / ambientes com carregamento dinâmico

`dist/Demo.luau` pode ser executado inteiro em um ambiente que suporte APIs de GUI do Roblox. Para integrar a library, carregue `dist/ConexaoUI.luau` pelo mecanismo disponível no seu ambiente: ele retorna `UI`. Os endereços deste repositório estão listados acima. O carregamento remoto requer acesso HTTP e suporte a `loadstring` no ambiente.

Não há garantia de funcionamento em todos os executores. APIs de arquivo, permissões de GUI, fontes e imagens dependem do ambiente. A biblioteca usa `PlayerGui` por padrão e permite `Parent` explícito. Nenhuma dependência externa é necessária durante a execução.

## API básica

```lua
local UI = require(game:GetService('ReplicatedStorage'):WaitForChild('ConexaoUI'))
local window = UI:CreateWindow({
    Id = 'MeuHub',
    Title = 'CONEXÃO UI',
    Subtitle = 'Meu projeto',
    Version = '1.0.0',
    Scale = 82,
    Transparency = 0.08,
    ToggleKey = Enum.KeyCode.RightControl,
    Config = {Enabled = true, Folder = 'ConexaoUI', Name = 'meu_perfil'},
})
window:CreateCategory('PRINCIPAL')
local tab = window:CreateTab({
    Id = 'home', Name = 'Principal', Icon = 'house', Description = 'Minha página',
})
tab:CreateToggle({
    Id = 'home/avisos', Name = 'Avisos', Default = true,
    Callback = function(value) print('Avisos:', value) end,
})
```

Propriedades aceitam a forma com inicial maiúscula ou minúscula: `Name`/`name`, `Callback`/`callback`, etc. A forma com inicial maiúscula tem prioridade. Os métodos continuam sendo `CreateWindow`, `CreateTab`, etc. Abas também aceitam `CreateTab("Nome", "house")`. Não existe dependência ou implementação da API Rayfield.

### Ícones

`Icon` aceita um ID numérico, `"rbxassetid://123"`, um símbolo ou estes nomes locais: `house`, `home`, `settings`, `user`, `star`, `search`, `palette`, `info`, `bolt`. IDs de imagem precisam estar acessíveis ao cliente Roblox. Os nomes locais usam desenhos de contorno em um espaço de 24 × 24, feitos com objetos de GUI. Eles não dependem de glifos de fonte nem de downloads. Também estão disponíveis `warning`, `check`, `chevron`, `close`, `minus` e `arrow`. Símbolos personalizados continuam usando a fonte do cliente.

Os cartões de tema são botões reais: ao selecionar, o tema é aplicado e a escolha é salva. A grade adapta-se a uma, duas ou quatro colunas. Os sliders usam marcador circular e campo numérico editável; respeitam limites e incremento também ao digitar.

## Componentes

Abas também oferecem `CreateGroup` para agrupar os controles em cards compactos, conforme o [guia de grupos](docs/GRUPOS.md). As chamadas diretas na aba continuam válidas.

Todos os componentes retornam um controle com `Instance`, `GetValue()`, `SetValue(value, silent?)`, `Update(properties)`, `SetDisabled(boolean)` e `Destroy()`. `Update` aceita `Name`, `Value`, `Silent` e `Disabled`. `silent=true` não chama o callback; a escolha ainda é guardada. Controles informativos têm atualização de conteúdo e não têm interação a desativar.

Para componentes persistentes, informe um `Id` estável e único por janela. Sem `Id`, usa `IdDaAba/NomeDoComponente`; renomear esse nome muda a chave. IDs duplicados são rejeitados.

```lua
local button = tab:CreateButton({
    Name = 'Executar', Icon = 'bolt', Variant = 'Secondary', Disabled = false,
    Callback = function() print('Clicado') end,
}) -- Variant: padrão, 'Primary', 'Secondary', 'Destructive'
button:SetValue('Novo texto')
button:SetDisabled(true)

local toggle = tab:CreateToggle({
    Id = 'recurso', Name = 'Recurso', Default = false,
    Callback = function(value) print(value) end,
})
toggle:SetValue(true)

local slider = tab:CreateSlider({
    Id = 'volume', Name = 'Volume', Min = 0, Max = 100,
    Increment = 5, Default = 50, Suffix = '%', Callback = function(value) print(value) end,
}) -- Step é alias de Increment. Mouse e toque.

local dropdown = tab:CreateDropdown({
    Id = 'perfil', Name = 'Perfil', Options = {'Padrão', 'Azul', 'Roxo'},
    Default = 'Padrão', Searchable = true,
    Callback = function(value) print(value) end,
})
dropdown:SetOptions({'Padrão', 'Novo'})
dropdown:SetValue('Novo')
dropdown:Open()  -- Também abre ao clicar no componente.
dropdown:Close()

local multi = tab:CreateDropdown({
    Id = 'paineis', Name = 'Painéis', Multi = true,
    Options = {'Início', 'Notícias', 'Dados'}, Default = {'Início'},
    Callback = function(values) print(table.concat(values, ', ')) end,
})
multi:SetValue({'Início', 'Dados'})

local text = tab:CreateTextbox({
    Id = 'apelido', Name = 'Apelido', Placeholder = 'Seu nome',
    Default = 'Visitante', MaxLength = 32,
    Validate = function(value) return #value > 0, 'Preencha este campo.' end,
    Callback = function(value) print(value) end,
}) -- Confirma ao perder o foco, inclusive Enter. Limite em caracteres UTF-8.

local key = tab:CreateKeybind({
    Id = 'atalho', Name = 'Atalho', Default = 'F6',
    Callback = function(keyCode) print('Acionado', keyCode) end,
    Changed = function(keyCode) print('Nova tecla', keyCode) end,
}) -- Clique para capturar; Esc cancela. Ignora digitação em TextBoxes.
key:SetValue(Enum.KeyCode.F7)

local color = tab:CreateColorPicker({
    Id = 'cor', Name = 'Cor', Default = '#9070F7',
    Callback = function(value) window:SetTheme({Primary = value}) end,
}) -- Abre um painel de cor separado com RGB e hexadecimal.
color:SetValue(Color3.fromRGB(90, 130, 255))
-- Aceita também '#5A82FF' e {90, 130, 255}.
-- GetValue retorna hex para persistência; .Color contém o Color3 atual.

tab:CreateParagraph({Name = 'Sobre', Content = 'Texto com altura automática.'})
tab:CreateLabel({Name = 'Estado', Text = 'Conectado'})
tab:CreateSection({Name = 'SEÇÃO', Content = 'Descrição opcional'})
tab:CreateDivider({})
tab:CreateBadge({Name = 'Novo', Content = 'v1.0', Color = 'Primary'})
local progress = tab:CreateProgressBar({Name = 'Progresso', Min = 0, Max = 100, Value = 60})
progress:SetValue(80)
```

O painel fecha pelo ×, clique externo, Esc, troca de aba, ocultação/minimização da janela ou destruição/desativação do controle. Apenas um dropdown fica aberto por janela. Em seleção única, escolher uma opção fecha o painel; em múltipla, permanece aberto. Atalhos da library são suspensos enquanto o painel está aberto.

Sliders exigem `Max > Min` e incremento positivo. Dropdowns usam opções de texto e descartam seleções que não estão mais na lista. Use `SetOptions` para alterar opções. Dropdowns abrem um painel sobre a interface, alinhado à direita da janela e limitado à tela. O painel contém título, botão ×, pesquisa opcional, grade rolável e ações Padrão/Limpar; seleção múltipla também possui Selecionar tudo. A grade usa duas colunas quando há largura e uma no celular. Selecionar tudo inclui todas as opções, mesmo com pesquisa ativa. Padrão restaura `Default` e Limpar envia `nil` (único) ou `{}` (múltiplo). A seleção única limpa é persistida com um marcador interno, para permanecer vazia ao reexecutar, mesmo quando há `Default`.

Callbacks usam `pcall` e erros aparecem como avisos. Na inicialização, os controles persistentes (exceto Keybind) chamam o callback com a escolha restaurada ou padrão, para aplicar a configuração ao projeto. `FireOnInit=false` desliga essa chamada. Os callbacks são agendados; escreva-os de forma independente e não dependa da ordem de conclusão. Keybind só executa o callback ao pressionar a tecla; `Changed` trata alterações da tecla.

## Salvamento automático

Formato JSON versionado com `Version`, `Values`, `Profiles`, `Active`, `Deleted` e `AutoLoad`. Arquivos antigos `{Version = 1, Values = {...}}` são migrados para o perfil `Default` na leitura; a gravação mantém o campo `Values` para compatibilidade. São guardados toggles, sliders, seleções únicas/múltiplas, texto confirmado, teclas, cores e a escala da janela. Botões, notificações e barras de progresso não são escolhas persistentes.

Por padrão, salvamento e restauração estão habilitados. O usuário pode desativar novas gravações pela aba Config; o botão Salvar alterações continua permitindo uma gravação manual. A escolha de desativar é gravada antes de interromper as gravações, quando o backend está disponível.

Quando `readfile`, `writefile`, `isfile` e `makefolder` estão disponíveis, o caminho é `ConexaoUI/meu_perfil.json` no sistema virtual de arquivos do ambiente/executor. `isfolder` é usado quando existe. Não é possível escolher arbitrariamente um caminho real do computador. Folder e Name aceitam letras, números, `_` e `-`.

Alterações são gravadas após 300 ms sem novas mudanças; `window:SaveConfig()` e `window:Destroy()` forçam a gravação. Encerrar o processo abruptamente pode perder os últimos 300 ms. Dados inválidos usam os valores padrão e geram aviso. As falhas não são apresentadas como sucesso: confira `window.Storage.Available`, `window.Storage.LastError` e o retorno de `SaveConfig()`.

Sem APIs de arquivo, a interface continua funcionando em memória. **No Roblox Studio e no cliente normal, LocalScripts não podem gravar arquivos no PC.** Para persistência real no seu próprio jogo, implemente um Adapter e uma ponte de servidor autorizada com DataStore. Nunca use DataStore diretamente em LocalScript.

Contrato opcional de armazenamento:

```lua
local adapter = {}
function adapter:Read(profileName)
    -- Retorne JSON obtido pelo seu sistema de armazenamento, ou nil.
    return meuArmazenamento:Read(profileName)
end
function adapter:Write(profileName, json)
    meuArmazenamento:Write(profileName, json)
end
-- Passe Config = {Name = 'perfil', Adapter = adapter} na criação da janela.
```

`meuArmazenamento` representa uma implementação fornecida pelo aplicativo; não faz parte da library. A biblioteca já inclui o backend de arquivos e o fallback em memória. Não guarde senhas ou tokens nos perfis. Use nomes de perfil diferentes para projetos/usuários que não devam compartilhar escolhas.

## Perfis integrados

Na aba Config, o seletor escolhe o perfil a manipular; **Definir como ativo** aplica suas escolhas aos componentes já existentes e chama os callbacks das abas do aplicativo depois de restaurar toda a aparência. Criar/importar apenas seleciona o novo perfil; ativar é uma ação separada. Um perfil novo começa como cópia das escolhas atuais.

- **Salvar alterações**: salva o estado atual no perfil ativo, mesmo com autosave desligado.
- **Carregar automaticamente**: controla a restauração das escolhas na próxima execução. Desligado, inicia uma sessão com padrões, preservando os perfis salvos. Somente salvar explicitamente essa sessão substitui as escolhas salvas do perfil ativo.
- **Excluir**: move o perfil selecionado para uma lixeira persistente, após confirmação. `Default` e o perfil ativo são protegidos. **Restaurar** recupera os valores e o nome.
- **Exportar**: coloca o JSON no campo de texto multilinha, para selecionar/copiar. **Importar** lê esse campo e cria outro perfil, sem executar código nem sobrescrever perfis existentes.

Nomes de perfis aceitam até 48 letras sem acentos, números, espaços, `_` e `-`. Nome vazio gera `Perfil 1`, `Perfil 2`, etc. Há limite de 50 perfis e 50 itens na lixeira; importações aceitam até 256 KiB de JSON. Não há dependência de área de transferência do executor.

API opcional para o autor do script (a interface já fornece esses controles):

```lua
local storage = window.Storage
storage:CreateProfile('Criativo')
window:LoadProfile('Criativo') -- restaura aparência e controles criados por esta library
window:SaveConfig()           -- grava manualmente o perfil ativo
local json = storage:ExportProfile('Criativo')
storage:ImportProfile(json, 'Copia')
storage:DeleteProfile('Copia')
storage:RestoreProfile('Copia')
```

As operações de gerenciamento do painel gravam suas alterações de forma explícita. Com backend indisponível, funcionam em memória e mostram um aviso de que não foi possível salvar. O painel de estado permite atualizar o último erro. A restauração afeta os componentes existentes; componentes criados depois usam o perfil ativo ao inicializar. Controles personalizados fora desta library precisam de integração do aplicativo.

## Janela e responsividade

```lua
window:SetScale(100)      -- Ocupa toda a área útil do ScreenGui.
window:SetScale(60)       -- Proporção da largura/altura disponíveis.
window:SetScale(0)        -- Esconde, mantendo botão flutuante de restauração.
window:SetVisible(false) -- × também esconde, não destrói.
window:SetVisible(true)
window:Minimize(true)    -- Apenas o header; botão − restaura.
window:Minimize(false)
window:SelectTab(tab)
window:Destroy()         -- Limpa eventos, interface e grava escolhas.
UI:Destroy()            -- Destrói todas as janelas desta instância da library.
```

Para valores entre 1 e 100, há dimensões mínimas de usabilidade, limitadas pela tela: os controles não são reduzidos a pontos ilegíveis. A sidebar usa ícones por padrão, como nas referências. `SidebarLayout="expanded"` na criação ou `SetSidebarLayout("expanded")` mostra nomes em telas largas; abaixo de 760 px, volta a ícones. Cards se reorganizam em uma coluna e o conteúdo rola. O tamanho respeita a área útil do Roblox, incluindo seus insets, e não cobre necessariamente a barra superior do aplicativo. Arraste pelo header com mouse/toque. A janela fica limitada à tela. Um botão flutuante permite restaurar sem teclado no celular.

O atalho padrão de mostrar/esconder é RightControl. É ignorado enquanto um TextBox tem foco, durante captura de tecla ou enquanto há confirmação aberta. A tecla de cada Keybind também respeita esses estados. Keybinds são uma função de teclado; os demais controles usam toque.

## Temas, gradientes e transparência

```lua
window:SetTheme({
    Background = Color3.fromRGB(16,18,22),
    Surface = Color3.fromRGB(28,31,36),
    SurfaceHover = Color3.fromRGB(40,44,52),
    Primary = Color3.fromRGB(143,110,247),
    Secondary = Color3.fromRGB(224,184,100),
    Text = Color3.fromRGB(244,245,250),
    MutedText = Color3.fromRGB(155,161,177),
    Border = Color3.fromRGB(58,61,72),
    Success = Color3.fromRGB(105,221,160),
    Warning = Color3.fromRGB(245,199,100),
    Error = Color3.fromRGB(242,113,131),
    CornerRadius = 14,
})
window:SetDim(0.6)          -- Escurece o jogo ao fundo; some ao esconder a janela.
window:SetTransparency(0.2) -- 0 opaco, 1 transparente; fundo e linhas de controles.
window:SetGradient({Color3.fromRGB(55,42,75), Color3.fromRGB(16,18,22)}, 35)
```

Na criação, `Theme` aceita uma tabela com substituições; ausente ou `"Dark"` usa o tema padrão. `SetTheme` atualiza os elementos vinculados sem recriar páginas. `PrimaryText` define a cor do texto sobre o destaque preenchido; se omitido, é calculado a partir de `Primary` para manter contraste. Gradientes de cards podem ter cores próprias; não são substituídos automaticamente pelo tema. Os controles da aba Configurações já salvam as personalizações sem callbacks definidos pelo autor do script. Setters chamados diretamente pelo aplicativo continuam disponíveis; `SetScale`, `SetTransparency` e `SetEffects` também sincronizam os respectivos controles nativos. Para outras mudanças feitas por código, atualize o controle em `window.SettingsControls` quando precisar persistir a escolha (por exemplo, `window.SettingsControls.accent:SetValue(cor)`).

### Luz e movimento

A borda possui dois rastros luminosos, o halo acompanha a janela e os botões preenchidos recebem um brilho suave que atravessa o preenchimento. A animação não altera posição nem tamanho da janela. Use `Effects = false` na criação ou `window:SetEffects(false)` para desativar. A escolha também fica disponível em **Interface → Efeitos de luz** e participa do salvamento automático. `Theme.Highlight` controla a segunda cor dos rastros; `Primary` e `Secondary` controlam os demais destaques.

## Dashboard configurável

```lua
local home = window:CreateDashboard({
    Id = 'dashboard', Name = 'Dashboard', Icon = 'house',
    Username = 'Criador', Avatar = 'rbxassetid://SEU_ID', Status = '● Online',
    SideTitle = 'Minha comunidade', SideDescription = 'Novidades e suporte',
    SideActionName = 'Saiba mais',
    SideAction = function() window:Notify({Content = 'Bem-vindo!'}) end,
    Stats = {
        {Id = 'perfil', Name = 'PERFIL', Value = 'Criativo', Icon = 'user'},
        {Id = 'versao', Name = 'VERSÃO', Value = '1.0', Icon = 'star'},
    },
    News = {{Title = 'Primeira versão', Content = 'Seu painel está pronto.'}},
    Actions = {{Name = 'Salvar', Icon = 'star', Callback = function() window:SaveConfig() end}},
})
home:SetStat('perfil', 'Padrão')
home:SetWelcome({Username = 'Novo nome', Status = '● Conectado',
    Gradient = {Color3.fromRGB(226,188,104), Color3.fromRGB(124,91,239)}})
```

`Avatar` é opcional; substitua `SEU_ID` por um asset permitido. `Stats`, `News` e `Actions` ausentes usam dados demonstrativos. A página também possui os métodos normais de criação de componentes.

## Notificações e confirmação

```lua
local notification = window:Notify({Title = 'Salvo', Content = 'Perfil atualizado.', Duration = 5})
notification:SetValue('Outro texto')
notification:Update({Title = 'Novo título', Content = 'Mensagem'})
notification:Destroy()
local dialog = window:Confirm({Content = 'Deseja continuar?', Callback = function(ok) print(ok) end})
dialog:SetValue('Confirma esta ação?')
-- dialog:Destroy() equivale a cancelar.
```

Notificações incluem fila, ícones, tipos Info/Success/Warning/Error, ações, animações e progresso de duração. `Duration=0` mantém o aviso até fechar; o mouse pausa a contagem por padrão. `Update`, `Pause`, `Resume`, `Close` e `Destroy` controlam o aviso. `Window:Toast()` usa o mesmo sistema.

`Window:Popup()` oferece de 1 a 10 opções com valores e callbacks, além de conteúdo atualizável, fila e cancelamento. `Confirm()` usa esse sistema com resultado booleano. Popups bloqueiam cliques e atalhos da library ao fundo; destruir a janela limpa filas e temporizadores sem executar ações pendentes. Veja a [documentação completa com exemplos](docs/NOTIFICACOES.md).

## Arquitetura e desenvolvimento

```
ConexaoUI/
  init.luau
  Core/        Window, Options, Theme, Icons, Effects, Animation, Elements, Input, Cleanup, Storage, Identity, Notifications, Dialogs
  Components/  Factory, Group, RowLayout, DropdownPanel, ColorPanel e entradas por componente
  Pages/       Overview, Dashboard, Settings, Profiles
  Examples/    Demo.client.luau, Minimal.client.luau
dist/          Biblioteca, demo e modelo Studio gerados
tools/         bundle.py, render_preview.py
tests/         Persistência, configurações, componentes, lifecycle e geometria
```

As entradas por componente delegam ao factory compartilhado para manter uma única implementação de ciclo de vida, callbacks e persistência. As páginas são mantidas durante a navegação. As luzes usam uma conexão de renderização por janela, pausam quando a janela fica oculta/minimizada e são desativadas pelo controle Efeitos de luz. A destruição desconecta tanto essa conexão quanto os eventos globais de input. Reexecutar com o mesmo `Id` remove a interface anterior e dispara a limpeza da janela anterior.

Requer Python 3 apenas para gerar os arquivos de distribuição:

```sh
cd /workspace/ui
python3 tools/bundle.py
python3 tests/run.py /workspace/tools/luau/luau
python3 tests/settings.py /workspace/tools/luau/luau
python3 tests/sliders.py /workspace/tools/luau/luau
python3 tests/dropdowns.py /workspace/tools/luau/luau
python3 tests/feedback.py /workspace/tools/luau/luau
python3 tests/lifecycle.py /workspace/tools/luau/luau
python3 tests/geometry.py /workspace/tools/luau/luau
/workspace/tools/luau/luau-compile dist/ConexaoUI.luau >/dev/null
/workspace/tools/luau/luau-compile dist/Demo.luau >/dev/null
```

O compilador/CLI Luau foi obtido da distribuição oficial `luau-lang/luau` por HTTPS e está em `/workspace/tools/luau`; não é uma dependência do Roblox. O bundle é determinístico e o modelo `.rbxmx` contém os mesmos módulos. Não há serviço de aplicação para iniciar neste ambiente.

Para revisar proporções fora do Roblox, `tools/render_preview.py` executa a distribuição no host simulado e gera JSON, HTML e PNG. Requer Python, Pillow e Luau CLI. Exemplo: `python3 tools/render_preview.py --page controls --luau /workspace/tools/luau/luau --output /tmp/conexao-controls`. Veja os limites e exemplos em [Visual](docs/VISUAL.md).

## Validação e limites

Executado neste ambiente: compilação Luau e testes da distribuição real com serviços/elementos simulados. Cobrem persistência e restauração, falhas de arquivos, perfis, configurações nativas, sliders, cores, dropdowns, notificações, popups e destruição. A demo completa também é iniciada e encerrada no host simulado. Um modelo aproximado de geometria cobre cinco resoluções, tamanho inicial, cabeçalho, larguras dos campos, altura das grades e isolamento do editor de cores. Os testes não validam o motor Roblox, seu codec JSON real nem a aparência.

**O motor Roblox não foi executado neste ambiente.** A 2.1 foi revisada também com representações aproximadas das propriedades de GUI, disponíveis em [Visual](docs/VISUAL.md). Elas usam fonte substituta e avatar ilustrativo. Ainda é necessário verificar o resultado no cliente real, incluindo:

- Abrir, fechar, restaurar, minimizar e reexecutar com o mesmo Id.
- Arrastar usando mouse e toque; redimensionar/rotacionar a tela.
- Navegação, pesquisa de controles, tooltips e sidebar com muitas abas.
- Sliders e campos RGB com toque; dropdowns únicos/múltiplos em telas pequenas.
- Digitação, validação e teclado virtual; captura de teclas sem disparar atalhos enquanto digita.
- Troca de tema, transparência e escala, incluindo 0 e 100.
- Criar/ativar/salvar/excluir/restaurar perfis, exportar/copiar e importar JSON; ligar/desligar auto load e autosave.
- Restauração do JSON e callbacks iniciais; falhas de escrita devem gerar aviso.
- Fila de notificações, pausa por hover, botões de ação e atualização de avisos.
- Fila de popups com várias opções, confirmação, cancelamento e textos extensos.
- Destruição sem conexões remanescentes e modal bloqueando o fundo.

A pesquisa do header filtra componentes na subpágina ativa de Configurações e nos controles criados pela API; não pesquisa textos internos do dashboard. A posição arrastada, aba ativa e estado minimizado não são persistidos. Teclados virtuais, símbolos personalizados e permissões de assets variam por dispositivo e requerem validação no cliente real. Em janelas extremamente pequenas, a rolagem mantém os controles disponíveis; textos extensos de botões podem ser truncados. O layout do dashboard foi preparado para os cards curtos mostrados na referência, não para artigos extensos.
