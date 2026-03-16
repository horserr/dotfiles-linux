local M = {}

M.open_file_dir = function()
    local path = vim.fn.expand("%:p:h")
    local os_name = vim.loop.os_uname().sysname

    if os_name == "Windows_NT" then
        os.execute("start " .. path)
    elseif os_name == "Darwin" then -- macOS
        os.execute("open " .. path)
    else -- Linux
        os.execute("xdg-open " .. path)
    end
end

return M
