require("spec_helper")

local list = require("util/list")
local build_parse_table = require("lr/parse_table_builder")
local Rules = require("rules")

describe("ParseTable", function()
  local state_machine
  local rules = {
    { "t0", _choice(_sym("t1"), _sym("t2")) },
    { "t1", _seq(_sym("t3"), _sym("t5")) },
    { "t2", _seq(_sym("t4"), _sym("t5")) },
    { "t3", _string("a") },
    { "t4", _string("b") },
    { "t5", _string("c") }}

  before_each(function()
    state_machine = build_parse_table(rules)
  end)

  it("turns grammar rules into state transitions and reduce/accept actions", function()
    assert.are.same({
      {
        SYM_t0 = 'SHIFT 2',
        SYM_t1 = 'SHIFT 3',
        SYM_t2 = 'SHIFT 3',
        SYM_t3 = 'SHIFT 4',
        CHAR_b = 'ADVANCE 10',
        SYM_t4 = 'SHIFT 8',
        CHAR_a = 'ADVANCE 7',
      },
      {
        DEFAULT = 'ACCEPT'
      },
      {
        DEFAULT = 'REDUCE 1 t0'
      },
      {
        SYM_t5 = 'SHIFT 5',
        CHAR_c = 'ADVANCE 6',
      },
      {
        DEFAULT = 'REDUCE 2 t1'
      },
      {
        DEFAULT = 'REDUCE 0 t5'
      },
      {
        DEFAULT = 'REDUCE 0 t3'
      },
      {
        CHAR_c = 'ADVANCE 6',
        SYM_t5 = 'SHIFT 9'
      },
      {
        DEFAULT = 'REDUCE 2 t2'
      },
      {
        DEFAULT = 'REDUCE 0 t4'
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
    local repeating_machine = build_parse_table({
      { "int", _rep(_class:digit(true)) }
    })

    assert.are.same({
      {
        SYM_int = "SHIFT 2",
        CLASS_digit = "ADVANCE 3",
      },
      {
        DEFAULT = "ACCEPT"
      },
      {
        CLASS_digit = "ADVANCE 3",
        DEFAULT = "REDUCE 0 int"
      }
    }, repeating_machine:visualize())
  end)
end)
