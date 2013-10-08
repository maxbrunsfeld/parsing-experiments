local Struct = require("struct")
local util = require("util")

return Struct({ "left", "right" }, {
  transitions = function(self)
    return util.alist_merge(
      self.left:transitions(),
      self.right:transitions(),
      self.class)
  end
})
