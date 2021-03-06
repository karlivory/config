local present, lsp_installer = pcall(require, "nvim-lsp-installer")

if not present then
  print("fail")
  return
end

local options = {

  ensure_installed = {
    -- issue: https://github.com/ansible/ansible-language-server/issues/391
    "ansiblels@b85edfaebba919afd8496679e022118f25827b15",
  },
  automatic_installation = {
    exclude = {
      "ansiblels",
    },
  },
  -- automatic_installation = true,

  ui = {
    icons = {
      server_installed = " ",
      server_pending = " ",
      server_uninstalled = " ﮊ",
    },
    keymaps = {
      toggle_server_expand = "<CR>",
      install_server = "i",
      update_server = "u",
      check_server_version = "c",
      update_all_servers = "U",
      check_outdated_servers = "C",
      uninstall_server = "X",
    },
  },

  max_concurrent_installers = 20,
}

lsp_installer.setup(options)
