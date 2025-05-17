local opt = vim.opt

-- 行号
opt.relativenumber = true
opt.number = true

-- 缩进
opt.tabstop = 2
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- 防止包裹
opt.wrap = false

-- 光标行
opt.cursorline = true

-- 启用鼠标
opt.mouse:append("a")

-- 系统剪切板
opt.clipboard:append("unnamedplus")

-- 默认新窗口右和下
opt.splitright = true
opt. splitbelow = true

-- 外观
opt.termguicolors = true
opt.signcolumn = "yes"

-- 查找
    -- 如果查找的内容中不存在大写，则大小写不敏感
opt.ignorecase = true
opt.smartcase = true
