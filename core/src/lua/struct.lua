return function(fields, proto)
  if not proto.initialize then
    proto.initialize = function(self, ...)
      local args = {...}
      for i, v in ipairs(fields) do
        if args[i] == nil then
          error("Missing field: " .. v)
        end
        self[v] = args[i]
      end
    end
  end

  local function eq(struct1, struct2)
    for i, field in ipairs(fields) do
      if struct1[field] ~= struct2[field] then
        return false
      end
    end
    return true
  end

  local function constructor(...)
    local result = {}
    setmetatable(result, { __index = proto, __eq = eq })
    return result:initialize(...) or result
  end

  proto.class = constructor

  return constructor
end
