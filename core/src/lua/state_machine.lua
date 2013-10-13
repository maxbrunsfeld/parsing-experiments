local util = require("util")
local Struct = require("struct")

local State = Struct({ "metadata", "action", "transitions" }, {
  initialize = function(self, metadata, action)
    self.metadata = metadata
    self.action = action
    self.transitions = {}
  end
})

return Struct({ "states" }, {
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
        result[t[1]:to_string()] = self:visualize_state(t[2])
      end
      return result
    end
  end
})
