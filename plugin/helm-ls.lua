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
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf(), name = "helm_ls" })
    if vim.tbl_isempty(clients) then
      return
    end
    conceal.conceal_templates_with_hover()
    conceal.clear_extmark_if_cursor_on_line()
  end,
})
