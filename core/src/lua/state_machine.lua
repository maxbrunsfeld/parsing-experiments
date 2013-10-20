local util = require("util")
local Struct = require("struct")

local State = Struct({ "metadata", "action", "transitions" }, {
  initialize = function(self, metadata, action)
    self.transitions = {}
  end
})

return Struct({ "states" }, {
  add_state = function(self, metadata, action)
    local state = State(metadata, action)
    state.index = #self.states + 1
    util.push(self.states, state)
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
    local visited_states = {}
    return self:visualize_state(self.states[1], visited_states)
  end,

  visualize_state = function(self, state, visited_states)
    if util.contains(visited_states, state) then
      return state.index
    else
      util.push(visited_states, state)

      local transitions = {}
      for i, t in ipairs(state.transitions) do
        transitions[t[1]:to_string()] = self:visualize_state(t[2], visited_states)
      end
      local action_string = state.action and state.action:to_string()

      return { state.index, transitions, action_string }
    end
  end
}, {
  Actions = {
    Reduce = Struct({ "new_sym" }, {
      to_string = function(self)
        return "REDUCE " .. self.new_sym
      end
    }),

    Accept = Struct({}, {
      to_string = function()
        return "ACCEPT"
      end
    })()
  }
})
