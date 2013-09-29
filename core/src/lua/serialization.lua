local Grammar = require("grammar")
local Rules = require("rules")
local _ = require("underscore")

local function map_pairs(pairs, fn)
  return _.map(pairs, function(pair)
    return { pair[1], fn(pair[2]) }
  end)
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
    end
  end
end

local function read_token(json)
  if type(json) == 'string' then
    return Rules.String(json)
  else
    return Rules.Pattern(json[2])
  end
end

return {
  read_grammar = function(json)
    return Grammar(
      json.name,
      map_pairs(json.rules, read_rule),
      map_pairs(json.tokens, read_token))
  end,

  write_grammar = function()
    return {}
  end
}
