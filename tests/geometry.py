"""Regression model for layout signals/stack heights. Not a Roblox renderer or visual proof."""
from pathlib import Path
import ast,subprocess,sys,tempfile
root=Path(__file__).resolve().parents[1]
cli=sys.argv[1] if len(sys.argv)>1 else '/workspace/tools/luau/luau'
tree=ast.parse((root/'tests/lifecycle.py').read_text())
host=next(ast.literal_eval(n.value) for n in tree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='host' for t in n.targets))
host=host.replace('local methods={}','local resolveSize,layoutContent\nlocal methods={}')
host=host.replace("if key=='AbsoluteSize' then", "if key=='AbsoluteContentSize' and layoutContent then return layoutContent(self) end\n   if key=='AbsoluteSize' and resolveSize then return resolveSize(self) end\n   if key=='AbsoluteSize' then")
host=host.replace("if name=='Players' then return {LocalPlayer=player}", "if name=='Players' then return {LocalPlayer=player,GetUserThumbnailAsync=function() return 'rbxassetid://998877',true end}")
geometry=r'''
local function padding(node)
 local p=node:FindFirstChildOfClass('UIPadding')
 if not p then return 0,0 end
 return (p.PaddingLeft and p.PaddingLeft.Offset or 0)+(p.PaddingRight and p.PaddingRight.Offset or 0),(p.PaddingTop and p.PaddingTop.Offset or 0)+(p.PaddingBottom and p.PaddingBottom.Offset or 0)
end
local function children(parent)
 local result={}
 for _,child in ipairs(parent:GetChildren()) do if child:IsA('GuiObject') and child.Visible then table.insert(result,child) end end
 table.sort(result,function(a,b) return (a.LayoutOrder or 0)<(b.LayoutOrder or 0) end)
 return result
end
resolveSize=function(node)
 if node.ClassName=='ScreenGui' or node.ClassName=='PlayerGui' then return viewport end
 local parent=node.Parent
 local size=parent and parent.AbsoluteSize or viewport
 local px,py=parent and padding(parent) or 0,0
 if parent then px,py=padding(parent) end
 local baseX=math.max(0,size.X-px) local baseY=math.max(0,size.Y-py)
 local u=node.Size local x=baseX*u.X.Scale+u.X.Offset local y=baseY*u.Y.Scale+u.Y.Offset
 local grid=parent and parent:FindFirstChildOfClass('UIGridLayout')
 if grid and node:IsA('GuiObject') then x=baseX*grid.CellSize.X.Scale+grid.CellSize.X.Offset y=grid.CellSize.Y.Offset end
 if node:IsA('TextLabel') and node.AutomaticSize==Enum.AutomaticSize.Y then
  local font=node.TextSize or 14 local chars=math.max(1,math.floor(math.max(1,x)/(font*.55)))
  local lines=0 for text in tostring(node.Text):gmatch('[^\n]*') do if #text>0 then lines+=math.max(1,math.ceil(#text/chars)) end end
  y=math.max(y,lines*(font+3))
 end
 return {X=math.max(0,x),Y=math.max(0,y)}
end
layoutContent=function(layout)
 local parent=layout.Parent
 if not parent then return {X=0,Y=0} end
 local items=children(parent) local width,height=0,0
 if layout.ClassName=='UIGridLayout' then
  local px=padding(parent) local available=math.max(0,parent.AbsoluteSize.X-px)
  local cell=available*layout.CellSize.X.Scale+layout.CellSize.X.Offset
  local gap=layout.CellPadding.X.Offset
  local columns=math.max(1,math.floor((available+gap+.001)/math.max(1,cell+gap)))
  local rows=math.ceil(#items/columns)
  return {X=available,Y=rows>0 and rows*layout.CellSize.Y.Offset+(rows-1)*layout.CellPadding.Y.Offset or 0}
 end
 local horizontal=layout.FillDirection==Enum.FillDirection.Horizontal
 for i,child in ipairs(items) do
  local s=child.AbsoluteSize local gap=i>1 and (layout.Padding and layout.Padding.Offset or 0) or 0
  if horizontal then width+=s.X+gap height=math.max(height,s.Y) else height+=s.Y+gap width=math.max(width,s.X) end
 end
 return {X=width,Y=height}
end
local function settleGeometry()
 settle()
 for _=1,20 do
  for _,node in ipairs(playerGui:GetDescendants()) do
   if node:IsA('GuiObject') then node:GetPropertyChangedSignal('AbsoluteSize'):Fire() end
   if node.ClassName=='UIListLayout' or node.ClassName=='UIGridLayout' then node:GetPropertyChangedSignal('AbsoluteContentSize'):Fire() end
  end
 end
end
player.UserId=12345 player.Name='tester'
local detectEnabled=true
local function getfenv() if detectEnabled then return {identifyexecutor=function() return 'Test Executor','1.0' end} end return {} end
'''
host=host.replace('local UI=(function()\n',geometry+'\nlocal UI=(function()\n')
tests=r'''
end)()
local checks=0
local function check(ok,message) assert(ok,message) checks+=1 end
local w=UI:CreateWindow({Id='Geometry',Scale=85})
local beforeMotion={X=w.Root.Position.X.Offset,Y=w.Root.Position.Y.Offset,W=w.Root.Size.X.Offset,H=w.Root.Size.Y.Offset}
local head=w.Effects.Trails[1][1] local firstX,firstY=head.Position.X.Offset,head.Position.Y.Offset
for _=1,40 do RunService.RenderStepped:Fire(.016) end
check(head.Position.X.Offset~=firstX or head.Position.Y.Offset~=firstY,'perimeter lights move when frames advance')
check(w.Root.Position.X.Offset==beforeMotion.X and w.Root.Position.Y.Offset==beforeMotion.Y and w.Root.Size.X.Offset==beforeMotion.W and w.Root.Size.Y.Offset==beforeMotion.H,'lighting never moves or resizes the window')
w:SetEffects(false) local paused=w.Effects.Time RunService.RenderStepped:Fire(.1)
check(w.Effects.Time==paused and not w.Effects.Layer.Visible and not w.Effects.Halo.Visible,'turning effects off pauses rendering and hides the lights')
check(w.SettingsControls.effects:GetValue()==false and w.Storage.Values['@ui/effects']==false,'effects API synchronizes and persists the native choice')
w:SetEffects(true)
check(w.HomeTab and w.Identity.Executor=='Test Executor','identity overview is automatic and executor uses provided detection')
check(w.Profile.Avatar.Image=='rbxassetid://998877' and w.HomeTab.Profile.Avatar.Image==w.Profile.Avatar.Image,'real thumbnail result is shared by sidebar and home')
check(w.HomeTab.Profile.Name.Text=='Test user' and w.HomeTab.Profile.Executor.Text=='Test Executor','home displays player and executor')
local tab=w:CreateTab('Controls')
local imageTab=w:CreateTab({Name='Image icon',Icon=12345})
check(imageTab.Icon:IsA('ImageLabel') and imageTab.Icon.Image=='rbxassetid://12345','numeric asset icons remain supported')
local a=tab:CreateGroup({Name='FIRST',Column=1}) local b=tab:CreateGroup({Name='SECOND',Column=2})
local action=a:CreateButton({Name='Execute',Icon='info'}) local switch=a:CreateToggle({Name='Toggle'})
a:CreateSlider({Name='Slider',Min=0,Max=100})
a:CreateDropdown({Name='Options',Options={'A','B'}})
check(action.LeadingIcon and action.LeadingIcon.Parent==action.Instance,'button icon belongs to the label area, not on top of action text')
check(not a.Instance:FindFirstChild('GroupHeader'):FindFirstChildOfClass('UIStroke'),'card header has no duplicate inner outline')
switch.Widget.MouseEnter:Fire() switch.Widget.MouseLeave:Fire() switch.Widget.MouseButton1Down:Fire() switch.Widget.MouseButton1Up:Fire()
check(switch.Widget.BackgroundTransparency==1,'compact switch remains unboxed through hover and pressed states')
local emphasized=b:CreateButton({Name='Primary',Variant='Primary'})
emphasized:SetDisabled(true) RunService.RenderStepped:Fire(.016)
check(not w.Effects.Buttons[emphasized.Widget].Light.Visible,'disabled action does not animate a glint')
emphasized:SetDisabled(false)
check(emphasized.Widget.TextColor3:ToHex()==w.Theme.Values.PrimaryText:ToHex(),'filled action uses contrast text instead of white on gold')
local color=b:CreateColorPicker({Name='Color',Default='#123456'})
b:CreateTextbox({Name='Text',Default='Hello'})
local function inspect(width,height)
 viewport={X=width,Y=height} w.Gui:GetPropertyChangedSignal('AbsoluteSize'):Fire() settleGeometry()
 RunService.RenderStepped:Fire(.08)
 for _,trail in ipairs(w.Effects.Trails) do for _,sprite in ipairs(trail) do check(sprite.Position.X.Offset>=0 and sprite.Position.Y.Offset>=0 and sprite.Position.X.Offset<=w.Root.AbsoluteSize.X and sprite.Position.Y.Offset<=w.Root.AbsoluteSize.Y,'perimeter follows viewport resizing at '..width) end end
 for _,page in ipairs(w.Tabs) do
  local icon=page.Icon local button=page.Button
  local cx=button.AbsoluteSize.X*icon.Position.X.Scale+icon.Position.X.Offset
  local cy=button.AbsoluteSize.Y*icon.Position.Y.Scale+icon.Position.Y.Offset
  check(icon.AnchorPoint.X==.5 and icon.AnchorPoint.Y==.5 and math.abs(cx-button.AbsoluteSize.X/2)<.01 and math.abs(cy-button.AbsoluteSize.Y/2)<.01,'font-free and image navigation icons share a center at '..width)
 end
 local header=w.Root:FindFirstChild('WindowHeader')
 local title=header:FindFirstChild('WindowTitle') local badge=header:FindFirstChild('WindowVersion') local search=header:FindFirstChild('HeaderSearch')
 local titleRight=title.Position.X.Offset+title.AbsoluteSize.X
 local controlsLeft=header.AbsoluteSize.X-(search.Visible and 252 or 82)
 check(titleRight<=controlsLeft-10,'title leaves space for header controls at '..width)
 if badge.Visible then
  check(titleRight+9<=badge.Position.X.Offset,'title cannot collide with version badge at '..width)
  check(badge.Position.X.Offset+badge.AbsoluteSize.X<=controlsLeft-10,'version badge cannot collide with search at '..width)
 end
 local transfer=w.ProfileControls.Transfer
 check(transfer.Widget.AbsoluteSize.Y<=44 and transfer.Instance.Size.Y.Offset<=90,'profile JSON field stays compact at '..width)
 for _,page in ipairs(w.Tabs) do
  for _,group in ipairs(page.Groups) do
   local root=group.Instance local stack=root:FindFirstChildOfClass('UIListLayout')
   local _,pad=padding(root)
   check(math.abs(root.Size.Y.Offset-(stack.AbsoluteContentSize.Y+pad))<1,'group height follows stack at '..width)
   for _,c in ipairs(group.Members) do
    if c.RowTransparent then
     local row=c.Instance local inner=row.AbsoluteSize.X local widget=c.Widget
     local left=widget.Position.X.Scale*inner+widget.Position.X.Offset
     check(left>=-1 and left+widget.AbsoluteSize.X<=inner+1,'widget stays inside row at '..width)
     if c.Kind=='Button' or c.Kind=='ColorPicker' or c.Kind=='Toggle' then check(widget.AbsoluteSize.X<=112,'compact controls cannot stretch into wide neon bars') end
    end
   end
  end
 end
 local gallery=w.SettingsTab.Page:FindFirstChild('ThemeGallery')
 if not gallery then for _,node in ipairs(w.SettingsTab.Page:GetDescendants()) do if node.Name=='ThemeGallery' then gallery=node break end end end
 local grid=gallery:FindFirstChildOfClass('UIGridLayout')
 check(gallery.Size.Y.Offset+1>=grid.AbsoluteContentSize.Y,'theme gallery reserves height for all rows at '..width)
 local parent=gallery.Parent local previous=-math.huge
 for _,child in ipairs(children(parent)) do check(child.LayoutOrder>previous,'explicit unique order prevents controls/gallery interleaving') previous=child.LayoutOrder end
 color:Open() settleGeometry()
 local popup
 for _,node in ipairs(w.Gui:GetDescendants()) do if node.Name=='ColorPickerOverlay' then popup=node.Children end end
 check(color.Instance.Size.Y.Offset<=60,'opening color picker never expands/covers neighboring controls')
 color:Close()
end
for _,size in ipairs({{1920,1080},{1280,720},{800,600},{390,844},{844,390}}) do inspect(size[1],size[2]) end
w:SelectTab(tab)
check(tab.Stroke.Transparency<1 and w.SettingsTab.Stroke.Transparency==1,'only active navigation has an outline')
w:SetSidebarLayout('expanded') settleGeometry()
check(tab.Icon.Position.X.Offset==22 and tab.Icon.Position.Y.Scale==.5,'expanded navigation keeps icon in its own aligned column')
w:SetSidebarLayout('icons') settleGeometry()
local paths=action.LeadingIcon:FindFirstChild('IconPaths')
check(paths and action.LeadingIcon.Text=='','built-in info icon uses outline geometry instead of a font character')
w:SetTheme({Secondary=Color3.fromRGB(70,190,255)})
for _,path in ipairs(paths:GetDescendants()) do
 if path.Name=='Ink' then check(path.BackgroundColor3:ToHex()=='46BEFF','outline fill follows the theme tint')
 elseif path.Name=='InkStroke' then check(path.Color:ToHex()=='46BEFF','outline stroke follows the theme tint') end
end
local swatch=color.Swatch local original=swatch.BackgroundColor3:ToHex()
w:SetTheme({SurfaceHover=Color3.fromRGB(1,255,1),Text=Color3.new(1,1,1)})
check(swatch.BackgroundColor3:ToHex()==original,'theme refresh cannot overwrite selected color preview')
w:SetTheme({Primary=Color3.fromRGB(30,30,60)})
check(emphasized.Widget.TextColor3:ToHex()=='FFFFFF','contrast text adapts to a dark primary color')
color:Open()
color.Popup.Hex.Text='#ABCDEF' color.Popup.Hex.FocusLost:Fire()
check(color:GetValue()=='#ABCDEF' and color.Popup.Preview.BackgroundColor3:ToHex()=='ABCDEF','hex editing updates control and preview')
color.Popup.Fields[1].Input.Text='0' color.Popup.Fields[1].Input.FocusLost:Fire()
check(color:GetValue()=='#00CDEF','RGB editing updates the selected channel')
color.Popup.Hex.Text='invalid' color.Popup.Hex.FocusLost:Fire()
check(color:GetValue()=='#00CDEF' and color.Popup.Hex.Text=='#00CDEF','invalid hex is rejected and last valid value restored')
color.Popup:Close()
check(w.DialogCount==0,'color editor releases modal/input ownership')
w:Destroy()
check(next(RunService.RenderStepped.listeners)==nil,'destroy releases the render subscription')
detectEnabled=false
viewport={X=1920,Y=1080}
local plain=UI:CreateWindow({Id='Plain',Home=false,Effects=false})
check(not plain.Effects.Enabled and plain.SettingsControls.effects:GetValue()==false,'effects opt-out is honored by the native settings')
check(plain.Root.AbsoluteSize.X<=1121 and plain.Root.AbsoluteSize.Y<=741,'initial desktop dimensions stay proportional to readable controls')
check(plain.HomeTab==nil and #plain.Tabs==1,'Home=false is an explicit opt-out from the identity page')
check(plain.Identity.Executor=='Não identificado','missing detection never fabricates an executor name')
plain:Destroy()
check(#playerGui:GetChildren()==0,'measured layouts and profile images clean up with window')
print('PASS: '..checks..' geometry/identity regressions (approximate layout model, not Roblox rendering)')
'''
# Mock nodes expose GetChildren(), not a public Children field. The unused popup search needs no internals.
tests=tests.replace("popup=node.Children", "popup=node:GetChildren()")
with tempfile.TemporaryDirectory() as folder:
 p=Path(folder)/'geometry.luau';p.write_text(host+(root/'dist/ConexaoUI.luau').read_text()+tests)
 subprocess.run([cli,str(p)],check=True)
