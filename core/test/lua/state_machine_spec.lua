require("spec_helper")

local StateMachine = require("state_machine")
local Tokens = require("tokens")
local Rules = require("rules")
local LrItem = require("lr_item")

describe("StateMachine", function()
  local state_machine
  local tokens = {
    { "t1", Tokens.String("ab") },
    { "t2", Tokens.String("c") },
    { "t3", Tokens.String("d") },
  }

  before_each(function()
    state_machine = StateMachine(tokens)
  end)

  describe("the start state", function()
    local start_state

    before_each(function()
      start_state = state_machine.states[1]
    end)

    it("is begins with a choice between all of the tokens", function()
      assert.are.same(
        LrItem(nil, _choice(_choice(_sym("t1"), _sym("t2")), _sym("t3"))),
        start_state.items[1])
    end)
  end)

  it("has the right next states", function()
    assert.are.same({
      LrItem("t1", _seq(_char("b"), _end))
    }, state_machine.states[2].items)

    -- assert.are.same({
      -- LrItem("t2", _end)
    -- }, state_machine.states[2].items)
  end)
end)