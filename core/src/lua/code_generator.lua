local Struct = require("util/struct")
local list = require("util/list")
local Rules = require("rules")
local ParseTable = require("lr/parse_table")

local SHIFT_WIDTH = 4
local LOOKAHEAD_CHAR = "lookahead_char"
local LOOKAHEAD_SYM = "lookahead_sym"

local CHAR_CLASS_FNS = {
  space = "iswhitespace",
  digit = "isdigit",
  word = "isalnum",
}

local function join(strings, sep)
  local result = strings[1] or ""
  for i, string in ipairs(strings) do
    if i ~= 1 then
      result = result .. sep .. string
    end
  end
  return result
end

local function rule_count(x)
  return #x.rules
end

local function str(value)
  return '"' .. value .. '"'
end

local function indent(code, n)
  local padding = string.rep("  ", n)
  return padding .. string.gsub(code, "\n", "\n" .. padding)
end

local function symbol_name(rule_name)
  return "symbol_" .. rule_name
end

local function symbols_enum(x)
  return indent(join(list.map(x.rules, function(rule)
    return symbol_name(rule)
  end), ",\n"), 1)
end

local function rule_names_array(x)
  return indent(join(list.map(x.rules, str), ",\n"), 1)
end

local function parser_function_name(x)
  return "ts_parse_math"
end

function equals(left, right)
  return left .. " == " .. right
end

local function fn_for_char_class(class_name)
  return CHAR_CLASS_FNS[class_name] or
    error("Unknown character class: " .. class_name)
end

function char(value)
  return "'" .. value .. "'"
end

local function condition_for_transition_on(transition_on)
  if (transition_on.class == Rules.Char) then
    return equals(LOOKAHEAD_CHAR, char(transition_on.value))
  elseif (transition_on.class == Rules.CharClass) then
    return fn_for_char_class(transition_on.name) .. "(" .. LOOKAHEAD_CHAR .. ")"
  elseif (transition_on.class == Rules.Sym) then
    return equals(LOOKAHEAD_SYM, symbol_name(transition_on.name))
  else
    error("Unknown transition type: " .. P.write(transition_on))
  end
end

local function code_for_action(action, rule)
  if action == nil then return "PARSE_ERROR();" end
  if action.class == ParseTable.Actions.Shift then
    return "SHIFT(" .. action.to_state.index .. ");"
  elseif action.class == ParseTable.Actions.Advance then
    return "ADVANCE(" .. action.to_state.index .. ");"
  elseif action.class == ParseTable.Actions.Accept then
    return "ACCEPT();"
  elseif action.class == ParseTable.Actions.Reduce then
    return "REDUCE(" .. symbol_name(action.symbol) .. ");"
  else
    error("Unknown parser action: " .. action)
  end
end

local function code_for_state_transition(transition)
  local condition = condition_for_transition_on(transition.on)
  local body = code_for_action(transition.action, transition.on)
  return "if (" .. condition .. ")\n" ..  indent(body, 1)
end

local function code_for_state_transitions(transitions)
  return join(list.map(transitions, code_for_state_transition), "\n") .. "\n"
end

local function code_for_state(state)
  return
    (#state.transitions > 0 and
      code_for_state_transitions(state.transitions) or
      "") ..
    (code_for_action(state.default_action))
end

local function case_for_state(state)
  return indent([[
case ]] .. state.index .. [[:
{
]] ..
indent(code_for_state(state), 1) .. [[

  break;
}]], 2)
end

local function cases_for_states(x)
  return join(list.map(x.state_machine.states, case_for_state), "\n\n")
end

local function parser(x)
  return [[
/*
 * Generated by libtree-sitter
 */

#include <tree_sitter/runtime.h>
#include <ctype.h>

enum {
]] ..
symbols_enum(x) ..
[[

};

static const char *rule_names[]] ..  rule_count(x) ..  [[] = {
]] ..
rule_names_array(x) ..
[[

};

TSTree * ]] .. parser_function_name(x) ..  [[(const char *input)
{
  TSTree *tree = ts_tree_new(rule_names);
  SETUP();

  PARSE_STATES {
]] ..
cases_for_states(x) ..
[[

  }

accept:
  return tree;
}
]]
end

return function(state_machine, grammar_name, rules)
  return parser({
    state_machine = state_machine,
    grammar_name = grammar_name,
    rules = rules
  })
end
