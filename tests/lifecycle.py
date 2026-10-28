"""Load the actual standalone library and exercise its public API with a GUI host mock."""
from pathlib import Path
import subprocess,sys,tempfile
root=Path(__file__).resolve().parents[1]
cli=sys.argv[1] if len(sys.argv)>1 else '/workspace/tools/luau/luau'
host=r'''
local nativeTypeof=typeof
local function typeof(value) if type(value)=='table' and value._type then return value._type end return nativeTypeof(value) end
local Vector2={new=function(x,y) return {X=x,Y=y} end}
local UDim={new=function(s,o) return {Scale=s or 0,Offset=o or 0} end}
local UDim2={new=function(xs,xo,ys,yo) return {X=UDim.new(xs,xo),Y=UDim.new(ys,yo)} end}
function UDim2.fromOffset(x,y) return UDim2.new(0,x,0,y) end
function UDim2.fromScale(x,y) return UDim2.new(x,0,y,0) end
local Color3={}
function Color3.fromRGB(r,g,b)
 local c={_type='Color3',R=r/255,G=g/255,B=b/255}
 function c:ToHex() return string.format('%02X%02X%02X',math.floor(self.R*255+.5),math.floor(self.G*255+.5),math.floor(self.B*255+.5)) end
 return c
end
function Color3.new(r,g,b) return Color3.fromRGB(r*255,g*255,b*255) end
function Color3.fromHex(s) return Color3.fromRGB(tonumber(s:sub(1,2),16),tonumber(s:sub(3,4),16),tonumber(s:sub(5,6),16)) end
local ColorSequence={new=function(...) return {...} end}
local NumberSequence={new=function(points) return points end}
local NumberSequenceKeypoint={new=function(time,value) return {Time=time,Value=value} end}
local TweenInfo={new=function(...) return {...} end}
local Enum=setmetatable({}, {__index=function(self,key) local values=setmetatable({}, {__index=function(t,name) local value={_type='EnumItem',Name=name} rawset(t,name,value) return value end}) rawset(self,key,values) return values end})
local function signal()
 local s={listeners={}}
 function s:Connect(fn) local token={} self.listeners[token]=fn return {_type='RBXScriptConnection',Disconnect=function() self.listeners[token]=nil end} end
 function s:Fire(...) for k,fn in pairs(table.clone(self.listeners)) do if self.listeners[k] then fn(...) end end end
 return s
end
local delayed={} local deferred={}
local task={spawn=function(fn,...) fn(...) end,delay=function(_,fn) local t={fn=fn} table.insert(delayed,t) return t end,defer=function(fn) table.insert(deferred,fn) end,cancel=function(t) t.cancelled=true end}
local function settle() local pending=deferred deferred={} for _,fn in ipairs(pending) do fn() end end
local made=0
local Instance={}
local viewport={X=1280,Y=800}
local methods={}
function methods:GetChildren() return table.clone(self._children) end
function methods:GetDescendants() local result={} for _,child in ipairs(self._children) do table.insert(result,child) for _,desc in ipairs(child:GetDescendants()) do table.insert(result,desc) end end return result end
function methods:IsDescendantOf(root) local parent=self.Parent while parent do if parent==root then return true end parent=parent.Parent end return false end
function methods:IsA(class) return self.ClassName==class or (class=='GuiObject' and (self.ClassName=='Frame' or self.ClassName=='CanvasGroup' or self.ClassName=='TextLabel' or self.ClassName=='TextButton' or self.ClassName=='TextBox' or self.ClassName=='ImageLabel' or self.ClassName=='ScrollingFrame')) end
function methods:FindFirstChild(name) for _,child in ipairs(self._children) do if child.Name==name then return child end end end
function methods:WaitForChild(name) return assert(self:FindFirstChild(name),'missing '..name) end
function methods:FindFirstChildOfClass(class) for _,child in ipairs(self._children) do if child:IsA(class) then return child end end end
function methods:GetPropertyChangedSignal(key) self._signals[key]=self._signals[key] or signal() return self._signals[key] end
function methods:Destroy()
 if self._dead then return end self._dead=true self.Destroying:Fire()
 for _,child in ipairs(self:GetChildren()) do child:Destroy() end
 self.Parent=nil
 for _,s in pairs(self._events) do table.clear(s.listeners) end
 for _,s in pairs(self._signals) do table.clear(s.listeners) end
end
function methods:ReleaseFocus() end
function Instance.new(class)
 made+=1
 local node={_props={ClassName=class,Name=class,Visible=true,Size=UDim2.fromOffset(100,40),Position=UDim2.new(),Text='',BackgroundTransparency=0},_children={},_signals={},_events={}}
 return setmetatable(node,{
  __index=function(self,key)
   if methods[key] then return methods[key] end
   if key=='AbsoluteSize' then
    if self.ClassName=='ScreenGui' or self.ClassName=='PlayerGui' then return viewport end
    local parent=self.Parent local size=parent and parent.AbsoluteSize or viewport local u=self.Size
    return {X=math.max(0,size.X*u.X.Scale+u.X.Offset),Y=math.max(0,size.Y*u.Y.Scale+u.Y.Offset)}
   end
   if key=='AbsolutePosition' then return {X=0,Y=0} end
   if self._props[key]~=nil then return self._props[key] end
   if key=='Destroying' or key=='InputBegan' or key=='Activated' or key=='MouseEnter' or key=='MouseLeave' or key=='MouseButton1Down' or key=='MouseButton1Up' or key=='Focused' or key=='FocusLost' then self._events[key]=self._events[key] or signal() return self._events[key] end
  end,
  __newindex=function(self,key,value)
   if key:sub(1,1)=='_' then rawset(self,key,value) return end
   if key=='Parent' then
    local old=self._props.Parent if old then local at=table.find(old._children,self) if at then table.remove(old._children,at) end end
    self._props.Parent=value if value then table.insert(value._children,self) end
   else self._props[key]=value end
   -- Real layout signals are emitted by the engine; tests trigger relevant ones explicitly.
  end,
 })
end
local player=Instance.new('Player') player.DisplayName='Test user'
local playerGui=Instance.new('PlayerGui') playerGui.Parent=player
local UIS={InputBegan=signal(),InputChanged=signal(),InputEnded=signal(),GetFocusedTextBox=function() return nil end}
local RunService={RenderStepped=signal()}
local tween={Create=function(_,node,_,props) return {Play=function() for key,value in pairs(props) do node[key]=value end end,Cancel=function() end} end}
local game={PlaceId=123,GetService=function(_,name)
 if name=='Players' then return {LocalPlayer=player} elseif name=='UserInputService' then return UIS elseif name=='TweenService' then return tween elseif name=='RunService' then return RunService elseif name=='HttpService' then return {} end
 error(name)
end}
local warnings={}
local function warn(text) table.insert(warnings,text) end
local beforeImport=made
local UI=(function()
'''
tests=r'''
end)()
local checks=0
local function check(ok,message) assert(ok,message) checks+=1 end
check(made==beforeImport and next(UI.Windows)==nil,'loading library creates no windows, buttons or demo')
local w=UI:CreateWindow({id='test',title='Our UI'}) settle()
check(#w.Tabs==2 and w.SettingsTab.Internal and w.HomeTab.Internal,'CreateWindow adds built-in identity and settings pages')
local tab=w:CreateTab('Principal','house')
check(w.ActiveTab==w.HomeTab and tab.Id=='Principal','caller creates tabs while the identity page remains the initial view')
w:SelectTab(tab)
local group=tab:CreateGroup({name='Controles',id='controls',column=1})
local other=tab:CreateGroup({Name='Extras',Column=2})
check(group.Name=='Controles' and #tab.Groups==2,'groups accept lowercase properties and column layout')
local called=0
local toggle=group:CreateToggle({name='Meu recurso',id='resource',default=true,callback=function(v) if v then called+=1 end end})
check(toggle.Value==true and called==1 and toggle.RowTransparent,'grouped toggle is compact and callback connected')
check(#group.Members==1 and table.find(tab.Controls,toggle)~=nil,'grouped controls register in tab for profiles')
local slider=group:CreateSlider({Name='Intensidade',Min=0,Max=100,Default=25})
check(slider.Widget~=nil and slider.Relayout~=nil,'slider uses real compact widget layout')
local dropdown=group:CreateDropdown({Name='Escolha',Options={'A','B'},Default='A'}) dropdown:Open()
group:SetCollapsed(true)
check(not group.Page.Visible and dropdown.Popup.Cleanup==nil,'collapsing a card closes owned dropdown')
group:Filter('intensidade') check(group.Instance.Visible and group.Page.Visible and slider.Instance.Visible and not toggle.Instance.Visible,'search finds nested controls and temporarily expands group')
group:Filter('') check(not group.Page.Visible and toggle.Instance.Visible,'clearing search restores collapsed state')
group:SetCollapsed(false) w:SetTransparency(.3)
check(group.Instance.BackgroundTransparency==.3 and toggle.Instance.BackgroundTransparency==1,'window transparency keeps compact rows transparent')
local color=group:CreateColorPicker({Name='Cor',Default='#ABCDEF'})
check(color.Popup~=nil and color.Expansion==nil and color:GetValue()=='#ABCDEF','grouped color picker uses a separate editor instead of expanding the row')
local text=group:CreateTextbox({Name='Nome',Default='Visitante'})
check(text.Widget.Text=='Visitante' and text.ErrorLabel~=nil,'grouped textbox retains validation UI')
local full=other:CreateTextbox({Name='JSON',MultiLine=true})
check(not full.RowTransparent,'multiline fields retain full card layout')
check(not pcall(function() group:CreateGroup({Name='Nested'}) end),'nested groups are not exposed as a fake API')
local beforeDuplicate=#tab.Controls local beforeChildren=#group.Page:GetChildren()
check(not pcall(function() group:CreateToggle({Id='resource',Name='Duplicate'}) end) and #tab.Controls==beforeDuplicate and #group.Page:GetChildren()==beforeChildren,'duplicate ids fail without orphaned rows')
local old=group.Id local saved=toggle:GetValue()
group:SetValue('Renamed') check(group.Id==old and toggle:GetValue()==saved,'renaming a group preserves persistence ids')
local titleToggle=tab:CreateToggle({Name='Visible',name='Ignored',Default=false})
check(titleToggle.Name=='Visible','capitalized properties win over aliases')
viewport={X=390,Y=780} w.Gui:GetPropertyChangedSignal('AbsoluteSize'):Fire() tab.LayoutGroups(300) slider.Relayout()
check(tab.Columns[1].Size.X.Scale==1 and slider.Widget.Size.X.Scale==1,'mobile stacks columns and expands touch widgets')
viewport={X=1280,Y=800} w.Gui:GetPropertyChangedSignal('AbsoluteSize'):Fire() tab.LayoutGroups(900)
check(tab.Columns[1].Size.X.Scale==.5,'desktop restores two columns')
local beforeRestore=called
w.Storage:CreateProfile('Grouped') toggle:SetValue(false,true) slider:SetValue(75,true)
w:LoadProfile('Grouped')
check(toggle:GetValue()==true and slider:GetValue()==25,'real profile switching restores grouped controls')
check(called==beforeRestore+1,'profile switching reapplies grouped control callback exactly once')
group:Destroy() check(#tab.Groups==1 and not w.Ids.resource and not table.find(tab.Controls,toggle),'group destruction unregisters its controls')
check(not pcall(function() group:CreateToggle({Name='late'}) end),'destroyed groups reject new controls')
local replacement=UI:CreateWindow({Id='test',Title='Replacement'}) settle()
check(w.Destroyed and #replacement.Tabs==2,'reinitialization destroys old UI without duplicating script tabs')
replacement:Destroy() check(not pcall(function() replacement:CreateTab('late') end),'destroyed window rejects new tabs')
check(next(UI.Windows)==nil,'destroyed windows are removed from library registry')
UI:Destroy()
check(#playerGui:GetChildren()==0,'library teardown removes all GUI objects')
print('PASS: '..checks..' library/group lifecycle assertions (Roblox GUI host mocked)')
'''
with tempfile.TemporaryDirectory() as folder:
 p=Path(folder)/'lifecycle.luau';p.write_text(host+(root/'dist/ConexaoUI.luau').read_text()+tests)
 subprocess.run([cli,str(p)],check=True)
 demo=Path(folder)/'demo.luau'
 demo.write_text(host[:host.rfind('local UI=(function()')]+(root/'dist/Demo.luau').read_text()+'''
settle()
assert(#playerGui:GetChildren()==1)
assert(UI.Version=='2.1.0')
UI:Destroy()
assert(#playerGui:GetChildren()==0)
print('PASS: standalone demo creates and tears down its own UI without external library imports (GUI host mocked)')
''')
 subprocess.run([cli,str(demo)],check=True)
