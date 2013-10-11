local util = require("util")
local Struct = require("struct")

return Struct({ "name", "consumed_sym_count", "rule" }, {
  transitions = function(self)
    return util.alist_map(self.rule:transitions(), function(rule)
      return self.class(self.name, self.consumed_sym_count + 1, rule)
    end)
  end
})
