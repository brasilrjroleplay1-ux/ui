# Base oficial Gen2

Conexão UI 3.3 utiliza [SiriusSoftwareLtd/rayfield-gen2](https://github.com/SiriusSoftwareLtd/rayfield-gen2/tree/576c1ff19448285f9506b50bee221977aef3ffbb), versão 1.2.1, commit `576c1ff19448285f9506b50bee221977aef3ffbb`.

Os componentes e os seis temas são os arquivos dessa base. A construção visual de `components/window.luau` foi preservada; a alteração nesse arquivo é o valor inicial de analytics. O diretório de arquivos e o nome do arquivo de preferências também foram separados para a Conexão. As alterações estão registradas em [UPSTREAM.json](../vendor/rayfield-gen2/UPSTREAM.json).

A camada da Conexão adiciona configurações automáticas e limpeza entre reexecuções. Em 3.1, [ConexaoUI/Features](../ConexaoUI/Features) acrescenta uma apresentação própria para o dropdown aberto, perfil clicável, preferências por janela e seis temas novos com prévias feitas de GuiObjects. O estado, os callbacks e a serialização dos controles continuam pertencendo ao Gen2. Essas extensões preservam os arquivos de componentes do vendor.

O visual final pode variar se o cliente não conseguir carregar os assets e as fontes utilizados pela base. Não foi produzida uma captura do cliente Roblox neste ambiente.

Em 3.1.1, `Features/Responsive.luau` amplia o ajuste automático: aproveita a altura em celulares na vertical, usa o viewport da interface quando a câmera ainda não está pronta e atualiza o cartão de tamanho nas configurações. A coordenação com janelas ocultas/minimizadas mantém o comportamento de abertura do Gen2.

Em 3.1.2, o perfil passa a usar uma página nativa dentro de `window.elements`, com a mesma rolagem e navegação das demais páginas. O clique no avatar reutiliza essa página, e Voltar retorna à aba anterior. Essa mudança é implementada em `Features/Profile.luau`.

Em 3.2, as configurações ficam visíveis no seletor de abas. Transparência e tamanho passam a ter controles próprios e persistência em `.ui.json`. O seletor de dropdown e a galeria de temas usam páginas temporárias na área de conteúdo. O cartão do jogador recebe um alvo de clique acima da imagem/texto, e o perfil mostra apenas os dados de conta e executor. A demo principal abre as configurações; os exemplos completos ficam em `Components.client.luau` e `Example.luau`.

Em 3.3, `Features/ProfileDashboard.luau` fornece a apresentação do perfil: banner com gradiente ligado ao tema, composição de avatar/nome/badges, cartões responsivos e atalhos. O botão Copiar usa a API de clipboard disponível no cliente; se ela não existir, informa isso no próprio perfil. A página é reutilizada entre aberturas e continua pertencendo à navegação nativa do painel.

Em 3.3.1, `Features/Scrolling.luau` mede o canvas das páginas e seletores, limita o scroll após mudanças de tamanho e revalida os layouts depois das animações. O slider de tamanho mantém apenas uma prévia durante o arraste e aplica/salva ao soltar. `Features/Startup.luau` fornece a abertura Conexão Studio; `src/init.luau` do vendor recebe um callback opcional, registrado em `UPSTREAM.json`, para preservar o restante do ciclo de criação.

Em 3.3.2, o ajuste automático também atualiza o valor e o indicador do slider. A sincronização usa `Set(value, true)`, preserva o modo automático e não sobrescreve o último tamanho manual salvo. O percentual segue a dimensão principal do layout na escala compacto–espaço disponível.

Consulte [NOTICE.md](../NOTICE.md) e [LICENSE](../LICENSE) para créditos e licença MPL-2.0. O arquivo de distribuição contém os avisos de copyright e o código legível.
