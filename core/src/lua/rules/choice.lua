local Struct = require("util/struct")
local alist = require("util/alist")

local Choice

Choice = Struct({ "left", "right" }, {
  transitions = function(self)
    return alist.merge(
      self.left:transitions(),
      self.right:transitions(),
      self.class)
  end
})

return Choice
