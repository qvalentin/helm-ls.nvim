---@class CustomModule
local M = {}

local util = require("helm-ls.utils")

local ns_id = vim.api.nvim_create_namespace("helm-ls-indent-hints") -- Create a unique namespace

-- Debounce timer
local debounce_timer = nil

-- Function to replace leading indentation with virtual underlines
local function replace_indentation_with_underline(bufnr, line, indent_count)
  local line_content = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]

  if line_content == nil then
    print("Line content is nil")
    return
  end

  if #line_content == 0 then
    -- Add a virtual underline for the full width of the indent_count
    local underline = string.rep(".", indent_count)

    vim.api.nvim_buf_set_extmark(bufnr, ns_id, line, 0, {
      virt_text = { { underline, "Underlined" } },
      virt_text_pos = "overlay",
      hl_mode = "combine",
      virt_text_hide = true,
    })
    return
  end

  local indent_length = #line_content:match("^%s*")

  -- Replace leading indentation with virtual underlines
  if indent_length > 0 then
    local underline = string.rep(".", math.min(indent_count, indent_length))

    vim.api.nvim_buf_set_extmark(bufnr, ns_id, line, 0, {
      virt_text = { { underline, "Underlined" } },
      virt_text_pos = "overlay",
      hl_mode = "combine",
      virt_text_hide = true,
    })
  end
end

local show_hint = function(row, indent_count)
  vim.api.nvim_buf_clear_namespace(0, ns_id, row, row + 1)
  vim.api.nvim_buf_add_highlight(0, ns_id, "Underlined", row, 0, indent_count)

  -- Replace leading indentation with virtual underlines
  replace_indentation_with_underline(0, row, indent_count)
end

local add_indent_hints = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, vim.bo.filetype)
  local root = parser:parse()[1]:root()

  local query = vim.treesitter.query.parse(
    vim.bo.filetype,
    [[
    (function_call
      function: (identifier) @func
      arguments: (argument_list) @args (#any-of? @func "nindent" "indent"))
  ]]
  )

  -- Get the range of visible lines in the current window
  local start_line = vim.fn.line("w0") - 1
  local end_line = vim.fn.line("w$") - 1

  for _, match in query:iter_matches(root, bufnr, start_line, end_line) do
    local new_line_indent = false
    for id, node in pairs(match) do
      local name = query.captures[id]
      local node_content = vim.treesitter.get_node_text(node, bufnr)
      if name == "args" then
        -- parse original_text to int
        local indent_count = tonumber(node_content)
        if not indent_count then
          return
        end

        local start_row = node:range()
        show_hint(start_row + (new_line_indent and 1 or 0), indent_count)
      elseif name == "func" then
        new_line_indent = node_content == "nindent"
      end
    end
  end
end

-- Debounced function call
local function debounce_add_indent_hints()
  if debounce_timer then
    debounce_timer:stop()
  end
  debounce_timer = vim.defer_fn(function()
    add_indent_hints()
  end, 100) -- 200ms debounce time
end

M.add_indent_hints = debounce_add_indent_hints
return M
