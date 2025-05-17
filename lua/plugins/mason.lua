return {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
        "neovim/nvim-lspconfig",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function (_, opts)
        -- 初始化 mason
        require("mason").setup(opts)

        -- 配置诊断选项，启用插入模式下的诊断更新
        vim.diagnostic.config({
            update_in_insert = true,
            -- 可以添加更多诊断配置选项
            -- virtual_text = true,
            -- signs = true,
            -- underline = true,
            -- severity_sort = true,
        })

        -- 封装 LSP 设置函数（简化版）
        local registry = require("mason-registry")
        local lspconfig = require("lspconfig")

        local function setup_lsp(mason_name, lsp_name, config)
            -- 尝试安装 LSP 服务器
            local success, package = pcall(registry.get_package, mason_name)
            if success and not package:is_installed() then
                package:install()
            end

            -- 直接使用传入的 lsp_name 配置 LSP
            lspconfig[lsp_name].setup(config or {})
        end

        -- 设置 Lua LSP（明确指定 lsp_name）
        setup_lsp("lua-language-server", "lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" }  -- 识别 vim 全局变量
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false
                    },
                    telemetry = {
                        enable = false
                    }
                }
            }
        })

        -- 设置 Python LSP
        setup_lsp("pyright", "pyright", {
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        diagnosticMode = "workspace",
                        useLibraryCodeForTypes = true,
                        typeCheckingMode = "basic"  -- 可以设为 "off", "basic" 或 "strict"
                    }
                }
            },
            -- 可选：指定 Python 解释器路径
            pythonPath = "/usr/bin/python3"
        })

        -- 设置 C/C++ LSP (clangd)
        setup_lsp("clangd", "clangd", {
            cmd = {
                "clangd",
                "--background-index",  -- 后台建立索引，提高性能
                "--clang-tidy",        -- 启用 clang-tidy 进行代码分析
                "--header-insertion=iwyu",  -- 按需包含头文件
                "--completion-style=detailed",  -- 提供详细的补全信息
                "--function-arg-placeholders",  -- 函数参数占位符
                "--fallback-style=llvm"  -- 使用 LLVM 代码风格
            },
            filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
            root_dir = function(fname)
                return lspconfig.util.root_pattern(
                    "compile_commands.json",
                    "compile_flags.txt",
                    ".git"
                )(fname) or lspconfig.util.find_git_ancestor(fname)
            end,
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true
            }
        })

        -- 可以添加更多 LSP 配置

        -- 启动 LSP
        vim.cmd("LspStart")
    end,
}
