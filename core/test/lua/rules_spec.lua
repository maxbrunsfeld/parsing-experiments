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

    describe("patterns", function()
      it("compiles the regex to a tree of rules", function()
        rule = Rules.Pattern("x*")
        assert.are.same(
          rule:transitions(),
          Rules.Repeat(Rules.Char("x")):transitions())
      end)
    end)

    describe("strings", function()
      it("reduces to a sequence of characters", function()
        rule = Rules.String("abcd")
        assert.are.same(
          rule:transitions(),
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

  describe("expanding regex patterns", function()
    local function expand_pattern(string)
      return Rules.Pattern(string):expand()
    end

    it("parses simple strings", function()
      rule = expand_pattern("lol")

      assert.are.same(
        _seq(_seq(_char("l"), _char("o")), _char("l")),
        rule)
    end)

    it("parses choices", function()
      rule = expand_pattern("lol|hah")

      assert.are.same(
        _choice(
          _seq(_seq(_char("l"), _char("o")), _char("l")),
          _seq(_seq(_char("h"), _char("a")), _char("h"))),
        rule)
    end)

    it("parses character classes", function()
      rule = expand_pattern("\\d")
      assert.are.same(_class.digit(true), rule)

      rule = expand_pattern("\\s")
      assert.are.same(_class.space(true), rule)

      rule = expand_pattern("\\w")
      assert.are.same(_class.word(true), rule)

      rule = expand_pattern("\\S")
      assert.are.same(_class.space(false), rule)

      rule = expand_pattern("\\W")
      assert.are.same(_class.word(false), rule)
    end)

    it("raises an error for unknown character classes", function()
      assert.has_error(function()
        expand_pattern("\\z")
      end, "Unknown character class: '\\z'")
    end)

    it("parses repetitions", function()
      rule = expand_pattern("\\s*")
      assert.are.same(_rep(_class.space(true)), rule)
    end)

    it("parses one-or-more repetitions", function()
      rule = expand_pattern("x+")
      assert.are.same(_seq(_char("x"), _rep(_char("x"))), rule)
    end)
  end)

  describe("expanding strings", function()
    local function expand_string(string)
      return Rules.String(string):expand()
    end

    it("returns a sequence of characters", function()
      rule = expand_string("abcd")

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
      rule = expand_string("a")
      assert.are.same(_char("a"), rule)
    end)
  end)
end)
