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
    end_line = end_row,
    end_col = end_col,
    hl_group = "Visual",
  })
end

local function highlight_keywords()
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, "helm")
  if not parser then
    return
  end

  local root = parser:parse()[1]:root()
  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1 -- 0-indexed

  -- Clear previous highlights first
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  local query = vim.treesitter.query.parse("helm", queries.action_block)
  if not query then
    return
  end

  -- Iterate over all matches, from innermost to outermost
  for _, match in query:iter_matches(root, bufnr) do
    local action_node
    local start_node
    local middle_node
    local end_node

    for id, nodes in pairs(match) do
      local capture_name = query.captures[id]
      if capture_name == "action" then
        action_node = nodes[1]
      elseif capture_name == "start" then
        start_node = nodes[1]
      elseif capture_name == "middle" then
        middle_node = nodes[1]
      elseif capture_name == "end" then
        end_node = nodes[1]
      end
    end

    if action_node and start_node and end_node then
      local start_row, start_col, end_row, end_col = action_node:range()

      if cursor_row >= start_row and cursor_row <= end_row then
        if (cursor_row == start_row and cursor_col < start_col) or (cursor_row == end_row and cursor_col > end_col) then
          -- Cursor is outside the node on the same line, so we continue searching for a parent block
        else
          -- Cursor is inside the block, highlight the keywords and stop.
          highlight_node(bufnr, start_node)
          if middle_node then
            highlight_node(bufnr, middle_node)
          end
          highlight_node(bufnr, end_node)
          return
        end
      end
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
