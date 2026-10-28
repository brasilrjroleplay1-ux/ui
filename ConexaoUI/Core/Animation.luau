local TweenService = game:GetService('TweenService')
return function(instance, props, duration)
 local tween = TweenService:Create(instance, TweenInfo.new(duration or .16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
 tween:Play()
 return tween
end
