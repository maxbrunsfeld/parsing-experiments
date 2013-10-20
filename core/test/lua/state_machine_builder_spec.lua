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
    assert.are.same(({
      1, {
        SYM_t0 = { 2, {}, "ACCEPT" },
        SYM_t1 = { 3, {}, "REDUCE t0" },
        SYM_t2 = 3,
        SYM_t3 = {
          4, {
            SYM_t5 = { 5, {}, "REDUCE t1" },
            CHAR_c = { 6, {}, "REDUCE t5" }
          }
        },
        CHAR_a = { 7, {}, "REDUCE t3" },
        SYM_t4 = {
          8, {
            SYM_t5 = { 9, {}, "REDUCE t2" },
            CHAR_c = 6
          }
        },
        CHAR_b = { 10, {}, "REDUCE t4" }
      }
    })[2], state_machine:visualize()[2])
  end)

  it("respects the ordering of choices", function()
    local transition_inputs = util.alist_keys(state_machine.states[1].transitions)
    assert.are.same(_sym("t0"), transition_inputs[1])
    assert.are.same(_sym("t1"), transition_inputs[2])
    assert.are.same(_sym("t2"), transition_inputs[3])
  end)

  it("handles sets of rules with repeating patterns", function()
    local repeating_machine = LR.build_state_machine({
      { "t0", _rep(_class:digit(true)) }
    })

    assert.are.same({
      1, {
        CLASS_digit = {
          3, {
            CLASS_digit = 3
          },
          "REDUCE t0"
        },
        SYM_t0 = { 2, {}, "ACCEPT" }
      }
    }, repeating_machine:visualize())
  end)
end)
