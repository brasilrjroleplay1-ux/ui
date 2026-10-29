# Conexão UI 3.1 · Rayfield Gen2

Esta versão usa o **source oficial do Rayfield Gen2 1.2.1** como base. A Conexão acrescenta dropdown em painel separado, perfil clicável, configurações automáticas e uma galeria de temas com prévias feitas na própria interface. É um fork sob MPL-2.0, com créditos e licença preservados. [Origem e alterações](docs/FORK.md) · [Licença e créditos](NOTICE.md).

## Executar a demonstração

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/Demo.luau"))()
```

A demo usa o novo tema `conexao`. Abra a engrenagem para ver as prévias e aplicar um tema. Clique no avatar/nome no rodapé da sidebar para abrir seu perfil.

## Criar sua janela

Carregar a library retorna a API. As abas e os controles do seu projeto são criados pelo seu script:

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/ConexaoUI.luau"))()
local window = UI:CreateWindow({
    name = "Meu Hub",
    subtitle = "Meu projeto",
    sidebarLayout = true,
    theme = "conexao",
})
local tab = window:CreateTab({ name = "Principal", icon = 93364949241311 })
tab:CreateButton({ name = "Meu botão", callback = function() window:Toast({ title = "Clicado" }) end })
tab:CreateToggle({ name = "Meu recurso", flag = "recurso", value = false, callback = function(value) print(value) end })
tab:CreateSlider({ name = "Intensidade", flag = "intensidade", range = { 0, 100 }, value = 50 })
tab:CreateDropdown({ name = "Modo", flag = "modo", options = { "A", "B", "C" }, value = "A" })
```

[Exemplo completo](Example.luau) · [Script-base](Starter.luau) · [Todos os componentes](docs/EXEMPLOS.md) · [API original Gen2](https://docs.sirius.menu/rayfield-gen2).

## O que já vem pronto

- Perfil da sidebar clicável: abre avatar, nome de exibição, @usuário, ID, executor e versão quando informados pelo ambiente. Se não houver identificação, a interface informa isso.
- Página de configurações pronta: salvamento/restauração, status do armazenamento, temas com prévias, atalho, cursor, toasts, haptics, perfil, posição e gerenciamento de configurações.
- Dropdown em painel separado com busca sempre visível, cartões de opções, seleção única/múltipla, Padrão, Limpar e Selecionar todos. Fecha pelo X, Escape ou clique fora. Em telas estreitas usa uma coluna.
- Salvamento e carregamento automáticos habilitados por padrão, incluindo toggles, sliders, dropdowns únicos/múltiplos, inputs, teclas e cores. Use `flag` estável e único por controle.
- Seis novos temas com gradientes e cores mais vivas; os seis temas originais também continuam disponíveis. As prévias usam as mesmas cores aplicadas à janela.
- Busca, notificações, toasts, popups, grupos, estatísticas, progresso e console da base oficial.
- Redimensionamento responsivo da base Gen2. `sidebarLayout = false` usa o layout original com abas no topo.

O botão de engrenagem abre as configurações. A tecla `K` mostra ou oculta a janela por padrão; esse atalho pode ser alterado nas configurações. `window.SettingsTab` expõe essa aba. As abas de exemplo pertencem ao script da demo.

## Temas com prévia

| ID | Visual |
| --- | --- |
| `conexao` | Violeta elétrico e azul |
| `aurora` | Verde e turquesa |
| `oceano` | Azul e ciano |
| `crepusculo` | Coral e violeta |
| `sakura` | Rosa e lavanda |
| `onyx` | Dourado sobre carvão |

Os temas originais são `default`, `amethyst`, `cobalt`, `ember`, `frost` e `rose`. A galeria completa mostra as 12 prévias. A escolha é aplicada na hora e lembrada na próxima execução. Para fixar o tema definido pelo script, use `rememberTheme = false` em `CreateWindow`.

## Configuração automática

Não é necessário declarar `configuration`. Para personalizar:

```lua
local window = UI:CreateWindow({
    name = "Meu Hub",
    configuration = {
        autoSave = true,
        autoLoad = true,
        fileName = "meu_hub",
        customFolder = "meu_projeto",
    },
})
```

O formato é JSON com extensão `.rfld`, armazenado em `ConexaoUI/Configurations/`. Sem `fileName`, o nome é derivado do Id/nome da janela e `game.PlaceId`. Mantenha esses identificadores estáveis. As preferências nativas usam `ConexaoUI/Settings/conexao.rfld`. O tema e as preferências de salvamento/restauração ficam ao lado da configuração em `<nome>.rfld.ui.json`. A restauração inicial acontece quando a janela aparece; controles acrescentados depois também recebem seus valores salvos, e seus callbacks são chamados com os valores restaurados.

As APIs de arquivo dependem do ambiente. No Studio, a base usa armazenamento simulado na sessão; LocalScripts normais não gravam arquivos no PC. A página informa se o armazenamento é da sessão, do dispositivo ou está indisponível, além de mostrar falhas ao salvar. `window:Save()` e `window:Load()` retornam sucesso/falha. Para desativar a automação, use os toggles nas configurações ou informe `configuration = { autoSave = false, autoLoad = false }`. Uma opção explícita no script prevalece sobre a preferência lembrada desses dois toggles.

## Instalar no Studio

1. Importe [dist/ConexaoUI.rbxmx](dist/ConexaoUI.rbxmx) em `ReplicatedStorage`.
2. Em um LocalScript de `StarterPlayerScripts`, use [ConexaoUI/Examples/Demo.client.luau](ConexaoUI/Examples/Demo.client.luau).
3. Execute Play. O modelo já inclui os módulos Gen2 dentro do módulo ConexaoUI.

O [default.project.json](default.project.json) também mapeia o projeto para Rojo. Fontes e imagens usam os mesmos assets Roblox da base original e dependem da disponibilidade deles no cliente.

## Origem, alterações e versão anterior

Os arquivos da base estão fixados em um commit conhecido. Os ajustes nela são o diretório de armazenamento da Conexão, o nome do arquivo de preferências e analytics inicialmente desligado. A camada [ConexaoUI/init.luau](ConexaoUI/init.luau) e os módulos em [ConexaoUI/Features](ConexaoUI/Features) implementam as extensões da Conexão. O renderer da versão 2 foi arquivado.

A 3.x usa a API Gen2. `CreateGroup` cria layouts em linha/coluna; dropdowns usam `multiSelect`; sliders usam `range`; valores iniciais usam `value`. A 3.1 continua lendo as configurações `.rfld` da 3.0. Veja os exemplos atualizados. A versão 2.1 completa, com seus fontes, testes, documentação e distribuição, está em [legacy/v2](legacy/v2).

## Desenvolvimento e validação

```sh
python3 tools/bundle.py
CONEXAO_LUNE=/workspace/tools/lune-0.8.9/lune python3 tools/test.py
```

Lune 0.8.9 é a versão fixada pelo upstream em `vendor/rayfield-gen2/rokit.toml`. O teste executa a suíte da base com serviços Roblox simulados e depois executa as distribuições reais da library e da demo no mesmo host. O bundle incorpora os fontes legíveis; não faz download de Lua adicional. As ferramentas completas do upstream e seu gate `make ci` estão descritos no [guia de contribuição](vendor/rayfield-gen2/CONTRIBUTING.md).

**O cliente Roblox não foi executado neste ambiente.** A compilação e os testes simulados verificam comportamento e integração. Fontes, assets, animações e toque ainda precisam de conferência no cliente real.
