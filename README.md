# Conexão UI 3.17.0 · Conexão Studio

Esta versão usa o **source oficial do Rayfield Gen2 1.2.1** como base. A Conexão acrescenta configurações visíveis, transparência e tamanho ajustáveis, perfil clicável, dropdowns em uma divisão interna do conteúdo e temas com prévia. É um fork sob MPL-2.0, com créditos e licença preservados. [Origem e alterações](docs/FORK.md) · [Licença e créditos](NOTICE.md).

Na **3.17.0**, as notificações usam cartões mais compactos, fundo neutro ligado ao tema, ícone circular, título em destaque e fechamento discreto. O padrão é o canto superior direito. Em Configurações → Aparência → **Posição das notificações**, escolha Superior ou Inferior; a preferência fica salva por conta. `notificationPosition` define o padrão inicial da janela, `window:SetNotificationPosition("Bottom")` altera durante a execução e `position = "Top"/"Bottom"` em `Notify` fixa a posição de um aviso. Alterar a preferência move os avisos que a acompanham sem reiniciar o tempo. [Exemplos](docs/EXEMPLOS.md#notificação-toast-e-popup).

Na **3.16.0**, Configurações usa uma página com rolagem vertical e seções expansíveis: Aparência, Temas, Salvamento, Controles e Desempenho. Os cabeçalhos têm ícone, descrição curta e seta; os controles aparecem logo abaixo. Várias seções podem ficar abertas, e essa escolha é lembrada por perfil. A antiga barra de abas internas foi substituída. `window:OpenSettings("saving")` continua abrindo a seção solicitada na mesma página.

Na **3.15.2**, o indicador à direita dos botões usa uma mão clicando, com o dedo levantado e traços de toque. O desenho vetorial acompanha os temas, foco, toque e bloqueio. Todos os `CreateButton` recebem o ícone automaticamente, inclusive dentro dos grupos.

Na **3.15.1**, toda janela já cria **Início** e **Configurações**, inclusive no exemplo completo de componentes. As duas ficam antes das abas do script na lateral. O seletor de Configurações aparece desde a primeira abertura, acima do fundo da navegação. Sem abas próprias, a janela abre no Início; a primeira aba criada pelo script continua sendo selecionada automaticamente.

Na **3.15.0**, a revisão visual alcança a janela inteira: fundos e cartões com mais separação, textos de apoio legíveis, cabeçalho mais espaçoso, navegação com seleção marcada e botões com destaque próprio. Switches e sliders usam controles circulares; Início, perfil e notificações acompanham as mesmas cores e hierarquia. As 60 paletas preservam seus IDs e cores de destaque. [O que mudou no visual](docs/VISUAL.md).

Na **3.14.1**, os sliders mostram o valor à direita da barra. Os campos editáveis incluem um lápis, borda e destaque ao passar o mouse ou focar pelo teclado. Toque no número ou no lápis para digitar. O layout mantém título, barra e edição separados e se reorganiza em espaços pequenos; validação e salvamento continuam iguais.

Na **3.14.0**, seus scripts podem criar grupos recolhíveis com `tab:CreateGroup({ name = "Minhas ações", collapsible = true, collapsed = true })`. Crie os controles com `grupo:CreateButton`, `grupo:CreateToggle`, `grupo:CreateSlider` e os outros componentes compatíveis com grupos. O cabeçalho abre e fecha pela seta; valores e callbacks dos controles permanecem nativos. Veja [como criar grupos recolhíveis](docs/EXEMPLOS.md#grupos-recolhíveis).

Na **3.13.0**, os dropdowns usam cartões em duas colunas quando há espaço, com marcação à direita e os modos **Escolha uma** e **Escolha várias**. O modo único substitui a seleção anterior e fecha; o múltiplo permite marcar/desmarcar e oferece Padrão, Limpar e Selecionar todos. O painel continua dentro da janela. O [exemplo completo](Example.luau) inclui Prioridade e Raridades para testar os dois modos.

Na **3.12.1**, os botões criados com `CreateButton` exibem uma seta de ação em um indicador à direita. Ela acompanha o tema, destaca o foco e responde ao toque. O texto reserva espaço para o indicador, inclusive em janelas pequenas e grupos de botões.

Na **3.12.0**, Configurações → **Desempenho** traz cartões expansíveis de Gráficos e Taxa de quadros. Inclui limite de FPS editável (30–360), contador de FPS/ping, três modos de gráficos reduzidos, controle da renderização 3D, cor de fundo e ocultação da interface do jogo. As funções dependentes do cliente indicam quando não estão disponíveis. Os ajustes são reversíveis e acompanham as opções de salvar/restaurar do perfil. [Funcionamento e limites](docs/DESEMPENHO.md).

Na **3.11.0**, as ações do dropdown usam botões maiores com ícones e texto em destaque. Padrão e Limpar ficam lado a lado; Selecionar todos ocupa uma linha própria. As categorias de Configurações têm ícones, superfícies com degradê e um indicador na categoria ativa. A organização muda entre uma linha, duas linhas e rolagem horizontal conforme o espaço, com respostas de foco, hover e toque.

Na **3.10.1**, a opção da lateral se chama **Navegação compacta**, com a descrição: “Exibe apenas os ícones na barra lateral, ampliando a área de conteúdo.”

Na **3.10.0**, Configurações → Aparência inclui **Navegação compacta**. A lateral pode ficar compacta mesmo em janelas grandes, e a escolha é salva no perfil ativo. `sidebarIconsOnly = true` define o padrão inicial em `CreateWindow`; `window:SetSidebarIconsOnly(true/false)` altera e salva a preferência durante a execução.

Na **3.9.3**, o cabeçalho mostra **CONEXÃO STUDIO** como um único título em negrito: as duas palavras têm o mesmo tamanho e se ajustam juntas ao espaço. O exemplo de componentes não cria a etiqueta TESTES no topo; o teste de etiquetas só cria uma ao clicar no botão correspondente.

Na **3.9.2**, o dropdown reserva uma coluna à direita **dentro da janela**. Os controles continuam à esquerda e recuperam a largura ao fechar. Janelas estreitas usam controles acima e opções abaixo, sempre dentro do painel. Busca, checkboxes e ações em lote continuam disponíveis com rolagem própria.

Na **3.9.1**, notificações exigem um título preenchido (`notificationTitle` nos controles ou `title` em `Notify`). A mensagem é opcional: vazia ou omitida, o aviso mostra apenas o título. Com `notification = false`, nenhum dos dois é necessário.

Na **3.9.0**, o dropdown abre uma lista compacta ao lado direito do campo, com checkboxes, busca e rolagem. A aba original continua visível. Se faltar espaço, a lista se reposiciona dentro da tela. Controles podem usar `notification = true` com `notificationTitle` preenchido e `notificationMessage` opcional, fixo ou uma função; `false` (padrão) dispensa a mensagem. [Exemplos](docs/EXEMPLOS.md#notificações-opcionais-nos-controles).

Na **3.8.0**, Configurações se divide em **Aparência, Temas, Salvamento e Controles**. O salvamento separa os dados pelo ID da conta Roblox e pelo projeto: escolhas dos controles, tema, transparência, tamanho, preferências da janela e presets nomeados. Outra conta começa com seus próprios valores. O compartilhamento fica desligado por padrão e cada conta precisa ativá-lo em Salvamento; a mudança vale na próxima execução. Arquivos antigos sem dono identificado são preservados e não são importados automaticamente. [Como funciona](docs/CONFIGURACOES.md).

## Executar a demonstração

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/Demo.luau"))()
```

A demo abre em **Início**, com saudação, servidor, executor e amigos, usando o tema neutro `default`. **Configurações** continua pronta na lateral, com transparência, tamanho, salvamento e temas. O cartão inferior mostra avatar, nome e executor e abre **Meu perfil**, uma página separada. A demo 3.6 salva suas preferências em `conexao_demo_studio36`.

Para testar os componentes e seus callbacks, execute o **exemplo interativo completo**:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/Components.luau"))()
```

Ele abre na aba **Testes**, com **Início** e **Configurações** no começo da lateral. Botão e toggle demonstram as notificações opcionais, e há um botão sem notificação. As abas Sliders, Dropdowns, Campos, Avisos e Dados e grupos incluem os demais componentes, entrada precisa, seleções únicas/múltiplas, cores, atalhos, popup com ações, texto dinâmico, estatística, progresso e console de eventos. Os sliders notificam na confirmação; o seletor de cor atualiza a leitura e tem um botão de notificação. No celular, um botão executa a mesma ação do atalho. As escolhas usam o perfil por conta da library. O script fica em [Example.luau](Example.luau); os controles e as ações são definidos nele.

A **3.6.1** mantém o cabeçalho de **44 px** e restaura a busca no topo. A lateral de **196 px** mostra ícones e nomes das abas, com avatar, nome do jogador e executor no rodapé. Abaixo de 480 px de largura de janela, ela se recolhe para 64 px para preservar a área dos controles. O topo usa marca, título e subtítulo na mesma linha. Nome, subtítulo e ícone continuam personalizáveis em `CreateWindow`.

Na **3.6.2**, o título Conexão Studio usa **CONEXÃO** maior e em negrito, com degradê discreto ligado ao tema, linha de assinatura e selo **STUDIO**. A versão mantém o contraste ao reabrir a janela. A marca se ajusta antes de tocar nos botões do topo; janelas com outros nomes continuam exibindo o título definido pelo script.

Na **3.7.0**, o valor do slider é editável: clique ou toque no número para digitar, confirme com Enter ou toque fora, ou use Escape para cancelar. `format = "percent"` mostra porcentagem; `format = "number"` mostra números. A entrada aceita ponto ou vírgula decimal, respeita `range` e `increment`, move a barra e passa pelo salvamento automático existente. Texto inválido preserva o valor anterior. Use `editable = false` para manter apenas o arraste. Os sliders de Configurações também recebem essa edição. A [demonstração de componentes](dist/Components.luau) inclui os dois formatos.

Na **3.7.1**, clicar no jogador da lateral abre um perfil redesenhado: capa em degradê com as cores do tema, avatar de 420 px com moldura, nome em destaque e selos com as logos do executor e do Roblox. Conta e cliente usam cartões com separadores, ID copiável e versão do executor. Em janelas estreitas, a identidade e os cartões passam para uma coluna com rolagem. O perfil continua separado do Início e o botão Voltar retorna à aba anterior. Para abrir pelo script, use `window:OpenProfile()`.

Na **3.7.2**, `Notify` e `Toast` usam cartões com superfície em degradê discreto, ícone em bloco próprio, título em negrito, botão de fechar e barra de tempo restante. As chamadas existentes continuam funcionando. `type = "info"`, `"success"`, `"warning"` ou `"error"` seleciona o indicador e a cor; sem `type`, o aviso usa a cor de destaque do tema. Passar o mouse pausa o tempo. A entrada combina deslocamento, escala e transparência; a saída recolhe o espaço do cartão. A largura e a pilha respeitam a tela, textos extensos têm rolagem interna e os avisos acompanham temas claros e escuros. A aba Avisos do [exemplo de componentes](dist/Components.luau) demonstra os estilos.

A abertura de **Conexão Studio** monta os elos da marca, faz uma passagem de luz pelo cartão e avança o indicador pelas etapas de construção da interface. O cartão sai antes da entrada da janela, que expande, revela o cabeçalho e depois o conteúdo. A entrada da janela termina em cerca de 0,76 s; ao reabrir, continua usando a restauração nativa. O cartão se ajusta à largura e à altura da tela. Fechar ou descarregar durante a sequência cancela a abertura e remove suas conexões. Os créditos da base permanecem no código e no repositório.

Na Home, servidor e salvamento ficam à esquerda; executor e amigos ficam à direita. Os cartões usam superfícies escuras e cor concentrada nos cantos, seguindo a [captura e o source da Luna](https://github.com/Nebula-Softworks/Luna-Interface-Suite). O ID da conta fica no rodapé da página. As logos acompanham os temas claros e escuros, e o avatar usa a imagem de **420 × 420 px**. Abaixo de 400 px de conteúdo, os cartões passam para uma coluna com rolagem nativa. A implementação continua sobre a base Gen2, sem carregar a Luna em tempo de execução. [Referências e licença](docs/REFERENCIAS.md).

O suporte está limitado a **Delta, Wave, Xeno e Solara**, com as quatro logos incluídas. Os demais nomes e clientes sem identificação são recusados antes da inicialização da UI. O **Roblox Studio** tem uma exceção explícita para desenvolvimento. [Política de suporte](docs/EXECUTORES.md) · [Origem das imagens](assets/README.md).

Esta seleção usa nomes conhecidos como critério de suporte. Não foram verificados números de usuários nem auditados os programas instalados. O nome é informado pelo próprio cliente e pode ser falsificado; a checagem não comprova segurança, autenticidade ou integridade do executável.

Na **3.7.3**, todas as APIs de identificação disponíveis precisam concordar com um nome permitido. Erros, respostas vazias, nomes com caracteres de controle e identificações conflitantes bloqueiam o carregamento antes da base visual e antes de cada nova janela. A política e o catálogo são imutáveis. A exceção do Studio não encobre um executor explicitamente identificado. A telemetria SIA permanece desativada, inclusive ao restaurar preferências antigas, e seu botão foi removido. Esses controles reduzem a exposição da library; não isolam nem verificam o aplicativo que a executa. [Limites e proteções](docs/SEGURANCA.md).

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

- **Início** mostra saudação, servidor, executor, amigos e salvamento. **Meu perfil**, aberto pelo cartão do jogador, mostra foto, nome, @usuário, ID, executor, versão e ambiente. São páginas independentes dentro do painel. A sessão mostra jogadores, capacidade, FPS, ping e tempo no painel. As contagens de amigos vêm das APIs do Roblox, com cache de um minuto enquanto a Home está aberta. Métricas indisponíveis aparecem como `—`.
- Página **Configurações** pronta e visível na sidebar: transparência, tamanho manual/automático, salvamento/restauração, temas com prévias, atalhos e opções nativas com nomes e descrições em português. A engrenagem continua abrindo essa mesma página.
- Dropdown divide a área interna: controles à esquerda e opções à direita, com checkboxes, busca, rolagem, Padrão, Limpar e Selecionar todos. Em janelas estreitas, a divisão é vertical. Seleção múltipla permanece aberta; escolha única, X, Escape, toque fora da janela ou outra aba encerram as opções e restauram o espaço dos controles.
- Notificações opcionais por controle: `notification = true`, `notificationTitle = "Seu título"` e `notificationMessage` opcional (texto ou função). Desligadas por padrão; callbacks e salvamento continuam funcionando.
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
| Mostrar meu perfil na lateral | Mostra ou oculta foto e nome no rodapé. |

A telemetria de uso da base fica desativada e não possui opção de ativação na UI. Preferências antigas não reativam a coleta.

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
        shareAcrossAccounts = false, -- padrão inicial; a escolha lembrada da conta prevalece
    },
})
```

O formato é JSON com extensão `.rfld`. O diretório padrão é `ConexaoUI/Configurations/Accounts/<UserId>/<projeto>/`; o perfil compartilhado usa `ConexaoUI/Configurations/Shared/<projeto>/`. Sem `fileName`, o projeto é derivado do Id/nome da janela e `game.PlaceId`. Mantenha esses identificadores estáveis. As preferências nativas usam o mesmo namespace sob `ConexaoUI/Settings/`. Tema, transparência, tamanho, modo de ícones da lateral e opções de salvamento/restauração ficam ao lado da configuração em `<nome>.rfld.ui.json`. A escolha individual de compartilhar fica em um arquivo `.scope.json` dentro da pasta privada da conta, mesmo quando o perfil ativo é compartilhado. A restauração inicial acontece quando a janela aparece; controles acrescentados depois também recebem seus valores salvos, e seus callbacks são chamados com os valores restaurados.

As APIs de arquivo dependem do ambiente. No Studio, a base usa armazenamento simulado na sessão; LocalScripts normais não gravam arquivos no PC. A página informa se o armazenamento é da sessão, do dispositivo ou está indisponível, além de mostrar falhas ao salvar. `window:Save()` e `window:Load()` retornam sucesso/falha. Para desativar a automação, use os toggles nas configurações ou informe `configuration = { autoSave = false, autoLoad = false }`. Uma opção explícita no script prevalece sobre a preferência lembrada desses dois toggles.

## Painel inicial e logos adicionais

`OpenHome()` abre o painel de sessão; `OpenProfile()` abre a página do jogador. A amostragem de FPS e tempo é encerrada ao destruir a janela; dados de rede ficam protegidos contra APIs ausentes. A UI não deduz região de servidor a partir do país do jogador e não anuncia compatibilidade de recursos a partir do nome do executor.

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
