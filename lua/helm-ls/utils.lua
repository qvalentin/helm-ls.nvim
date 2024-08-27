-- Function to check if the cursor is on the same line as the node
local function is_cursor_on_line(start_row)
  local cursor_row = unpack(vim.api.nvim_win_get_cursor(0))
  return (cursor_row - 1) == start_row
end

return {
  is_cursor_on_line = is_cursor_on_line,
}
