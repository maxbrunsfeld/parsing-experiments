local list = require("util/list")

local function keys(t)
  return list.pluck(t, 1)
end

local function map(t, fn)
  return list.map(t, function(pair)
    return { pair[1], fn(pair[2]) }
  end)
end

local function find(t, entry)
  return list.find(t, function(pair)
    return pair[1] == entry
  end)
end

local function get(alist, key)
  local entry = find(alist, key)
  return entry and entry[2]
end

local function merge(t1, ...)
  local args = {...}
  local fn = table.remove(args, #args)
  local result = list.copy(t1)
  for i, table in ipairs(args) do
    for i, transition in ipairs(table) do
      local existing = find(result, transition[1])
      if existing then
        existing[2] = fn(existing[2], transition[2])
      else
        result[#result + 1] = transition
      end
    end
  end
  return result
end

return {
  get = get,
  keys = keys,
  map = map,
  merge = merge
}
