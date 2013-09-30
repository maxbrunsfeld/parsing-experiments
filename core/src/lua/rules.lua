local End, Seq, Sym, Choice

local function copy_table(t)
  local result = {}
  for k, v in pairs(t) do
    result[k] = v
  end
  return result
end

local function map_transitions(t, fn)
  local result = {}
  for i, pair in ipairs(t) do
    result[i] = { pair[1], fn(pair[2]) }
  end
  return result
end

local function find_transition(entry, t)
  for i, pair in ipairs(t) do
    if pair[1] == entry[1] then
      return pair
    end
  end
end

local function merge_transitions(t1, t2, fn)
  local result = copy_table(t1)
  for i, transition in ipairs(t2) do
    local existing = find_transition(transition, result)
    if existing then
      existing[2] = fn(existing[2], transition[2])
    else
      result[#result + 1] = transition
    end
  end
  return result
end

End = "__END__"

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
    return {{ self, End }}
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
