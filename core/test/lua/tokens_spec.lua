require("spec_helper")

local Tokens = require("tokens")
local Rules = require("rules")

describe("Tokens", function()
  local token

  describe("calculating transitions", function()
    describe("regex patterns", function()
      it("compiles the regex to a tree of rules", function()
        token = Tokens.Pattern("x*")
        assert.are.same(
          token:transitions(),
          Rules.Repeat(Rules.Char("x")):transitions())
      end)
    end)
  end)
end)
