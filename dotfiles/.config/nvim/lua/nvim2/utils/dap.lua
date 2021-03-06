-- local dap = require('dap')

local M = {}

-- M.breakpoint = false
M.debug = false

-- function M.toggle_breakpoint()
--     if not M.breakpoint then
--         if vim.bo.filetype == 'java' then
--             require("jdtls_dap").setup_dap_main_class_configs()
--         end
--
--         M.breakpoint = true
--     end
--
--     dap.toggle_breakpoint()
-- end

function M.toggle_debug()
  if not M.debug then
    M.debug = true
    require("dap").continue()
  else
    M.debug = false
    require("dap").disconnect()
    require("nvim-dap-virtual-text").refresh()
  end
end

return M
