local util = require("util")
local Struct = require("struct")
local Rules = require("rules")
local Item = require("lr/item")
local ItemSet = require("lr/item_set")
local StateMachine = require("state_machine")

local AUGMENTED_RULE = "__AUGMENTED_RULE__"

local StateMachineBuilder = Struct({ "rules" }, {
  initialize = function(self, rules)
    self.rules = rules
    self.machine = StateMachine({})
  end,

  build = function(self)
    local start_rule_name = self.rules[1][1]
    local start_item = Item(AUGMENTED_RULE, 0, Rules.Sym(start_rule_name))
    local item_set = ItemSet(start_item, self.rules)
    self:add_state_for_item_set(item_set)
    return self.machine
  end,

  add_state_for_item_set = function(self, item_set)
    if not self.machine:has_state_with_metadata(item_set) then
      local action = self:action_for_item_set(item_set)
      self.machine:add_state(item_set, action)
      local transitions = item_set:transitions(self.rules)
      for i, transition in ipairs(transitions) do
        local transition_on = transition[1]
        local new_item_set = transition[2]
        self:add_state_for_item_set(new_item_set)
        self.machine:add_transition(item_set, transition_on, new_item_set)
      end
    end
  end,

  action_for_item_set = function(self, item_set)
    for i, item in ipairs(item_set) do
      if item.rule == Rules.End then
        if item.name == AUGMENTED_RULE then
          return StateMachine.Actions.Accept
        else
          return StateMachine.Actions.Reduce(item.consumed_sym_count, item.name)
        end
      end
    end
  end
})

return function(rules)
  return StateMachineBuilder(rules):build()
end
