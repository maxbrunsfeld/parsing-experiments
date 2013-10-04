require("spec_helper")

local Rules = require("rules")

describe("Rules", function()
  local rule

  describe("calculating transitions", function()
    describe("symbols", function()
      it("ends after the symbol is consumed", function()
        rule = _sym("one")
        assert.are.same({
          { _sym("one"), _end }
        }, rule:transitions())
      end)
    end)

    describe("characters", function()
      it("ends after the char is consumed", function()
        rule = _char("x")
        assert.are.same({
          { _char("x"), _end }
        }, rule:transitions())
      end)
    end)

    describe("character classes", function()
      it("ends after the character class is consumed", function()
        rule = _class.space(true)
        assert.are.same({
          { _class.space(true), _end }
        }, rule:transitions())
      end)
    end)

    describe("sequences", function()
      it("leads to the rest of the sequence", function()
        rule = _seq(_sym("one"), _sym("two"))
        assert.are.same({
          { _sym("one"), _sym("two") }
        }, rule:transitions())
      end)
    end)

    describe("choices", function()
      it("merges the transitions for the two sides", function()
        rule = _choice(
          _seq(_sym("one"), _sym("two")),
          _seq(_sym("three"), _sym("four")))

        assert.are.same({
          { _sym("one"), _sym("two") },
          { _sym("three"), _sym("four") }
        }, rule:transitions())
      end)

      it("handles cases where both sides start with the same token", function()
        rule = _choice(
          _seq(_sym("one"), _sym("two")),
          _seq(_sym("one"), _sym("four")))

        assert.are.same({
          { _sym("one"), _choice(_sym("two"), _sym("four")) }
        }, rule:transitions())
      end)
    end)

    describe("repetitions", function()
      it("can end or continue", function()
        rule = _rep(_sym("one"))
        assert.are.same({
          { _sym("one"), _choice(rule, _end) }
        }, rule:transitions())
      end)

      it("handles sequences", function()
        rule = _rep(_seq(_sym("one"), _sym("two")))
        assert.are.same({
          { _sym("one"), _seq(_sym("two"), _choice(rule, _end)) }
        }, rule:transitions())
      end)

      it("handles choices", function()
        rule = _rep(_choice(_sym("one"), _sym("two")))
        assert.are.same({
          { _sym("one"), _choice(rule, _end) },
          { _sym("two"), _choice(rule, _end) }
        }, rule:transitions())
      end)
    end)
  end)
end)
