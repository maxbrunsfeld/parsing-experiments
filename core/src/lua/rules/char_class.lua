local Struct = require("struct")
local End = require("rules/end")

local function builder(name)
  return function(self, coefficient)
    return self(name, coefficient)
  end
end

return Struct({ "name", "coefficient" }, {
  transitions = function(self)
    return {{ self, End }}
  end,

  to_string = function(self)
    return "CLASS_" .. self.name
  end
}, {
  digit = builder("digit"),
  space = builder("space"),
  word = builder("word")
})
