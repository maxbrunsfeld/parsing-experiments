local LR = require("lr")
local Rules = require("rules")
local util = require("util")
local Struct = require("struct")

local State = Struct({ "metadata", "action", "transitions" }, {
  initialize = function(self, metadata, action)
    self.metadata = metadata
    self.action = action
    self.transitions = {}
  end
})

local StateMachine = Struct({ "states" }, {
  add_state = function(self, metadata, action)
    util.push(self.states, State(metadata, action))
    return self
  end,

  add_transition = function(self, metadata1, transition_on, metadata2)
    util.push(
      self:state_with_metadata(metadata1).transitions,
      { transition_on, self:state_with_metadata(metadata2) })
    return self
  end,

  has_state_with_metadata = function(self, metadata)
    return self:_state_with_metadata(metadata) ~= nil
  end,

  state_with_metadata = function(self, metadata)
    return self:_state_with_metadata(metadata) or
      error("No state with metadata: " .. P.write(metadata))
  end,

  _state_with_metadata = function(self, metadata)
    return util.find(self.states, function(state)
      return state.metadata == metadata
    end)
  end,

  visualize = function(self)
    return self:visualize_state(self.states[1])
  end,

  visualize_state = function(self, state)
    if state.action then
      return state.action
    else
      local result = {}
      for i, t in ipairs(state.transitions) do
        result[self:visualize_transition_on(t[1])] = self:visualize_state(t[2])
      end
      return result
    end
  end,

  visualize_transition_on = function(self, rule)
    if rule.class == Rules.CharClass then
      return "CLASS_" .. rule.value
    elseif rule.class == Rules.Char then
      return "CHAR_" .. rule.value
    else
      return "SYM_" .. rule.name
    end
  end
})

local AUGMENTED_RULE = "__AUGMENTED_RULE__"

local Builder = Struct({ "machine", "rules" }, {
  build = function(self)
    local start_rule_name = self.rules[1][1]
    local start_item = LR.Item(AUGMENTED_RULE, 0, Rules.Sym(start_rule_name))
    local item_set = LR.ItemSet(start_item, self.rules)
    self:add_state_for_item_set(item_set)
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
          return { "ACCEPT" }
        else
          return { "REDUCE", item.consumed_sym_count, item.name }
        end
      end
    end
  end
})

StateMachine.build = function(class, rules)
  local result = class({})
  Builder(result, rules):build()
  return result
end

return StateMachine
