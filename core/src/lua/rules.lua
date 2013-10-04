local Struct = require("struct")
local util = require("util")

local End = Struct({}, {
  initialize = function(self)
    self[1] = "__END__"
  end,

  transitions = function(self)
    return {}
  end
})()

local Sym = Struct({ "name" }, {
  transitions = function(self)
    return {{ self, End }}
  end
})

local Seq = Struct({ "left", "right" }, {
  initialize = function(self, left, right)
    if left == End then
      return right
    else
      self.left = left
      self.right = right
    end
  end,

  transitions = function(self)
    return util.alist_map(self.left:transitions(), function(rule)
      return self.class(rule, self.right)
    end)
  end
})

local Choice = Struct({ "left", "right" }, {
  transitions = function(self)
    return util.alist_merge(
      self.left:transitions(),
      self.right:transitions(),
      self.class)
  end
})

local Repeat = Struct({ "value" }, {
  transitions = function(self)
    return util.alist_map(self.value:transitions(), function(value)
      return Seq(value, Choice(self, End))
    end)
  end
})

local CharClass = (function()
  local function make_char_class(name)
    return Struct({ "coefficient" }, {
      transitions = function(self)
        return {{ self, End }}
      end
    })
  end

  return {
    digit = make_char_class("digit"),
    space = make_char_class("space"),
    word = make_char_class("word")
  }
end)()

local Char = Struct({ "value" }, {
  transitions = function(self)
    return {{ self, End }}
  end
})

return {
  Char = Char,
  CharClass = CharClass,
  Choice = Choice,
  End = End,
  Repeat = Repeat,
  Seq = Seq,
  Sym = Sym
}
