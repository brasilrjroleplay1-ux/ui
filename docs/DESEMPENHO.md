# Desempenho · 3.12.0

Abra Configurações → Desempenho, ou use `window:OpenSettings("performance")`. Clique no cabeçalho/seta de Gráficos ou Taxa de quadros para expandir e recolher o cartão. A disposição usa duas colunas quando há espaço e uma coluna em janelas estreitas.

| Controle | Comportamento |
| --- | --- |
| Limite de FPS | Envia de 30 a 360 FPS ao executor ao confirmar o slider ou digitar o valor. Não muda a cada movimento do arraste. |
| Mostrar FPS e ping | Exibe um contador no topo, com quadros medidos e ping disponível no cliente. Pode continuar visível com a janela oculta. |
| Gráficos reduzidos | Aplica o modo selecionado apenas no cliente. Desligar restaura as propriedades alteradas. |
| Modo Leve | Reduz a qualidade salva do cliente, desativa sombras globais e pós-processamento. |
| Modo Equilibrado | Acrescenta a redução de reflexos/iluminação ambiental, animação da água e efeitos de partículas, trilhas e feixes. |
| Modo Máximo | Acrescenta remoção visual de decals/texturas, sombras e reflexos de partes. Nenhuma instância é destruída. |
| Desativar renderização 3D | Usa `RunService:Set3dRenderingEnabled` quando permitido. A interface 2D da library continua acessível. |
| Cor de fundo | Seleciona Preto, Grafite ou Branco para o fundo exibido enquanto o 3D estiver desligado. |
| Ocultar interface do jogo | Oculta ScreenGuis de PlayerGui e observa novas interfaces/reaberturas; preserva a library. Não altera CoreGui. |
| Restaurar desempenho | Libera os ajustes ativos, restaura os valores capturados e atualiza os controles. |

O limite de FPS precisa de `setfpscap` ou `set_fps_cap`. A library não instala essas funções e não simula suporte: o slider fica bloqueado se a função não existir e volta ao valor anterior se o executor recusar a operação. Um limite maior não garante mais quadros; o desempenho depende do aparelho e do jogo. Para restaurar, usa `getfpscap`/`get_fps_cap` quando disponível; sem leitura do limite original, o retorno é 60 FPS. Abrir ou salvar uma janela sem mexer no slider não configura um limite automaticamente.

A renderização 3D também depende da permissão do cliente. Ao desligar a função ou descarregar a janela, a library restaura o estado capturado; quando o cliente não oferece leitura desse estado, volta à renderização ativa.

A otimização processa até 120 objetos por Heartbeat, com um orçamento de tempo, e acompanha novos descendentes. Ela não remove partes do mundo nem altera CanCollide ou o material físico. Os valores originais são guardados em memória e restaurados somente se ainda corresponderem ao valor aplicado pela library, preservando alterações posteriores do jogo. Objetos destruídos são ignorados. Desligar Gráficos reduzidos restaura os efeitos imediatamente; sair durante um lote também restaura o que já foi processado.

As escolhas e a expansão dos cartões são salvas no perfil por conta/projeto quando o salvamento automático estiver ligado. Salvar agora também captura esses ajustes. Com carregamento automático desligado, os efeitos não são reaplicados ao abrir. Um novo perfil começa sem otimização, ocultação ou renderização desativada. O modo compartilhado segue as mesmas regras das demais configurações.

Os ajustes globais do cliente têm um dono por instância da library: se outra janela assumir um ajuste, a janela anterior libera seus efeitos e sincroniza os controles. Descarregar a janela cancela a fila e restaura qualidade, interface, renderização e limite de FPS que ela assumiu.
