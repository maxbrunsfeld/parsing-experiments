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

local function alist_get(alist, key)
  for i, pair in ipairs(alist) do
    if pair[1] == key then
      return pair[2]
    end
  end
end

local function alist_keys(t)
  return pluck(t, 1)
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

function deepcompare(t1,t2,ignore_mt)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then
    return false
  end
  if ty1 ~= 'table' and ty2 ~= 'table' then
    return t1 == t2
  end

  local mt1 = debug.getmetatable(t1)
  local mt2 = debug.getmetatable(t2)
  if mt1 and mt1 == mt2 and mt1.__eq then
    if not ignore_mt then
      return t1 == t2
    end
  else
    if t1 == t2 then
      return true
    end
  end

  for k1, v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not deepcompare(v1, v2) then
      return false
    end
  end
  for k2, _ in pairs(t2) do
    if t1[k2] == nil then
      return false
    end
  end

  return true
end

return {
  map = map,
  contains = contains,
  deepcompare = deepcompare,
  push = push,
  mapcat = mapcat,
  pluck = pluck,
  alist_get = alist_get,
  alist_keys = alist_keys,
  alist_map = alist_map,
  alist_merge = alist_merge
}
