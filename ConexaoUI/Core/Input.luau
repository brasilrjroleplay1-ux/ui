local UIS=game:GetService('UserInputService')
local Input={}
function Input.drag(handle,window,cleanup,clamp)
 local active,start,origin
 cleanup:Add(handle.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   active=i start=i.Position origin=window.Position
  end
 end))
 cleanup:Add(UIS.InputChanged:Connect(function(i)
  if active and (i==active or i.UserInputType==Enum.UserInputType.MouseMovement) then
   local d=i.Position-start
   window.Position=UDim2.new(origin.X.Scale,origin.X.Offset+d.X,origin.Y.Scale,origin.Y.Offset+d.Y)
   clamp()
  end
 end))
 cleanup:Add(UIS.InputEnded:Connect(function(i) if i==active or i.UserInputType==Enum.UserInputType.MouseButton1 then active=nil end end))
end
function Input.slider(track,cleanup,onFraction)
 local active
 local function update(i) onFraction(math.clamp((i.Position.X-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)) end
 cleanup:Add(track.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then active=i update(i) end
 end))
 cleanup:Add(UIS.InputChanged:Connect(function(i) if active and (i==active or i.UserInputType==Enum.UserInputType.MouseMovement) then update(i) end end))
 cleanup:Add(UIS.InputEnded:Connect(function(i) if i==active or i.UserInputType==Enum.UserInputType.MouseButton1 then active=nil end end))
end
return Input
