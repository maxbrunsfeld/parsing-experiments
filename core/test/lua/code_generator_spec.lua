local StateMachine = require("state_machine")
local CodeGenerator = require("code_generator")

describe("CodeGenerator", function()
  local generator

  before_each(function()
    state_machine = StateMachine({})
      :add_state(1)
      :add_state(2)
      :add_transition(1, "hi", 2)
    generator = CodeGenerator(state_machine, "the_grammar")
  end)

  it("works", function()
    print(generator:code())
  end)
end)
