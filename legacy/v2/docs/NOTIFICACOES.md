# Notificações, toasts e popups da Conexão UI

Estes recursos são implementados pela nossa library e usam o mesmo tema escuro, cards arredondados, bordas finas e cores de destaque da interface. Não precisam ser recriados em cada script.

Crie sua janela antes dos exemplos:

```luau
local ConexaoUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/ConexaoUI.luau"
))()
local Window = ConexaoUI:CreateWindow({Title = "Meu Hub"})
```

No Studio, use o ModuleScript em vez de `loadstring`, conforme o [guia de instalação](../README.md#roblox-studio).

## Notificação completa

```luau
local notice = Window:Notify({
    Title = "Perfil salvo",
    Content = "Suas escolhas foram salvas.",
    Kind = "Success",
    Duration = 6,
    PauseOnHover = true,
    Actions = {{
        Name = "Abrir configurações",
        Callback = function(handle)
            Window:SelectTab(Window.SettingsTab)
        end,
    }},
    OnClose = function(reason)
        print("Aviso encerrado:", reason)
    end,
})
```

| Propriedade | Função |
| --- | --- |
| `Title` | Título; padrão `Conexão UI`. |
| `Content` | Mensagem com quebra de linha e altura automática. |
| `Kind` | `Info`, `Success`, `Warning` ou `Error`; ajusta ícone e destaque. |
| `Icon` | Ícone personalizado: nome local, símbolo ou ID de imagem. |
| `Duration` | Segundos visíveis; padrão 5. `0` mantém até fechar. |
| `PauseOnHover` | Pausa a contagem enquanto o mouse está no card; padrão `true`. |
| `Actions` | Até cinco botões `{Name, Callback, Close}`. |
| `OnClose` | Recebe `timeout`, `dismiss`, `action` ou `destroy`. |

O card tem botão ×, animações de entrada/saída e barra de duração. O tempo só começa quando o aviso aparece, não enquanto aguarda na fila. Erros de callbacks são tratados com `pcall` e enviados ao console.

`Close = false` mantém o aviso após uma ação. Seu callback recebe o próprio controle:

```luau
Window:Notify({
    Title = "Aviso persistente",
    Content = "Você pode atualizar este aviso.",
    Duration = 0,
    Actions = {{
        Name = "Atualizar",
        Close = false,
        Callback = function(handle)
            handle:Update({Content = "Atualizado!", Kind = "Success"})
        end,
    }},
})
```

## Atualização e ciclo de vida

```luau
notice:SetValue("Nova mensagem")
notice:Update({Title = "Novo título", Kind = "Warning", Duration = 8})
notice:Pause()
notice:Resume()
-- notice:Close()    -- Fechamento manual, reason = dismiss.
-- notice:Destroy()  -- Fechamento pelo autor, reason = destroy.
```

`Update` aceita os campos da criação; atualizar `Duration` reinicia a duração. Atualizações após fechar retornam `false`. `State` indica `Queued`, `Visible`, `Closing` ou `Closed`. `OnClose` executa uma única vez. Destruir a janela limpa os avisos e os temporizadores sem executar callbacks do aplicativo.

## Fila e celular

```luau
local Window = ConexaoUI:CreateWindow({
    Title = "Meu Hub",
    Notifications = {
        MaxVisible = 3,
        MaxQueue = 50,
        Width = 360,
    },
})
```

No desktop, até três avisos aparecem por padrão. Em telas abaixo de 600 px de largura ou altura, um aviso fica visível e os demais aguardam; avisos excedentes voltam à fila ao reduzir a tela. Mensagens longas e ações ficam acessíveis pela rolagem da área de notificações.

`MaxVisible` aceita 1–5; `MaxQueue`, 1–200. Uma fila cheia rejeita novas notificações com um erro explícito. `Width` é limitado ao espaço da tela. As notificações são temporárias e não são gravadas nos perfis.

## Toast

```luau
Window:Toast({
    Title = "Atenção",
    Content = "Confira suas preferências.",
    Kind = "Warning",
    Duration = 4,
})
```

`Toast` é um nome alternativo para o mesmo sistema de notificações, com a mesma fila e os mesmos recursos.

## Popup com várias escolhas

```luau
local popup = Window:Popup({
    Title = "O que deseja abrir?",
    Content = "Escolha uma opção para continuar.",
    Cancellable = true,
    DismissOnOutside = false,
    Options = {
        {Name = "Configurações", Value = "settings"},
        {Name = "Principal", Value = "home"},
        {Name = "Cancelar", Value = false, Variant = "Secondary"},
    },
    Callback = function(value)
        if value == "settings" then
            Window:SelectTab(Window.SettingsTab)
        end
        -- Cancelamento por ×, Esc ou Cancel() entrega nil.
        -- A opção acima chamada Cancelar entrega false, pois esse é seu Value.
    end,
})
```

O popup bloqueia cliques e atalhos da library ao fundo, usa uma área rolável para conteúdo/opções e se limita ao tamanho da tela. Aceita de 1 a 10 opções; se omitidas, cria o botão Fechar. Uma opção sem `Value` entrega seu índice, e pode ter seu próprio `Callback(value)` além do callback geral.

`Variant` de opção pode ser `Primary`, `Secondary` ou `Destructive`. O padrão usa fundo neutro; `Primary` recebe preenchimento de destaque. Os popups são exibidos um por vez, com até 20 aguardando. Ao abrir um popup, um dropdown aberto é fechado.

```luau
popup:Update({Title = "Outro título", Content = "Outro texto"})
popup:SetValue("Atualizar apenas a mensagem")
popup:SetOptions({{Name = "Entendi", Value = true}})
-- popup:Cancel()
-- popup:Destroy()
```

`State` indica `Queued`, `Visible` ou `Closed`. `Cancellable = false` esconde o × e ignora Esc/clique externo; uma opção ou o autor do script ainda pode encerrá-lo. Destruir a janela limpa popups ativos e aguardando sem chamar callbacks.

## Confirmação

```luau
Window:Confirm({
    Title = "Restaurar aparência",
    Content = "Deseja restaurar os padrões?",
    ConfirmText = "Restaurar",
    CancelText = "Voltar",
    Destructive = true,
    Callback = function(confirmed)
        print("Confirmado:", confirmed)
    end,
})
```

`Confirm` usa o mesmo sistema de popup, mas seu callback sempre recebe booleano: `true` ao confirmar e `false` ao cancelar. As chamadas de versões anteriores continuam válidas.

## Exemplo e validação

O [Example.luau](../Example.luau) e a [demo](../dist/Demo.luau) incluem uma aba **Avisos e popups** com botões funcionais para experimentar esses recursos.

Os testes executam os módulos reais em Luau com GUI, relógio e tweens simulados. Cobrem fila, temporizadores, pausa, atualização, ações, erros, redimensionamento, cancelamento e limpeza. Não substituem testes visuais e de toque em Roblox Studio ou no cliente real.
