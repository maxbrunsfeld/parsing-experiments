local Struct = require("struct")
local Seq = require("rules/seq")
local End = require("rules/end")
local Char = require("rules/char")

return Struct({ 'value' }, {
  expand = function(self)
    local result = End
    for i = 1, string.len(self.value) do
      result = Seq(result, Char(string.sub(self.value, i, i)))
    end
    return result
  end,

  transitions = function(self)
    return self:expand():transitions()
  end
})
