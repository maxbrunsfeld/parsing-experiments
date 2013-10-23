local list = require("util/list")
local Struct = require("util/struct")
local Rules = require("rules")
local Item = require("lr/item")
local ItemSet = require("lr/item_set")
local StateMachine = require("state_machine")

local AUGMENTED_RULE = {}

local StateMachineBuilder = Struct({ "rules" }, {
  initialize = function(self, rules)
    self.machine = StateMachine({})
  end,

  build = function(self)
    local start_rule_name = self.rules[1][1]
    local start_item = Item(AUGMENTED_RULE, Rules.Sym(start_rule_name))
    local item_set = ItemSet(start_item, self.rules)
    self:add_state_for_item_set(item_set)
    return self.machine
  end,

  add_state_for_item_set = function(self, item_set)
    if not self.machine:has_state_with_metadata(item_set) then
      local action = self:default_action_for_item_set(item_set)
      self.machine:add_state(item_set, action)
      local transitions = item_set:transitions(self.rules)
      for i, transition in ipairs(transitions) do
        local transition_on = transition[1]
        local new_item_set = transition[2]
        self:add_transition_for_item_sets(item_set, new_item_set, transition_on)
      end
    end
  end,

  default_action_for_item_set = function(self, item_set)
    local done_item = list.find(item_set, function(item)
      return item:is_done()
    end)
    if done_item then
      if done_item.name == AUGMENTED_RULE then
        return StateMachine.AcceptTransition(nil)
      else
        return StateMachine.ReduceTransition(nil, done_item.name)
      end
    end
  end,

  add_transition_for_item_sets = function(self, item_set, new_item_set, transition_on)
    if self:item_set_is_done(new_item_set) then
      local item = new_item_set[1]
      if item.name == AUGMENTED_RULE then
        self.machine:add_accept_transition(item_set, transition_on)
      else
        self.machine:add_reduce_transition(item_set, transition_on, item.name)
      end
    else
      self:add_state_for_item_set(new_item_set)
      self.machine:add_shift_transition(item_set, transition_on, new_item_set)
    end
  end,

  item_set_is_done = function(self, item_set)
    return #item_set == 1 and (#(item_set[1]:transitions()) == 0)
  end
})

return function(rules)
  return StateMachineBuilder(rules):build()
end
