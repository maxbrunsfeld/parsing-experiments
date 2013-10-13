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

  if not methods.eq then
    function methods:eq(other)
      if other.class ~= class_methods then
        return false
      end
      for i, field in ipairs(fields) do
        if self[field] ~= other[field] then
          return false
        end
      end
      return true
    end
  end

  setmetatable(class_methods, {
    __call = function(_, ...)
      local result = {}
      setmetatable(result, { __index = methods, __eq = methods.eq })
      return result:initialize(...) or result
    end
  })

  return class_methods
end
