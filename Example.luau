-- Teste completo da Conexão UI 3.9. Os controles deste arquivo pertencem ao script.
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/brasilrjroleplay1-ux/ui/main/dist/ConexaoUI.luau"))()
local window = UI:CreateWindow({
    Id = "ConexaoDemo3", -- substitui a janela da demo inicial ao executar este exemplo
    name = "CONEXÃO STUDIO", subtitle = UI.Version, sidebarLayout = true,
    theme = "conexao",
    configuration = { fileName = "conexao_componentes_v3" },
})

-- Cada variável representa a aba que receberá os controles.
local testes = window:CreateTab({ name = "Testes", icon = 93364949241311 })
local sliders = window:CreateTab({ name = "Sliders", icon = 129180860773723 })
local dropdowns = window:CreateTab({ name = "Dropdowns", icon = 88479147175134 })
local campos = window:CreateTab({ name = "Campos", icon = 100604009889706 })
local avisos = window:CreateTab({ name = "Avisos", icon = 125823673784681 })
local dados = window:CreateTab({ name = "Dados e grupos", icon = 84750991656135 })
local selo -- etiquetas do topo só aparecem se o script criar uma explicitamente

-- Os mostradores existem antes dos callbacks, inclusive durante a restauração dos valores.
testes:CreateText({ name = "Teste sua library", text = "Clique no botão, mude o toggle e explore as abas. As ações aparecem em notificações e no console de Dados e grupos." })
local ultimaAcao = testes:CreateText({ name = "Última ação", text = "Aguardando seu primeiro teste." })
local contador = testes:CreateStat({ name = "Interações nesta execução", value = 0 })
local paragrafo = dados:CreateText({ name = "Texto dinâmico", text = "O conteúdo deste cartão pode ser atualizado pelo script com :Set()." })
local progresso = dados:CreateProgress({ name = "Progresso da porcentagem", range = { 0, 100 }, value = 50 })
local etapas = dados:CreateProgress({ name = "Progresso em etapas", range = { 0, 100 }, value = 0, steps = 5 })
local estatistica = dados:CreateStat({ name = "Valor escolhido no slider", value = 50, suffix = "%" })
local console = dados:CreateConsole({ name = "Eventos dos callbacks", height = 160, text = "Pronto para testar.", maxLines = 60 })
local pronto, interacoes, ultimoAviso = false, 0, nil

local function registrar(titulo, detalhe)
    -- Restaurar uma configuração aplica os valores, mas não gera uma pilha de avisos de teste.
    if not pronto or window.unloaded or window._loading then return false end
    local fim = utf8.offset(detalhe, 161)
    local resumo = fim and (detalhe:sub(1, fim - 1) .. "…") or detalhe
    interacoes += 1
    contador:Set(interacoes)
    ultimaAcao:SetTitle(titulo)
    ultimaAcao:Set(resumo)
    console:Append("[" .. titulo .. "] " .. resumo)
    return true
end
local function notificar(titulo, detalhe, tipo)
    if registrar(titulo, detalhe) then
        ultimoAviso = window:Notify({ title = titulo, content = detalhe, type = tipo or "info", duration = 4 })
    end
end
local function textoDaSelecao(valores)
    if type(valores) ~= "table" then return tostring(valores) end
    return #valores == 0 and "Nenhuma opção selecionada" or table.concat(valores, ", ")
end

