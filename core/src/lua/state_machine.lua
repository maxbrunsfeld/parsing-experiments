local LrItem = require("lr_item")
local Rules = require("rules")
local util = require("util")
local Set = require("set")

local State, StateMachine

State = (function()
  local proto = {}

  function proto:add_item(item)
    if not self.items:contains(item) then
      self.items:add(item)
      local transitions = item:transitions()
      for i, pair in ipairs(transitions) do
        pp(pair[1].class)
        local transition_val = pair[1]
        if transition_val.class == Rules.Sym then
          local next_rule = util.alist_find(self.rules, transition_val.name)[2]
          local next_item = LrItem(transition_val.name, next_rule)
          pp(next_item)
          self:add_item(next_item)
        end
      end
    end
  end

  function proto:transitions()
    return util.mapcat(self.items, function(item)
      return util.map(item:transitions(), function(transition)
        return { transition[1], State(self.rules, transition[2]) }
      end)
    end)
  end

  return function(rules, item)
    local result = { rules = rules, items = Set() }
    setmetatable(result, { __index = proto })
    result:add_item(item)
    return result
  end
end)()

StateMachine = (function()
  local proto = {}

  function proto:build_choice(tokens)
    local symbols = util.map(tokens, function(pair)
      return Rules.Sym(pair[1])
    end)

    local result = symbols[1]
    for i = 2, #symbols do
      result = Rules.Choice(result, symbols[i])
    end
    return result
  end

  function proto:add_state(state)
    if not self.states:contains(state) then
      self.states:add(state)
      local transitions = state:transitions()
      for i, v in ipairs(transitions) do
        self:add_state(v[2])
      end
    end
  end

  return function(tokens)
    local result = { states = Set() }
    setmetatable(result, { __index = proto })
    local state = State(tokens, LrItem(nil, result:build_choice(tokens)))
    result:add_state(state)
    return result
  end
end)()

return StateMachine
