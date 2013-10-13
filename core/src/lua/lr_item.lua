local util = require("util")
local Struct = require("struct")
local Rules = require("rules")

local LRItem

local function add_item_to_set(item, set, rules)
  if not util.contains(set, item) then
    util.push(set, item)
    local transitions = item:transitions()
    for i, pair in ipairs(transitions) do
      local transition_on = pair[1]
      if transition_on.class == Rules.Sym then
        local transition_name = transition_on.name
        local transition_item = LRItem(transition_name, 0, util.alist_get(rules, transition_name))
        add_item_to_set(transition_item, set, rules)
      end
    end
  end
end

LRItem = Struct({ "name", "consumed_sym_count", "rule" }, {
  transitions = function(self)
    return util.alist_map(self.rule:transitions(), function(rule)
      return self.class(self.name, self.consumed_sym_count + 1, rule)
    end)
  end
}, {
  build_item_set = function(start_item, rules)
    local result = {}
    add_item_to_set(start_item, result, rules)
    return result
  end,

  transitions_for_item_set = function(item_set, rules)
    return util.mapcat(item_set, function(item)
      return util.map(item:transitions(), function(transition)
        return { transition[1], LRItem.build_item_set(transition[2], rules) }
      end)
    end)
  end
})

return LRItem