-- BOTÃO E TOGGLE: callback é onde o seu script executa a ação desejada.
local secaoTestes = testes:CreateSection({ name = "Botão e toggle" })
local botao = testes:CreateButton({
    name = "Testar botão", icon = 125823673784681,
    notification = true,
    notificationTitle = "Botão clicado", notificationType = "success",
    notificationMessage = "O callback do botão foi executado.",
    callback = function() registrar("Botão clicado", "O callback do botão foi executado.") end,
})
local ativacao = testes:CreateToggle({
    name = "Toggle com notificação", flag = "demo/ativo", value = false,
    notification = true, notificationTitle = "Toggle alterado",
    notificationMessage = function(ativo) return ativo and "Você ativou o toggle." or "Você desativou o toggle." end,
    callback = function(ativo) registrar("Toggle alterado", ativo and "Você ativou o toggle." or "Você desativou o toggle.") end,
})
-- Mensagem vazia é válida: este botão mostra apenas o título.
testes:CreateButton({ name = "Notificação só com título", notification = true,
    notificationTitle = "Ação concluída", notificationMessage = "",
    callback = function() registrar("Ação concluída", "Aviso apenas com título.") end,
})
-- false dispensa título e mensagem; o callback continua funcionando normalmente.
testes:CreateButton({ name = "Botão sem notificação", notification = false,
    callback = function() registrar("Sem notificação", "O callback foi executado sem criar um aviso.") end,
})
testes:CreateToggle({
    name = "Bloquear o botão de teste", value = false, forgetState = true,
    description = "Demonstra Lock e Unlock. Desative para liberar o botão novamente.",
    callback = function(bloqueado)
        if bloqueado then botao:Lock("Desative o bloqueio abaixo para testar o botão.") else botao:Unlock() end
        notificar("Bloqueio do botão", bloqueado and "O botão foi bloqueado." or "O botão foi liberado.")
    end,
})
testes:CreateButton({ name = "Zerar contador de interações", callback = function()
    interacoes = 0
    contador:Set(0)
    ultimaAcao:SetTitle("Contador zerado")
    ultimaAcao:Set("Faça outro teste para contar novas interações.")
    console:Append("[Contador] Zerado.")
    window:Toast({ title = "Contador zerado", type = "success" })
end })
testes:CreateButton({ name = "Salvar escolhas agora", callback = function()
    local ok = window:Save()
    notificar("Salvamento", ok and "Escolhas salvas no perfil ativo." or "Não foi possível salvar neste cliente.", ok and "success" or "error")
end })
testes:CreateButton({ name = "Carregar escolhas salvas", callback = function()
    local ok = window:Load()
    notificar("Restauração", ok and "As escolhas salvas foram aplicadas." or "Não foi possível carregar uma configuração.", ok and "success" or "warning")
end })

-- SLIDERS: atualize mostradores durante o movimento; notifique apenas na confirmação.
sliders:CreateText({ name = "Arraste ou digite", text = "Nos sliders editáveis, toque no valor e digite. Enter ou tocar fora confirma; Escape cancela. Mínimo, máximo e incremento continuam valendo." })
sliders:CreateSlider({
    name = "Porcentagem editável", flag = "demo/intensidade", range = { 0, 100 }, increment = 0.25, value = 50, format = "percent",
    callback = function(valor, arrastando)
        progresso:Set(valor)
        estatistica:Set(valor)
        if not arrastando then notificar("Porcentagem confirmada", string.format("Valor: %.2f%%", valor)) end
    end,
})
sliders:CreateSlider({
    name = "Número com precisão", flag = "demo/precisao", range = { -100, 1000 }, increment = 0.01, value = 25.5, format = "number",
    callback = function(valor, arrastando)
        if not arrastando then notificar("Número confirmado", string.format("Valor: %.2f", valor)) end
    end,
})
sliders:CreateSlider({
    name = "Número inteiro", flag = "demo/inteiro", range = { 0, 10 }, increment = 1, value = 3, format = "number",
    callback = function(valor, arrastando) if not arrastando then notificar("Inteiro confirmado", tostring(valor)) end end,
})
sliders:CreateSlider({
    name = "Somente arraste", flag = "demo/arraste", range = { 0, 100 }, value = 30, editable = false,
    description = "editable = false mantém o arraste e desativa a digitação.",
    callback = function(valor, arrastando) if not arrastando then notificar("Arraste confirmado", tostring(valor)) end end,
})
sliders:CreateSection({ name = "Slider compacto: apenas o trilho" })
sliders:CreateSlider({ minimal = true, flag = "demo/compacto", range = { 0, 100 }, value = 20,
    callback = function(valor, arrastando) if not arrastando then notificar("Slider compacto", tostring(valor)) end end,
})

