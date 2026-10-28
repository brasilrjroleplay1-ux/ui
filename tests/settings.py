"""Exercise built-in settings wiring in Luau. GUI primitives are mocked."""
from pathlib import Path
import subprocess,sys,tempfile
root=Path(__file__).resolve().parents[1]
cli=sys.argv[1] if len(sys.argv)>1 else '/workspace/tools/luau/luau'
source=(root/'ConexaoUI/Pages/Settings.luau').read_text()
source='\n'.join(line for line in source.splitlines() if not line.startswith('local E=require') and not line.startswith('local Factory=require') and not line.startswith('local Profiles=require') and not line.startswith('local Group=require'))
host=r'''
local Color3={}
local mt={__index={ToHex=function(self) return string.format('%02X%02X%02X',self.r,self.g,self.b) end}}
function Color3.fromRGB(r,g,b) return setmetatable({r=r,g=g,b=b},mt) end
function Color3.new(r,g,b) return Color3.fromRGB(r*255,g*255,b*255) end
function Color3.fromHex(hex) return Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16)) end
local ColorSequence={new=function(...) return {...} end}
local Enum={FillDirection={Horizontal='Horizontal',Vertical='Vertical'},SortOrder={LayoutOrder='LayoutOrder'},TextTruncate={AtEnd='AtEnd'},AutomaticSize={Y='Y'},KeyCode={RightControl={Name='RightControl'},F8={Name='F8'}}}
local UDim2={new=function(...) return {...} end,fromOffset=function(...) return {...} end}
local E={}
function E.new(_,props) local node=props or {} node.Activated={Connect=function(_,fn) node.Click=fn return {} end} return node end
function E.text(_,text) return E.new('TextLabel',{Text=text}) end
function E.button(_,text) return E.new('TextButton',{Text=text}) end
function E.list() return {} end
function E.corner() end
local Profiles={create=function() return {} end}
local Group={new=function(tab,opts,parent) return {Page={},Window=tab.Window,Cleanup=tab.Cleanup,Controls=tab.Controls,Id=opts.Id,Members={}} end}
local Factory={}
function Factory.create(tab,kind,o)
 local c={Kind=kind,Options=o,Id=o.Id,Default=o.Default,Persistent=o.Persistent~=false and o.Id~=nil}
 if o.Id then c.Value=tab.Window.Storage.Values[o.Id] end
 if c.Value==nil then c.Value=o.Default end
 function c:SetValue(value,silent)
  if kind=='ColorPicker' then
   self.Color=type(value)=='table' and value or Color3.fromHex(value:gsub('#','')) value='#'..self.Color:ToHex()
  end
  self.Value=value if o.Id then tab.Window.Storage.Values[o.Id]=value end
  if not silent and o.Callback then o.Callback(kind=='ColorPicker' and self.Color or value) end
 end
 function c:GetValue() return self.Value end
 c:SetValue(c.Value,true)
 table.insert(tab.Controls,c)
 return c
end
local function window(values)
 local w={Tabs={},Theme={Values={Primary=Color3.fromRGB(143,110,247),Background=Color3.fromRGB(16,18,22)}},Storage={Values=values or {},Available=true,Enabled=true,Flushes=0},ProfileName='test',ScalePercent=78,Transparency=.08}
 function w.Theme:Bind() end
 function w.Storage:Flush() self.Flushes+=1 return self.Enabled end
 function w:CreateTab(opts) self.Tab={Window=self,Page={AbsoluteSize={X=800}},Button={},Id=opts.Id,Controls={},Internal=opts.Internal,Cleanup={Add=function() end}} table.insert(self.Tabs,self.Tab) return self.Tab end
 function w:SetDim(value) self.Dim=value end
 function w:SetScale(value) self.ScalePercent=value end
 function w:SetTransparency(value) self.Transparency=value end
 function w:SetTheme(values) for k,v in pairs(values) do self.Theme.Values[k]=v end end
 function w:SetGradient(colors,rotation) self.Gradient={colors,rotation} end
 function w:Confirm(opts) opts.Callback(true) end
 function w:SaveConfig() return self.Storage:Flush() end
 function w:Notify(opts) self.LastNotification=opts.Content end
 return w
end
'''
tests=r'''
local count=0
local function check(ok,msg) assert(ok,msg) count+=1 end
local w=window({['@ui/scale']=60,['@ui/transparency']=25,['@ui/accent']='#123456',['app/feature']=true})
local tab=Settings.create(w,{})
local cardCount=0 for _ in pairs(tab.ThemeCards) do cardCount+=1 end
check(cardCount==8,'eight clickable theme previews')
tab.ThemeCards.Aurora.Button.Click()
check(w.SettingsControls.theme:GetValue()=='Aurora','preview selects persistent theme')
check(tab.ThemeCards.Aurora.Border.Thickness==2,'selected theme is outlined')
w.SettingsControls.accent:SetValue('#123456',true) w:SetTheme({Primary=w.SettingsControls.accent.Color})
tab.Relayout(220) tab.Relayout(400) tab.Relayout(900)
w.SettingsControls.dim:SetValue(60) check(w.Dim==.6,'game dim control connected')
check(w.SettingsTab==tab and tab.Button.LayoutOrder==100000,'settings created and ordered')
check(w.ScalePercent==60 and w.Transparency==.25,'appearance restored synchronously')
check(w.Theme.Values.Primary:ToHex()=='123456','color restored')
check(w.ToggleKey.Name=='RightControl','default key works')
check(w.Storage.Values['app/feature']==true,'application state preserved')
w.SettingsControls.scale:SetValue(100) check(w.ScalePercent==100,'built-in scale connected')
w.SettingsControls.transparency:SetValue(80) check(w.Transparency==.8,'transparency connected')
w.SettingsControls.theme:SetValue('Dourado') check(w.SettingsControls.accent:GetValue()=='#E0B864','preset updates persisted color controls')
w.SettingsControls.gradient:SetValue(true) w.SettingsControls.rotation:SetValue(90) check(w.Gradient[2]==90,'gradient controls connected')
w.SettingsControls.key.Options.Changed(Enum.KeyCode.F8) check(w.ToggleKey.Name=='F8','shortcut change connected')
local function find(name) for _,c in ipairs(tab.Controls) do if c.Options.Name==name then return c end end error(name) end
local auto=find('Salvar automaticamente') auto:SetValue(false)
check(not w.Storage.Enabled and w.Storage.Flushes==1,'opt-out saved before disabling writes')
auto:SetValue(true) check(w.Storage.Enabled and w.Storage.Flushes==2,'enable resumes writes')
find('Restaurar aparência padrão').Options.Callback()
check(w.ScalePercent==78 and w.Transparency==.08,'reset restores initial appearance')
check(w.Storage.Values['app/feature']==true,'reset preserves application choices')
w.Storage.Profiles={Other={['@ui/theme']='Oceano',['@ui/accent']='#010203',['@ui/scale']=44,['@ui/autosave']=false,['app/feature']=true}}
function w.Storage:ActivateProfile(name) self.Values=self.Profiles[name] self.Active=name end
local applied=0
local appControl={Id='app/feature',Persistent=true,Kind='Toggle',Default=false}
function appControl:SetValue(value,silent) self.Value=value if not silent then applied+=1 check(w.ScalePercent==44,'application callback sees restored native settings') end end
function appControl:GetValue() return self.Value end
table.insert(w.Tabs,{Controls={appControl}})
w:LoadProfile('Other')
check(appControl.Value==true and applied==1,'profile activation applies application callbacks once')
check(w.Theme.Values.Primary:ToHex()=='010203','profile activation applies saved custom color after preset')
check(not w.Storage.Enabled,'profile activation restores autosave preference')
local off=window({['@ui/autosave']=false}) Settings.create(off,{}) check(not off.Storage.Enabled,'opt-out restored on rerun')
print('PASS: '..count..' built-in settings assertions (GUI primitives mocked)')
'''
with tempfile.TemporaryDirectory() as temp:
 p=Path(temp)/'settings.luau'
 p.write_text(host+'\nlocal Settings=(function()\n'+source+'\nend)()\n'+tests)
 subprocess.run([cli,str(p)],check=True)
