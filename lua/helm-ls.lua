-- main module file

---@class Config
---@field conceal_templates table
---@field indent_hints table
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
M.setup = function(args)
  -- Validate and merge configuration
  if args then
    if args.conceal_templates and type(args.conceal_templates) ~= "table" then
      error("Helm-ls: Invalid type for conceal_templates in config")
    end
    if args.indent_hints and type(args.indent_hints) ~= "table" then
      error("Helm-ls: Invalid type for indent_hints in config")
    end
  end

  M.config = vim.tbl_deep_extend("force", M.config, args or {})

  local conceal = nil
  local indent_hints = nil

  if M.config.conceal_templates.enabled then
    conceal = require("helm-ls.conceal")
    conceal.set_config(M.config.conceal_templates)
  end

  if M.config.indent_hints.enabled then
    indent_hints = require("helm-ls.indent-hints")
    indent_hints.set_config(M.config.indent_hints)
  end

  if not conceal and not indent_hints then
    -- create no autocommand as the features are disabled
    return
  end

  local hasparsers, parsers = pcall(require, "nvim-treesitter.parsers")
  if not hasparsers or not parsers.has_parser("helm") then
    vim.notify(
      "Helm-ls.nvim: tree-sitter parser for helm not installed, some features will not work. Make sure you have nvim-treesitter and then install it with :TSInstall helm",
      vim.log.levels.WARN
    )
    return
  end

  local group_id = vim.api.nvim_create_augroup("helm-ls.nvim", { clear = true })

  -- Define file patterns as constants
  local file_patterns = { "*.yaml", "*.yml", "*.helm", "*.tpl" }

  -- Define the autocommand
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group_id,
    pattern = file_patterns,
    callback = function()
      if vim.bo.filetype ~= "helm" then
        return
      end
      if indent_hints then
        indent_hints.add_indent_hints()
      end
      if conceal then
        conceal.update_conceal_templates()
      end
    end,
  })
end

return M
