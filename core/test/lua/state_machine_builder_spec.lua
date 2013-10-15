require("spec_helper")

local LR = require("lr")
local Rules = require("rules")
local util = require("util")

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
      SYM_t0 = "ACCEPT",
      SYM_t1 = "REDUCE 1 t0",
      SYM_t2 = "REDUCE 1 t0",
      SYM_t3 = {
        SYM_t5 = "REDUCE 2 t1",
        CHAR_c = "REDUCE 1 t5"
      },
      SYM_t4 = {
        SYM_t5 = "REDUCE 2 t2",
        CHAR_c = "REDUCE 1 t5"
      },
      CHAR_a = "REDUCE 1 t3",
      CHAR_b = "REDUCE 1 t4"
    }, state_machine:visualize())
  end)

  it("respects the ordering of choices", function()
    local transition_inputs = util.alist_keys(state_machine.states[1].transitions)
    assert.are.same(_sym("t0"), transition_inputs[1])
    assert.are.same(_sym("t1"), transition_inputs[2])
    assert.are.same(_sym("t2"), transition_inputs[3])
  end)
end)
