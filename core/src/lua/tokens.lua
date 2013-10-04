local regex = require("regex")
local Rules = require("rules")
local Struct = require("struct")

local String = Struct({ 'value' }, {
  transitions = function(self)
    local result = Rules.End
    for i = 1, string.len(self.value) do
      result = Rules.Seq(result, Rules.Char(string.sub(self.value, i, i)))
    end
    return result:transitions()
  end
})

local Pattern = Struct({ 'value' }, {
  transitions = function(self)
    return regex(self.value):transitions()
  end
})

return {
  String = String,
  Pattern = Pattern,
}
