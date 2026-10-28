"""Execute real dropdown and popup code in Luau with GUI/input mocks."""
from pathlib import Path
import subprocess,sys,tempfile
root=Path(__file__).resolve().parents[1]
cli=sys.argv[1] if len(sys.argv)>1 else '/workspace/tools/luau/luau'
def source(name):
 text=(root/name).read_text()
 return '\n'.join(x for x in text.splitlines() if not x.startswith('local ') or ('=require(' not in x and '= require(' not in x))
host=r'''
local Enum={Font={Gotham='Gotham'},TextXAlignment={Left='Left'},AutomaticSize={Y='Y'},ScrollingDirection={Y='Y'},SortOrder={LayoutOrder='LayoutOrder'},TextTruncate={None='None'},KeyCode={Escape='Escape'}}
local UDim={new=function(scale,offset) return {Scale=scale or 0,Offset=offset or 0} end}
local UDim2={new=function(xs,xo,ys,yo) return {X={Scale=xs,Offset=xo},Y={Scale=ys,Offset=yo}} end}
function UDim2.fromOffset(x,y) return UDim2.new(0,x,0,y) end
function UDim2.fromScale(x,y) return UDim2.new(x,0,y,0) end
local Vector2={new=function(x,y) return {X=x,Y=y} end}
local Color3={new=function(...) return {...} end}
local task={spawn=function(fn) fn() end}
local function warn() end
local function signal()
 local s={callbacks={}}
 function s:Connect(fn) local token={} self.callbacks[token]=fn return {Destroy=function() self.callbacks[token]=nil end} end
 function s:Fire(...) local listeners=table.clone(self.callbacks) for token,fn in pairs(listeners) do if self.callbacks[token] then fn(...) end end end
 return s
end
local UIS={InputBegan=signal()}
local game={GetService=function() return UIS end}
local E={}
function E.new(class,props,parent)
 local node=props or {} node.ClassName=class node.Parent=parent node.Children={} node.Changes={}
 if parent then table.insert(parent.Children,node) end
 function node:GetPropertyChangedSignal(key) self.Changes[key]=self.Changes[key] or signal() return self.Changes[key] end
 function node:Destroy() self.Dead=true self.Parent=nil end
 for _,name in ipairs({'Activated','MouseEnter','MouseLeave','MouseButton1Down','MouseButton1Up'}) do node[name]=signal() end
 return node
end
function E.text(parent,text) return E.new('TextLabel',{Text=text},parent) end
function E.button(parent,text) return E.new('TextButton',{Text=text},parent) end
function E.icon(parent,value) return E.new('TextLabel',{Text=value},parent) end
function E.fit() end function E.corner() end function E.list() end function E.pad() return {} end
local Input={} local function Animate() end
'''
tests=r'''
local checks=0
local function check(ok,msg) assert(ok,msg) checks+=1 end
local w={Gui=E.new('ScreenGui',{AbsoluteSize={X=1280,Y=720}}),Root={AbsolutePosition={X=50,Y=30},AbsoluteSize={X=1100,Y=650}},Theme={Values={CornerRadius=14}},Storage={Values={}},Ids={},Transparency=.08}
function w.Theme:Bind(node,key,value) node[key]=value end function w.Theme:Forget() end
function w.Storage:Set(key,value) self.Values[key]=value end
local tab={Window=w,Id='test',Page=E.new('Frame',{}),Cleanup=Cleanup.new(),Controls={}}
local calls=0
local multi=Factory.create(tab,'Dropdown',{Name='Zones',Options={'Forest','Ocean','Desert','Mountain'},Default={'Forest'},Multi=true,FireOnInit=false,Callback=function() calls+=1 end})
local function panel() local p=multi.Popup for _,node in ipairs(w.Gui.Children) do if not node.Dead then for _,c in ipairs(node.Children) do if c.Name=='Options' then return c,node end end end end error('no panel') end
local function find(node,predicate) for _,child in ipairs(node.Children) do if not child.Dead then if predicate(child) then return child end local result=find(child,predicate) if result then return result end end end end
local function byText(parent,text) return find(parent,function(c) return c.Text==text end) end
multi:Open() check(w.DialogCount==1 and multi.Popup.Cleanup~=nil,'open creates a modal popup')
local p=panel()
local grid=find(p,function(c) return c.ClassName=='UIGridLayout' end)
check(grid.CellSize.X.Scale==.5,'desktop uses two columns')
check(#multi.Popup.Buttons==4,'options rendered')
check(multi.Popup.Buttons[1].Check.Visible and not multi.Popup.Buttons[2].Check.Visible,'initial selection owns an independent visible check icon')
byText(p,'Ocean').Activated:Fire()
check(#multi:GetValue()==2 and calls==1,'multi click updates value and callback')
check(multi.Popup.Buttons[2].Check.Visible,'selection updates its outline check icon')
check(multi.Popup.Cleanup~=nil,'multi selection keeps popup open')
local query=find(p,function(c) return c.ClassName=='TextBox' end)
query.Text='des' query:GetPropertyChangedSignal('Text'):Fire()
check(#multi.Popup.Buttons==1 and multi.Popup.Buttons[1].Value=='Desert','search filters options')
byText(p,'Selecionar tudo').Activated:Fire() check(#multi:GetValue()==4,'select all includes all options even when filtered')
byText(p,'Limpar').Activated:Fire() check(#multi:GetValue()==0,'clear removes selections')
byText(p,'Padrão').Activated:Fire() check(multi:GetValue()[1]=='Forest' and #multi:GetValue()==1,'default restores configured selection')
query.Text='nothing' query:GetPropertyChangedSignal('Text'):Fire()
check(byText(p,'Nenhuma opção encontrada.').Visible,'empty search state visible')
multi:SetOptions({'Forest','Other'}) check(#multi:GetValue()==1,'option update preserves valid selection')
w.Gui.AbsoluteSize={X=360,Y=640} w.Gui:GetPropertyChangedSignal('AbsoluteSize'):Fire()
check(grid.CellSize.X.Scale==1 and p.Size.X.Offset<=336,'mobile uses one column within screen')
UIS.InputBegan:Fire({KeyCode='Escape'}) check(w.DialogCount==0 and multi.Popup.Cleanup==nil,'Escape closes and releases modal count')
multi:Open() multi:SetDisabled(true) check(multi.Popup.Cleanup==nil,'disabling closes popup')
multi:SetDisabled(false) multi:Open()
local single=Factory.create(tab,'Dropdown',{Name='Mode',Options={'One','Two'},Default='One',FireOnInit=false})
single:Open() check(multi.Popup.Cleanup==nil and w.DialogCount==1,'opening another dropdown closes the first')
single.Popup.Buttons[2].Button.Activated:Fire()
check(single:GetValue()=='Two' and single.Popup.Cleanup==nil and w.DialogCount==0,'single selection closes popup')
single:SetValue(nil)
check(w.Storage.Values['test/Mode'].__ConexaoEmptyDropdown==true,'cleared single selection has a persisted marker')
single:Destroy()
local restored=Factory.create(tab,'Dropdown',{Name='Mode',Options={'One','Two'},Default='One',FireOnInit=false})
check(restored:GetValue()==nil,'cleared selection survives reinitialization instead of falling back to default')
restored:SetValue('Two') check(w.Storage.Values['test/Mode']=='Two','new selection replaces explicit-clear marker')
restored:Destroy()
multi:Open() local _,layer=panel() layer.Children[1].Activated:Fire() check(multi.Popup.Cleanup==nil,'outside click closes popup')
multi:Open() multi:Destroy() check(w.DialogCount==0,'destroy cleans popup and input connections')
print('PASS: '..checks..' dropdown/popup assertions (GUI/input primitives mocked)')
'''
with tempfile.TemporaryDirectory() as temp:
 p=Path(temp)/'dropdowns.luau'
 p.write_text(host+'\nlocal Cleanup=(function()\n'+source('ConexaoUI/Core/Cleanup.luau')+'\nend)()\nlocal DropdownPanel=(function()\n'+source('ConexaoUI/Components/DropdownPanel.luau')+'\nend)()\nlocal Options=(function()\n'+source('ConexaoUI/Core/Options.luau')+'\nend)()\nlocal RowLayout=(function()\n'+source('ConexaoUI/Components/RowLayout.luau')+'\nend)()\nlocal Factory=(function()\n'+source('ConexaoUI/Components/Factory.luau')+'\nend)()\n'+tests)
 subprocess.run([cli,str(p)],check=True)
