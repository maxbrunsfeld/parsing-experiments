local function copy_table(t)
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
    result[i] = fn(v)
  end
  return result
end

local function pluck(t, field_name)
  return map(t, function(row) return row[field_name] end)
end

local function mapcat(t, fn)
  local result = {}
  for i, v in ipairs(t) do
    local term = fn(v)
    for j, v in ipairs(term) do
      result[i + j - 1] = v
    end
  end
  return result
end

local function alist_map(t, fn)
  return map(t, function(pair)
    return { pair[1], fn(pair[2]) }
  end)
end

local function alist_find(t, entry)
  for i, pair in ipairs(t) do
    if pair[1] == entry then
      return pair
    end
  end
end

local function alist_merge(t1, t2, fn)
  local result = copy_table(t1)
  for i, transition in ipairs(t2) do
    local existing = alist_find(result, transition[1])
    if existing then
      existing[2] = fn(existing[2], transition[2])
    else
      result[#result + 1] = transition
    end
  end
  return result
end

return {
  map = map,
  contains = contains,
  push = push,
  mapcat = mapcat,
  pluck = pluck,
  alist_map = alist_map,
  alist_find = alist_find,
  alist_merge = alist_merge
}
