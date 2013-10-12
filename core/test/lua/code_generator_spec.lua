local StateMachine = require("state_machine")
local CodeGenerator = require("code_generator")

describe("CodeGenerator", function()
  local generator

  before_each(function()
    state_machine = StateMachine({})
      :add_state(state1)
      :add_state(state2)
    generator = CodeGenerator(state_machine, "the_grammar")
  end)

  it("works", function()
    print(generator:code())
  end)
end)
