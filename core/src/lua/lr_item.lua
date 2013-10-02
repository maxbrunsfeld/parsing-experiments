local util = require("util")
local LrItem

LrItem = (function()
  local proto = {}

  local function eq(left, right)
    return (left.name == right.name) and (left.rule == right.rule)
  end

  function proto:transitions()
    return util.alist_map(self.rule:transitions(), function(rule)
      return LrItem(self.name, rule)
    end)
  end

  return function(name, rule)
    local result = { name = name, rule = rule }
    setmetatable(result, { __index = proto, __eq = eq })
    return result
  end
end)()

return LrItem
