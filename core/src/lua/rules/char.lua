local Struct = require("struct")
local End = require("rules/end")

return Struct({ "value" }, {
  transitions = function(self)
    return {{ self, End }}
  end,

  to_string = function(self)
    return "CHAR_" .. self.value
  end
})
