local Struct = require("util/struct")
local alist = require("util/alist")
local End = require("rules/end")

return Struct({ "left", "right" }, {
  initialize = function(self, left, right)
    if left == End then
      return right
    end
  end,

  transitions = function(self)
    return alist.map(self.left:transitions(), function(rule)
      return self.class(rule, self.right)
    end)
  end
})
