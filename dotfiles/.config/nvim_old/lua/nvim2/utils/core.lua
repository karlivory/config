local bo = vim.bo
local cmd = vim.cmd
local api = vim.api

local M = {
  is_rest = false,
}

function M.disable_builtin_plugins()
  local default_plugins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "matchit",
    "tar",
    "tarPlugin",
    "rrhelper",
    "spellfile_plugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
  }

  for _, plugin in pairs(default_plugins) do
    vim.g["loaded_" .. plugin] = 1
  end
end

function M.bufdelete()
  if bo.modified then
    cmd("write")
  end

  local bufnr = api.nvim_get_current_buf()

  local buffers = vim.tbl_filter(function(buf)
    return bo[buf].buflisted and api.nvim_buf_is_valid(buf)
  end, api.nvim_list_bufs())

  if bufnr ~= buffers[#buffers] then
    cmd("bnext")
  else
    cmd("bprevious")
  end

  cmd("silent! ScrollViewDisable | bd " .. bufnr .. " | silent! ScrollViewEnable")
end

-- Count number of properties in table
-- Because of lua only count consecutive properties
-- @param T Table
function M.tablelength(T)
  local count = 0

  for _ in pairs(T) do
    count = count + 1
  end

  return count
end

function M.file_extension(filename)
  local t = {}
  for str in string.gmatch(filename, "([^%.]+)") do
    table.insert(t, str)
  end

  if #t == 1 or t[1] == "" then
    return ""
  end

  return t[#t]
end

function M.git_hover()
  local path = vim.fn.expand("%:h")

  if path == "" or path == ".git" then
    return
  end

  local blame = require("git_utils").blame(vim.fn.expand("%:p"), vim.api.nvim_win_get_cursor(0)[1])
  if M.tablelength(blame) == 0 then
    return
  end

  local texts = { "Author: " .. blame.author, "" }

  local message = blame.message
  local count_line = 0
  for line in string.gmatch(message, "([^\n]*)(\n?)") do
    if count_line == 0 then
      table.insert(texts, "Summary: " .. line)
      count_line = count_line + 1
    else
      table.insert(texts, line)
    end
  end

  local width = 72
  local height = 10

  if #texts < 10 then
    height = #texts
  end

  local buf = api.nvim_create_buf(false, true)

  local opts = {
    relative = "cursor",
    width = width,
    height = height,
    col = 0,
    row = 1,
    anchor = "NW",
    border = "single",
    style = "minimal",
  }

  api.nvim_open_win(buf, 1, opts)

  api.nvim_buf_set_lines(buf, 0, #texts, false, texts)

  api.nvim_buf_set_keymap(buf, "n", "<Leader>g", ":close<CR>", { silent = true, nowait = true, noremap = true })

  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "bufhidden", "delete")
  api.nvim_buf_set_option(buf, "modifiable", false)
end

function M.rest()
  if M.is_rest then
    vim.cmd("tabclose")

    M.is_rest = false
  else
    vim.cmd("tabedit new")
    vim.bo.bufhidden = "wipe"

    local valid_win = M.win_rest and api.nvim_win_is_valid(M.win_rest)
    local window = valid_win and M.win_rest or api.nvim_get_current_win()

    local valid_buf = M.buf_rest and api.nvim_buf_is_valid(M.buf_rest)
    local buf = valid_buf and M.buf_rest or api.nvim_create_buf(false, false)

    api.nvim_buf_set_name(buf, "test.http")

    api.nvim_buf_set_option(buf, "buftype", "nofile")
    api.nvim_buf_set_option(buf, "bufhidden", "delete")
    api.nvim_buf_set_option(buf, "filetype", "http")

    api.nvim_set_current_buf(buf)
    api.nvim_win_set_buf(window, buf)

    M.is_rest = true
    M.win_rest = window
    M.buf_rest = buf
  end
end

M.map_filetype_filename = {
  sh = "*.sh,*.zsh",
  cmake = "CMakeLists.txt",
  css = "*.css",
  cpp = "*.cpp,*.hpp",
  dart = "*.dart",
  dockerfile = "Dockerfile",
  elixir = "*.ex",
  go = "*.go",
  haskell = "*.hs",
  html = "*.html",
  java = "*.java",
  javascript = "*.js",
  javascriptreact = "*.jsx",
  json = "*.json",
  lua = "*.lua",
  markdown = "*.md",
  php = "*.php",
  python = "*.py",
  rust = "*.rs",
  solidity = "*.sol",
  svelte = "*.svelte",
  tex = "*.tex",
  typescript = "*.ts",
  typescriptreact = "*.tsx",
  xml = "*.xml",
  yaml = "*.yaml,*.yml",
}

function M.autocommand_by_filetypes(setting_filetypes, events, command)
  local autocmd = "autocmd " .. events .. " "
  local i = 1
  for _, filetype in pairs(setting_filetypes) do
    if i > 1 then
      autocmd = autocmd .. ","
    end

    autocmd = autocmd .. M.map_filetype_filename[filetype]

    i = i + 1
  end

  autocmd = autocmd .. " " .. command

  cmd(autocmd)
end

local function cmd_option(callback)
  return { noremap = true, silent = true, callback = callback }
end

function M.rename_popup()
  local current_name = api.nvim_eval('expand("<cword>")')

  local width = 50
  local buf = api.nvim_create_buf(false, true)
  local opts = {
    relative = "cursor",
    width = width,
    height = 1,
    col = 0,
    row = 1,
    anchor = "NW",
    border = "single",
    style = "minimal",
  }

  local win_handle = api.nvim_open_win(buf, 1, opts)

  local texts = { current_name }
  api.nvim_buf_set_lines(buf, 0, 1, false, texts)

  api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { silent = true, nowait = true, noremap = true })
  api.nvim_buf_set_keymap(
    buf,
    "i",
    "<CR>",
    "",
    cmd_option(function()
      local name = api.nvim_buf_get_lines(buf, 0, 1, false)[1]
      api.nvim_win_close(win_handle, true)

      if name ~= "" then
        vim.lsp.buf.rename(name)
      end

      local keys = vim.api.nvim_replace_termcodes("<ESC>l", true, false, true)
      api.nvim_feedkeys(keys, "i", true)
    end)
  )

  api.nvim_buf_set_keymap(
    buf,
    "n",
    "<CR>",
    "",
    cmd_option(function()
      local name = api.nvim_buf_get_lines(buf, 0, 1, false)[1]
      api.nvim_win_close(win_handle, true)

      if name ~= "" then
        vim.lsp.buf.rename(name)
      end

      local keys = vim.api.nvim_replace_termcodes("l", true, false, true)
      api.nvim_feedkeys(keys, "i", true)
    end)
  )

  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "bufhidden", "delete")

  -- Normal to insert
  api.nvim_feedkeys("A", "n", true)
end

function M.toggle_test()
  local current_test = api.nvim_eval("ultest#status()")
  if current_test["tests"] > 0 then
    if current_test["passed"] > 0 or current_test["failed"] > 0 or current_test["running"] > 0 then
      vim.api.nvim_command("UltestClear")
    else
      vim.api.nvim_command("UltestNearest")
    end
  end
end

function M.cover_score()
  local score_raw = vim.api.nvim_exec('!go test -cover | sed -n 2p | cut -d " " -f 2 | tr -d "\\n"', true)
  local newline_position = string.find(score_raw, "\n")
  print(string.sub(score_raw, newline_position))
end

function M.project_files()
  local ok = pcall(require("telescope.builtin").git_files)
  if not ok then
    require("telescope.builtin").find_files()
  end
end

return M
