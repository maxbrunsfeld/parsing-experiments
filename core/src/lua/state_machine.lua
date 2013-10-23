local list = require("util/list")
local Struct = require("util/struct")

local State = Struct({ "metadata", "default_action", "transitions" }, {
  initialize = function(self)
    self.transitions = {}
  end
})

local ShiftTransition = Struct({ "on", "to_state" }, {
  to_string = function(self)
    return "SHIFT " .. self.to_state.index
  end
})

local ReduceTransition = Struct({ "on", "symbol" }, {
  to_string = function(self)
    return "REDUCE " .. self.symbol
  end
})

local AcceptTransition = Struct({ "on" }, {
  to_string = function(self)
    return "ACCEPT"
  end
})

return Struct({ "states" }, {
  add_state = function(self, metadata, default_action)
    local state = State(metadata, default_action)
    state.index = #self.states + 1
    list.push(self.states, state)
    return self
  end,

  add_shift_transition = function(self, from_metadata, transition_on, to_metadata)
    list.push(
      self:state_with_metadata(from_metadata).transitions,
      ShiftTransition(transition_on, self:state_with_metadata(to_metadata)))
    return self
  end,

  add_reduce_transition = function(self, from_metadata, transition_on, symbol)
    list.push(
      self:state_with_metadata(from_metadata).transitions,
      ReduceTransition(transition_on, symbol))
    return self
  end,

  add_accept_transition = function(self, from_metadata, transition_on)
    list.push(
      self:state_with_metadata(from_metadata).transitions,
      AcceptTransition(transition_on))
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
    return list.find(self.states, function(state)
      return state.metadata == metadata
    end)
  end,

  visualize = function(self)
    return list.map(self.states, function(state)
      return self:visualize_state(state)
    end)
  end,

  visualize_state = function(self, state)
    local result = {}
    for i, transition in ipairs(state.transitions) do
      result[transition.on:to_string()] = transition:to_string()
    end
    result["DEFAULT"] = state.default_action and state.default_action:to_string()
    return result
  end
}, {
  ShiftTransition = ShiftTransition,
  ReduceTransition = ReduceTransition,
  AcceptTransition = AcceptTransition
})
