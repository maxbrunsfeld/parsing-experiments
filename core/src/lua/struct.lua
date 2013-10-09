return function(fields, methods, class_methods)
  if not methods then methods = {} end
  if not class_methods then class_methods = {} end
  methods.class = class_methods

  if not methods.initialize then
    methods.initialize = function(self, ...)
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

  setmetatable(class_methods, {
    __call = function(_, ...)
      local result = {}
      setmetatable(result, { __index = methods, __eq = eq })
      return result:initialize(...) or result
    end
  })

  return class_methods
end
