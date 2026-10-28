local Factory=require(script.Parent.Factory)
return function(tab, kind, options) return Factory.create(tab, kind, options) end
