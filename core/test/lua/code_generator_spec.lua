local StateMachine = require("state_machine")
local CodeGenerator = require("code_generator")
local Rules = require("rules")

describe("CodeGenerator", function()
  local generator

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

    generator = CodeGenerator(state_machine, "the_grammar")
  end)

  it("includes the write C libraries", function()
    assert.equal([[
#include <tree_sitter/runtime.h>
#include <ctype.h>]],
      generator:includes())
  end)

  it("generates a parsing function", function()
    assert.equal([[
TSNode * the_grammar(const char ** input_string)
{
state_1:
    if (lookahead_char == 'a') {
        shift();
        goto state_2;
    }
    if (isdigit(lookahead_char)) {
        shift();
        goto state_3;
    }
    if (lookahead_sym == SYM_rule1) {
        goto state_4;
    }
    if (lookahead_sym == SYM_rule2) {
        goto state_4;
    }
    error();
state_2:
    reduce(1, SYM_rule1);
state_3:
    reduce(1, SYM_rule2);
state_4:
    accept();
}]], 
      generator:parse_function())
  end)
end)
