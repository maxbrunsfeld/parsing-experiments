local StateMachine = require("state_machine")
local generate_code = require("code_generator")
local LR = require("lr")
local Rules = require("rules")
local path = require("pl.path")

local PRINT_PARSER = true
local TEST_DIR = string.sub(path.normpath(path.dirname(debug.getinfo(1).source) .. "/.."), 2)
local PARSER_DIR = path.join(TEST_DIR, "c/parsers")

describe("CodeGenerator", function()
  local grammar, state_machine

  describe("other grammars", function()
    before_each(function()
      state_machine = StateMachine({})
        :add_state(1)
        :add_state(2, StateMachine.Actions.Reduce(1, "rule1"))
        :add_state(3, StateMachine.Actions.Reduce(1, "rule2"))
        :add_state(4, StateMachine.Actions.Accept)
        :add_transition(1, Rules.Char("a"), 2)
        :add_transition(1, Rules.CharClass:digit(true), 3)
        :add_transition(1, Rules.Sym("rule1"), 4)
        :add_transition(1, Rules.Sym("rule2"), 4)
    end)
  end)

  describe("math expression", function()
    before_each(function()
      state_machine = LR.build_state_machine({
        { "expr", _choice(
            _seq(_sym("expr"), _char("+"), _sym("term")),
            _sym("term")) },
        { "term", _choice(
            _seq(_sym("term"), _char("*"), _sym("factor")),
            _sym("factor")) },
        { "factor", _choice(
            _sym("number"),
            _sym("variable"),
            _seq(_char("("), _sym("expr"), _char(")"))) },
        { "number", _rep(_class:digit(true)) },
        { "variable", _rep(_class:word(true)) }
      })
    end)

    it("generates a parsing function", function()
      -- P.dump(state_machine:visualize())
      test_generated_code(state_machine, "math", {
        "expr", "term", "factor", "number", "variable"
      })
    end)
  end)
end)

function parser_file_path(grammar_name)
  return path.join(PARSER_DIR, grammar_name .. ".c")
end

function test_generated_code(state_machine, grammar_name, rules)
  local code = generate_code(state_machine, grammar_name, rules)
  if PRINT_PARSER then
    print("")
    print(grammar_name .. ":")
    print(code)
  else
    local file_path = parser_file_path(grammar_name)
    local current_code = io.open(file_path, "r"):read("*all")
    assert.are.equal(current_code, code)
  end
end
