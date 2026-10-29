# Base oficial Gen2

Conexão UI 3.1 utiliza [SiriusSoftwareLtd/rayfield-gen2](https://github.com/SiriusSoftwareLtd/rayfield-gen2/tree/576c1ff19448285f9506b50bee221977aef3ffbb), versão 1.2.1, commit `576c1ff19448285f9506b50bee221977aef3ffbb`.

Os componentes e os seis temas são os arquivos dessa base. A construção visual de `components/window.luau` foi preservada; a alteração nesse arquivo é o valor inicial de analytics. O diretório de arquivos e o nome do arquivo de preferências também foram separados para a Conexão. As alterações estão registradas em [UPSTREAM.json](../vendor/rayfield-gen2/UPSTREAM.json).

A camada da Conexão adiciona configurações automáticas e limpeza entre reexecuções. Em 3.1, [ConexaoUI/Features](../ConexaoUI/Features) acrescenta uma apresentação própria para o dropdown aberto, perfil clicável, preferências por janela e seis temas novos com prévias feitas de GuiObjects. O estado, os callbacks e a serialização dos controles continuam pertencendo ao Gen2. Os arquivos do vendor não foram alterados para instalar essas extensões.

O visual final pode variar se o cliente não conseguir carregar os assets e as fontes utilizados pela base. Não foi produzida uma captura do cliente Roblox neste ambiente.

Consulte [NOTICE.md](../NOTICE.md) e [LICENSE](../LICENSE) para créditos e licença MPL-2.0. O arquivo de distribuição contém os avisos de copyright e o código legível.
