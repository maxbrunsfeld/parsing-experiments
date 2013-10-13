local Struct = require("struct")
local End = require("rules/end")

return Struct({ "name" }, {
  transitions = function(self)
    return {{ self, End }}
  end,

  to_string = function(self)
    return "SYM_" .. self.name
  end
})
