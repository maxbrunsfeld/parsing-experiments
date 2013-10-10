require("spec_helper")

local StateMachine = require("state_machine")
local Rules = require("rules")
local LrItem = require("lr_item")
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
    state_machine = StateMachine:build(rules)
  end)

  it("turns grammar rules into state transitions and push/accept actions", function()
    assert.are.same({
      SYM_t1 = { "ACCEPT" },
      SYM_t2 = { "ACCEPT" },
      SYM_t3 = {
        SYM_t5 = { "PUSH", "t1" },
        CHAR_c = { "PUSH", "t5" }
      },
      SYM_t4 = {
        SYM_t5 = { "PUSH", "t2" },
        CHAR_c = { "PUSH", "t5" }
      },
      CHAR_a = { "PUSH", "t3" },
      CHAR_b = { "PUSH", "t4" }
    }, state_machine:visualize())
  end)

  it("respects the ordering of choices", function()
    local transition_inputs = util.alist_keys(state_machine.states[1].transitions)
    assert.are.same(_sym("t1"), transition_inputs[1])
    assert.are.same(_sym("t2"), transition_inputs[2])
  end)
end)
