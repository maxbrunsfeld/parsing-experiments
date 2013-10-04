local Struct = require("struct")
local util = require("util")

local End, Seq, Sym, Choice

Sym = Struct({ "name" }, {
  transitions = function(self)
    return {{ self, End }}
  end
})

Seq = Struct({ "left", "right" }, {
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
      return Seq(rule, self.right)
    end)
  end
})

Choice = Struct({ "left", "right" }, {
  transitions = function(self)
    return util.alist_merge(
      self.left:transitions(),
      self.right:transitions(),
      self.class)
  end
})

Repeat = Struct({ "value" }, {
  transitions = function(self)
    return util.alist_map(self.value:transitions(), function(value)
      return Seq(value, Choice(self, End))
    end)
  end
})

CharClass = (function()
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

Char = Struct({ "value" }, {
  transitions = function(self)
    return {{ self, End }}
  end
})

End = Struct({}, {
  transitions = function(self)
    return {}
  end
})()

End[1] = "__END__"

return {
  Char = Char,
  CharClass = CharClass,
  Choice = Choice,
  End = End,
  Repeat = Repeat,
  Seq = Seq,
  Sym = Sym
}
