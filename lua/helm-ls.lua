-- main module file

---@class Config
---@field conceal_templates table
---@field indent_hints table
---@field action_highlight table
local config = {
  conceal_templates = {
    enabled = true,
  },
  indent_hints = {
    enabled = true,
    only_for_current_line = true,
    hint_on_same_line = false,
    hl_group = nil,
    hl_link = nil,
    hl_bg = nil,
  },
  action_highlight = {
    enabled = true,
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
    if args.action_highlight and type(args.action_highlight) ~= "table" then
      error("Helm-ls: Invalid type for action_highlight in config")
    end
  end

  M.config = vim.tbl_deep_extend("force", M.config, args or {})

  require("helm-ls.conceal").set_config(M.config.conceal_templates)
  require("helm-ls.indent-hints").set_config(M.config.indent_hints)
  require("helm-ls.action-highlight").setup(M.config.action_highlight)

  if not vim.treesitter.language.add("helm") then
    vim.notify(
      "Helm-ls.nvim: tree-sitter parser for helm not installed, some features will not work. Make sure you have nvim-treesitter and then install it with :TSInstall helm",
      vim.log.levels.WARN
    )
    return
  end

  local group_id = vim.api.nvim_create_augroup("helm-ls.nvim", { clear = true })

  -- Define file patterns as constants
  local file_patterns = { "*.yaml", "*.yml", "*.helm", "*.tpl", "NOTES.txt" }

  -- Define the autocommand
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group_id,
    pattern = file_patterns,
    callback = function()
      if vim.bo.filetype ~= "helm" then
        return
      end
      if M.config.indent_hints.enabled then
        require("helm-ls.indent-hints").add_indent_hints()
      end
      if M.config.conceal_templates.enabled then
        require("helm-ls.conceal").update_conceal_templates()
      end
      if M.config.action_highlight.enabled then
        require("helm-ls.action-highlight").highlight_current_block()
      end
    end,
  })
end

-- Namespaces each feature draws in
local feature_namespaces = {
  indent_hints = "helm-ls-indent-hints",
  conceal_templates = "helm-ls-conceal",
  action_highlight = "helm-ls-action-highlight",
}

-- Toggle a feature on/off. Returns the new state.
---@param feature "indent_hints" | "conceal_templates" | "action_highlight"
---@return boolean|nil enabled
M.toggle = function(feature)
  local cfg = M.config[feature]
  if type(cfg) ~= "table" or cfg.enabled == nil then
    vim.notify(("helm-ls: unknown feature %q"):format(feature), vim.log.levels.ERROR)
    return
  end

  cfg.enabled = not cfg.enabled
  if not cfg.enabled then
    -- wipe the displayed feature in all buffers
    local ns_id = vim.api.nvim_create_namespace(feature_namespaces[feature])
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    end
  end

  vim.notify(("helm-ls: %s %s"):format(feature, cfg.enabled and "enabled" or "disabled"))
  return cfg.enabled
end

return M
