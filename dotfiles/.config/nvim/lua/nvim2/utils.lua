-- Utils module
-- M.file and M.ensure_file_exists are copied from
-- https://github.com/NvChad/extensions/tree/785eaa25a9bbdf47a6808dc5b6da1747abe10b2b

local M = {}
local fn = vim.fn

M.change_colorscheme = require("nvim2.utils.change_colorscheme")
M.toggle_boolean = require("nvim2.utils.toggle_boolean")
M.reload_config = require("nvim2.utils.reload_config")
M.dap = require("nvim2.utils.dap")
M.core = require("nvim2.utils.core")
M.dap = require("nvim2.utils.dap")

M.better_escape = function()
  vim.cmd([[nohls]])
  vim.cmd([[ccl]])
  M.close_all_floating_windows()
  require("cmp").close()
end

M.save = function()
  local ft = vim.bo.filetype
  if G.languages[ft] then
    if G.languages[ft].autoformat then
      vim.cmd([[write]])
      vim.cmd([[FormatWrite]])
      return
    end
  end
  vim.cmd([[write]])
end

M.toggle_autoformat = function()
  local ft = vim.bo.filetype
  if G.languages[ft] then
    G.languages[ft].autoformat = not G.languages[ft].autoformat
  end
end

M.kmap = function(mode, lhs, rhs, mapping_name, mapping_opts)
  local opts = mapping_opts or {}
  local name = mapping_name or rhs
  local whichkey_exists, wk = pcall(require, "which-key")

  if whichkey_exists then
    opts.mode = mode
    wk.register({ [lhs] = { rhs, name } }, opts)
  else
    opts.mode = nil
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

M.Class = function(members)
  members = members or {}
  local mt = {
    __metatable = members,
    __index = members,
  }
  local function new(_, init)
    return setmetatable(init or {}, mt)
  end
  members.new = members.new or new
  return mt
end

-- 1st arg - r or w
-- 2nd arg - file path
-- 3rd arg - content if 1st arg is w
-- return file data on read, nothing on write
M.file = function(mode, filepath, content)
  local data
  local base_dir = fn.fnamemodify(filepath, ":h")
  -- check if file exists in filepath, return false if not
  if mode == "r" and fn.filereadable(filepath) == 0 then
    return false
  end
  -- check if directory exists, create it and all parents if not
  if mode == "w" and fn.isdirectory(base_dir) == 0 then
    fn.mkdir(base_dir, "p")
  end
  local fd = assert(vim.loop.fs_open(filepath, mode, 438))
  local stat = assert(vim.loop.fs_fstat(fd))
  if stat.type ~= "file" then
    data = false
  else
    if mode == "r" then
      data = assert(vim.loop.fs_read(fd, stat.size, 0))
    else
      assert(vim.loop.fs_write(fd, content, 0))
      data = true
    end
  end
  assert(vim.loop.fs_close(fd))
  return data
end

M.close_all_floating_windows = function()
  local closed_windows = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then -- is_floating_window?
      vim.api.nvim_win_close(win, false) -- do not forcefully
      table.insert(closed_windows, config)
    end
  end
  -- print(vim.inspect(closed_windows))
end

-- ensures the given file_path is a valid path
-- if the file at file_path does not exist, it will be created with the given default_content
M.ensure_file_exists = function(file_path, default_content)
  -- store in data variable
  local data = M.file("r", file_path)

  -- check if data is false or nil and create a default file if it is
  if not data then
    M.file("w", file_path, default_content)
    data = M.file("r", file_path)
  end

  -- if the file was still not created, then something went wrong
  if not data then
    print("Error: Could not create: " .. file_path)
    return false
  end

  return true
end

M.lsp_get_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
  return capabilities
end

M.lsp_progress_report_handler = function(_, result, ctx)
  -- needed for fidget.nvim
  -- see: https://github.com/j-hui/fidget.nvim/issues/57
  local lsp = vim.lsp
  local info = {
    client_id = ctx.client_id,
  }

  local kind = "report" -- this is dumb, kind is never "report"
  if result.complete then
    kind = "end"
  elseif result.workDone == 0 then
    kind = "begin"
  elseif result.workDone > 0 and result.workDone < result.totalWork then
    kind = "report"
  else
    kind = "end"
  end

  local percentage = 0
  if result.totalWork > 0 and result.workDone >= 0 then
    percentage = result.workDone / result.totalWork * 100
  end

  local msg = {
    token = result.id,
    value = {
      kind = kind,
      percentage = percentage,
      title = result.task,
      message = result.subTask,
    },
  }

  pcall(lsp.handlers["$/progress"], nil, msg, info)
end

return M
