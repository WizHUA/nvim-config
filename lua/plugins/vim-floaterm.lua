-- lua/plugins/floaterm.lua
return {
  "voldikss/vim-floaterm",
  keys = {
    {
      "<leader>ft",
      function()
        vim.cmd("silent write")  -- 保存当前文件
        vim.cmd("FloatermToggle")
      end,
      desc = "Toggle terminal (with save)",
      mode = { "n", "t" },  -- 同时支持 normal 和 terminal 模式
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

    -- 终端模式专用退出方案
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "floaterm",
      callback = function()
        -- 终端模式按两次 <Esc> 退出并关闭
        vim.keymap.set("t", "<Esc>", "<Esc><Cmd>FloatermToggle<CR>", { buffer = true })
      end
    })
  end
}
