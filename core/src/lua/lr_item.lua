local util = require("util")
local Struct = require("struct")

return Struct({ "name", "rule" }, {
  transitions = function(self)
    return util.alist_map(self.rule:transitions(), function(rule)
      return self.class(self.name, rule)
    end)
  end
})
