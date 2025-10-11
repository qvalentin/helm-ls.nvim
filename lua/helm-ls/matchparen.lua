---@class MatchParenModule
local M = {}

local queries = require("helm-ls.queries")

local function is_cursor_on_node(cursor_row, cursor_col, node)
  local start_row, start_col, _, end_col = node:range()
  if cursor_row == start_row and cursor_col >= start_col and cursor_col < end_col then
    return true
  end
  return false
end

function M.jump_to_matching_keyword()
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, "helm")
  if not parser then
    return
  end

  local root = parser:parse()[1]:root()
  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1 -- 0-indexed

  local query = vim.treesitter.query.parse("helm", queries.action_block)
  if not query then
    return
  end

  local matches = {}
  for _, captures in query:iter_matches(root, bufnr) do
    table.insert(matches, captures)
  end

  -- Iterate backwards to find the innermost match first
  for i = #matches, 1, -1 do
    local match = matches[i]
    local start_node
    local middle_node
    local end_node

    for id, nodes in pairs(match) do
      local capture_name = query.captures[id]
      if capture_name == "start" then
        start_node = nodes[1]
      elseif capture_name == "middle" then
        middle_node = nodes[1]
      elseif capture_name == "end" then
        end_node = nodes[1]
      end
    end

    if start_node and end_node then
      if is_cursor_on_node(cursor_row, cursor_col, start_node) then
        local target_node = middle_node or end_node
        local target_row, target_col = target_node:start()
        vim.api.nvim_win_set_cursor(0, { target_row + 1, target_col })
        return true
      elseif middle_node and is_cursor_on_node(cursor_row, cursor_col, middle_node) then
        local end_start_row, end_start_col = end_node:start()
        vim.api.nvim_win_set_cursor(0, { end_start_row + 1, end_start_col })
        return true
      elseif is_cursor_on_node(cursor_row, cursor_col, end_node) then
        local target_row, target_col = start_node:start()
        vim.api.nvim_win_set_cursor(0, { target_row + 1, target_col })
        return true
      end
    end
  end
  return false
end

return M
