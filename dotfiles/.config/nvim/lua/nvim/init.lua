--require('nvim.utils.nvim.global')
require('nvim.global')
require('nvim.plugins')
--require('nvim.general')

require('nvim.core')
require('nvim.core.utils')
require('nvim.core.options')

vim.defer_fn(function()
   require("nvim.core.utils").load_mappings()
end, 0)