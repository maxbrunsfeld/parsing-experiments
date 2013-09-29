require("spec_helper")

local Rules = require("rules")

describe("Rules", function()
  local rule

  describe("calculating transitions", function()
    describe("symbols", function()
      it("ends after the symbol is consumed", function()
        rule = Rules.Sym("one")
        assert.are.same({ one = Rules.End }, rule:transitions())
      end)
    end)

    describe("characters", function()
      it("ends after the char is consumed", function()
        rule = Rules.Char("x")
        assert.are.same({ x = Rules.End }, rule:transitions())
      end)
    end)

    describe("characters", function()
      it("ends after the char is consumed", function()
        rule = Rules.CharClass("space")
        assert.are.same({ space = Rules.End }, rule:transitions())
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

      it("handles cases where both sides start with the same token", function()
        rule = Rules.Choice(
          Rules.Seq(
            Rules.Sym("one"),
            Rules.Sym("two")),
          Rules.Seq(
            Rules.Sym("one"),
            Rules.Sym("four")))

        assert.are.same({
          one = Rules.Choice(Rules.Sym("two"), Rules.Sym("four"))
        }, rule:transitions())
      end)
    end)

    describe("repetitions", function()
      it("can end or continue", function()
        rule = Rules.Repeat(Rules.Sym("one"))

        assert.are.same({
          one = Rules.Choice(rule, Rules.End)
        }, rule:transitions())
      end)

      it("handles sequences", function()
        rule = Rules.Repeat(Rules.Seq(Rules.Sym("one"), Rules.Sym("two")))

        assert.are.same({
          one = Rules.Seq(
            Rules.Sym("two"),
            Rules.Choice(rule, Rules.End))
        }, rule:transitions())
      end)

      it("handles choices", function()
        rule = Rules.Repeat(Rules.Choice(Rules.Sym("one"), Rules.Sym("two")))

        assert.are.same({
          one = Rules.Choice(rule, Rules.End),
          two = Rules.Choice(rule, Rules.End)
        }, rule:transitions())
      end)
    end)
  end)
end)
