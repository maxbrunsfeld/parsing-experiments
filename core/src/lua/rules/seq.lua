local Struct = require("struct")
local util = require("util")
local End = require("rules/end")

return Struct({ "left", "right" }, {
  initialize = function(self, left, right)
    if left == End then
      return right
    end
  end,

  transitions = function(self)
    return util.alist_map(self.left:transitions(), function(rule)
      return self.class(rule, self.right)
    end)
  end
})
