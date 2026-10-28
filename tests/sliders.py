"""Exercise real Factory slider/progress behavior; GUI/input services are mocked."""
from pathlib import Path
import subprocess,sys,tempfile
root=Path(__file__).resolve().parents[1]
cli=sys.argv[1] if len(sys.argv)>1 else '/workspace/tools/luau/luau'
factory=(root/'ConexaoUI/Components/Factory.luau').read_text()
factory='\n'.join(x for x in factory.splitlines() if not x.startswith('local ') or '=require(' not in x)
cleanup=(root/'ConexaoUI/Core/Cleanup.luau').read_text()
options=(root/'ConexaoUI/Core/Options.luau').read_text()
rowlayout='\n'.join(x for x in (root/'ConexaoUI/Components/RowLayout.luau').read_text().splitlines() if '= require(' not in x)
host=r'''
local Enum={AutomaticSize={Y='Y'},Font={GothamMedium='GothamMedium'}}
local UDim2={new=function(xs,xo,ys,yo) return {X={Scale=xs,Offset=xo},Y={Scale=ys,Offset=yo}} end}
function UDim2.fromScale(x,y) return UDim2.new(x,0,y,0) end
function UDim2.fromOffset(x,y) return UDim2.new(0,x,0,y) end
local Vector2={new=function(x,y) return {X=x,Y=y} end}
local nativeTypeof=typeof
local function typeof(value) if type(value)=='table' and value._color then return 'Color3' end return nativeTypeof(value) end
local Color3={}
function Color3.fromRGB(r,g,b)
 local color={_color=true,R=r/255,G=g/255,B=b/255}
 function color:ToHex() return string.format('%02X%02X%02X',math.floor(self.R*255+.5),math.floor(self.G*255+.5),math.floor(self.B*255+.5)) end
 return color
end
function Color3.fromHex(hex) return Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16)) end
local task={spawn=function(fn) fn() end}
local warned=false
local function warn() warned=true end
local game={GetService=function() return {} end}
local function signal()
 local s={callbacks={}}
 function s:Connect(fn)
  local token={} self.callbacks[token]=fn
  return {Destroy=function() self.callbacks[token]=nil end}
 end
 function s:Fire(...) for _,fn in pairs(self.callbacks) do fn(...) end end
 return s
end
local E={}
function E.new(class,props,parent)
 assert(class~='TextLabel' or props.ClearTextOnFocus==nil,'TextBox-only property on TextLabel')
 local node=props or {} node.ClassName=class node.Parent=parent node.Children={}
 if parent then table.insert(parent.Children,node) end
 function node:Destroy() self.Dead=true self.Parent=nil end
 function node:ReleaseFocus() self.Released=true end
 for _,key in ipairs({'Focused','FocusLost','Activated','MouseEnter','MouseLeave','MouseButton1Down','MouseButton1Up'}) do node[key]=signal() end
 return node
end
function E.text(parent,text) return E.new('TextLabel',{Text=text},parent) end
function E.button(parent,text) return E.new('TextButton',{Text=text},parent) end
function E.corner() end
function E.pad() end
function E.list() end
local Input={slider=function(track,_,fn) track.Drag=fn end}
local function Animate() end
'''
tests=r'''
local checks=0
local function check(ok,msg) assert(ok,msg) checks+=1 end
local w={Transparency=.08,Ids={},Theme={Values={CornerRadius=14}},Storage={Values={['test/amount']=87}}}
function w.Theme:Bind(node,property,key) node[property]=key end
function w.Theme:Forget() end
function w.Storage:Set(id,value) self.Values[id]=value end
local tab={Window=w,Page={Children={}},Id='test',Controls={},Cleanup=Cleanup.new()}
local calls=0
local c=Factory.create(tab,'Slider',{Name='amount',Min=0,Max=100,Increment=5,Default=50,Suffix='%',Callback=function() calls+=1 end})
check(c:GetValue()==85 and calls==1,'restored slider snaps and applies callback')
local line=c.Instance.Children[2]
local field=line.Children[1] local track=line.Children[2]
check(field.Text=='85%','formatted numeric field')
track.Drag(1) check(c:GetValue()==100 and field.Text=='100%','drag reaches maximum')
track.Drag(0) check(c:GetValue()==0,'drag reaches minimum')
c:SetDisabled(true) track.Drag(.5) check(c:GetValue()==0,'disabled slider ignores drag')
field.Focused:Fire() check(field.Released,'disabled numeric input releases focus')
c:SetDisabled(false) field.Text='37%' field.FocusLost:Fire() check(c:GetValue()==35,'typed input respects step')
field.Text='invalid' field.FocusLost:Fire() check(field.Text=='35%','invalid input restores previous value')
field.Text='999' field.FocusLost:Fire() check(c:GetValue()==100,'typed input clamped')
local before=calls c:SetValue(60,true) check(calls==before and w.Storage.Values['test/amount']==60,'silent update still persists')
local progress=Factory.create(tab,'ProgressBar',{Name='progress',Min=0,Max=100,Value=68})
check(progress:GetValue()==68 and progress.Instance.Children[2].Children[1].ClassName=='TextLabel','progress uses a display-only label')
c:Destroy() check(#tab.Controls==1 and w.Ids['test/amount']==nil,'slider destruction unregisters control')
w.Storage.Values['test/cor']='invalid color from imported profile'
local color=Factory.create(tab,'ColorPicker',{Name='cor',Default='#123456',FireOnInit=false})
check(color:GetValue()=='#123456','invalid stored color falls back to configured default')
color:SetValue({'255','128','0'},true) check(color:GetValue()=='#FF8000','RGB string channels are normalized to numbers')
check(not color:SetValue('not a color',true) and color:GetValue()=='#FF8000','invalid color update preserves last valid value')
color:Destroy()
w.Storage.Values['test/badDefault']='invalid'
local fallback=Factory.create(tab,'ColorPicker',{Name='badDefault',Default='invalid',FireOnInit=false})
check(fallback:GetValue()=='#9070F7','invalid default uses safe library fallback')
fallback:Destroy()
tab.Cleanup:Destroy() check(#tab.Controls==0,'tab teardown cleans remaining controls')
print('PASS: '..checks..' slider/progress/color assertions (GUI/input primitives mocked)')
'''
with tempfile.TemporaryDirectory() as temp:
 p=Path(temp)/'sliders.luau'
 p.write_text(host+'\nlocal Cleanup=(function()\n'+cleanup+'\nend)()\nlocal Options=(function()\n'+options+'\nend)()\nlocal RowLayout=(function()\n'+rowlayout+'\nend)()\nlocal Factory=(function()\n'+factory+'\nend)()\n'+tests)
 subprocess.run([cli,str(p)],check=True)
