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

    generator = CodeGenerator(state_machine, "the_grammar")
  end)

  it("works", function()
    print("-----")
    print(generator:code())
    print("-----")
  end)
end)
