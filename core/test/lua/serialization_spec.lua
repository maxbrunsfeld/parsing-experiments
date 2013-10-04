require("spec_helper")

local Grammar = require("grammar")
local Rules = require("rules")
local Tokens = require("tokens")
local Serialization = require("serialization")

describe("Grammar", function()
  describe("reading", function()
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
            "factor"}}}},
      {"tokens", {
        {"times", "*"},
        {"plus", "+"},
        {"number", {"PATTERN", "\\d+"}},
        {"name", {"PATTERN", "\\w+"}}}}}

    before_each(function()
      grammar = Serialization.read_grammar(serial_grammar)
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
        assert.is.equal(2, table.getn(rules))
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
    end)

    describe("the tokens", function()
      local tokens

      before_each(function()
        tokens = grammar.tokens
      end)

      it("gets one for each entry in the tokens JSON", function()
        assert.is.equal(4, table.getn(tokens))
      end)

      it("builds the right tokens", function()
        assert.is.equal('times', tokens[1][1])
        assert.are.same(Tokens.String("*"), tokens[1][2])
      end)
    end)
  end)
end)
