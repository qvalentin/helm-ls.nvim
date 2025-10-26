local M = {}

M.action_parts = [[
  ("range" @start)
  ("if" @start)
  ("with" @start)
  ("define" @start)
  ("block" @start)
  (["else" "else if"] @middle)
  ("end" @end)
]]

return M
