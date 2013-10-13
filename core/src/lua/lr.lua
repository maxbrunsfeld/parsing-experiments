local util = require("util")
local Struct = require("struct")
local Rules = require("rules")

local Item = Struct({ "name", "consumed_sym_count", "rule" }, {
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

local ItemSet = Struct({}, {
  initialize = function(self, item, rules)
    self:add_item(item, rules)
  end,

  eq = function(self, other)
    if (other.class ~= self.class) or (#self ~= #other) then return false end
    for i, item in ipairs(self) do
      if item ~= other[i] then return false end
    end
    return true
  end,

  add_item = function(self, item, rules)
    if not util.contains(self, item) then
      util.push(self, item)
      for i, symbol in ipairs(item:next_symbols()) do
        local rule = util.alist_get(rules, symbol.name)
        local transition_item = Item(symbol.name, 0, rule)
        self:add_item(transition_item, rules)
      end
    end
  end,

  transitions = function(self, rules)
    return util.mapcat(self, function(item)
      return util.map(item:transitions(), function(transition)
        return { transition[1], self.class(transition[2], rules) }
      end)
    end)
  end
})

return {
  Item = Item,
  ItemSet = ItemSet
}
