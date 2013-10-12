local Struct = require("Struct")
local util = require("util")
local Rules = require("rules")

-- string utils
local function join(strings, sep)
  local result = strings[1]
  for i, string in ipairs(strings) do
    if i ~= 1 then
      result = result .. sep .. string
    end
  end
  return result
end

local SHIFT_WIDTH = 4

return Struct({ "state_machine", "grammar_name" }, {
  initialize = function(self, state_machine, grammar_name)
    self.state_machine = state_machine
    self.grammar_name = grammar_name
    self.indent = 0
  end,

  code = function(self)
    return join({
      self:includes(), "",
      self:parse_function()
    }, "\n")
  end,

  includes = function(self)
    return [[#include <tree_sitter/runtime.h>]]
  end,

  parse_function = function(self)
    return self:_function(
      "TSNode *", self.grammar_name,
      {"const char ** input_string"},
      function()
        return join(
          util.map(self.state_machine.states, function(state, i)
            return self:labeled("state_" .. i, function()
              return self:code_for_state(state)
            end)
          end), "\n")
      end)
  end,

  code_for_state = function(self, state, i)
    return self:lines(util.map(state.transitions, function(transition)
      return _if(self:code_for_transition_on(transition[1]), function()
        return "stuff"
      end)
    end))
  end,

  code_for_transition_on = function(self, transition_on)
    if (transition_on.class == Rules.Char) then
      return "next_char == " .. self:char(transition_on.value)
    else
    end
  end,

  -- generic C code helpers

  char = function(self, value)
    return "'" .. value .. "'"
  end,

  labeled = function(self, label_name, code_fn)
    return label_name .. ":\n" .. code_fn()
  end,

  _if = function(self, condition, body_fn)
    return self:lines({
      "if (" .. condition .. ")",
      "{",
      self:indented(body_fn),
      "}"
    })
  end,

  _function = function(self, return_type, fn_name, params, body_fn)
    local args = "<args>"
    return self:lines({
      return_type ..  " " .. fn_name ..
      "(" .. join(params, ", ") .. ")",
      "{",
      self:indented(body_fn),
      "}"})
  end,

  indented = function(self, fn)
    self.indent = self.indent + 1
    local result = fn()
    self.indent = self.indent - 1
    return result
  end,

  lines = function(self, inputs)
    return join(util.map(inputs, function(line)
      if (type(line) == "table") then
        self:lines(line)
      else
        return string.rep(" ", (self.indent * SHIFT_WIDTH)) .. line
      end
    end), "\n")
  end
})

