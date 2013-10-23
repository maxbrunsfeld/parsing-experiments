require("spec_helper")

local list = require("util/list")
local LR = require("lr")
local Rules = require("rules")

describe("StateMachine", function()
  local state_machine
  local rules = {
    { "t0", _choice(_sym("t1"), _sym("t2")) },
    { "t1", _seq(_sym("t3"), _sym("t5")) },
    { "t2", _seq(_sym("t4"), _sym("t5")) },
    { "t3", _string("a") },
    { "t4", _string("b") },
    { "t5", _string("c") }}

  before_each(function()
    state_machine = LR.build_state_machine(rules)
  end)

  it("turns grammar rules into state transitions and reduce/accept actions", function()
    assert.are.same({
      {
        SYM_t0 = "ACCEPT",
        SYM_t1 = "REDUCE t0",
        SYM_t2 = "REDUCE t0",
        SYM_t3 = "SHIFT 2",
        SYM_t4 = "SHIFT 3",
        CHAR_a = "REDUCE t3",
        CHAR_b = "REDUCE t4"
      },
      {
        SYM_t5 = "REDUCE t1",
        CHAR_c = "REDUCE t5"
      },
      {
        SYM_t5 = "REDUCE t2",
        CHAR_c = "REDUCE t5"
      }
    }, state_machine:visualize())
  end)

  it("respects the ordering of choices", function()
    local transition_inputs = list.pluck(state_machine.states[1].transitions, "on")
    assert.are.same(_sym("t0"), transition_inputs[1])
    assert.are.same(_sym("t1"), transition_inputs[2])
    assert.are.same(_sym("t2"), transition_inputs[3])
  end)

  it("handles sets of rules with repeating patterns", function()
    local repeating_machine = LR.build_state_machine({
      { "int", _rep(_class:digit(true)) }
    })

    assert.are.same({
      {
        SYM_int = "ACCEPT",
        CLASS_digit = "SHIFT 2",
      },
      {
        CLASS_digit = "SHIFT 2",
        DEFAULT = "REDUCE int"
      }
    }, repeating_machine:visualize())
  end)
end)
