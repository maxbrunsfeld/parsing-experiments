local Struct = require("util/struct")
local list = require("util/list")
local Rules = require("rules")
local StateMachine = require("state_machine")
local c = require("c_code")

-- string utils
local function concat(...)
  local result = {}
  for i, table in ipairs({...}) do
    for i, entry in ipairs(table) do
      result[#result + 1] = entry
    end
  end
  return result
end

local LOOKAHEAD_CHAR = "lookahead_char"
local LOOKAHEAD_SYM = "lookahead_sym"

local CHAR_CLASS_FNS = {
  space = "iswhitespace",
  digit = "isdigit",
  word = "isalnum",
}

local CodeGenerator = Struct({ "state_machine", "grammar_name", "rules" }, {
  code = function(self)
    return c.render(concat(
      self:includes(),
      c.blank_line,
      c.declare(
        "const char *rule_names[" .. #self.rules .. "]",
        c.array(list.map(self.rules, function(rule)
          return c.string(rule)
        end))),
      c.blank_line,
      self:parse_function()
    ))
  end,

  includes = function(self)
    return {
      c.include_sys("tree_sitter/runtime"),
      c.include_sys("ctype")
    }
  end,

  parse_function = function(self)
    return c.fn_def(
      "TSNode *", self.grammar_name,
      {"const char **input"},
      concat(
        c.declare(
          "TSTree *tree",
          { c.fn_call("ts_tree_new") }),
        c.declare(
          "TSParser *p",
          { c.fn_call("ts_parser_new") }),
        list.mapcat(self.state_machine.states, function(state)
          return concat(
            { c.label(self:label_for_state(state)) },
            self:code_for_state(state))
        end)))
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
      return {
        c.statement(c.fn_call("accept"))
      }
    elseif action.class == StateMachine.Actions.Reduce then
      return {
        c.statement(c.fn_call("reduce", {
          action.symbol_count,
          self:sym(action.new_sym)
        }))
      }
    else
      error("Unknown action: " .. P.write(action))
    end
  end,

  code_for_state_transitions = function(self, transitions)
    return concat(list.mapcat(transitions, function(transition)
      local condition = self:code_for_transition_on(transition[1])

      local body
      if transition[1].class == Rules.Sym then
        body = {
          c._goto(self:label_for_state(transition[2]))
        }
      else
        body = {
          c.statement(c.fn_call("shift")),
          c._goto(self:label_for_state(transition[2])),
        }
      end

      return c._if(condition, body)
    end), {
      c.statement(c.fn_call("error"))
    })
  end,

  label_for_state = function(self, state, i)
    return "state_" .. state.index
  end,

  code_for_transition_on = function(self, transition_on)
    if (transition_on.class == Rules.Char) then
      return c.equals(LOOKAHEAD_CHAR, c.char(transition_on.value))
    elseif (transition_on.class == Rules.CharClass) then
      return c.fn_call(self:fn_for_char_class(transition_on.name), { LOOKAHEAD_CHAR })
    elseif (transition_on.class == Rules.Sym) then
      return c.equals(LOOKAHEAD_SYM, self:sym(transition_on.name))
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
  end
})

return function(...)
  return CodeGenerator(...):code()
end
