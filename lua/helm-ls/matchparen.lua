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
    return false
  end
  parser:parse()

  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1

  local cursor_node = vim.treesitter.get_node({ bufnr = bufnr, include_anonymous = true })
  if not cursor_node then
    return false
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
    return false
  end

  -- 2. Get all parts, filter nested, and identify node under cursor
  local parts_query = vim.treesitter.query.parse("helm", queries.action_parts)
  if not parts_query then
    return false
  end

  local start_nodes, middle_nodes, end_nodes = {}, {}, {}
  local cursor_on_node

  for id, node in parts_query:iter_captures(action_node, bufnr) do
    local is_nested = false
    local parent = node:parent()
    while parent and parent:id() ~= action_node:id() do
      if vim.tbl_contains(action_types, parent:type()) then
        is_nested = true
        break
      end
      parent = parent:parent()
    end

    if not is_nested then
      if is_cursor_on_node(cursor_row, cursor_col, node) then
        cursor_on_node = node
      end
      local capture_name = parts_query.captures[id]
      if capture_name == "start" then
        table.insert(start_nodes, node)
      elseif capture_name == "middle" then
        table.insert(middle_nodes, node)
      elseif capture_name == "end" then
        table.insert(end_nodes, node)
      end
    end
  end

  if not cursor_on_node then
    return false
  end

  -- Sort nodes by position
  table.sort(start_nodes, function(a, b) return a:start() < b:start() end)
  table.sort(middle_nodes, function(a, b) return a:start() < b:start() end)
  table.sort(end_nodes, function(a, b) return a:start() < b:start() end)

  -- 3. Find which list the cursor_on_node is in and jump
  local function jump_to(node)
    local r, c = node:start()
    vim.api.nvim_win_set_cursor(0, { r + 1, c })
    return true
  end

  for i, node in ipairs(start_nodes) do
    if node:id() == cursor_on_node:id() then
      if #middle_nodes > 0 then
        return jump_to(middle_nodes[1])
      elseif #end_nodes > 0 then
        return jump_to(end_nodes[1])
      end
      return false
    end
  end

  for i, node in ipairs(middle_nodes) do
    if node:id() == cursor_on_node:id() then
      if i + 1 <= #middle_nodes then
        return jump_to(middle_nodes[i + 1])
      elseif #end_nodes > 0 then
        return jump_to(end_nodes[1])
      end
      return false
    end
  end

  for i, node in ipairs(end_nodes) do
    if node:id() == cursor_on_node:id() then
      if #start_nodes > 0 then
        return jump_to(start_nodes[1])
      end
      return false
    end
  end

  return false
end

return M