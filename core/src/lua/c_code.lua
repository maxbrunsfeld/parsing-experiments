local list = require("util/list")

local SHIFT_WIDTH = 4

local function join(strings, sep)
  local result = strings[1] or ""
  for i, string in ipairs(strings) do
    if i ~= 1 then
      result = result .. sep .. string
    end
  end
  return result
end

local function concat(table1, ...)
  local result = table1
  for i, table in ipairs({...}) do
    for i, entry in ipairs(table) do
      result[#result + 1] = entry
    end
  end
  return result
end

local blank_line = { "" }

function array(elements)
  return concat({ "{", },
    indented(list.map(elements, function(el) return line(el .. ",") end)),
    { "}" })
end

function equals(left, right)
  return left .. " == " .. right
end

function render(lines)
  return join(list.map(lines, function(line)
    if type(line) == 'string' then
      return line
    elseif line.indent then
      return string.rep(" ", (line.indent * SHIFT_WIDTH)) .. line.value
    else
      return line.value
    end
  end), "\n")
end

function fn_call(name, args)
  return name .. "(" .. (args and join(args, ", ") or "") .. ")"
end

function fn_def(return_type, name, params, body)
  return concat({
    return_type ..  " " .. name ..  "(" .. join(params, ", ") .. ")",
    "{",
  }, indented(body), {
    "}"
  })
end

function _goto(label_name)
  return statement("goto " .. label_name)
end

function char(value)
  return "'" .. value .. "'"
end

function label(label_name)
  return label_name .. ":"
end

function _if(condition, body)
  return concat({
    line("if (" .. condition .. ") {"),
  }, 
    indented(body),
  {
    line("}")
  })
end

function indented(lines)
  return list.map(lines, function(line)
    if line.indent ~= nil then
      line.indent = line.indent + 1
    end
    return line
  end)
end

function statement(input)
  return line(input .. ";")
end

function _string(value)
  return '"' .. value .. '"'
end

function declare(variable, value)
  value[1] = variable .. " = " .. value[1]
  value[#value] = value[#value] .. ";"
  return value
end

function include_sys(lib_name)
  return line("#include <" .. lib_name .. ".h>")
end

function line(input)
  return { value = input, indent = 0 }
end

return {
  _goto = _goto,
  _if = _if,
  array = array,
  blank_line = blank_line,
  char = char,
  declare = declare,
  equals = equals,
  fn_call = fn_call,
  fn_def = fn_def,
  include_sys = include_sys,
  label = label,
  line = line,
  render = render,
  string = _string,
  statement = statement,
}
