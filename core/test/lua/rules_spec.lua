require("spec_helper")

local Rules = require("rules")

describe("Rules", function()
  local rule

  describe("calculating transitions", function()
    describe("symbols", function()
      it("ends after the symbol is consumed", function()
        rule = Rules.Sym("one")

        assert.are.same({
          one = Rules.End
        }, rule:transitions())
      end)
    end)

    describe("sequences", function()
      it("leads to the rest of the sequence", function()
        rule = Rules.Seq(Rules.Sym("one"), Rules.Sym("two"))

        assert.are.same({
          one = Rules.Sym("two")
        }, rule:transitions())
      end)
    end)

    describe("choices", function()
      it("merges the transitions for the two sides", function()
        rule = Rules.Choice(
          Rules.Seq(
            Rules.Sym("one"),
            Rules.Sym("two")),
          Rules.Seq(
            Rules.Sym("three"),
            Rules.Sym("four")))

        assert.are.same({
          one = Rules.Sym("two"),
          three = Rules.Sym("four")
        }, rule:transitions())
      end)
    end)
  end)
end)
