local list = require("util/list")
local alist = require("util/alist")
local Struct = require("util/struct")
local Rules = require("rules")

local function rule_is_done(rule)
  if rule == Rules.End then
    return true
  elseif rule.class == Rules.Choice then
    return rule_is_done(rule.left) or rule_is_done(rule.right)
  else
    return false
  end
end

return Struct({ "name", "rule" }, {
  required = { "name", "rule" },

  initialize = function(self, name, rule, symbol_count)
    self.symbol_count = symbol_count
  end,

  transitions = function(self)
    return list.map(self.rule:transitions(), function(transition)
      local symbol_count = (transition[1].class == Rules.Sym) and
        (self.symbol_count + 1) or
        self.symbol_count
      return { transition[1], self.class(self.name, transition[2], symbol_count) }
    end)
  end,

  next_symbols = function(self)
    return list.filter(list.pluck(self:transitions(), 1), function(transition_on)
      return transition_on.class == Rules.Sym
    end)
  end,

  is_done = function(self)
    return rule_is_done(self.rule)
  end
})
