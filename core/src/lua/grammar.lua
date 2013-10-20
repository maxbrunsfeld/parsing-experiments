local Struct = require("util/struct")
local alist = require("util/alist")
local Rules = require("rules")

local function map_pairs(t, fn)
  local result = {}
  for i, pair in ipairs(t) do
    result[i] = { pair[1], fn(pair[2]) }
  end
  return result
end

local function read_rule(json)
  if type(json) == 'string' then
    return Rules.Sym(json)
  else
    local head = json[1]
    if head == 'CHOICE' then
      return Rules.Choice(
        read_rule(json[2]),
        read_rule(json[3]))
    elseif head == 'SEQ' then
      return Rules.Seq(
        read_rule(json[2]),
        read_rule(json[3]))
    elseif json[1] == 'PATTERN' then
      return Rules.Pattern(json[2])
    else
      return Rules.String(json[2])
    end
  end
end

local Grammar

Grammar = Struct({ "name", "rules" }, {}, {
  read = function(json)
    return Grammar(
      alist.get(json, "name"),
      map_pairs(alist.get(json, "rules"), read_rule))
  end
})

return Grammar
