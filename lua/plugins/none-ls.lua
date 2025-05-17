return {
    "nvimtools/none-ls.nvim",
    dependencies = { 
        "nvim-lua/plenary.nvim",
        "williamboman/mason.nvim",
    },
    event = "VeryLazy",
    config = function()
        -- 在 config = function() 的开头添加
        -- 确保 ~/.local/bin 在 PATH 中
        local home = vim.fn.expand("$HOME")
        local local_bin = home .. "/.local/bin"
        if not string.find(vim.env.PATH or "", local_bin) then
            vim.env.PATH = local_bin .. ":" .. (vim.env.PATH or "")
        end

        local null_ls = require("null-ls")
        local registry = require("mason-registry")
        
        -- 安装格式化工具的辅助函数
        local function ensure_installed(name)
            local success, package = pcall(registry.get_package, name)
            if success and not package:is_installed() then
                package:install()
            end
        end
        
        -- 安装常用格式化工具
        ensure_installed("stylua")       -- Lua 格式化
        ensure_installed("prettier")     -- JavaScript/TypeScript/JSON/HTML/CSS 等格式化
        -- ensure_installed("black")        -- Python 格式化：
        -- ensure_installed("clang-format") -- C/C++ 格式化
        
        -- 配置 none-ls
        null_ls.setup({
            debug = false,
            sources = {
                -- Lua
                null_ls.builtins.formatting.stylua,
                
                -- Web 开发
                null_ls.builtins.formatting.prettier.with({
                    filetypes = {
                        "javascript", "typescript", "json", "yaml",
                        "html", "css", "scss", "markdown", "vue"
                    },
                }),
                
                -- Python
                (function()
                    -- 尝试多个可能的路径
                    local possible_paths = {
                        "/home/wizhua/.local/bin/black",  -- 绝对路径
                        "/wizhua/.local/bin/black",       -- 另一种可能的路径
                        "black",                          -- PATH 中的可执行文件
                    }
                    
                    for _, path in ipairs(possible_paths) do
                        local is_executable = vim.fn.executable(path) == 1
                        -- 如果找到可执行的 black，立即返回
                        if is_executable then
                            vim.notify("已找到可执行的 black: " .. path, vim.log.levels.INFO)
                            return null_ls.builtins.formatting.black.with({
                                command = path,
                            })
                        end
                    end
                    
                    -- 找不到任何可执行的 black
                    vim.notify("无法找到可执行的 black 格式化工具", vim.log.levels.WARN)
                    return nil
                end)(),
                
                -- C/C++
                vim.fn.executable("/usr/bin/clang-format") == 1 
                    and null_ls.builtins.formatting.clang_format.with({
                        command = "/usr/bin/clang-format",
                    })
                    or nil,
            },
        })
        
        -- 自动格式化设置
        local format_group = vim.api.nvim_create_augroup("LspFormatting", {})
        
        -- 可选：设置保存时自动格式化
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = format_group,
            callback = function()
                vim.lsp.buf.format({ async = false })
            end,
            -- 可以指定文件类型，例如：pattern = { "*.lua", "*.py", "*.cpp" }
            pattern = { "*.py" },
        })
    end,
    keys = {
        {
            "<leader>lf",
            function()
                vim.lsp.buf.format({ async = true })
            end,
            desc = "格式化当前文件",
        },
        {
            "<leader>lF",
            function()
                vim.cmd("silent! write")
                vim.lsp.buf.format({ async = false })
            end,
            desc = "保存并格式化当前文件",
        },
    },
}