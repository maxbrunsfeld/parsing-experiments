local function copy(t)
  local result = {}
  for k, v in pairs(t) do
    result[k] = v
  end
  return result
end

local function contains(table, el)
  for i, v in ipairs(table) do
    if v == el then
      return true
    end
  end
  return false
end

local function push(table, el)
  table[#table + 1] = el
end

local function map(t, fn)
  local result = {}
  for i, v in ipairs(t) do
    result[i] = fn(v, i)
  end
  return result
end

local function pluck(t, field_name)
  return map(t, function(row) return row[field_name] end)
end

local function mapcat(t, fn)
  local result = {}
  local k = 1
  for i, v in ipairs(t) do
    local term = fn(v)
    for j, v in ipairs(term) do
      result[k] = v
      k = k + 1
    end
  end
  return result
end

local function find(t, fn)
  for i, entry in ipairs(t) do
    if fn(entry) then
      return entry
    end
  end
end

return {
  contains = contains,
  copy = copy,
  deepcompare = deepcompare,
  find = find,
  map = map,
  mapcat = mapcat,
  pluck = pluck,
  push = push
}
