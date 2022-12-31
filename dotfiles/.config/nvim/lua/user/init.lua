local config = {
  lsp = {
    skip_setup =
    {
      "rust_analyzer", -- handled by rust-tools.nvim
      "jdtls" -- handled by nvim-jdtls
    },
  },
  -- -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
  -- diagnostics = {
  --   virtual_text = true,
  --   underline = true,
  -- },
  --
  -- -- LuaSnip Options
  -- luasnip = {
  --   -- Add paths for including more VS Code style snippets in luasnip
  --   vscode_snippet_paths = {},
  --   -- Extend filetypes
  --   filetype_extend = {
  --     -- javascript = { "javascriptreact" },
  --   },
  -- },
}

return config
