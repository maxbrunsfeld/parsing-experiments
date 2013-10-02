local proto = {}

function proto:contains(el)
  for i, v in ipairs(self) do
    if v == el then
      return true
    end
  end
  return false
end

function proto:add(el)
  if not self:contains(el) then
    self[#self + 1] = el
  end
end

return function()
  local result = {}
  setmetatable(result, { __index = proto })
  return result
end
