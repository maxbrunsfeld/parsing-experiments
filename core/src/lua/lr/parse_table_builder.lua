local list = require("util/list")
local Struct = require("util/struct")
local Rules = require("rules")
local Item = require("lr/item")
local ItemSet = require("lr/item_set")
local ParseTable = require("lr/parse_table")

local AUGMENTED_RULE = {}

local ParseTableBuilder = Struct({ "rules" }, {
  initialize = function(self, rules)
    self.table = ParseTable({})
  end,

  build = function(self)
    local start_rule_name = self.rules[1][1]
    local start_item = Item(AUGMENTED_RULE, Rules.Sym(start_rule_name))
    local item_set = ItemSet(start_item, self.rules)
    self:add_state_for_item_set(item_set)
    return self.table
  end,

  add_state_for_item_set = function(self, item_set)
    if not self.table:has_state_with_metadata(item_set) then
      local action = self:default_action_for_item_set(item_set)
      self.table:add_state(item_set, action)
      local transitions = item_set:transitions(self.rules)
      for _, transition in ipairs(transitions) do
        local transition_on, to_item_set = unpack(transition)
        self:add_transition_between_item_sets(item_set, transition_on, to_item_set)
      end
    end
  end,

  default_action_for_item_set = function(self, item_set)
    local done_item = list.find(item_set, function(item)
      return item:is_done()
    end)
    return done_item and self:action_for_finishing_item(done_item)
  end,

  add_transition_between_item_sets = function(self, item_set, transition_on, to_item_set)
    local action
    if to_item_set:is_done() then
      action = self:action_for_finishing_item(to_item_set[1])
    else
      self:add_state_for_item_set(to_item_set)
      local to_state = self.table:state_with_metadata(to_item_set)
      if transition_on.class == Rules.Sym then
        action = ParseTable.Actions.Shift(to_state)
      else
        action = ParseTable.Actions.Advance(to_state)
      end
    end
    self.table:add_transition(item_set, transition_on, action)
  end,

  action_for_finishing_item = function(self, item)
    if item.name == AUGMENTED_RULE then
      return ParseTable.Actions.Accept()
    else
      return ParseTable.Actions.Reduce(item.name)
    end
  end
})

return function(rules)
  return ParseTableBuilder(rules):build()
end
