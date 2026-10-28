"""Execute the real notification/dialog managers with a deterministic clock and GUI mocks."""
from pathlib import Path
import subprocess,sys,tempfile
root=Path(__file__).resolve().parents[1]
cli=sys.argv[1] if len(sys.argv)>1 else '/workspace/tools/luau/luau'
def source(name):
 return '\n'.join(line for line in (root/name).read_text().splitlines() if not (line.startswith('local ') and ('= require(' in line or '=require(' in line)))
host=r'''
local Enum={SortOrder={LayoutOrder='LayoutOrder'},VerticalAlignment={Bottom='Bottom'},AutomaticSize={Y='Y'},ScrollingDirection={Y='Y'},TextTruncate={AtEnd='AtEnd'},KeyCode={Escape='Escape'},EasingStyle={Linear='Linear'}}
local UDim2={new=function(xs,xo,ys,yo) return {X={Scale=xs or 0,Offset=xo or 0},Y={Scale=ys or 0,Offset=yo or 0}} end}
function UDim2.fromOffset(x,y) return UDim2.new(0,x,0,y) end
function UDim2.fromScale(x,y) return UDim2.new(x,0,y,0) end
local Vector2={new=function(x,y) return {X=x,Y=y} end}
local Color3={new=function(...) return {...} end}
local TweenInfo={new=function(...) return {...} end}
local now=0 local jobs={} local nextJob=0
local os={clock=function() return now end}
local task={}
function task.delay(delay,callback) nextJob+=1 local job={at=now+delay,fn=callback,id=nextJob} table.insert(jobs,job) return job end
function task.cancel(job) job.cancelled=true end
function task.spawn(fn,...) fn(...) end
local function advance(seconds)
 local target=now+seconds local count=0
 while true do
  local earliest=nil
  for _,job in ipairs(jobs) do
   if not job.cancelled and not job.done and job.at<=target and (not earliest or job.at<earliest.at or (job.at==earliest.at and job.id<earliest.id)) then earliest=job end
  end
  if not earliest then break end
  count+=1 assert(count<10000,'scheduler loop') now=earliest.at earliest.done=true earliest.fn()
 end
 now=target
end
local warnings=0
local function warn() warnings+=1 end
local function signal()
 local self={listeners={}}
 function self:Connect(callback)
  local token={} self.listeners[token]=callback
  return {Destroy=function() self.listeners[token]=nil end}
 end
 function self:Fire(...) for key,fn in pairs(table.clone(self.listeners)) do if self.listeners[key] then fn(...) end end end
 return self
end
local UIS={InputBegan=signal()}
local TweenService={}
function TweenService:Create(node,info,properties)
 return {Play=function() for k,v in pairs(properties) do node[k]=v end end,Cancel=function() end}
end
local game={GetService=function(_,name) if name=='TweenService' then return TweenService else return UIS end end}
local E={}
function E.new(class,props,parent)
 local node=props or {} node.ClassName=class node.Parent=parent node.Children={} node.Signals={}
 if parent then table.insert(parent.Children,node) end
 for _,key in ipairs({'Activated','MouseEnter','MouseLeave'}) do node[key]=signal() end
 function node:GetPropertyChangedSignal(key) self.Signals[key]=self.Signals[key] or signal() return self.Signals[key] end
 function node:IsA(kind) return kind==self.ClassName end
 function node:Destroy() self.Dead=true self.Parent=nil end
 return node
end
function E.text(parent,text) return E.new('TextLabel',{Text=text},parent) end
function E.button(parent,text) return E.new('TextButton',{Text=text},parent) end
function E.icon(parent,value) return E.new(type(value)=='number' and 'ImageLabel' or 'TextLabel',{Text=value},parent) end
function E.scroll(parent) return E.new('ScrollingFrame',{},parent) end
function E.corner() end function E.pad() end function E.list() return {} end
local function window()
 local w={Gui=E.new('ScreenGui',{AbsoluteSize={X=1280,Y=800}}),Theme={}}
 function w.Theme:Bind(node,property,key) node[property]=key end
 function w.Theme:Forget() end
 return w
end
local checks=0
local function check(ok,message) assert(ok,message) checks+=1 end
local function child(parent,text)
 for _,node in ipairs(parent.Children) do if not node.Dead and node.Text==text then return node end end
 error('missing child '..text)
end
'''
window_source=(root/'ConexaoUI/Core/Window.luau').read_text()
bindings=window_source[window_source.index(' w.Notifications=Notifications.new'):window_source.index(' Input.drag(header,root,clean,clamp)')]
tests=r'''
local w=window()
local manager=Notifications.new(w,{MaxVisible=1})
local reasons={}
local n=manager:Notify({Title='Saved',Content='Text',Kind='Success',Duration=2,OnClose=function(reason) table.insert(reasons,reason) end})
local queued=manager:Notify({Content='Next',Duration=0})
check(n.State=='Visible' and queued.State=='Queued','notifications respect capacity and queue')
check(n.Icon.Text=='✓' and n.Fill.BackgroundColor3=='Success','semantic icon and theme are applied')
advance(1) n:Pause() advance(10)
check(n.State=='Visible' and math.abs(n.Remaining-1)<.001,'pause preserves remaining duration')
n:Resume() advance(1.2)
check(n.State=='Closed' and queued.State=='Visible' and reasons[1]=='timeout','timeout closes once and promotes queued notification')
advance(100) check(queued.State=='Visible','zero duration remains until dismissed')
queued:Update({Title='Updated',Content='Updated body',Kind='Error',Actions={{Name='Try',Close=false,Callback=function(h) h:SetValue('Action result') end}}})
check(queued.Title.Text=='Updated' and queued.Body.Text=='Updated body' and queued.Icon.Text=='×','live content/kind update')
child(queued.Actions,'Try').Activated:Fire()
check(queued.State=='Visible' and queued.Body.Text=='Action result','nonclosing action can update notification')
queued:Update({Duration=1}) advance(1.2) check(queued.State=='Closed','updated duration resets timer')
local before=warnings
local bad=manager:Notify({Duration=0,Actions={{Name='Broken',Callback=function() error('test') end}}})
child(bad.Actions,'Broken').Activated:Fire() advance(.2)
check(bad.State=='Closed' and warnings==before+1,'action errors are isolated and normal dismissal works')
local hover=manager:Notify({Duration=1}) hover.Card.MouseEnter:Fire() advance(2)
check(hover.State=='Visible' and hover.Paused,'hover pauses countdown')
hover.Card.MouseLeave:Fire() advance(1.2) check(hover.State=='Closed','mouse leave resumes countdown')
local pending=manager:Notify({Duration=0}) local removed=manager:Notify({Duration=0}) removed:Destroy()
check(removed.State=='Closed' and #manager.Queue==0,'queued notification can be destroyed')
pending:Destroy() advance(.2) check(not pending:Update({Content='too late'}),'closed notification rejects updates')
check(not pcall(function() manager:Notify({Actions={{Callback=function() end}}}) end),'malformed actions are rejected before creating UI')
manager:Destroy()
local mobile=Notifications.new(w,{MaxVisible=3})
local a=mobile:Notify({Duration=5}) local b=mobile:Notify({Duration=5}) local c=mobile:Notify({Duration=5})
w.Gui.AbsoluteSize={X=360,Y=640} w.Gui:GetPropertyChangedSignal('AbsoluteSize'):Fire()
check(#mobile.Active==1 and #mobile.Queue==2,'resize queues extra cards on small screens')
check(mobile.Layer.Size.X.Offset<=336,'notification width stays inside mobile viewport')
a:Close() w.Gui:GetPropertyChangedSignal('AbsoluteSize'):Fire() advance(.2)
check(a.State=='Closed' and b.State=='Visible','resize during exit does not resurrect a closed record')
mobile:Destroy() advance(10)
check(b.State=='Closed' and c.State=='Closed' and next(mobile.Records)==nil,'manager destruction clears active/queued timers')
local quiet=Notifications.new(w)
local closeCalls=0 quiet:Notify({Duration=1,OnClose=function() closeCalls+=1 end}) quiet:Destroy() advance(5)
check(closeCalls==0,'window teardown does not run notification callbacks')
local cap=Notifications.new(w,{MaxVisible=1,MaxQueue=1}) cap:Notify({Duration=0}) cap:Notify({Duration=0})
check(not pcall(function() cap:Notify({}) end),'notification queue is bounded') cap:Destroy()
local dialogs=Dialogs.new(w)
local choices={}
local d=dialogs:Popup({Title='Choose',Content='Pick',Options={{Name='Yes',Value=true},{Name='No',Value=false}},Callback=function(value) table.insert(choices,{value}) end})
local nextDialog=dialogs:Popup({Content='Next'})
check(d.State=='Visible' and nextDialog.State=='Queued' and w.DialogCount==1,'popups are serialized and counted')
d:Update({Title='Changed',Content='New content',Options={{Name='Keep',Value=false}}})
check(d.Title.Text=='Changed' and d.Body.Text=='New content','popup supports live content/options updates')
child(d.Actions,'Keep').Activated:Fire()
check(d.State=='Closed' and choices[1][1]==false and nextDialog.State=='Visible' and w.DialogCount==1,'false-valued option resolves once and opens next popup')
UIS.InputBegan:Fire({KeyCode='Escape'}) check(nextDialog.State=='Closed' and w.DialogCount==0,'Escape cancels active popup')
local lock=dialogs:Popup({Cancellable=false,DismissOnOutside=true})
UIS.InputBegan:Fire({KeyCode='Escape'}) lock.Layer.Children[1].Activated:Fire()
check(lock.State=='Visible' and not lock.CloseButton.Visible,'noncancellable popup ignores Escape and outside click')
lock:Destroy() check(lock.State=='Closed','caller can destroy noncancellable popup')
local out=dialogs:Popup({DismissOnOutside=true}) out.Layer.Children[1].Activated:Fire() check(out.State=='Closed','outside click cancels when requested')
check(not pcall(function() dialogs:Popup({Options={}}) end),'empty popup options are rejected')
local callbacks=0
local first=dialogs:Popup({Callback=function() callbacks+=1 end}) local waiting=dialogs:Popup({Callback=function() callbacks+=1 end})
waiting:Destroy() check(callbacks==1 and first.State=='Visible','queued popup cancellation is isolated')
child(first.Actions,'Fechar').Activated:Fire() first:Destroy() check(callbacks==2,'popup callback runs at most once')
local muted=dialogs:Popup({Callback=function() callbacks+=1 end}) dialogs:Destroy()
check(muted.State=='Closed' and w.DialogCount==0 and callbacks==2,'window teardown cleans modals without application callbacks')
check(not muted:Update({Content='late'}),'closed popup rejects updates')
local w2=window()
local o={} local clean=Cleanup.new() local w=w2
-- BINDING_SOURCE
local forwarded=w2:Notify({Duration=0}) local toast=w2:Toast({Duration=0})
check(forwarded.State=='Visible' and toast.State=='Visible','Window Notify and Toast forward to shared manager')
local bools={}
local confirm=w2:Confirm({ConfirmText='Go',CancelText='Back',Callback=function(value) table.insert(bools,value) end})
child(confirm.Actions,'Go').Activated:Fire()
check(bools[1]==true,'Window Confirm returns true for confirm action')
local cancel=w2:Confirm({Callback=function(value) table.insert(bools,value) end}) cancel:Cancel()
check(bools[2]==false,'Window Confirm adapts cancellation to false')
local popup=w2:Popup({Options={{Name='Choice',Value='choice'}}})
check(popup.State=='Visible','Window Popup forwards general choices')
clean:Destroy()
check(forwarded.State=='Closed' and toast.State=='Closed' and popup.State=='Closed' and w2.DialogCount==0,'window cleanup owns both managers')
print('PASS: '..checks..' notification/popup assertions (GUI, clock and tween services mocked)')
'''
tests=tests.replace('-- BINDING_SOURCE',bindings)
with tempfile.TemporaryDirectory() as temp:
 p=Path(temp)/'feedback.luau'
 p.write_text(host+'\nlocal Cleanup=(function()\n'+source('ConexaoUI/Core/Cleanup.luau')+'\nend)()\nlocal Notifications=(function()\n'+source('ConexaoUI/Core/Notifications.luau')+'\nend)()\nlocal Dialogs=(function()\n'+source('ConexaoUI/Core/Dialogs.luau')+'\nend)()\n'+tests)
 subprocess.run([cli,str(p)],check=True)
