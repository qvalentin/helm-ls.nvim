-- main module file

---@class Config
---@field opt string Your config option
local config = {
  conceal_templates = {
    enabled = true,
  },
  indent_hints = {
    enabled = true,
    only_for_current_line = true,
  },
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
  --
  -- Create the autocommand group "ConcealWithLsp" if it doesn't already exist
  local group_id = vim.api.nvim_create_augroup("ConcealWithLsp", { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group_id,
    pattern = { "*.yaml", "*.yml", "*.helm", "*.tpl" },
    callback = function()
      if vim.bo.filetype ~= "helm" then
        return
      end
      if M.config.indent_hints then
        local indent_hints = require("helm-ls.indent-hints")

        indent_hints.add_indent_hints()
      end
      if M.config.conceal_templates then
        local conceal = require("helm-ls.conceal")
        local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf(), name = "helm_ls" })
        if vim.tbl_isempty(clients) then
          return
        end
        conceal.conceal_templates_with_hover()
        conceal.clear_extmark_if_cursor_on_line()
      end
    end,
  })
end

return M
