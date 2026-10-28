"""Real Luau execution of storage and cleanup with mocked host services only."""
from pathlib import Path
import subprocess
import tempfile
import sys
root=Path(__file__).resolve().parents[1]
cli=sys.argv[1] if len(sys.argv)>1 else '/workspace/tools/luau/luau'
setup=r'''
local delayed={}
local task={delay=function(_,fn) table.insert(delayed,fn) end}
local function drain() local pending=delayed delayed={} for _,fn in ipairs(pending) do fn() end end
local warnings={}
local function warn(message) table.insert(warnings,message) end
-- HttpService itself is supplied by Roblox. The mock codec records payloads;
-- these tests cover our persistence logic, not Roblox's JSON implementation.
local packets={} local serial=0
local function clone(value) if type(value)~='table' then return value end local result={} for k,v in pairs(value) do result[k]=clone(v) end return result end
local codec={}
function codec:JSONEncode(value)
 serial+=1 local text='packet:'..serial
 packets[text]=clone(value) return text
end
function codec:JSONDecode(text) assert(packets[text],'invalid JSON fixture') return clone(packets[text]) end
local game={GetService=function(_,name) assert(name=='HttpService') return codec end}
local env={}
local function getfenv() return env end
'''
storage=(root/'ConexaoUI/Core/Storage.luau').read_text()
cleanup=(root/'ConexaoUI/Core/Cleanup.luau').read_text()
profiles=(root/'ConexaoUI/Pages/Profiles.luau').read_text()
tests=r'''
local count=0
local function check(condition,message) assert(condition,message) count+=1 end
local data=nil local writes=0
local adapter={Read=function() return data end,Write=function(_,name,value) check(name=='profile','profile name') data=value writes+=1 end}
local store=Storage.new({Name='profile',Adapter=adapter})
check(store.Available,'adapter detected')
store:Set('toggle',true) store:Set('slider',75) store:Set('multi',{'A','B'})
check(writes==0,'writes debounced') drain() check(writes==1,'one write for burst')
local restored=Storage.new({Name='profile',Adapter=adapter})
check(restored.Values.toggle==true and restored.Values.slider==75,'restore scalar choices')
check(#restored.Values.multi==2,'restore multiple choices')
store:Set('slider',20) store:Destroy() local before=writes drain()
check(writes==before,'destroy flushes and cancels pending writes')
check(Storage.new({Name='profile',Adapter=adapter}).Values.slider==20,'flush preserved final value')
local memory=Storage.new() check(not memory.Available,'unsupported host uses memory') memory:Set('x',1) check(not memory:Flush(),'no false disk success')
local disabled=Storage.new({Enabled=false,Adapter=adapter}) disabled:Set('x',3) drain() check(writes==before,'disabled storage never writes')
data='broken'
local corrupted=Storage.new({Name='profile',Adapter=adapter}) check(next(corrupted.Values)==nil and corrupted.LastError~=nil,'corrupt file uses defaults')
local failing=Storage.new({Adapter={Read=function() error('denied') end,Write=function() error('denied') end}})
check(failing.LastError~=nil and failing:Flush()==false,'read and write errors reported')
check(not pcall(Storage.new,{Name='../escape'}),'path traversal rejected')
local files={} local folders={} local creations=0
env.isfile=function(path) return files[path]~=nil end
env.readfile=function(path) return files[path] end
env.writefile=function(path,text) assert(folders.ConexaoUI) files[path]=text end
env.makefolder=function(path) assert(not folders[path],'already exists') folders[path]=true creations+=1 end
env.isfolder=function(path) return folders[path]==true end
local disk=Storage.new() disk:Set('color','#12ABEF') check(disk:Flush(),'executor API write') check(disk:Flush() and creations==1,'existing folder preserved')
check(Storage.new().Values.color=='#12ABEF','executor API reload')
env.isfolder=nil check(disk:Flush(),'repeat write remains supported')
local fallback=Storage.new() check(fallback:Flush(),'existing-folder error tolerated without isfolder')
local profiles=Storage.new({Name='profiles',Adapter={Read=function() return nil end,Write=function(_,_,text) data=text end}})
profiles:Set('feature',true)
local created=profiles:CreateProfile('Criativo')
check(created=='Criativo' and #profiles:ListProfiles()==2,'create named profile')
profiles:ActivateProfile(created) profiles:Set('feature',false)
check(profiles.Profiles.Default.feature==true,'profile values isolated')
profiles:ActivateProfile('Default') check(profiles.Values.feature==true,'activation restores choices')
check(not pcall(function() profiles:DeleteProfile('Default') end),'default profile protected')
check(not pcall(function() profiles:CreateProfile('Criativo') end),'duplicate name rejected')
profiles:DeleteProfile('Criativo') check(not profiles.Profiles.Criativo and #profiles:ListProfiles(true)==1,'deleted profile retained')
profiles:RestoreProfile('Criativo') check(profiles.Profiles.Criativo.feature==false,'restore preserves choices')
local exported=profiles:ExportProfile('Criativo')
local imported=profiles:ImportProfile(exported,'Importado') check(profiles.Profiles[imported].feature==false,'export/import roundtrip')
check(not pcall(function() profiles:ImportProfile('broken','Bad') end),'invalid import rejected')
profiles:ActivateProfile('Importado') check(not pcall(function() profiles:DeleteProfile('Importado') end),'active profile protected')
profiles.Enabled=false check(profiles:SaveProfile(),'manual save works with autosave disabled')
profiles.AutoLoad=false profiles:Flush(true)
local noauto=Storage.new({Name='profiles',Adapter={Read=function() return data end,Write=function(_,_,text) data=text end}})
check(noauto.SessionOnly and next(noauto.Values)==nil,'auto load disabled starts fresh session')
check(noauto.Profiles.Importado.feature==false,'saved choices retained when auto load is off')
noauto:Set('feature',123) noauto:Flush(true)
check(noauto.Profiles.Importado.feature==false,'metadata save does not overwrite dormant profile')
noauto:SaveProfile() check(noauto.Profiles.Importado.feature==123 and not noauto.SessionOnly,'manual save commits fresh session')
check(not pcall(function() profiles:ImportProfile(string.rep('x',262145),'Huge') end),'oversize import rejected')
local c=Cleanup.new() local calls=0 c:Add(function() calls+=1 end) c:Destroy() c:Destroy() check(calls==1,'cleanup idempotent')
c:Add(function() calls+=1 end) check(calls==2,'late resources cleaned immediately')
local uiStore=Storage.new()
local uiWindow={Storage=uiStore}
function uiWindow:Notify(o) self.Notice=o.Content end
function uiWindow:Confirm(o) o.Callback(true) end
function uiWindow:LoadProfile(name) self.Storage:ActivateProfile(name) end
local controls={}
local function create(kind,o)
 local c={Value=o.Default,Options=o}
 function c:GetValue() return self.Value end
 function c:SetValue(v) self.Value=v end
 function c:SetOptions(values) self.Options.Options=values if not table.find(values,self.Value) then self.Value=nil end end
 controls[o.Name]=c return c
end
local panel=Profiles.create(uiWindow,create)
local function click(name) controls[name].Options.Callback() end
panel.Name:SetValue('LayoutA') click('Criar configuração')
check(uiStore.Profiles.LayoutA~=nil and panel.Selected:GetValue()=='LayoutA','profile UI creates and selects a profile')
click('Definir como ativo') check(uiStore.Active=='LayoutA','profile UI activates selection')
click('Exportar configuração selecionada') check(type(panel.Transfer:GetValue())=='string','export placed in copyable text field')
panel.Name:SetValue('LayoutB') click('Importar como novo perfil') check(uiStore.Profiles.LayoutB~=nil,'profile UI imports JSON')
click('Excluir configuração selecionada') check(uiStore.Deleted.LayoutB~=nil,'profile UI confirms deletion')
panel.Deleted:SetValue('LayoutB') click('Restaurar perfil excluído') check(uiStore.Profiles.LayoutB~=nil,'profile UI restores deleted item')
controls['Carregar automaticamente'].Options.Callback(false) check(not uiStore.AutoLoad,'profile UI autoload toggle connected')
click('Salvar alterações') check(uiWindow.Notice~=nil,'profile UI reports unavailable disk')
print('PASS: '..count..' storage/cleanup/profile assertions (host services mocked)')
'''
source=setup+'\nlocal Storage=(function()\n'+storage+'\nend)()\nlocal Cleanup=(function()\n'+cleanup+'\nend)()\nlocal Profiles=(function()\n'+profiles+'\nend)()\n'+tests
with tempfile.TemporaryDirectory() as temp:
    path=Path(temp)/'storage.luau'
    path.write_text(source)
    subprocess.run([cli,str(path)],check=True)
