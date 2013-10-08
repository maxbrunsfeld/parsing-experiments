local Struct = require("struct")
local End = require("rules/end")

return (function()
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
