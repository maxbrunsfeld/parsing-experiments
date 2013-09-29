local End, Seq, Sym, Choice

local function map_transitions(t, fn)
  local result = {}
  for k, v in pairs(t) do
    result[k] = fn(v)
  end
  return result
end

local function merge_transitions(t1, t2, fn)
  local result = {}
  for k, v in pairs(t1) do
    result[k] = v
  end
  for k, v in pairs(t2) do
    local v1 = t1[k]
    if v1 then
      result[k] = fn(v1, v)
    else
      result[k] = v
    end
  end
  return result
end

End = "__END__"

Sym = (function(self)
  local proto = {}

  function proto:transitions()
    return { [self.name] = End }
  end

  return function(name)
    local result = { name = name }
    setmetatable(result, { __index = proto })
    return result
  end
end)()

Seq = (function()
  local proto = {}

  function proto:transitions()
    return map_transitions(self.left:transitions(), function(rule)
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
    return merge_transitions(
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
    return map_transitions(self.value:transitions(), function(value)
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
    return { [self.value] = End }
  end

  return function(value)
    local result = { value = value }
    setmetatable(result, { __index = proto })
    return result
  end
end)()

Char = (function()
  local proto = {}

  function proto:transitions()
    return { [self.value] = End }
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
