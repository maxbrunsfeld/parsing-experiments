require("spec_helper")

local Tokens = require("tokens")
local Rules = require("rules")

describe("Tokens", function()
  local token

  describe("converting tokens to rule trees", function()
    local rule

    describe("regex tokens", function()
      local function to_rule(string)
        return Tokens.Pattern(string):to_rule()
      end

      it("parses simple strings", function()
        rule = to_rule("lol")

        assert.are.same(
          _seq(_seq(_char("l"), _char("o")), _char("l")),
          rule)
      end)

      it("parses choices", function()
        rule = to_rule("lol|hah")

        assert.are.same(
          _choice(
            _seq(_seq(_char("l"), _char("o")), _char("l")),
            _seq(_seq(_char("h"), _char("a")), _char("h"))),
          rule)
      end)

      it("parses character classes", function()
        rule = to_rule("\\d")
        assert.are.same(_class.digit(true), rule)

        rule = to_rule("\\s")
        assert.are.same(_class.space(true), rule)

        rule = to_rule("\\w")
        assert.are.same(_class.word(true), rule)

        rule = to_rule("\\S")
        assert.are.same(_class.space(false), rule)

        rule = to_rule("\\W")
        assert.are.same(_class.word(false), rule)
      end)

      it("raises an error for unknown character classes", function()
        assert.has_error(function()
          to_rule("\\z")
        end, "Unknown character class: '\\z'")
      end)

      it("parses repetitions", function()
        rule = to_rule("\\s*")
        assert.are.same(_rep(_class.space(true)), rule)
      end)

      it("parses one-or-more repetitions", function()
        rule = to_rule("x+")
        assert.are.same(_seq(_char("x"), _rep(_char("x"))), rule)
      end)
    end)

    describe("string tokens", function()
      local function to_rule(string)
        return Tokens.String(string):to_rule()
      end

      it("returns a sequence of characters", function()
        rule = to_rule("abcd")

        assert.are.same(
          _seq(
            _seq(
              _seq(
                _char("a"),
                _char("b")),
              _char("c")),
            _char("d")),
          rule)
      end)

      it("handles single characters", function()
        rule = to_rule("a")
        assert.are.same(_char("a"), rule)
      end)
    end)
  end)

  describe("calculating transitions", function()
    describe("regex patterns", function()
      it("compiles the regex to a tree of rules", function()
        token = Tokens.Pattern("x*")
        assert.are.same(
          token:transitions(),
          Rules.Repeat(Rules.Char("x")):transitions())
      end)
    end)

    describe("strings", function()
      it("reduces to a sequence of characters", function()
        token = Tokens.String("abcd")
        assert.are.same(
          token:transitions(),
          _seq(
            _seq(
              _seq(
                _char("a"),
                _char("b")),
              _char("c")),
            _char("d")):transitions())
      end)
    end)
  end)
end)
