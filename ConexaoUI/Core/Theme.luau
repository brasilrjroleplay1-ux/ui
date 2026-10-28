local Theme = {}
Theme.Default = {
 Background = Color3.fromRGB(16,18,22), Surface = Color3.fromRGB(28,31,36),
 SurfaceHover = Color3.fromRGB(40,44,52), Primary = Color3.fromRGB(143,110,247),
 Secondary = Color3.fromRGB(224,184,100), Text = Color3.fromRGB(244,245,250),
 MutedText = Color3.fromRGB(155,161,177), Border = Color3.fromRGB(58,61,72),
 Success = Color3.fromRGB(105,221,160), Warning = Color3.fromRGB(245,199,100),
 Error = Color3.fromRGB(242,113,131), CornerRadius = 14,
}
function Theme.new(overrides)
 local self = {Values = table.clone(Theme.Default), Bindings = {}}
 if type(overrides) == 'table' then for k,v in pairs(overrides) do self.Values[k] = v end end
 function self:Bind(instance, property, key)
  instance[property] = self.Values[key]
  self.Bindings[instance] = self.Bindings[instance] or {}
  self.Bindings[instance][property] = key
 end
 function self:Apply(values)
  for k,v in pairs(values) do if self.Values[k] ~= nil then self.Values[k] = v end end
  for instance, props in pairs(self.Bindings) do
   if instance.Parent == nil then self.Bindings[instance] = nil else
    for property,key in pairs(props) do instance[property] = self.Values[key] end
   end
  end
 end
 function self:Forget(root)
  for instance in pairs(self.Bindings) do if instance == root or instance:IsDescendantOf(root) then self.Bindings[instance] = nil end end
 end
 return self
end
return Theme
