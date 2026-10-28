local Factory=require(script.Parent.Factory)
return function(tab, options) return Factory.create(tab, 'Toggle', options) end
