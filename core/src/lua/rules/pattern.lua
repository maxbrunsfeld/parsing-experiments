local Struct = require("util/struct")
local Seq = require("rules/seq")
local End = require("rules/end")
local Char = require("rules/char")
local Choice = require("rules/choice")
local Repeat = require("rules/repeat")
local CharClass = require("rules/char_class")

local CHAR_CLASS_MAP = {
  d = { "digit", true },
  D = { "digit", false },
  s = { "space", true },
  S = { "space", false },
  w = { "word", true },
  W = { "word", false }
}

local RegexParser = Struct({ 'input' }, {
  initialize = function(self, input)
    self.i = 1
    self.len = string.len(input)
  end,

  main = function(self)
    local term = self:term()
    if self:has_more() and self:peek() == '|' then
      self:consume(1)
      return Choice(term, self:term())
    else
      return term
    end
  end,

  term = function(self)
    local result = End
    while self:has_more() and (self:peek() ~= '|') do
      result = Seq(result, self:factor())
    end
    return result
  end,

  factor = function(self)
    local result = self:atom()
    if self:has_more() then
      local char = self:peek()
      if char == '*' then
        self:consume(1)
        result = Repeat(result)
      elseif char == '+' then
        self:consume(1)
        result = Seq(result, Repeat(result))
      end
    end
    return result
  end,

  atom = function(self)
    if self:peek() == "\\" then
      self:consume(1)
      local char = self:next()
      local class_desc = CHAR_CLASS_MAP[char]
      if not class_desc then
        error("Unknown character class: '\\" .. char .."'")
      end
      return CharClass[class_desc[1]](CharClass, class_desc[2])
    else
      return Char(self:next())
    end
  end,

  -- primitives

  next = function(self)
    local result = self:peek()
    self:consume(1)
    return result
  end,

  peek = function(self)
    return string.sub(self.input, self.i, self.i)
  end,

  consume = function(self, n)
    self.i = self.i + n
  end,

  has_more = function(self)
    return self.i <= self.len
  end
})

return Struct({ 'value' }, {
  expand = function(self)
    return RegexParser(self.value):main()
  end,

  transitions = function(self)
    return self:expand():transitions()
  end
})
