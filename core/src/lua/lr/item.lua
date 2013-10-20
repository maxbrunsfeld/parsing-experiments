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

  transitions = function(self)
    return alist.map(self.rule:transitions(), function(rule)
      return self.class(self.name, rule)
    end)
  end,

  next_symbols = function(self)
    local result = {}
    for i, transition in ipairs(self:transitions()) do
      if transition[1].class == Rules.Sym then
        list.push(result, transition[1])
      end
    end
    return result
  end,

  is_done = function(self)
    return rule_is_done(self.rule)
  end
})
