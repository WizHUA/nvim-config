return {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    opts = {
        PATH = "prepend", -- 将 Mason 的 bin 目录添加到 PATH 开头
        pip = {
            -- 指定安装命令
            install_args = {
                "--user", -- 使用用户安装模式
            },
            -- upgrade_pip = true, -- 自动升级 pip
        },
        -- 可以指定 Python 解释器路径
        -- python_path = vim.fn.exepath("python3"),
        
        -- 调整 UI 设置（可选）
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            }
        },
        
        -- 打开日志以便调试
        log_level = vim.log.levels.DEBUG,
    },
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

            -- 添加 on_attach 回调函数，禁用 LSP 格式化功能
            config = config or {}
            local original_on_attach = config.on_attach
            config.on_attach = function(client, bufnr)
                -- 禁用 LSP 格式化，由 none-ls 处理
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
                
                -- 如果有原始的 on_attach，也执行它
                if original_on_attach then
                    original_on_attach(client, bufnr)
                end
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
