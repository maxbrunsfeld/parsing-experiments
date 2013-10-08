local LrItem = require("lr_item")
local Rules = require("rules")
local util = require("util")
local Struct = require("struct")

local State = Struct({ "items" }, {
  initialize = function(self, initial_item, rules)
    self.items = {}
    self:add_item(initial_item, rules)
  end,

  add_item = function(self, item, rules)
    if not util.contains(self.items, item) then
      util.push(self.items, item)
      local transitions = item:transitions()
      for i, pair in ipairs(transitions) do
        local transition_val = pair[1]
        if transition_val.class == Rules.Sym then
          local next_rule = util.alist_get(rules, transition_val.name)
          local next_item = LrItem(transition_val.name, next_rule)
          self:add_item(next_item, rules)
        end
      end
    end
  end,

  transitions = function(self, rules)
    return util.mapcat(self.items, function(item)
      return util.map(item:transitions(), function(transition)
        return { transition[1], self.class(transition[2], rules) }
      end)
    end)
  end
})

return Struct({ "rules" }, {
  initialize = function(self, rules, state)
    self.states = {}
    local state = State(LrItem(rules[1][1], rules[1][2]), rules)
    self:add_state(state, rules)
  end,

  add_state = function(self, state, rules)
    if not util.contains(self.states, state) then
      util.push(self.states, state)
      local transitions = state:transitions(rules)
      for i, v in ipairs(transitions) do
        self:add_state(v[2], rules)
      end
    end
  end
})
