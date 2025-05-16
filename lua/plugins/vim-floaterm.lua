-- lua/plugins/floaterm.lua
return {
  "voldikss/vim-floaterm",
  keys = {
    {
      "<leader>ft",
      function()
        -- 仅当文件不是插件配置时保存（避免重载循环）
        if not vim.fn.expand("%:p"):match("nvim%-config/lua/plugins") then
          vim.cmd("silent write")
        end
        vim.cmd("FloatermToggle")
      end,
      desc = "Toggle terminal (safe save)",
      mode = "n",  -- 仅限 normal 模式触发，避免终端模式冲突
      silent = true
    },
  },
  config = function()
    -- 基础设置
    vim.g.floaterm_width = 0.8
    vim.g.floaterm_height = 0.75
    vim.g.floaterm_position = "center"

    -- 美化配置
    vim.g.floaterm_borderchars = "─│─│╭╮╯╰"
    vim.g.floaterm_title = "yecc is looking!"
    vim.g.floaterm_autoclose = 2

    -- 更符合直觉的退出逻辑
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "floaterm",
      callback = function()
        -- 终端模式按一次 <Esc> 隐藏窗口（保持进程）
        vim.keymap.set("t", "<Esc>", "<Cmd>FloatermToggle<CR>", { buffer = true })
        -- 添加额外退出方式：按 Ctrl+d 关闭终端进程
        vim.keymap.set("t", "<C-d>", "<Cmd>FloatermKill<CR>", { buffer = true })
      end
    })
  end
}
