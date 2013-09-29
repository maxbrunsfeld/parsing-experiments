local proto = {}

function proto:get_name()
  return "Ok"
end

return function(name, rules, tokens)
  result = {
    name = name,
    tokens = tokens,
    rules = rules
  }

  setmetatable(result, { __index = grammar })
  return result
end
