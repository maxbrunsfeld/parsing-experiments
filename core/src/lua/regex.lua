local Rules = require("rules")

local Compiler = (function()
  local proto = {}

  local CHAR_CLASS_MAP = {
    d = { "digit", true },
    D = { "digit", false },
    s = { "space", true },
    S = { "space", false },
    w = { "word", true },
    W = { "word", false }
  }

  function proto:main()
    local term = self:term()
    if self:has_more() and self:peek() == '|' then
      self:consume(1)
      return Rules.Choice(term, self:term())
    else
      return term
    end
  end

  function proto:term()
    local result = Rules.End
    while self:has_more() and (self:peek() ~= '|') do
      result = Rules.Seq(result, self:factor())
    end
    return result
  end

  function proto:factor()
    local result = self:atom()
    if self:has_more() then
      local char = self:peek()
      if char == '*' then
        self:consume(1)
        result = Rules.Repeat(result)
      elseif char == '+' then
        self:consume(1)
        result = Rules.Seq(result, Rules.Repeat(result))
      end
    end
    return result
  end

  function proto:atom()
    if self:peek() == "\\" then
      self:consume(1)
      local char = self:next()
      local class_desc = CHAR_CLASS_MAP[char]
      if not class_desc then
        error("Unknown character class: '\\" .. char .."'")
      end
      return Rules.CharClass[class_desc[1]](class_desc[2])
    else
      return Rules.Char(self:next())
    end
  end

  -- primitives

  function proto:next()
    local result = self:peek()
    self:consume(1)
    return result
  end

  function proto:peek()
    return string.sub(self.input, self.i, self.i)
  end

  function proto:consume(n)
    self.i = self.i + n
  end

  function proto:has_more()
    return self.i <= self.len
  end

  return function(input)
    local result = {
      input = input,
      i = 1,
      len = string.len(input),
      value = nil
    }
    setmetatable(result, { __index = proto })
    return result
  end
end)()

local function compile(input)
  return Compiler(input):main()
end

return { compile = compile }
