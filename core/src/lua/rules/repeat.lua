local Struct = require("util/struct")
local alist = require("util/alist")
local Seq = require("rules/seq")
local End = require("rules/end")
local Choice = require("rules/choice")

return Struct({ "value" }, {
  transitions = function(self)
    return alist.map(self.value:transitions(), function(value)
      return Seq(value, Choice(self, End))
    end)
  end
})
