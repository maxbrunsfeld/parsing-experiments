local util = require("util")
local Struct = require("struct")
local Item = require("lr/item")

return Struct({}, {
  initialize = function(self, item, rules)
    dbg.call(function()
      self:add_item(item, rules)
    end)
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
        local transition_item = Item(symbol.name, rule)
        self:add_item(transition_item, rules)
      end
    end
  end,

  transitions = function(self, rules)
    local args = util.map(self, function(item)
      return util.map(item:transitions(), function(transition)
        return { transition[1], self.class(transition[2], rules) }
      end)
    end)

    local merge_fn = function(left, right)
      local result = left
      for i, item in ipairs(right) do
        result:add_item(item)
      end
      return result
    end

    util.push(args, merge_fn)
    return util.alist_merge(unpack(args))
  end
})
