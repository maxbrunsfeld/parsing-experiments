local regex = require("regex")

local String, Pattern

String = (function()
  local proto = {}

  function proto:transitions()
    return {}
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
