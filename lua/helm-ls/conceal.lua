---@class CustomModule
local M = {}

local lsp = vim.lsp
local api = vim.api
local ns_id = api.nvim_create_namespace("conceal_ns")

-- Debounce timer
local debounce_timer = nil

-- Cache to store hover results
local hover_cache = {}

-- Function to check if the cursor is on the same line as the node
local function is_cursor_on_line(start_row)
  local cursor_row = unpack(api.nvim_win_get_cursor(0))
  return (cursor_row - 1) == start_row
end

-- Function to extract hover text from the LSP result
local function extract_hover_text(contents)
  local markdown_lines = lsp.util.convert_input_to_markdown_lines(contents)
  markdown_lines = lsp.util.trim_empty_lines(markdown_lines)

  if vim.tbl_isempty(markdown_lines) then
    return nil
  end

  return markdown_lines[3] or markdown_lines[2] or markdown_lines[1]
end

-- Function to pad hover text to match the length of the original text
local function pad_text(hover_text, original_length)
  if #hover_text < original_length then
    hover_text = hover_text .. string.rep(" ", original_length - #hover_text)
  end
  return hover_text
end

-- Helper function to request hover information from the LSP
local function request_hover(bufnr, line, col, callback)
  lsp.buf_request(bufnr, "textDocument/hover", {
    textDocument = lsp.util.make_text_document_params(),
    position = { line = line, character = col },
  }, callback)
end

-- Helper function to set an extmark with the hover result
local function set_extmark(bufnr, start_row, start_col, end_row, end_col, hover_text, original_text)
  hover_text = pad_text(hover_text, #original_text)

  -- Set conceal for the syntax element
  api.nvim_buf_set_extmark(bufnr, ns_id, start_row, start_col, {
    end_row = end_row,
    end_col = end_col,
    virt_text = { { hover_text, "Conceal" } },
    virt_text_pos = "overlay",
    hl_mode = "blend",
    virt_text_hide = true,
  })
end

-- Function to handle LSP hover requests and apply concealment
local function apply_concealment(bufnr, start_row, start_col, end_row, end_col, node)
  local original_text = vim.treesitter.get_node_text(node, bufnr)
  -- Use cached hover result if available
  local hover_text = hover_cache[original_text]
  if hover_text then
    set_extmark(bufnr, start_row, start_col, end_row, end_col, hover_text, original_text)
  else
    request_hover(bufnr, end_row, end_col - 1, function(err, result, ctx, _)
      if err or not result or not result.contents then
        return
      end

      hover_text = extract_hover_text(result.contents)
      hover_cache[original_text] = hover_text

      set_extmark(bufnr, start_row, start_col, end_row, end_col, hover_text, original_text)
    end)
  end
end

-- Main function to conceal templates with hover
local conceal_templates_with_hover = function()
  local bufnr = api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, vim.bo.filetype)
  local root = parser:parse()[1]:root()

  local query = vim.treesitter.query.parse(
    vim.bo.filetype,
    [[
    ((selector_expression)  ["}}" "|" ]) @selector
  ]]
  )

  -- Get the range of visible lines in the current window
  local start_line = vim.fn.line("w0") - 1 -- Convert to 0-based index
  local end_line = vim.fn.line("w$") - 1   -- Convert to 0-based index

  print("start_line: " .. start_line)
  print("end_line: " .. end_line)

  for _, match in query:iter_matches(root, bufnr, start_line, end_line) do
    for id, node in pairs(match) do
      local start_row, start_col, end_row, end_col = node:range()

      if is_cursor_on_line(start_row) then
        return
      end

      apply_concealment(bufnr, start_row, start_col, end_row, end_col, node)
    end
  end
end

-- Debounced function call
local function debounce_conceal_templates_with_hover()
  if debounce_timer then
    debounce_timer:stop()
  end
  debounce_timer = vim.defer_fn(function()
    conceal_templates_with_hover()
  end, 500) -- 200ms debounce time
end

-- Function to clear extmarks on the cursor's current line
local clear_extmark_if_cursor_on_line = function()
  local bufnr = api.nvim_get_current_buf()
  local cursor_row = unpack(api.nvim_win_get_cursor(0))

  api.nvim_buf_clear_namespace(bufnr, ns_id, cursor_row - 1, cursor_row)
end

M.conceal_templates_with_hover = conceal_templates_with_hover
M.clear_extmark_if_cursor_on_line = clear_extmark_if_cursor_on_line
return M
