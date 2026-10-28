-- Studio: coloque ConexaoUI em ReplicatedStorage e este LocalScript em StarterPlayerScripts.
local UI=require(game:GetService('ReplicatedStorage'):WaitForChild('ConexaoUI'))
local window=UI:CreateWindow({
 Title='CONEXÃO UI',Subtitle='Criada para o seu próximo projeto',Version='1.4.0',
 Id='ConexaoDemo',Scale=82,ToggleKey=Enum.KeyCode.RightControl,
})
window:CreateCategory('WORKSPACE')
local home=window:CreateDashboard({Username=game:GetService('Players').LocalPlayer.DisplayName})
local tab=window:CreateTab({Name='Componentes',Icon='star',Description='Exemplos interativos'})
tab:CreateSection({Name='CONTROLES',Content='Uma API reutilizável. Os dados abaixo são demonstrativos.'})
tab:CreateButton({Name='Mostrar notificação',Icon='info',Callback=function() window:Notify({Title='Tudo conectado',Content='Callback executado.'}) end})
tab:CreateToggle({Id='demo/notifications',Name='Notificações',Default=true,Callback=function(value) home:SetStat('status',value and 'Ativo' or 'Pausado') end})
tab:CreateSlider({Id='demo/volume',Name='Volume demonstrativo',Min=0,Max=100,Increment=5,Default=50,Callback=function(value) print('Volume',value) end})
tab:CreateDropdown({Id='demo/profile',Name='Perfil',Options={'Padrão','Criativo','Compacto'},Default='Padrão',Searchable=true,Callback=function(value) home:SetStat('profile',value or 'Nenhum') end})
tab:CreateDropdown({Id='demo/modules',Name='Módulos visíveis',Options={'Painel','Estatísticas','Novidades','Atalhos','Notificações','Aparência','Perfis','Ajuda'},Multi=true,Default={'Painel'},Callback=function(values) print(table.concat(values,', ')) end})
tab:CreateTextbox({Id='demo/nickname',Name='Apelido',Placeholder='Como quer ser chamado?',Default='Visitante',MaxLength=32,Validate=function(value) return #value>0,'Digite um nome.' end,Callback=function(value) home:SetWelcome({Username=value}) end})
tab:CreateKeybind({Id='demo/key',Name='Atalho de notificação',Default='F6',Callback=function() window:Notify({Content='Você pressionou o atalho.'}) end})
tab:CreateColorPicker({Id='demo/color',Name='Cor de destaque',Default='#9070F7',Callback=function(color) window:SetTheme({Primary=color}) end})
tab:CreateProgressBar({Name='Progresso demonstrativo',Value=68})
tab:CreateBadge({Name='API v1.0',Content='Pronta para integrar'})
tab:CreateParagraph({Name='Sobre os perfis',Content='Toggles, sliders, seleções, texto, teclas e cores são restaurados quando o armazenamento está disponível.'})
tab:CreateDivider({})
tab:CreateButton({Name='Abrir confirmação',Variant='Destructive',Callback=function() window:Confirm({Content='Executar esta ação demonstrativa?',Callback=function(confirmed) window:Notify({Content=confirmed and 'Ação confirmada.' or 'Cancelada.'}) end}) end})
window:SelectTab(home)
