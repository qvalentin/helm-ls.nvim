local M = {}

M.action_block = [[
  [
    (range_action "range" @start ("else" @middle)? "end" @end)
    (if_action "if" @start  ("else" @middle)? ("else if" @middle)? "end" @end)
    (with_action "with" @start ("else" @middle)? "end" @end)
    (define_action "define" @start "end" @end)
    (block_action "block" @start "end" @end)
  ] @action
]]

return M
