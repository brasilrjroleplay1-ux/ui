# Visual 2.0

As imagens abaixo são **prévias técnicas aproximadas**, geradas a partir das propriedades de GUI da distribuição Luau. Não são capturas do Roblox. A fonte é substituta, o avatar é ilustrativo e o fundo é artificial. Gradientes, métricas de texto, imagens, rolagem e toque precisam ser conferidos no cliente real.

## Dashboard automático

`CreateWindow` fornece o perfil, as ações rápidas e os cards de estado. No Roblox, o avatar e os nomes vêm do jogador; o executor só é identificado quando o ambiente fornece essa informação.

![Prévia aproximada do Dashboard](previews/home.png)

## Componentes criados pelo script

Cards escuros com uma borda, títulos compactos, separadores discretos e botões com contorno. Switches mostram a cápsula dourada e o marcador azul claro, sem uma segunda caixa externa. Sliders usam trilho fino; cores aparecem em uma amostra pequena com hexadecimal. Os controles de exemplo da imagem pertencem ao script de prévia.

![Prévia aproximada dos controles](previews/controls.png)

```luau
local tab = window:CreateTab({Name = "Principal", Icon = "star"})
local group = tab:CreateGroup({Name = "RECURSOS", Icon = "bolt"})
group:CreateButton({
    Name = "Mostrar notificação", Text = "Mostrar", Icon = "info",
    Callback = function() window:Notify({Content = "Olá!"}) end,
})
group:CreateToggle({Name = "Ativar recurso", Default = true})
```

Use `Variant = "Primary"` para uma ação preenchida. Os botões comuns e `Secondary` mantêm o fundo neutro. `Destructive` usa texto e contorno vermelhos.

## Configurações e perfis nativos

Seleção, ativação e salvamento ficam no card Configuração. Criação, exclusão, restauração e importação/exportação ficam no card Perfis. O campo JSON continua editável e selecionável para copiar seu conteúdo.

![Prévia aproximada dos perfis](previews/profiles.png)

## Tela pequena

As colunas passam a uma; sliders e campos largos vão para baixo do rótulo. A página rola para acessar o restante dos controles. O tamanho inicial evita ocupar monitores grandes inteiros, e o slider nativo permite ajustá-lo até 100% da área disponível.

![Prévia aproximada das configurações no celular](previews/mobile-settings.png)

## Gerar novas prévias

Instale Pillow no ambiente de desenvolvimento e tenha o Luau CLI disponível. O script não usa navegador nem baixa imagens:

```sh
python3 tools/bundle.py
python3 tools/render_preview.py --page home --luau /workspace/tools/luau/luau --output /tmp/conexao-home
python3 tools/render_preview.py --page controls --luau /workspace/tools/luau/luau --output /tmp/conexao-controls
python3 tools/render_preview.py --page profiles --luau /workspace/tools/luau/luau --output /tmp/conexao-profiles
python3 tools/render_preview.py --page settings --width 390 --height 844 --luau /workspace/tools/luau/luau --output /tmp/conexao-mobile
```

Cada chamada produz `.json`, `.html` e `.png`. O renderizador compartilha o host dos testes de geometria e serve para encontrar problemas de proporção e sobreposição; ele não substitui a execução da demo no Roblox.
