# Conexão UI 3.3 · Rayfield Gen2

Esta versão usa o **source oficial do Rayfield Gen2 1.2.1** como base. A Conexão acrescenta configurações visíveis, transparência e tamanho ajustáveis, perfil clicável e seletores de opções/temas dentro do painel. É um fork sob MPL-2.0, com créditos e licença preservados. [Origem e alterações](docs/FORK.md) · [Licença e créditos](NOTICE.md).

## Executar a demonstração

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/Demo.luau"))()
```

A demo abre diretamente em **Configurações**, com transparência, tamanho, salvamento e temas. Usa o tema `conexao`. Clique no cartão com avatar/nome no rodapé da sidebar para abrir seu perfil.

Os exemplos de botões, campos, avisos e grupos estão separados em [dist/Components.luau](dist/Components.luau) e no [script completo](Example.luau). A library cria as configurações; as abas do seu projeto são criadas pelo seu script.

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

- Perfil da sidebar clicável: abre uma página dentro do painel principal com banner em gradiente, avatar maior, nome, @usuário e badges do cliente. Os cartões de executor/versão e ID se organizam em duas colunas ou uma no celular. Há ações para copiar o ID, abrir Configurações/Temas e voltar à aba anterior.
- Página **Configurações** pronta e visível na sidebar: transparência, tamanho manual/automático, salvamento/restauração, temas com prévias, atalhos e as opções nativas do Gen2. A engrenagem continua abrindo essa mesma página.
- Dropdown dentro da área de conteúdo, mantendo a sidebar acessível: busca, cartões de opções, seleção única/múltipla, Padrão, Limpar e Selecionar todos. Voltar, Escape ou selecionar outra aba encerra o seletor. Em telas estreitas usa uma coluna, e o cabeçalho do controle separa o título do valor.
- Salvamento e carregamento automáticos habilitados por padrão, incluindo toggles, sliders, dropdowns únicos/múltiplos, inputs, teclas e cores. Use `flag` estável e único por controle.
- Seis novos temas com gradientes e cores mais vivas; os seis temas originais também continuam disponíveis. As prévias usam as mesmas cores aplicadas à janela.
- Busca, notificações, toasts, popups, grupos, estatísticas, progresso e console da base oficial.
- Tamanho automático ativado desde `CreateWindow`: acompanha a resolução, o redimensionamento, a rotação do celular e a troca de câmera. No celular em pé, a janela aproveita a altura disponível. `sidebarLayout = false` usa o layout original com abas no topo.

O botão de engrenagem abre as configurações. A tecla `K` mostra ou oculta a janela por padrão; esse atalho pode ser alterado nas configurações. `window.SettingsTab` expõe essa aba. As abas de exemplo pertencem ao script da demo.

Não é necessário criar a página de configurações no seu script. A janela oculta ou minimizada mantém esse estado durante a rotação e usa o tamanho atualizado quando é reaberta.

## Transparência e tamanho

- **Transparência do fundo, 0–100%:** 0 deixa o fundo sólido e 100 o deixa transparente. Texto e ícones mantêm sua opacidade.
- **Ajustar tamanho automaticamente:** vem ativado e acompanha o tamanho/orientação da tela.
- **Tamanho da janela, 0–100%:** arrastar ativa o modo manual. 0 mantém um tamanho compacto acessível; 100 usa o espaço disponível, preservando margens para os controles do Roblox. Mesmo no modo manual, a proporção é recalculada ao mudar de tela.

Essas escolhas são lembradas por janela. Você pode ativar o ajuste automático novamente a qualquer momento.

## Temas com prévia

| ID | Visual |
| --- | --- |
| `conexao` | Violeta elétrico e azul |
| `aurora` | Verde e turquesa |
| `oceano` | Azul e ciano |
| `crepusculo` | Coral e violeta |
| `sakura` | Rosa e lavanda |
| `onyx` | Dourado sobre carvão |

Os temas originais são `default`, `amethyst`, `cobalt`, `ember`, `frost` e `rose`. A galeria completa abre dentro do painel e mostra as 12 prévias. A escolha é aplicada na hora e lembrada na próxima execução, mantendo a transparência configurada. Para fixar o tema definido pelo script, use `rememberTheme = false` em `CreateWindow`.

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

O formato é JSON com extensão `.rfld`, armazenado em `ConexaoUI/Configurations/`. Sem `fileName`, o nome é derivado do Id/nome da janela e `game.PlaceId`. Mantenha esses identificadores estáveis. As preferências nativas usam `ConexaoUI/Settings/conexao.rfld`. Tema, transparência, tamanho e preferências de salvamento/restauração ficam ao lado da configuração em `<nome>.rfld.ui.json`. A restauração inicial acontece quando a janela aparece; controles acrescentados depois também recebem seus valores salvos, e seus callbacks são chamados com os valores restaurados.

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
