local plugin = require("helm-ls")

describe("setup", function()
  it("works with default", function()
    assert("Hello" == "Hello!", "my first function with param = Hello!")
  end)

  it("works with custom var", function()
    assert("custom" == "custom", "my first function with param = custom")
  end)
end)
