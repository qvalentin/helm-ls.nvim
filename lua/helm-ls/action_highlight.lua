---@class ActionHighlightModule
local M = {}

local queries = require("helm-ls.queries")

local ns_id = vim.api.nvim_create_namespace("helm-ls-action-highlight")

local function highlight_node(bufnr, node)
  if not node then
    return
  end
  local start_row, start_col, end_row, end_col = node:range()
  vim.api.nvim_buf_set_extmark(bufnr, ns_id, start_row, start_col, {
    end_row = end_row,
    end_col = end_col,
    hl_group = "Visual",
  })
end

local function highlight_keywords()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  local parser = vim.treesitter.get_parser(bufnr, "helm")
  if not parser then
    return
  end

  -- Make sure tree is parsed. parse() is idempotent.
  parser:parse()

  local cursor_node = vim.treesitter.get_node({ bufnr = bufnr, include_anonymous = true })
  if not cursor_node then
    return
  end

  -- 1. Find the containing action node by traversing up from cursor
  local action_node
  local current_node = cursor_node
  local action_types = { "range_action", "if_action", "with_action", "define_action", "block_action" }
  while current_node do
    if vim.tbl_contains(action_types, current_node:type()) then
      action_node = current_node
      break
    end
    current_node = current_node:parent()
  end

  if not action_node then
    return -- No action found at cursor
  end

  -- 2. Find parts within that action node and highlight them
  local parts_query = vim.treesitter.query.parse("helm", queries.action_parts)
  if not parts_query then
    return
  end

  for id, node_to_highlight in parts_query:iter_captures(action_node, bufnr) do
    local is_nested = false
    local parent = node_to_highlight:parent()
    -- Check if the capture is inside a nested action block
    while parent and parent:id() ~= action_node:id() do
      if vim.tbl_contains(action_types, parent:type()) then
        is_nested = true
        break
      end
      parent = parent:parent()
    end

    if not is_nested then
      highlight_node(bufnr, node_to_highlight)
    end
  end
end

function M.setup(config)
  -- Not needed for now
end

function M.highlight_current_block()
  highlight_keywords()
end

return M
