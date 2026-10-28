-- Public client metadata only. Never guesses an executor name or reads credentials.
local Players=game:GetService('Players')
local Identity={}
function Identity.new(w,options)
 local player=Players.LocalPlayer
 local executor='Não identificado'
 local env=getfenv()
 local detect=env.identifyexecutor or env.getexecutorname
 if type(detect)=='function' then
  local ok,name=pcall(detect)
  if ok and type(name)=='string' and name~='' then executor=name end
 else
  local ok,studio=pcall(function() return game:GetService('RunService'):IsStudio() end)
  if ok and studio then executor='Roblox Studio' end
 end
 local self={DisplayName=player.DisplayName or player.Name or 'Jogador',Username=player.Name or 'Jogador',UserId=player.UserId or 0,Executor=executor,Images={}}
 local avatar=options.Avatar
 if type(avatar)=='number' then avatar='rbxassetid://'..avatar end
 self.Avatar=avatar or ('rbxthumb://type=AvatarHeadShot&id='..self.UserId..'&w=150&h=150')
 function self:BindImage(image) image.Image=self.Avatar table.insert(self.Images,image) end
 if not avatar and self.UserId>0 then
  task.spawn(function()
   local ok,url,ready=pcall(function() return Players:GetUserThumbnailAsync(self.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
   if not ok or not ready or w.Destroyed then return end
   self.Avatar=url
   for _,image in ipairs(self.Images) do if image.Parent then image.Image=url end end
  end)
 end
 function self:Destroy() table.clear(self.Images) end
 return self
end
return Identity
