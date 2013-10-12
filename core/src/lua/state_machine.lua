local LrItem = require("lr_item")
local Rules = require("rules")
local util = require("util")
local Struct = require("struct")

local AUGMENTED_RULE = "__AUGMENTED_RULE__"
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
    local state1 = self:state_with_metadata(metadata1)
    local state2 = self:state_with_metadata(metadata2)
    if not state1 then error("add_transition - no state1 with metadata: " .. P.write(metadata1)) end
    if not state2 then error("add_transition - no state2 with metadata: " .. P.write(metadata2)) end
    util.push(state1.transitions, { transition_on, state2 })
    return self
  end,

  has_state_with_metadata = function(self, metadata)
    return self:state_with_metadata(metadata) ~= nil
  end,

  state_with_metadata = function(self, metadata)
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

local Builder = Struct({ "machine", "rules" }, {
  build = function(self)
    local start_rule_name = self.rules[1][1]
    local start_item = LrItem(AUGMENTED_RULE, 0, Rules.Sym(start_rule_name))
    local item_set = self:build_item_set(start_item)
    self:add_state_for_item_set(item_set)
  end,

  add_state_for_item_set = function(self, item_set)
    if not self.machine:has_state_with_metadata(item_set) then
      local action = self:action_for_item_set(item_set)
      self.machine:add_state(item_set, action)
      local transitions = self:transitions_for_item_set(item_set)
      for i, transition in ipairs(transitions) do
        local transition_on = transition[1]
        local new_item_set = transition[2]
        self:add_state_for_item_set(new_item_set)
        self.machine:add_transition(item_set, transition_on, new_item_set)
      end
    end
  end,

  transitions_for_item_set = function(self, item_set)
    return util.mapcat(item_set, function(item)
      return util.map(item:transitions(), function(transition)
        return { transition[1], self:build_item_set(transition[2]) }
      end)
    end)
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
  end,

  build_item_set = function(self, initial_item)
    local result = {}
    self:add_item_to_set(initial_item, result)
    return result
  end,

  add_item_to_set = function(self, item, set)
    if not util.contains(set, item) then
      util.push(set, item)
      local transitions = item:transitions()
      for i, pair in ipairs(transitions) do
        local transition_on = pair[1]
        if transition_on.class == Rules.Sym then
          local transition_name = transition_on.name
          local transition_item = self:item_at_start_of_rule(transition_name)
          self:add_item_to_set(transition_item, set)
        end
      end
    end
  end,

  item_at_start_of_rule = function(self, rule_name)
    return LrItem(rule_name, 0, util.alist_get(self.rules, rule_name))
  end
})

StateMachine.build = function(class, rules)
  local result = class({})
  Builder(result, rules):build()
  return result
end

return StateMachine
