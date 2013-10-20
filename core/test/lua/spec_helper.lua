P = require("pl.pretty")
dbg = require("externals/debugger")

local R = require("rules")

_sym = R.Sym
_char = R.Char
_class = R.CharClass
_rep = R.Repeat
_end = R.End
_string = R.String
_pattern = R.Pattern

function tree_builder(binary_fn)
  return function(...)
    local args = {...}
    local result = args[1]
    for i, arg in ipairs(args) do
      if i > 1 then
        result = binary_fn(result, arg)
      end
    end
    return result
  end
end

_choice = tree_builder(R.Choice)
_seq = tree_builder(R.Seq)
