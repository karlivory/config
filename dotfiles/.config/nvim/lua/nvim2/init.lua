local present, impatient = pcall(require, "impatient")
if present then
  impatient.enable_profile()
end

require("nvim2.utils.core").disable_builtin_plugins()

require("nvim2.globals")
require("nvim2.plugins.packer")
require("nvim2.options")
require("nvim2.ui.statusline")
require("nvim2.utils").change_colorscheme("gruvbox")
require("nvim2.mappings")
require("nvim2.autocommands")
