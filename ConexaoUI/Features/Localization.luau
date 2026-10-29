--!nonstrict
-- SPDX-License-Identifier: MPL-2.0
-- Translate through Gen2's public locale API; preserve control names, flags and callbacks.
local locale = require(script.Parent.Parent.Gen2.utility.locale)
local Localization = {}
local portuguese = {
    ["General"] = "Controles e interação",
    ["Toggle Keybind"] = "Tecla para abrir / fechar",
    ["Unlock cursor while open"] = "Liberar cursor com o menu aberto",
    ["Unlocks the cursor while the menu is open so you can configure in FPS games that lock it."] = "Permite usar o mouse no painel em jogos que prendem o cursor, como jogos em primeira pessoa.",
    ["Welcome toast"] = "Aviso de boas-vindas",
    ["Shows a 'Signed in as' toast the first time you open the menu on a new account."] = "Mostra um aviso com seu nome ao abrir o painel pela primeira vez nesta conta.",
    ["Haptics"] = "Vibração ao tocar",
    ["A subtle tap as you interact, on devices that support haptics."] = "Vibração leve ao usar os controles, se o dispositivo oferecer suporte.",
    ["Usage analytics"] = "Estatísticas anônimas de uso",
    ["Sends anonymous counts of which parts of this window are used, so it can be made better. Never your name, what you type or your messages. sirius.menu/privacy"] = "Envia contagens anônimas de uso à Sirius, responsável pela base Gen2. Não inclui seu nome, textos digitados ou mensagens. sirius.menu/privacy",
    ["Window"] = "Janela e perfil",
    ["Show profile"] = "Mostrar meu perfil na lateral",
    ["Shows your avatar and name at the base of the sidebar. Turn it off to keep them out of a stream or a screenshot."] = "Exibe sua foto e seu nome no rodapé da lateral. Desative para ocultá-los em capturas ou transmissões.",
    ["Keep window on screen"] = "Manter a janela dentro da tela",
    ["Stops the window being dragged off the edge of the screen and lost."] = "Impede que o painel seja arrastado para fora da área visível.",
    ["Reset Window Position"] = "Centralizar a janela",
    ["Configurations"] = "Perfis de configuração",
    ["Saved Configurations"] = "Configurações salvas",
    ["No saved configurations"] = "Nenhuma configuração salva",
    ["Configuration Name"] = "Nome da configuração",
    ["Name a new configuration, or leave blank to overwrite the selected one."] = "Digite um nome para criar outra configuração. Deixe vazio para atualizar a selecionada.",
    ["e.g. PvP Loadout"] = "Ex.: Meu perfil",
    ["Save"] = "Salvar",
    ["Load"] = "Carregar",
    ["Delete"] = "Excluir",
    ["Name your configuration first"] = "Dê um nome à configuração primeiro",
    ["Saved configuration"] = "Configuração salva",
    ["Couldn't save configuration"] = "Não foi possível salvar",
    ["Pick a configuration to load"] = "Selecione uma configuração para carregar",
    ["Loaded configuration"] = "Configuração carregada",
    ["Couldn't load configuration"] = "Não foi possível carregar",
    ["Pick a configuration to delete"] = "Selecione uma configuração para excluir",
    ["Deleted configuration"] = "Configuração excluída",
    ["Couldn't delete configuration"] = "Não foi possível excluir",
    ["Tap to show"] = "Toque para abrir",
    ["Signed in as"] = "Conectado como",
    ["Search all pages"] = "Buscar em todas as abas",
    ["Search..."] = "Buscar...",
    ["No results"] = "Nenhum resultado",
    ["No matches"] = "Nenhuma opção encontrada",
    ["None"] = "Selecionar",
    ["Various"] = "Várias opções",
    ["Recording"] = "Pressione uma tecla",
    ["Keybind unavailable"] = "Tecla indisponível",
    ["%s is bound to %s. Kept %s."] = "%s já está vinculada a %s. Mantida %s.",
    ["%s is the menu toggle key. Kept %s."] = "%s abre e fecha o menu. Mantida %s.",
    ["Off in secure mode, since a game can see the cursor being unlocked."] = "Desativado no modo seguro: o jogo pode detectar a liberação do cursor.",
}

function Localization.configure(properties)
    -- Register first: developer-provided translations still override these built-ins.
    locale.register({ ["pt-br"] = portuguese, pt = portuguese })
    properties.locale = properties.locale or properties.Locale or "pt-br"
end

return Localization
