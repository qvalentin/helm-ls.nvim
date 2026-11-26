local M = require("helm-ls")

local function fresh_module()
  package.loaded["helm-ls"] = nil
  return require("helm-ls")
end

describe("setup", function()
  before_each(function()
    M = fresh_module()
  end)

  it("uses the default config", function()
    M.setup({})
    assert.is_true(M.config.indent_hints.enabled)
    assert.is_true(M.config.indent_hints.only_for_current_line)
    assert.is_false(M.config.indent_hints.hint_on_same_line)
    assert.is_true(M.config.conceal_templates.enabled)
    assert.is_true(M.config.action_highlight.enabled)
  end)

  it("merges user options over the defaults", function()
    M.setup({ action_highlight = { enabled = false }, indent_hints = { hint_on_same_line = true } })
    assert.is_false(M.config.action_highlight.enabled)
    assert.is_true(M.config.indent_hints.hint_on_same_line)
    -- unrelated defaults survive the merge
    assert.is_true(M.config.indent_hints.only_for_current_line)
  end)

  it("errors on a non-table feature config", function()
    for _, feature in ipairs({ "conceal_templates", "indent_hints", "action_highlight" }) do
      local ok, err = pcall(M.setup, { [feature] = "nope" })
      assert.is_false(ok, feature .. " should reject a non-table config")
      assert.truthy(tostring(err):match("Invalid type for " .. feature))
    end
  end)
end)

describe("toggle", function()
  local original_notify
  local calls

  before_each(function()
    M = fresh_module()
    M.setup({})
    original_notify, calls = vim.notify, {}
    -- capture notifications only after setup(), so the missing-treesitter-parser
    -- warning from setup cannot pollute the calls asserted on below
    vim.notify = function(msg, level)
      table.insert(calls, { msg = msg, level = level })
    end
  end)

  after_each(function()
    vim.notify = original_notify
  end)

  it("disables an enabled feature and returns the new state", function()
    assert.is_false(M.toggle("indent_hints"))
    assert.is_false(M.config.indent_hints.enabled)
    assert.is_true(M.toggle("indent_hints"))
    assert.is_true(M.config.indent_hints.enabled)
  end)

  it("enables a feature that was disabled in the config", function()
    M.setup({ action_highlight = { enabled = false } })
    assert.is_true(M.toggle("action_highlight"))
    assert.is_true(M.config.action_highlight.enabled)
  end)

  it("returns nil and notifies an error for unknown features", function()
    local result = M.toggle("does_not_exist")
    assert.is_nil(result)
    assert.equal(1, #calls)
    assert.truthy(calls[1].msg:match("unknown feature"))
    assert.equal(vim.log.levels.ERROR, calls[1].level)
  end)

  it("clears the feature namespace in all buffers when disabling", function()
    local buf_a = vim.api.nvim_create_buf(false, true)
    local buf_b = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf_a, 0, -1, false, { "   indented" })
    vim.api.nvim_buf_set_lines(buf_b, 0, -1, false, { "   indented" })

    local ns = vim.api.nvim_create_namespace("helm-ls-indent-hints")
    vim.api.nvim_buf_set_extmark(buf_a, ns, 0, 0, { end_col = 3, hl_group = "Underlined" })
    vim.api.nvim_buf_set_extmark(buf_b, ns, 0, 1, { end_col = 3, hl_group = "Underlined" })

    local marks = #vim.api.nvim_buf_get_extmarks(buf_a, ns, 0, -1, {})
      + #vim.api.nvim_buf_get_extmarks(buf_b, ns, 0, -1, {})
    assert.equal(2, marks)

    assert.is_false(M.toggle("indent_hints"))

    assert.equal(1, #calls)
    assert.truthy(calls[1].msg:match("indent_hints disabled"))
    -- the success notification is sent without an explicit level
    assert.is_nil(calls[1].level)

    assert.same({}, vim.api.nvim_buf_get_extmarks(buf_a, ns, 0, -1, {}))
    assert.same({}, vim.api.nvim_buf_get_extmarks(buf_b, ns, 0, -1, {}))

    vim.api.nvim_buf_delete(buf_a, { force = true })
    vim.api.nvim_buf_delete(buf_b, { force = true })
  end)
end)