-- DROPDOWNS: false permite uma escolha; true permite várias, inclusive todas.
local opcoes = { "Opção 1", "Opção 2", "Opção 3", "Opção 4", "Opção 5" }
dropdowns:CreateText({ name = "Uma ou várias escolhas", text = "As opções dividem o painel por dentro: controles à esquerda, checkboxes à direita. Em janelas estreitas, ficam abaixo. Fechar devolve o espaço à aba." })
dropdowns:CreateDropdown({
    name = "Escolha única", flag = "demo/unica", options = opcoes, value = "Opção 1", multiSelect = false,
    notification = true, notificationTitle = "Escolha única", notificationMessage = textoDaSelecao,
    callback = function(escolha) registrar("Escolha única", textoDaSelecao(escolha)) end,
})
local multiplo = dropdowns:CreateDropdown({
    name = "Escolha múltipla", flag = "demo/multipla", options = opcoes, value = { "Opção 1" }, multiSelect = true,
    notification = true, notificationTitle = "Escolha múltipla", notificationMessage = textoDaSelecao,
    callback = function(escolhas) registrar("Escolha múltipla", textoDaSelecao(escolhas)) end,
})
local listaLonga = {}
for i = 1, 30 do table.insert(listaLonga, string.format("Item %02d", i)) end
dropdowns:CreateDropdown({
    name = "Lista longa para buscar", flag = "demo/lista", options = listaLonga, value = { "Item 01" }, multiSelect = true,
    callback = function(escolhas) notificar("Lista longa", textoDaSelecao(escolhas)) end,
})
dropdowns:CreateButton({ name = "Selecionar as cinco por código", callback = function() multiplo:Set(table.clone(opcoes)) end })
dropdowns:CreateButton({ name = "Limpar seleção por código", callback = function() multiplo:Set({}) end })
local extra = false
dropdowns:CreateButton({ name = "Atualizar opções do dropdown", callback = function()
    extra = not extra
    local novas = table.clone(opcoes)
    if extra then table.insert(novas, "Opção extra") end
    multiplo:Refresh(novas)
    notificar("Lista atualizada", extra and "Uma opção extra foi adicionada." or "A lista voltou às cinco opções.")
end })

-- INPUT, COR E ATALHOS. O botão da ação do atalho também pode ser usado no celular.
campos:CreateInput({ name = "Texto de exemplo", flag = "demo/apelido", placeholder = "Digite e confirme", value = "Visitante", clearOnFocus = false,
    callback = function(texto) notificar("Texto confirmado", texto ~= "" and texto or "O campo ficou vazio.") end,
})
campos:CreateInput({ name = "Campo numérico", flag = "demo/numerico", value = "10", numeric = true,
    callback = function(texto) notificar("Campo numérico", tostring(texto)) end,
})
local corAtual, alphaAtual = Color3.fromRGB(166, 112, 255), 1
local corTexto = campos:CreateText({ name = "Cor escolhida", text = "#A670FF · opacidade 100%" })
campos:CreateColorPicker({ name = "Seletor de cor", flag = "demo/cor", color = corAtual, alpha = 1,
    callback = function(cor, alpha)
        corAtual, alphaAtual = cor, alpha
        local resumo = "#" .. cor:ToHex():upper() .. string.format(" · opacidade %.0f%%", alpha * 100)
        corTexto:Set(resumo)
        registrar("Cor alterada", resumo)
    end,
})
campos:CreateButton({ name = "Notificar a cor escolhida", callback = function()
    notificar("Cor escolhida", "#" .. corAtual:ToHex():upper() .. string.format(" · opacidade %.0f%%", alphaAtual * 100))
end })
local function acaoDoAtalho() notificar("Atalho acionado", "A mesma função pode ser chamada por uma tecla ou por um botão.", "success") end
campos:CreateKeybind({ name = "Atalho de exemplo", flag = "demo/atalho", value = Enum.KeyCode.F6,
    callback = acaoDoAtalho,
    onChanged = function(tecla) notificar("Atalho alterado", tecla.Name) end,
})
campos:CreateButton({ name = "Executar ação do atalho", callback = acaoDoAtalho })
campos:CreateKeybind({ name = "Atalho de segurar", flag = "demo/segurar", value = Enum.KeyCode.F7, hold = true,
    callback = function(segurando) notificar("Tecla de segurar", segurando and "A tecla está pressionada." or "A tecla foi solta.") end,
})
campos:CreateText({ name = "Sobre as teclas", text = "F6 e F7 exigem teclado. Toque no campo da tecla para mudar o atalho. No celular, use Executar ação do atalho para testar o callback." })

