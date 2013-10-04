local Struct = require("struct")

describe("Struct", function()
  local SomeStruct = Struct({ "field_a", "field_b" }, {
    initialize = function(self, fa, fb)
      self.field_a = fa
      self.field_b = fb
      self.field_c = "from-initialize"
    end,

    do_stuff = function(self)
      return self.field_b + self.field_c
    end
  })

  it("creates a constructor", function()
    local struct = SomeStruct(1, 2)
    assert.equal(struct.field_a, 1)
    assert.equal(struct.field_b, 2)
  end)

  it("assigns objects a class", function()
    local struct = SomeStruct(1, 2)
    assert.equal(struct.class, SomeStruct)
  end)

  it("calls the initialize method if one is provided", function()
    local struct = SomeStruct(1, 2)
    assert.equal(struct.field_c, "from-initialize")
  end)

  it("works when an initialize method is not provided", function()
    local OtherStruct = Struct({ "a", "b" }, {})
    local struct = OtherStruct(1, 2)
  end)

  describe("equality", function()
    local Struct1 = Struct({ "a", "b" }, {})
    local Struct2 = Struct({ "a", "b" }, {})

    it("returns false for different struct types", function()
      local s1 = Struct1(1, 2)
      local s2 = Struct2(1, 2)
      assert.falsy(s1 == s2)
    end)

    it("returns true for structs with the same type and field values", function()
      local s1 = Struct1(1, 2)
      local s2 = Struct1(1, 2)
      assert.truthy(s1 == s2)
    end)
  end)
end)
