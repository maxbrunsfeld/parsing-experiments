local list = require("util/list")
local Struct = require("util/struct")

local State = Struct({ "metadata", "default_action", "transitions" }, {
  initialize = function(self)
    self.transitions = {}
  end,

  visualize = function(self)
    local result = {}
    for i, transition in ipairs(self.transitions) do
      result[transition.on:to_string()] = transition.action:to_string()
    end
    result.DEFAULT = self.default_action and self.default_action:to_string()
    return result
  end
})

local Transition = Struct({ "on", "action" })

return Struct({ "states" }, {
  add_state = function(self, metadata, default_action)
    local state = State(metadata, default_action)
    state.index = #self.states + 1
    list.push(self.states, state)
    return state
  end,

  add_transition = function(self, from_metadata, transition_on, action)
    list.push(
      self:state_with_metadata(from_metadata).transitions,
      Transition(transition_on, action))
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
      return state:visualize()
    end)
  end
}, {
  Actions = {
    Advance = Struct({ "to_state" }, {
      to_string = function(self)
        return "ADVANCE " .. self.to_state.index
      end
    }),

    Shift = Struct({ "to_state" }, {
      to_string = function(self)
        return "SHIFT " .. self.to_state.index
      end
    }),

    Reduce = Struct({ "symbol" }, {
      to_string = function(self)
        return "REDUCE " .. self.symbol
      end
    }),

    Accept = Struct({}, {
      to_string = function(self)
        return "ACCEPT"
      end
    })
  }
})
