local LrItem = require("lr_item")
local Rules = require("rules")
local util = require("util")
local Struct = require("struct")

local State = Struct({ "metadata", "transitions", "action" })

local StateMachine = Struct({ "states" }, {
  add_state = function(self, state)
    util.push(self.states, state)
    return self
  end,

  add_transition = function(self, state1, transition_on, state2)
    util.push(state1.transitions, { transition_on, state2 })
    return self
  end,

  visualize = function(self)
    return self:visualize_state(self.states[1])
  end,

  visualize_state = function(self, state)
    if state.action then
      return state.action
    end

    local result = {}
    for i, t in ipairs(state.transitions) do
      result[self:visualize_transition_on(t[1])] = self:visualize_state(t[2])
    end
    return result
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
    -- print("start_rule_name: " ..  )
    local start_item = self:item_at_start_of_rule(start_rule_name)
    local state = self:build_state(start_item)
    self:add_state_to_machine(state)
  end,

  add_state_to_machine = function(self, state)
    if not util.contains(self.machine.states, state) then
      self.machine:add_state(state)

      local transitions = self:state_transitions(state)
      for i, transition in ipairs(transitions) do
        self:add_state_to_machine(transition[2], self.rules)
        self.machine:add_transition(state, transition[1], transition[2])
      end
    end
  end,

  state_transitions = function(self, state)
    return util.mapcat(state.metadata, function(item)
      return util.map(item:transitions(), function(transition)
        return { transition[1], self:build_state(transition[2]) }
      end)
    end)
  end,

  state_action = function(self, state)
    for i, item in ipairs(state.metadata) do
      if item.rule == Rules.End then
        if item.name == self.rules[1][1] then
          return { "ACCEPT" }
        else
          return { "PUSH", item.name }
        end
      end
    end
  end,

  build_state = function(self, initial_item)
    local result = State({}, {}, {})
    self:add_item_to_state(initial_item, result)
    result.action = self:state_action(result)
    return result
  end,

  add_item_to_state = function(self, item, state)
    if not util.contains(state.metadata, item) then
      util.push(state.metadata, item)

      local transitions = item:transitions()
      for i, pair in ipairs(transitions) do
        local transition_on = pair[1]
        if transition_on.class == Rules.Sym then
          local transition_name = transition_on.name
          local transition_item = self:item_at_start_of_rule(transition_name)
          self:add_item_to_state(transition_item, state)
        end
      end
    end
  end,

  item_at_start_of_rule = function(self, rule_name)
    local rule = util.alist_get(self.rules, rule_name)
    return LrItem(rule_name, rule)
  end
})

StateMachine.build = function(class, rules)
  local result = class({})
  Builder(result, rules):build()
  return result
end

return StateMachine
