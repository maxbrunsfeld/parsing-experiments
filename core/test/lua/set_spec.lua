require("spec_helper")

local Set = require("set")

describe("Set", function()
  local set

  before_each(function()
    set = Set()
  end)

  it("starts out empty", function()
    assert.is.equal(0, #set)
    assert.is.falsy(set:contains(1))
  end)

  describe("adding an element", function()
    before_each(function()
      set:add(1)
    end)

    it("contains that element", function()
      assert.is.equal(1, #set)
      assert.is.truthy(set:contains(1))
    end)

    describe("adding it again", function()
      it("does nothing", function()
        set:add(1)
        assert.is.equal(1, #set)
        assert.is.truthy(set:contains(1))
      end)
    end)
  end)
end)
