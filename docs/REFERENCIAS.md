# Referência visual da Home 3.6

A composição segue a segunda captura da Luna fornecida pelo usuário: barra lateral de ícones, cabeçalho baixo, avatar separado da saudação, servidor à esquerda e cliente/amigos à direita. O cartão inferior esquerdo informa o estado do salvamento da Conexão.

Na revisão 3.6.1, a lateral volta a mostrar nomes quando há espaço e a busca retorna ao topo, conforme o pedido posterior do usuário. O cartão do jogador abre uma página de perfil independente da Home.

Foram consultados o [source da Luna Interface Suite](https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua), especialmente `CreateWindow` e `CreateHomeTab`, e a [documentação](https://github.com/Nebula-Softworks/Luna-Interface-Suite/blob/main/Documentation.md). O source lido tem SHA-256 `621c6e442cfc6fe609e928ac26d385cb9ea7f2e0ed63bc0d45e153356d6caf5a`.

O source carrega parte da interface de um asset Roblox (`86467455075715`). A tentativa de leitura desse asset neste ambiente retornou HTTP 401; as proporções foram reconstruídas a partir da captura, sem importar ou executar esse asset. Não foi obtida uma captura do cliente Roblox neste ambiente.

O código da Conexão usa seus próprios GuiObjects e a base Gen2 já incluída no repositório. Paginação de amigos, tratamento de erros, cache e limpeza pertencem ao ciclo de vida da janela. Nomes e contagens indisponíveis não são inventados.

Luna Interface Suite: Copyright (c) 2024 Nebula Softworks. A licença [BSD 3-Clause](../licenses/Luna-BSD-3-Clause.txt) está incluída com os créditos. Isso não implica endosso por seus autores.
