local util = require("util")

return function(field_names, methods, class_methods)
  if not methods then methods = {} end
  if not class_methods then class_methods = {} end
  methods.class = class_methods
  local required_fields = methods.required or {}

  local function set_fields(obj, ...)
    local field_values = {...}
    for i, name in ipairs(field_names) do
      obj[name] = field_values[i]
      if obj[name] == nil and util.contains(required_fields, name) then
        error("Missing field - " .. name)
      end
    end
  end

  if not methods.eq then
    function methods:eq(other)
      if other.class ~= class_methods then
        return false
      end
      for i, field in ipairs(field_names) do
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
      set_fields(result, ...)
      if result.initialize then
        return result:initialize(...) or result
      else
        return result
      end
    end
  })

  return class_methods
end
