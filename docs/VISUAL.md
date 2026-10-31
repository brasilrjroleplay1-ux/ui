# Revisão visual · 3.15.0

A revisão combina a organização das referências Venyx/Luna com destaques mais vivos. As cores têm funções diferentes: a janela fica no fundo, os cartões delimitam o conteúdo e a cor de destaque identifica seleção e ações.

- **Janela e navegação:** cabeçalho com mais espaço, fundos próprios para o topo e a lateral, abas mais legíveis e um marcador na aba selecionada. Navegação compacta continua disponível.
- **Cartões e controles:** bordas mais discretas, ações com preenchimento próprio, títulos em destaque e mais espaço entre controles. Textos de apoio usam uma cor legível, em vez de depender de transparência elevada.
- **Switches e sliders:** botão circular, estados ativo/inativo mais claros, transições curtas e trilho mais fino no slider. O campo numérico com lápis continua à direita quando há espaço.
- **Início e perfil:** saudação com fundo colorido, valores da sessão mais visíveis e cartão do jogador com destaque ao passar o mouse. Conta e executor continuam em uma página própria.
- **Notificações:** faixa lateral na cor do tipo, corpo de texto maior, ícone e botão de fechar mais visíveis. Duração, pausa por hover e rolagem continuam funcionando.

As mudanças são aplicadas automaticamente em `CreateWindow`, nas Configurações prontas e nos controles criados depois, inclusive em grupos. Não é necessário mudar os callbacks do seu script. Os valores e arquivos de configuração mantêm o funcionamento anterior.

Os [60 temas](TEMAS.md) mantêm suas identidades e continuam incluindo opções claras, escuras e neon. As prévias da galeria usam as cores atualizadas. A transparência configurada também vale para os novos fundos do cabeçalho e da navegação. Temas personalizados e trocas por código continuam aceitos.

Os testes usam os bundles distribuídos e serviços Roblox simulados para conferir contraste das paletas, posicionamento, seleção, edição, configuração por conta e limpeza de instâncias. A aparência final depende da renderização do cliente Roblox; imagens de inspeção fora dele são simulações, não capturas do jogo.
