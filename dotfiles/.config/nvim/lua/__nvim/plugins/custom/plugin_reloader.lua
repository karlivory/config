local M = {}

M.reload = function()
  for name,_ in pairs(package.loaded) do
    if name:match('^nvim2') then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  print("Config reloaded!")
end

return M
