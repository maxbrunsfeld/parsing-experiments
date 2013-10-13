local util = require("util")
local Struct = require("struct")
local Rules = require("rules")

return Struct({ "name", "consumed_sym_count", "rule" }, {
  transitions = function(self)
    return util.alist_map(self.rule:transitions(), function(rule)
      return self.class(self.name, self.consumed_sym_count + 1, rule)
    end)
  end,

  next_symbols = function(self)
    local result = {}
    for i, transition in ipairs(self:transitions()) do
      if transition[1].class == Rules.Sym then
        util.push(result, transition[1])
      end
    end
    return result
  end
})
