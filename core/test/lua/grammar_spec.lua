require("spec_helper")

local Grammar = require("grammar")
local Rules = require("rules")

describe("Grammar", function()
  describe("deserializing", function()
    local grammar
    local serial_grammar = {
      {"name", "my-language"},
      {"rules", {
        {"sum",
          {"CHOICE",
            {"SEQ", "product", {"SEQ", "plus", "product"}},
            "product"}},
        {"product",
          {"CHOICE",
            {"SEQ", "factor", {"SEQ", "times", "factor"}},
            "factor"}},
        {"times", {"STRING", "*"}},
        {"plus", {"STRING", "+"}},
        {"number", {"PATTERN", "\\d+"}},
        {"name", {"PATTERN", "\\w+"}}}}}

    before_each(function()
      grammar = Grammar.read(serial_grammar)
    end)

    it("gets the name", function()
      assert.is.equal("my-language", grammar.name)
    end)

    describe("the rules", function()
      local rules

      before_each(function()
        rules = grammar.rules
      end)

      it("gets one for each entry in the rules JSON", function()
        assert.is.equal(6, #rules)
      end)

      it("builds the right rules", function()
        assert.is.equal('sum', rules[1][1])
        assert.are.same(
          Rules.Choice(
            Rules.Seq(
              Rules.Sym("product"),
              Rules.Seq(Rules.Sym("plus"), Rules.Sym("product"))),
            Rules.Sym("product")),
          rules[1][2])

        assert.is.equal('product', rules[2][1])
        assert.are.same(
          Rules.Choice(
            Rules.Seq(
              Rules.Sym("factor"),
              Rules.Seq(Rules.Sym("times"), Rules.Sym("factor"))),
            Rules.Sym("factor")),
          rules[2][2])
      end)

      it("builds the right tokens", function()
        assert.is.equal('times', rules[3][1])
        assert.are.same(Rules.String("*"), rules[3][2])
      end)
    end)
  end)
end)
