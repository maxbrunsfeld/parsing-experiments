local Struct = require("Struct")
local util = require("util")
local Rules = require("rules")
local StateMachine = require("state_machine")

-- string utils
local function join(strings, sep)
  local result = strings[1] or ""
  for i, string in ipairs(strings) do
    if i ~= 1 then
      result = result .. sep .. string
    end
  end
  return result
end

local SHIFT_WIDTH = 4
local LOOKAHEAD_CHAR = "lookahead_char"
local LOOKAHEAD_SYM = "lookahead_sym"

local CHAR_CLASS_FNS = {
  space = "iswhitespace",
  digit = "isdigit",
  word = "isalnum",
}

return Struct({ "state_machine", "grammar_name" }, {
  initialize = function(self, state_machine, grammar_name)
    self.state_machine = state_machine
    self.grammar_name = grammar_name
    self.indent = 0

    for i, state in ipairs(state_machine.states) do
      state.index = i
    end
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
          util.map(self.state_machine.states, function(state)
            return join({
              self:label(self:label_for_state(state)),
              self:code_for_state(state)
            }, "\n")
          end), "\n")
      end)
  end,

  code_for_state = function(self, state, i)
    if state.action then
      return self:code_for_state_action(state.action)
    else
      return self:code_for_state_transitions(state.transitions)
    end
  end,

  code_for_state_action = function(self, action)
    if action == StateMachine.Actions.Accept then
      return self:statement(self:fn_call("accept"))
    elseif action.class == StateMachine.Actions.Reduce then
      return self:statement(self:fn_call("reduce", {
        action.symbol_count,
        self:sym(action.new_sym)
      }))
    else
      error("Unknown action: " .. P.dump(action))
    end
  end,

  code_for_state_transitions = function(self, transitions)
    return join(util.map(transitions, function(transition)
      return self:_if(self:code_for_transition_on(transition[1]), function()
        return join({
          self:statement(self:fn_call("consume")),
          self:statement(self:_goto(self:label_for_state(transition[2]))),
        }, "\n")
      end)
    end), "\n")
  end,

  label_for_state = function(self, state, i)
    return "state_" .. state.index
  end,

  code_for_transition_on = function(self, transition_on)
    if (transition_on.class == Rules.Char) then
      return LOOKAHEAD_CHAR .. " == " .. self:char(transition_on.value)
    elseif (transition_on.class == Rules.CharClass) then
      return self:fn_call(self:fn_for_char_class(transition_on.name), { LOOKAHEAD_CHAR })
    elseif (transition_on.class == Rules.Sym) then
      return LOOKAHEAD_SYM .. " == " .. self:sym(transition_on.name)
    else
      error("Unknown transition type: " .. P.write(transition_on))
    end
  end,

  fn_for_char_class = function(self, class_name)
    return CHAR_CLASS_FNS[class_name] or
      error("Unknown character class: " .. class_name)
  end,

  sym = function(self, name)
    return "SYM_" .. name
  end,

  -- generic C code helpers

  fn_call = function(self, fn_name, args)
    local args_string = args and join(args, ", ") or ""
    return fn_name .. "(" .. args_string .. ")"
  end,

  _goto = function(self, label_name)
    return "goto " .. label_name
  end,

  char = function(self, value)
    return "'" .. value .. "'"
  end,

  label = function(self, label_name)
    return label_name .. ":"
  end,

  _if = function(self, condition, body_fn)
    return join({
      self:line("if (" .. condition .. ") {"),
      self:indented(body_fn),
      self:line("}")
    }, "\n")
  end,

  _function = function(self, return_type, fn_name, params, body_fn)
    return join({
      return_type ..  " " .. fn_name ..  "(" .. join(params, ", ") .. ")",
      "{",
      self:indented(body_fn),
      "}"
    }, "\n")
  end,

  indented = function(self, fn)
    self.indent = self.indent + 1
    local result = fn()
    self.indent = self.indent - 1
    return result
  end,

  statement = function(self, input)
    return self:line(input .. ";")
  end,

  line = function(self, input)
    return string.rep(" ", (self.indent * SHIFT_WIDTH)) .. input
  end
})

