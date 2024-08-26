---@class CustomModule
local M = {}

local lsp = vim.lsp
local api = vim.api
local ns_id = api.nvim_create_namespace("conceal_ns")

M.conceal_templates_with_hover = function()
  local bufnr = api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, vim.bo.filetype)
  local root = parser:parse()[1]:root()

  -- Define the Tree-sitter query for the syntax you want to conceal
  local query = vim.treesitter.query.parse(
    vim.bo.filetype,
    [[
    ((selector_expression)  "}}") @selector
  ]]
  )

  for _, match, metadata in query:iter_matches(root, bufnr, 0, -1) do
    for id, node in pairs(match) do
      local start_row, start_col, end_row, end_col = node:range()

      local cursor_row = unpack(api.nvim_win_get_cursor(0))
      if cursor_row - 1 == start_row then
        return
      end

      -- Request hover information from the LSP
      lsp.buf_request(bufnr, "textDocument/hover", {
        textDocument = lsp.util.make_text_document_params(),
        position = { line = end_row, character = end_col - 1 },
      }, function(err, result, ctx, _)
        if err or not result or not result.contents then
          return
        end

        local markdown_lines = lsp.util.convert_input_to_markdown_lines(result.contents)
        markdown_lines = lsp.util.trim_empty_lines(markdown_lines)
        if vim.tbl_isempty(markdown_lines) then
          return
        end

        local original_text = vim.treesitter.get_node_text(node, bufnr)

        local hover_text = markdown_lines[3]
        if #markdown_lines < 3 then
          hover_text = markdown_lines[1]
        end

        -- Pad the hover text with spaces if it's shorter than the original text
        if #hover_text < #original_text then
          hover_text = hover_text .. string.rep(" ", #original_text - #hover_text)
        end

        -- Set conceal for the syntax element
        api.nvim_buf_set_extmark(bufnr, ns_id, start_row, start_col, {
          end_row = end_row,
          end_col = end_col,
          virt_text = { { hover_text, "Conceal" } }, -- Replace node content with the hover result
          virt_text_pos = "overlay", -- Overlay the text, replacing the original content
          virt_text_hide = true,
          hl_mode = "blend", -- Combine with the existing text's highlight
        })
      end)
    end
  end
end

M.clear_extmark_if_cursor_on_line = function()
  local bufnr = api.nvim_get_current_buf()
  local cursor_row = unpack(api.nvim_win_get_cursor(0))

  -- Clear extmarks on the line where the cursor is
  api.nvim_buf_clear_namespace(bufnr, ns_id, cursor_row - 1, cursor_row)
end

return M
