local Struct = require("struct")

return Struct({}, {
  initialize = function(self)
    self[1] = "__END__"
  end,

  transitions = function()
    return {}
  end
})()
