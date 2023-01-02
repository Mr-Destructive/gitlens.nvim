local M = {}


local function get_commit_author(line)
  local command = string.format("git blame -L %d,+1 --format='%%an' %s", line, vim.fn.expand("%"))
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  local fields = {}
    for line in result:gmatch("[^\r\n]+") do
  for field in line:gmatch("[^%s]+") do
    table.insert(fields, field)
  end
  end
  local author_name = {} 
  local author = fields[2]
  for substring in author:gmatch("[^(]+") do
      table.insert(author_name, substring)
  end
  local commit_author = author_name[1]
  return {commit_author}
end

local ns = vim.api.nvim_create_namespace "commit_author" 
function M.Display_commit_author_lazy()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local commit_author = get_commit_author(line)
  local ext_mark = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
  for i, v in pairs(ext_mark) do 
  vim.api.nvim_buf_del_extmark(0, ns, v[1])
  end
  vim.api.nvim_buf_set_extmark(0, ns, line-1, 0, {virt_text = {commit_author,}, })
end
vim.api.nvim_create_autocmd("CursorMoved", {
    group = vim.api.nvim_create_augroup("Git Commit", {clear = true}),
    callback = Display_commit_author_lazy,
})
return M
