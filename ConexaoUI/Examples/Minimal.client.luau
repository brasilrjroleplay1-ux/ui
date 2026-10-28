-- Configurações e salvamento já são criados pela library.
local UI=require(game:GetService('ReplicatedStorage'):WaitForChild('ConexaoUI'))
local window=UI:CreateWindow({Title='Meu Hub'})
local tab=window:CreateTab({Name='Principal',Icon='house'})
tab:CreateToggle({Name='Meu recurso',Default=false,Callback=function(enabled)
 print('Meu recurso:',enabled)
end})
