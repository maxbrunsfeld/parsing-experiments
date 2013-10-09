require("spec_helper")

local StateMachine = require("state_machine")
local Rules = require("rules")
local LrItem = require("lr_item")
local util = require("util")

describe("StateMachine", function()
  local state_machine
  local states

  local t0 = _choice(_sym("t1"), _sym("t2"))
  local t1 = _seq(_sym("t3"), _sym("t5"))
  local t2 = _seq(_sym("t4"), _sym("t5"))
  local t3 = _string("a")
  local t4 = _string("b")
  local t5 = _string("c")

  local rules = {
    { "t0", t0 },
    { "t1", t1 },
    { "t2", t2 },
    { "t3", t3 },
    { "t4", t4 },
    { "t5", t5 }}

  before_each(function()
    state_machine = StateMachine:build(rules)
    states = state_machine.states
  end)

  it("starts with the first rule, and expands the leading non-terminals", function()
    assert_items(1, {
      LrItem("t0", t0),
      LrItem("t1", t1),
      LrItem("t3", t3),
      LrItem("t2", t2),
      LrItem("t4", t4)
    })
  end)

  it("has transitions for each leading symbol", function()
    assert_transition(1, _sym("t1"), 2)
    assert_items(2, {
      LrItem("t0", _end)
    })

    assert_transition(1, _sym("t2"), 2)
    assert_items(2, {
      LrItem("t0", _end)
    })
  end)

  function assert_transition(n, transition_on, m)
    local transitions = states[n].transitions
    local transition_to = util.alist_get(transitions, transition_on)
    assert(
      transition_to,
      "Expected state " .. n ..
      " to have a transition on " .. P.write(transition_on) .. ", " ..
      "but actual transition keys are: " .. P.write(util.alist_keys(transitions)))
    assert(
      util.deepcompare(states[m], transition_to),
      "Expected transtion to item set " .. P.write(states[m].items) .. ", " ..
      "but actual item set is: " .. P.write(transition_to.items))
  end

  function assert_items(n, items)
    assert.are.same(items, states[n].metadata)
  end
end)
