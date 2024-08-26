local conceal = require("helm-ls.conceal")
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
    print("Checking if LSP is ready", vim.lsp.buf.server_ready)
    local clients = vim.lsp.get_clients()
    print("Checking if LSP is ready", vim.tbl_isempty(clients))
    if vim.tbl_isempty(clients) then
      return
    end
    conceal.conceal_templates_with_hover()
    conceal.clear_extmark_if_cursor_on_line()
  end,
})
