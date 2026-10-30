# Conexão UI 3.5.2 · Conexão Studio

Esta versão usa o **source oficial do Rayfield Gen2 1.2.1** como base. A Conexão acrescenta configurações visíveis, transparência e tamanho ajustáveis, perfil clicável e seletores de opções/temas dentro do painel. É um fork sob MPL-2.0, com créditos e licença preservados. [Origem e alterações](docs/FORK.md) · [Licença e créditos](NOTICE.md).

## Executar a demonstração

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/Demo.luau"))()
```

A demo abre em **Visão geral**, com perfil, cliente, atalhos e cartões da sessão. Usa o tema `conexao`. **Configurações** continua pronta na sidebar, com transparência, tamanho, salvamento e temas. O cartão com avatar/nome no rodapé também abre o painel inicial.

A abertura mostra **Conexão Studio**, com marca em vetores e texto local. Os créditos da base permanecem no código e no repositório. O nome da sua janela continua personalizável em `CreateWindow`.

Na **3.5.2**, a composição combina boas-vindas compactas, cartão do cliente, atalhos com ícones e uma grade de estatísticas, inspirada nas referências visuais fornecidas e na Home da [Luna Interface Suite](https://github.com/Nebula-Softworks/Luna-Interface-Suite). A implementação é da Conexão sobre a base Gen2; não carrega código da Luna. O avatar continua em **420 × 420 px**. A página usa a rolagem do painel e reorganiza os cartões em telas menores.

O suporte está limitado a **Delta, Wave, Xeno e Solara**, com as quatro logos incluídas. Os demais nomes e clientes sem identificação são recusados antes da inicialização da UI. O **Roblox Studio** tem uma exceção explícita para desenvolvimento. [Política de suporte](docs/EXECUTORES.md) · [Origem das imagens](assets/README.md).

Esta seleção usa nomes conhecidos como critério de suporte. Não foram verificados números de usuários nem auditados os programas instalados. O nome é informado pelo próprio cliente e pode ser falsificado; a checagem não comprova segurança, autenticidade ou integridade do executável.

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

- Painel inicial e perfil clicável: banner compacto, avatar, nome, @usuário e logos de cliente/plataforma; cartões de cliente e conta; atalhos para Configurações, Temas e copiar o Job ID. A sessão mostra jogadores/limite, FPS, ping, tempo no painel, Place ID e estado do salvamento. Métricas indisponíveis aparecem como `—`.
- Página **Configurações** pronta e visível na sidebar: transparência, tamanho manual/automático, salvamento/restauração, temas com prévias, atalhos e opções nativas com nomes e descrições em português. A engrenagem continua abrindo essa mesma página.
- Dropdown dentro da área de conteúdo, mantendo a sidebar acessível: busca, cartões de opções, seleção única/múltipla, Padrão, Limpar e Selecionar todos. Voltar, Escape ou selecionar outra aba encerra o seletor. Em telas estreitas usa uma coluna, e o cabeçalho do controle separa o título do valor.
- Salvamento e carregamento automáticos habilitados por padrão, incluindo toggles, sliders, dropdowns únicos/múltiplos, inputs, teclas e cores. Use `flag` estável e único por controle.
- **60 temas com paletas distintas:** 54 da Conexão e seis clássicos da base. A galeria inclui busca e filtros por família, com temas claros, escuros e neon. As prévias usam as mesmas cores aplicadas à janela.
- Busca, notificações, toasts, popups, grupos, estatísticas, progresso e console da base oficial.
- Tamanho automático ativado desde `CreateWindow`: acompanha a resolução, o redimensionamento, a rotação do celular e a troca de câmera. No celular em pé, a janela aproveita a altura disponível. `sidebarLayout = false` usa o layout original com abas no topo.

O botão de engrenagem abre as configurações. A tecla `K` mostra ou oculta a janela por padrão; esse atalho pode ser alterado nas configurações. `window.SettingsTab` expõe essa aba. As abas de exemplo pertencem ao script da demo.

Não é necessário criar a página de configurações no seu script. A janela oculta ou minimizada mantém esse estado durante a rotação e usa o tamanho atualizado quando é reaberta.

## Transparência e tamanho

- **Transparência do fundo, 0–100%:** 0 deixa o fundo sólido e 100 o deixa transparente. Texto e ícones mantêm sua opacidade.
- **Ajustar tamanho automaticamente:** vem ativado e acompanha o tamanho/orientação da tela.
- No automático, o slider acompanha o tamanho calculado ao abrir, girar a tela ou ativar essa opção. A porcentagem usa a escala de compacto a espaço disponível, pela largura na sidebar e pela altura no layout com abas no topo. O último tamanho manual continua salvo separadamente.
- **Tamanho da janela, 0–100%:** o arraste mostra uma prévia do valor e mantém a janela parada. Ao soltar, aplica o tamanho, ativa o modo manual e salva a escolha. 0 mantém um tamanho compacto acessível; 100 usa o espaço disponível, preservando margens para os controles do Roblox. Mesmo no modo manual, a proporção é recalculada ao mudar de tela.

Essas escolhas são lembradas por janela. Você pode ativar o ajuste automático novamente a qualquer momento.

Na **3.5.2**, os controles em largura total recalculam sua disposição pelo espaço disponível e pelo texto exibido. Toggles reservam espaço para o interruptor e quebram nomes longos em linhas. Sliders colocam o trilho abaixo do título quando necessário; em janelas pequenas, o percentual também ganha sua própria linha. Campos de texto e teclas podem ficar abaixo do título. As descrições usam toda a largura disponível, e os dropdowns separam título e seleção antes de colidirem.

O puxador do slider mantém margem nas duas extremidades, com uma área maior para toque. A janela continua aplicando o tamanho manual ao soltar, e uma medição de fonte interrompida por outra mudança de largura é descartada. A altura dos controles acompanha o texto mesmo durante a animação de clique.

As páginas e os seletores recalculam a área rolável a partir do conteúdo e das margens. A barra aparece quando há mais conteúdo; após redimensionar, a posição permanece dentro do intervalo válido. Ao reabrir a janela, os layouts são conferidos depois da animação.

## Temas com prévia

| ID | Visual |
| --- | --- |
| `conexao` | Violeta elétrico e azul |
| `aurora` | Verde e turquesa |
| `oceano` | Azul e ciano |
| `crepusculo` | Coral e violeta |
| `sakura` | Rosa e lavanda |
| `onyx` | Dourado sobre carvão |

Os seis temas acima continuam disponíveis. A galeria completa oferece **60 prévias**, com as famílias Assinatura, Neon, Natureza, Cósmicos, Claros, Minerais e Clássicos. A busca aceita nome, ID, cores e estilo, inclusive sem acentos. Os filtros funcionam junto com a busca, e a lista se adapta à largura do painel.

As prévias das configurações ocupam uma área de **156–300 px de altura com rolagem própria**. A galeria completa também tem altura limitada: busca e filtros ficam fora da lista rolável. Em janelas baixas, o cabeçalho fica compacto; nas menores, a busca permanece disponível e as famílias voltam a aparecer quando houver espaço. O mapa de cores na documentação é uma imagem de referência, não o tamanho da galeria no Roblox.

Veja o [catálogo completo e o mapa das paletas](docs/TEMAS.md). Os temas originais mantêm os IDs `default`, `amethyst`, `cobalt`, `ember`, `frost` e `rose`. A escolha é aplicada na hora e lembrada na próxima execução, mantendo a transparência configurada. Para fixar o tema definido pelo script, use `rememberTheme = false` em `CreateWindow`.

```lua
window:ChangeTheme("cyberpunk")
window:OpenThemes()
```

## Opções de interação

Os controles nativos agora vêm em português, mantendo seus valores salvos e callbacks:

| Opção | Função |
| --- | --- |
| Tecla para abrir / fechar | Troca o atalho que mostra ou oculta a janela. |
| Liberar cursor com o menu aberto | Permite usar o mouse quando o jogo prende o cursor. |
| Aviso de boas-vindas | Exibe o aviso inicial com seu nome. |
| Vibração ao tocar | Ativa o retorno tátil em aparelhos compatíveis. |
| Estatísticas anônimas de uso | Controla a telemetria da base Sirius/Gen2; vem desativada em uma instalação nova. |
| Mostrar meu perfil na lateral | Mostra ou oculta foto e nome no rodapé. |

O idioma padrão é `pt-br`. O script pode usar `locale = "en"` ou fornecer `translations`/`translator` pela API Gen2. O tradutor do projeto e as traduções fornecidas em `CreateWindow` têm prioridade.

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

## Painel inicial e logos adicionais

`OpenHome()` e `OpenProfile()` abrem a mesma página. A amostragem de FPS e tempo é encerrada ao destruir a janela; dados de rede ficam protegidos contra APIs ausentes. A UI não deduz região de servidor a partir do país do jogador e não anuncia compatibilidade de recursos a partir do nome do executor.

```lua
window:OpenHome()
local stats = window:GetSessionStats()
print(stats.players, stats.maximum, stats.fps, stats.ping, stats.elapsed)
```

Para personalizar a logo de um executor permitido, registre um asset Roblox ou URI local **antes de criar a janela**. Cadastrar uma imagem ou alias visual não libera outros executores:

```lua
-- Substitua o número pelo ID público da sua imagem.
UI:RegisterExecutorIcon("Delta", 1234567890)
```

## Instalar no Studio

1. Importe [dist/ConexaoUI.rbxmx](dist/ConexaoUI.rbxmx) em `ReplicatedStorage`.
2. Em um LocalScript de `StarterPlayerScripts`, use [ConexaoUI/Examples/Demo.client.luau](ConexaoUI/Examples/Demo.client.luau).
3. Execute Play. O modelo já inclui os módulos Gen2 dentro do módulo ConexaoUI.

Fora do Studio, esta versão exige a identificação de um dos quatro executores permitidos por `identifyexecutor` ou `getexecutorname`. Nomes são comparados por igualdade, ignorando maiúsculas e espaços extras; sufixos como “Clone” ou “Runtime” não são aceitos automaticamente.

O [default.project.json](default.project.json) também mapeia o projeto para Rojo. Fontes e imagens usam os mesmos assets Roblox da base original e dependem da disponibilidade deles no cliente.

## Origem, alterações e versão anterior

Os arquivos da base estão fixados em um commit conhecido. Os ajustes nela são o diretório de armazenamento da Conexão, o nome do arquivo de preferências, analytics inicialmente desligado, miniaturas de avatar em alta resolução com cache separado e um callback opcional para a abertura personalizada. A camada [ConexaoUI/init.luau](ConexaoUI/init.luau) e os módulos em [ConexaoUI/Features](ConexaoUI/Features) implementam as extensões da Conexão. O renderer da versão 2 foi arquivado.

A 3.x usa a API Gen2. `CreateGroup` cria layouts em linha/coluna; dropdowns usam `multiSelect`; sliders usam `range`; valores iniciais usam `value`. A 3.1 continua lendo as configurações `.rfld` da 3.0. Veja os exemplos atualizados. A versão 2.1 completa, com seus fontes, testes, documentação e distribuição, está em [legacy/v2](legacy/v2).

## Desenvolvimento e validação

```sh
python3 tools/bundle.py
CONEXAO_LUNE=/workspace/tools/lune-0.8.9/lune python3 tools/test.py
```

Lune 0.8.9 é a versão fixada pelo upstream em `vendor/rayfield-gen2/rokit.toml`. O teste executa a suíte da base com serviços Roblox simulados e depois executa as distribuições reais da library e da demo no mesmo host. O bundle incorpora os fontes legíveis; não faz download de Lua adicional. As ferramentas completas do upstream e seu gate `make ci` estão descritos no [guia de contribuição](vendor/rayfield-gen2/CONTRIBUTING.md).

**O cliente Roblox não foi executado neste ambiente.** A compilação e os testes simulados verificam comportamento e integração. Fontes, assets, animações e toque ainda precisam de conferência no cliente real.
