local StateMachine = require("state_machine")
local generate_code = require("code_generator")
local LR = require("lr")
local Rules = require("rules")
local path = require("pl.path")
local alist = require("util/alist")

local PRINT_PARSER = true
local TEST_DIR = string.sub(path.normpath(path.dirname(debug.getinfo(1).source) .. "/.."), 2)
local PARSER_DIR = path.join(TEST_DIR, "c/parsers")

describe("CodeGenerator", function()
  it("works for math expressions", function()
    test_generated_code("math", {
      { "expr", _choice(
          _seq(_sym("expr"), _char("+"), _sym("term")),
          _sym("term")) },
      { "term", _choice(
          _seq(_sym("term"), _char("*"), _sym("factor")),
          _sym("factor")) },
      { "factor", _choice(
          _sym("number"),
          _sym("variable"),
          _seq(_char("("), _sym("expr"), _char(")")))
      },
      { "number", _rep(_class:digit(true)) },
      { "variable", _rep(_class:word(true)) }
    })
  end)
end)

function parser_file_path(grammar_name)
  return path.join(PARSER_DIR, grammar_name .. ".c")
end

function test_generated_code(grammar_name, rules)
  local state_machine = LR.build_state_machine(rules)
  local code = generate_code(state_machine, grammar_name, alist.keys(rules))
  local file_path = parser_file_path(grammar_name)
  if PRINT_PARSER then
    local f = io.open(file_path, "w")
    f:write(code)
    f:close()
  else
    local current_code = io.open(file_path, "r"):read("*all")
    assert.are.equal(current_code, code)
  end
end
