require("spec_helper")

local Rules = require("Rules")
local regex = require("regex")

describe("compiling a regex", function()
  local rule

  it("parses simple strings", function()
    rule = regex.compile("lol")

    assert.are.same(
      _seq(_seq(_char("l"), _char("o")), _char("l")),
      rule)
  end)

  it("parses choices", function()
    rule = regex.compile("lol|hah")

    assert.are.same(
      _choice(
        _seq(_seq(_char("l"), _char("o")), _char("l")),
        _seq(_seq(_char("h"), _char("a")), _char("h"))),
      rule)
  end)

  it("parses character classes", function()
    rule = regex.compile("\\d")
    assert.are.same(_class("digit"), rule)

    rule = regex.compile("\\s")
    assert.are.same(_class("space"), rule)

    rule = regex.compile("\\w")
    assert.are.same(_class("word"), rule)
  end)

  it("parses repetitions", function()
    rule = regex.compile("\\s*")
    assert.are.same(_rep(_class("space")), rule)
  end)

  it("parses one-or-more repetitions", function()
    rule = regex.compile("x+")
    assert.are.same(_seq(_char("x"), _rep(_class("x"))), rule)
  end)
end)