-- NOTIFICAÇÕES, TOASTS E POPUP COM AÇÕES.
for _, exemplo in ipairs({ { "info", "Notificação padrão" }, { "success", "Aviso de sucesso" }, { "warning", "Aviso de atenção" }, { "error", "Aviso de erro" } }) do
    local tipo, titulo = exemplo[1], exemplo[2]
    avisos:CreateButton({ name = titulo, callback = function() notificar(titulo, "Este aviso foi criado pelo callback do botão de teste.", tipo) end })
end
avisos:CreateButton({ name = "Toast no topo", callback = function()
    if registrar("Toast", "Posição: topo") then window:Toast({ title = "Toast no topo", subtitle = "Exemplo compacto", position = "Top", type = "success" }) end
end })
avisos:CreateButton({ name = "Toast embaixo", callback = function()
    if registrar("Toast", "Posição: embaixo") then window:Toast({ title = "Toast embaixo", subtitle = "Exemplo compacto", position = "Bottom" }) end
end })
avisos:CreateButton({ name = "Notificação com texto longo", callback = function()
    notificar("Texto longo", string.rep("Este texto demonstra a quebra de linha e a rolagem interna da notificação. ", 12))
end })
avisos:CreateButton({ name = "Fechar o último aviso", callback = function()
    if ultimoAviso then ultimoAviso:Close() end
    registrar("Aviso fechado", "O último aviso de teste recebeu Close().")
end })
avisos:CreateButton({ name = "Popup com confirmação", callback = function()
    registrar("Popup", "Escolha uma das ações para testar seu callback.")
    window:Popup({ title = "Teste de confirmação", content = "Os botões abaixo executam callbacks definidos neste script.", options = {
        { text = "Cancelar", callback = function() notificar("Popup", "Você escolheu cancelar.") end },
        { text = "Confirmar", style = "primary", callback = function() notificar("Popup", "Você escolheu confirmar.", "success") end },
    } })
end })

-- TEXTO, ESTATÍSTICA, PROGRESSO, CONSOLE E GRUPOS COM CONTROLES COMPACTOS.
dados:CreateDivider({ text = "Atualizações pelo script" })
local etapa = 0
dados:CreateButton({ name = "Avançar progresso em etapas", callback = function()
    etapa = etapa >= 100 and 0 or etapa + 20
    etapas:Set(etapa)
    paragrafo:SetTitle("Texto atualizado")
    paragrafo:Set("A etapa atual é " .. etapa .. "%. Este texto foi atualizado pelo callback.")
    notificar("Etapa alterada", tostring(etapa) .. "%")
end })
dados:CreateButton({ name = "Escrever no console", callback = function() notificar("Console", "Uma nova linha foi adicionada pelo callback.") end })
dados:CreateButton({ name = "Limpar console", callback = function()
    notificar("Console limpo", "As linhas anteriores foram removidas.")
    console:Clear()
end })
dados:CreateButton({ name = "Atualizar selo do topo", callback = function()
    notificar("Selo atualizado", "O texto do selo no cabeçalho foi alterado.")
    local texto = tostring(interacoes) .. " AÇÕES"
    if selo then selo:SetText(texto) else selo = window:CreateTag({ text = texto }) end
end })
dados:CreateSection({ name = "Grupos e colunas" })
local linha = dados:CreateGroup()
local esquerda = linha:CreateGroup({ direction = "column" })
local direita = linha:CreateGroup({ direction = "column" })
esquerda:CreateButton({ name = "Botão esquerdo", callback = function() notificar("Grupo esquerdo", "O botão pertence à coluna esquerda.") end })
esquerda:CreateToggle({ name = "Toggle esquerdo", flag = "demo/esquerdo", value = false,
    callback = function(valor) notificar("Grupo esquerdo", valor and "Toggle ativado." or "Toggle desativado.") end,
})
direita:CreateButton({ name = "Botão direito", callback = function() notificar("Grupo direito", "O botão pertence à coluna direita.") end })
direita:CreateToggle({ name = "Toggle direito", flag = "demo/direito", value = false,
    callback = function(valor) notificar("Grupo direito", valor and "Toggle ativado." or "Toggle desativado.") end,
})

-- Mantenha os primeiros testes visíveis antes dos mostradores mais altos.
secaoTestes:MoveTo(2)
botao:MoveTo(3)
ativacao:MoveTo(4)
pronto = true
testes:Select()
