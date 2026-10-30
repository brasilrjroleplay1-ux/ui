# Proteções e limites

A Conexão UI aplica uma lista explícita de suporte: Delta, Wave, Xeno e Solara. Isso não é uma certificação de segurança desses aplicativos. Um executor controla a execução do Luau e pode falsificar seu nome, interceptar APIs ou alterar o código; uma biblioteca executada dentro dele não consegue isolá-lo nem verificar a integridade do programa instalado.

## Admissão

O carregamento verifica a identificação antes de importar a base visual, e cada `CreateWindow` verifica novamente antes de carregar preferências. Todas as funções de identificação disponíveis precisam informar o mesmo nome permitido. Erros, respostas inválidas, conflitos, caracteres de controle e nomes fora da lista causam recusa. O código não tenta contornar a recusa por meio de outro nome. A exceção para desenvolvimento no Studio só se aplica sem APIs de executor presentes.

O catálogo e as regras compiladas são imutáveis para evitar alterações acidentais por outros scripts. A cópia pública `SupportedExecutors` e o registro de imagens não concedem acesso. Essas proteções não constituem uma fronteira contra um host que modifica a própria execução.

## Privacidade

O coletor opcional SIA da base fica desativado antes da construção da janela. Preferências antigas com `usageAnalytics = true` não reativam a coleta; carregar e salvar essas preferências força a opção para `false`. A UI não oferece um botão para ativar essa telemetria. A implementação preserva as preferências globais de outras libraries.

Isso não desativa toda a comunicação da interface. Avatares, fontes e imagens Roblox podem precisar de downloads; a Home consulta informações de amigos pelo Roblox. Um script consumidor também pode habilitar explicitamente o heartbeat da API Gen2 para seu próprio endereço. As logos de executores acompanham o bundle e não precisam ser baixadas.

## Arquivos e código carregado

O salvamento automático grava configurações e preferências no diretório `ConexaoUI`. A base sanitiza os nomes de arquivo e subpastas antes de montar os caminhos. Cache de imagens e fontes também usa o diretório da library. Isso organiza os acessos da Conexão, sem restringir o acesso que o executor ou o script consumidor já tem ao dispositivo.

O bundle contém a base e as extensões em código legível; a UI não baixa outra library Luau para montá-las. Os módulos do vendor são fixados em um commit e verificados por hash, com as alterações documentadas em `FORK.md`. Para reproduzir uma versão publicada, use o endereço raw de um commit específico. O carregamento inicial com `loadstring(game:HttpGet(...))` ainda depende da rede e do executor.

## Validação

Os testes executam a política, o bundle e as preferências em serviços Roblox simulados. Eles verificam recusa antes da inicialização, consenso de identificação, imutabilidade das regras, bloqueio de opt-in antigo e limpeza da janela. Não são uma auditoria dos executores nem uma garantia de ausência de malware no cliente.
