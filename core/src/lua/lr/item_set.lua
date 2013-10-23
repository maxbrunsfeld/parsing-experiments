local list = require("util/list")
local alist = require("util/alist")
local Struct = require("util/struct")
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
    if not list.contains(self, item) then
      list.push(self, item)
      for i, symbol in ipairs(item:next_symbols()) do
        local rule = alist.get(rules, symbol.name)
        local transition_item = Item(symbol.name, rule)
        self:add_item(transition_item, rules)
      end
    end
  end,

  transitions = function(self, rules)
    local args = list.map(self, function(item)
      return alist.map(item:transitions(), function(to_item)
        return self.class(to_item, rules)
      end)
    end)

    local merge_fn = function(left, right)
      local result = left
      for i, item in ipairs(right) do
        result:add_item(item)
      end
      return result
    end

    list.push(args, merge_fn)
    return alist.merge(unpack(args))
  end,

  is_done = function(self)
    return
      (#self == 1) and
      (#(self[1]:transitions()) == 0)
  end
})
