local LrItem = require("lr_item")
local Rules = require("rules")
local util = require("util")
local Struct = require("struct")

local State = Struct({ "metadata", "transitions" })

local StateMachine = Struct({ "states" }, {
  add_state = function(self, state)
    util.push(self.states, state)
    return self
  end,

  add_transition = function(self, state1, transition_on, state2)
    util.push(state1.transitions, { transition_on, state2 })
    return self
  end
})

local Builder = Struct({ "rules" }, {
  build = function(self)
    local result = StateMachine({})
    local state = self:build_state(LrItem(self.rules[1][1], self.rules[1][2]))
    self:add_state_to_machine(result, state, self.rules)
    return result
  end,

  add_state_to_machine = function(self, machine, state)
    if not util.contains(machine.states, state) then
      machine:add_state(state)
      local transitions = self:state_transitions(state)
      for i, transition in ipairs(transitions) do
        self:add_state_to_machine(machine, transition[2], self.rules)
        machine:add_transition(state, transition[1], transition[2])
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

  build_state = function(self, initial_item)
    local result = State({}, {})
    self:add_item_to_state(result, initial_item)
    return result
  end,

  add_item_to_state = function(self, state, item)
    if not util.contains(state.metadata, item) then
      util.push(state.metadata, item)
      local transitions = item:transitions()
      for i, pair in ipairs(transitions) do
        local transition_on = pair[1]
        if transition_on.class == Rules.Sym then
          local sym_name = transition_on.name
          local next_rule = util.alist_get(self.rules, sym_name)
          local next_item = LrItem(sym_name, next_rule)
          self:add_item_to_state(state, next_item)
        end
      end
    end
  end
})

StateMachine.build = function(class, rules)
  return Builder(rules):build()
end

return StateMachine
