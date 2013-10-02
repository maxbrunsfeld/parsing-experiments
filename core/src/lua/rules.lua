local End, Seq, Sym, Choice

local util = require("util")

End = (function()
  local proto = {}

  function proto:transitions()
    return {}
  end

  local result = { "__END__" }
  setmetatable(result, { __index = proto })
  return result
end)()

Sym = (function(self)
  local proto = {}

  function proto:transitions()
    return {{ self, End }}
  end

  local function eq(s1, s2)
    return s1.name == s2.name
  end

  return function(name)
    local result = { name = name }
    setmetatable(result, { __index = proto, __eq = eq })
    return result
  end
end)()

Seq = (function()
  local proto = {}

  function proto:transitions()
    return util.alist_map(self.left:transitions(), function(rule)
      return Seq(rule, self.right)
    end)
  end

  return function(left, right)
    if left == End then
      return right
    else
      local result = { left = left, right = right }
      setmetatable(result, { __index = proto })
      return result
    end
  end
end)()

Choice = (function()
  local proto = {}

  function proto:transitions()
    return util.alist_merge(
      self.left:transitions(),
      self.right:transitions(),
      function(left, right)
        return Choice(left, right)
      end)
  end

  return function(left, right)
    local result = { left = left, right = right }
    setmetatable(result, { __index = proto })
    return result
  end
end)()

Repeat = (function()
  local proto = {}

  function proto:transitions()
    return util.alist_map(self.value:transitions(), function(value)
      return Seq(value, Choice(self, End))
    end)
  end

  return function(value)
    local result = { value = value }
    setmetatable(result, { __index = proto })
    return result
  end
end)()

CharClass = (function()
  local proto = {}

  function proto:transitions()
    return {{ self, End }}
  end

  local function Class(name)
    return function(value)
      local result = { value = value }
      setmetatable(result, { __index = proto })
      return result
    end
  end

  return {
    digit = Class("digit"),
    space = Class("space"),
    word = Class("word")
  }
end)()

Char = (function()
  local proto = { class = Char }

  function proto:transitions()
    return {{ self, End }}
  end

  return function(value)
    local result = { value = value }
    setmetatable(result, { __index = proto })
    return result
  end
end)()

return {
  Char = Char,
  CharClass = CharClass,
  Choice = Choice,
  End = End,
  Repeat = Repeat,
  Seq = Seq,
  Sym = Sym
}
