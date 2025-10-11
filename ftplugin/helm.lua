-- set up the gotmpl commentstring
vim.opt_local.commentstring = "{{/* %s */}}"

vim.keymap.set("n", "%", function()
  local jumped = require("helm-ls.matchparen").jump_to_matching_keyword()
  if not jumped then
    -- Fallback to default % behavior
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("%", true, false, true), "n", false)
  end
end, { buffer = true, noremap = true, silent = true, desc = "Jump to matching keyword" })
