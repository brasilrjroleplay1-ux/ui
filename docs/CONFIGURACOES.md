# Configurações por conta · 3.8.0

A separação já vem ativada em `CreateWindow`. A library usa o ID de `Players.LocalPlayer`, não o nome de usuário. A mesma conta continua com seus dados se mudar de nome. Sem uma identificação de conta válida, a janela não escolhe um diretório genérico.

## Categorias

| Categoria | Conteúdo |
| --- | --- |
| Aparência | Transparência, ajuste automático, tamanho manual e tamanho atual. |
| Temas | Prévias das paletas e acesso à galeria completa. |
| Salvamento | Perfil atual, compartilhamento, salvar/restaurar automaticamente e presets nomeados. |
| Controles | Atalho da janela, cursor, boas-vindas, vibração e opções da lateral. |

A barra de categorias permite rolagem horizontal no celular e mantém a opção selecionada visível. Trocar a categoria não reaplica os callbacks dos controles do script.

## Individual por padrão

Cada conta tem suas próprias escolhas de toggle, slider, dropdown, input e demais controles persistentes. Tema, transparência, tamanho, salvamento/restauração e preferências nativas da janela também ficam separados. A lista de presets mostra apenas os arquivos do perfil ativo.

Por exemplo, A salva intensidade 80 e duas opções no dropdown. B abre o mesmo script e recebe os valores iniciais definidos pelo autor. B salva intensidade 20. Quando A executar novamente, continua com 80 e suas duas opções; B continua com 20.

O nome do arquivo e a subpasta do projeto participam do namespace. Mantenha `Id`, `fileName` e `customFolder` estáveis para reencontrar os mesmos dados. O nome padrão do arquivo inclui `game.PlaceId`.

## Compartilhar entre contas

1. Abra Configurações → Salvamento.
2. Ative Compartilhar entre contas na conta desejada.
3. Execute o script novamente para usar o perfil compartilhado.
4. Ative a opção e execute novamente também nas outras contas que devem participar.

A escolha pertence a cada conta. A ativar não muda a preferência de B. Um perfil compartilhado novo começa com os valores iniciais do script; os dados individuais não são copiados automaticamente. Depois de salvar no compartilhado, as demais contas participantes carregam esse mesmo perfil no dispositivo.

Desligar a opção e executar novamente retorna ao perfil individual preservado. Até a nova execução, a janela continua lendo e gravando no perfil que abriu; a página informa o modo atual e a troca pendente. Uma falha ao salvar a opção não ativa o compartilhamento.

O script pode definir `configuration.shareAcrossAccounts = true` como padrão inicial. A opção já lembrada da conta tem prioridade. `window:SetSharedConfiguration(boolean)` salva a mesma preferência e retorna sucesso/falha; `window.ConfigurationScope.shared` informa o modo ativo e `nextShared` informa o próximo.

## Arquivos antigos e local de gravação

Arquivos de versões anteriores não registravam o dono. Eles permanecem preservados, mas não são importados automaticamente: adotar esses valores na primeira conta que executar poderia misturar dados de outra pessoa. Na primeira execução da 3.8.0, uma conta sem perfil próprio começa com os valores do script.

Arquivos individuais ficam sob `ConexaoUI/Configurations/Accounts/<UserId>/<projeto>/`; os compartilhados ficam sob `ConexaoUI/Configurations/Shared/<projeto>/`. O projeto inclui a subpasta e o nome de arquivo configurados pelo script. As preferências nativas usam o namespace equivalente sob `ConexaoUI/Settings/`.

As preferências visuais ficam em `.rfld.ui.json`, ao lado da configuração. O consentimento de compartilhar fica no `.scope.json` da pasta individual. Arquivos temporários não confirmados não ativam o compartilhamento.

O cache de imagens/fontes continua comum, pois não contém escolhas dos controles. No Studio, arquivos são simulados na sessão; gravar no dispositivo exige as APIs de arquivo do executor. Essa organização não restringe o acesso do próprio executor ao disco e não sincroniza dados entre dispositivos.
