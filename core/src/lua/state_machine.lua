local LrItem = require("lr_item")
local Rules = require("rules")
local util = require("util")
local Struct = require("struct")

local State = Struct({ "rules", "items" }, {
  initialize = function(self, rules, item)
    self.rules = rules
    self.items = {}
    self:add_item(item)
  end,

  add_item = function(self, item)
    if not util.contains(self.items, item) then
      util.push(self.items, item)
      local transitions = item:transitions()
      for i, pair in ipairs(transitions) do
        local transition_val = pair[1]
        if transition_val.class == Rules.Sym then
          local next_rule = util.alist_find(self.rules, transition_val.name)[2]
          local next_item = LrItem(transition_val.name, next_rule)
          self:add_item(next_item)
        end
      end
    end
  end,

  transitions = function(self)
    return util.mapcat(self.items, function(item)
      return util.map(item:transitions(), function(transition)
        return { transition[1], self.class(self.rules, transition[2]) }
      end)
    end)
  end
})

return Struct({ "tokens" }, {
  initialize = function(self, tokens, state)
    self.states = {}
    local state = State(tokens, LrItem(true, self:build_choice(tokens)))
    self:add_state(state)
  end,

  build_choice = function(self, tokens)
    local symbols = util.map(tokens, function(pair)
      return Rules.Sym(pair[1])
    end)

    local result = symbols[1]
    for i = 2, #symbols do
      result = Rules.Choice(result, symbols[i])
    end

    return result
  end,

  add_state = function(self, state)
    if not util.contains(self.states, state) then
      util.push(self.states, state)
      local transitions = state:transitions()
      for i, v in ipairs(transitions) do
        self:add_state(v[2])
      end
    end
  end
})
