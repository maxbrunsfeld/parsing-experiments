local regex = require("regex")
local Rules = require("rules")

local String, Pattern

String = (function()
  local proto = {}

  function proto:transitions()
    local result = Rules.End
    for i = 1, string.len(self.value) do
      result = Rules.Seq(result, Rules.Char(string.sub(self.value, i, i)))
    end
    return result:transitions()
  end

  return function(value)
    local result = { value = value }
    setmetatable(result, { __index = proto })
    return result
  end
end)()

Pattern = (function()
  local proto = {}

  function proto:transitions()
    return regex.compile(self.value):transitions()
  end

  return function(value)
    local result = { value = value }
    setmetatable(result, { __index = proto })
    return result
  end
end)()

return {
  String = String,
  Pattern = Pattern,
}
