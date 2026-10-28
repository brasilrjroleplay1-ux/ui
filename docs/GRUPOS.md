# Criar sua interface com a Conexão UI

A library fornece os componentes e o estilo. **Seu script escolhe as abas, os grupos e os controles que aparecem.** Carregar `dist/ConexaoUI.luau` apenas retorna a API; a janela só é criada quando o script chama `CreateWindow`.

- [Script-base para adaptar](../Starter.luau)
- [Exemplo de todos os componentes](../Example.luau)
- [Referência de componentes](EXEMPLOS.md)

## Exemplo com o layout das referências

```luau
local ConexaoUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/ConexaoUI.luau"
))()

local Window = ConexaoUI:CreateWindow({
    Title = "Meu Hub",
    Id = "MeuHub",
    SidebarLayout = "icons",
})

local Tab = Window:CreateTab({Name = "Principal", Icon = "house"})
local Recursos = Tab:CreateGroup({Name = "RECURSOS", Icon = "bolt", Column = 1})
local Opcoes = Tab:CreateGroup({Name = "OPÇÕES", Icon = "settings", Column = 2})

Recursos:CreateToggle({
    Id = "recurso",
    Name = "Ativar recurso",
    Default = false,
    Callback = function(value) print("Ativado:", value) end,
})

Opcoes:CreateSlider({
    Id = "intensidade",
    Name = "Intensidade",
    Min = 0, Max = 100, Default = 50,
    Callback = function(value) print(value) end,
})

Opcoes:CreateDropdown({
    Id = "escolhas",
    Name = "Escolhas",
    Multi = true,
    Options = {"Opção A", "Opção B", "Opção C"},
    Default = {"Opção A"},
    Callback = function(values) print(table.concat(values, ", ")) end,
})
```

O resultado usa cards escuros com títulos/ícones, bordas finas e linhas compactas. Em espaço suficiente, o nome fica à esquerda e o controle à direita. Em telas pequenas, o controle ocupa uma linha abaixo do nome para manter uma área de toque utilizável. O dropdown continua abrindo seu painel com pesquisa e seleção.

## Propriedades do grupo

| Propriedade | Uso |
| --- | --- |
| `Name` | Título do card. |
| `Id` | Identificador estável; recomendado quando o nome pode mudar. |
| `Icon` | Nome local, símbolo ou ID de imagem. |
| `Description` | Descrição opcional dentro do card. |
| `Column` | `1` ou `2` para os dois lados do layout. Sem `Column`, usa a largura da página. |
| `Collapsed` | `true` inicia recolhido; clique no cabeçalho para alternar. |
| `Compact` | Padrão `true`; `false` mantém os controles no formato de cards maiores. |

As duas colunas passam a uma quando o conteúdo tem menos de 700 px disponíveis. Os grupos usam os mesmos métodos de criação da aba: `CreateButton`, `CreateToggle`, `CreateSlider`, `CreateDropdown`, `CreateTextbox`, `CreateKeybind`, `CreateColorPicker` e componentes informativos. Grupos dentro de grupos não fazem parte da API.

```luau
Recursos:SetCollapsed(true)
Recursos:SetCollapsed(false)
Recursos:SetValue("OUTRO TÍTULO")
Recursos:Update({Name = "RECURSOS", Collapsed = false})
-- Recursos:Destroy() -- Destrói também seus controles e desconecta eventos.
```

`Compact = false` pode ser passado em um componente específico. Campos `MultiLine` mantêm o formato maior. O seletor de cor expande seu conteúdo abaixo da linha, sem cobrir os controles seguintes.

## Configurações, perfis e busca

A aba Configurações continua automática e agora usa os mesmos grupos visuais. Nenhuma aba de jogo, botão de exemplo ou dashboard é criado automaticamente.

Os controles de grupos participam do salvamento e da restauração de perfis. IDs explícitos não mudam ao mover um controle de grupo; sem ID, a chave usa a aba, o grupo e o nome do controle. Mantenha esses identificadores estáveis entre execuções. Renomear um grupo por `SetValue` mantém sua chave original.

A pesquisa do header encontra nomes de controles e títulos de grupos. Durante a pesquisa, grupos encontrados são expandidos temporariamente; limpar o campo restaura o estado recolhido. Recolher um grupo fecha seu dropdown aberto.

## Sidebar e propriedades

```luau
Window:SetSidebarLayout("icons")    -- Sidebar compacta, como nas referências.
Window:SetSidebarLayout("expanded") -- Ícone e nome em telas largas.

-- Formas válidas de criar abas:
local OutraAba = Window:CreateTab("Outra aba", "star")
local AbaComTabela = Window:CreateTab({name = "Mais", icon = "info"})
```

Os nomes de propriedades aceitam `Name`/`name`, `Callback`/`callback`, etc. Uma chave com inicial maiúscula tem prioridade se as duas formas forem fornecidas. Isso não altera os nomes dos métodos nem os nomes dos campos da API: use `Default`, `Min`, `Max` e `Multi`, conforme a documentação.

A sidebar usa ícones por padrão; `expanded` mostra os nomes quando há espaço. O perfil no rodapé pode receber `Avatar` na criação da janela; `ShowProfile = false` o oculta. O título de cada aba aparece no conteúdo usando o nome escolhido pelo seu script.

## Validação

O teste de ciclo de vida carrega a distribuição real com um host Roblox simulado e verifica que importar a library não cria interface, que apenas as configurações prontas aparecem em `CreateWindow`, que grupos participam dos perfis/busca e que reexecutar/destruir limpa os objetos. A demo completa também é iniciada e encerrada nesse host. Aparência, tipografia e toque ainda precisam ser conferidos no Roblox real.
