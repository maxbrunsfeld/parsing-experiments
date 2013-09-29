return {

  Sym = (function()
    local proto = {}

    function proto:transitions()
      return {}
    end

    return function(name)
      local result = { name = name }
      setmetatable(result, { __index = proto })
      return result
    end
  end)(),

  Choice = (function()
    local proto = {}

    function proto:transitions()
      return {}
    end

    return function(left, right)
      local result = { left = left, right = right }
      setmetatable(result, { __index = proto })
      return result
    end
  end)(),

  Seq = (function()
    local proto = {}

    function proto:transitions()
      return {}
    end

    return function(left, right)
      local result = { left = left, right = right }
      setmetatable(result, { __index = proto })
      return result
    end
  end)(),

  String = (function()
    local proto = {}

    function proto:transitions()
      return {}
    end

    return function(value)
      local result = { value = value }
      setmetatable(result, { __index = proto })
      return result
    end
  end)(),

  Pattern = (function()
    local proto = {}

    function proto:transitions()
      return {}
    end

    return function(value)
      local result = { value = value }
      setmetatable(result, { __index = proto })
      return result
    end
  end)(),

  End = ({})

}
