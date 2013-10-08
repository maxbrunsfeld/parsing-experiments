local Struct = require("struct")
local util = require("util")
local Seq = require("rules/seq")
local Choice = require("rules/choice")
local End = require("rules/end")

return Struct({ "value" }, {
  transitions = function(self)
    return util.alist_map(self.value:transitions(), function(value)
      return Seq(value, Choice(self, End))
    end)
  end
})
