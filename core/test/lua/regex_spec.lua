require("spec_helper")

local Rules = require("Rules")
local regex = require("regex")

describe("compiling a regex", function()
  local rule

  it("parses simple strings", function()
    rule = regex("lol")

    assert.are.same(
      _seq(_seq(_char("l"), _char("o")), _char("l")),
      rule)
  end)

  it("parses choices", function()
    rule = regex("lol|hah")

    assert.are.same(
      _choice(
        _seq(_seq(_char("l"), _char("o")), _char("l")),
        _seq(_seq(_char("h"), _char("a")), _char("h"))),
      rule)
  end)

  it("parses character classes", function()
    rule = regex("\\d")
    assert.are.same(_class.digit(true), rule)

    rule = regex("\\s")
    assert.are.same(_class.space(true), rule)

    rule = regex("\\w")
    assert.are.same(_class.word(true), rule)

    rule = regex("\\S")
    assert.are.same(_class.space(false), rule)

    rule = regex("\\W")
    assert.are.same(_class.word(false), rule)
  end)

  it("raises an error for unknown character classes", function()
    assert.has_error(function()
      regex("\\z")
    end, "Unknown character class: '\\z'")
  end)

  it("parses repetitions", function()
    rule = regex("\\s*")
    assert.are.same(_rep(_class.space(true)), rule)
  end)

  it("parses one-or-more repetitions", function()
    rule = regex("x+")
    assert.are.same(_seq(_char("x"), _rep(_char("x"))), rule)
  end)
end)
