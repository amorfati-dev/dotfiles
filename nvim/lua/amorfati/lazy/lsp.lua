return {
    {
        "mason-org/mason-lspconfig.nvim",

        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
            "j-hui/fidget.nvim",
        },

        opts = {
            ensure_installed = {
                "lua_ls",
                "pyright",
                "vtsls",
            },
        },

        config = function(_, opts)
            require("fidget").setup()

            require("mason-lspconfig").setup(opts)

            -- Nvim 0.11+ ships diagnostics with signs + underline only.
            -- Turn the text back on so errors are visible in the buffer.
            vim.diagnostic.config({
                virtual_text = { source = "if_many", spacing = 2 },
                severity_sort = true,
                float = { border = "rounded", source = "if_many" },
            })

            vim.o.winborder = "rounded"

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },

                        diagnostics = {
                            globals = { "vim" },
                        },

                        workspace = {
                            -- Only the `lua/` dirs: scanning every runtime
                            -- path drags in docs/syntax and makes lua_ls crawl.
                            library = vim.list_extend(
                                vim.api.nvim_get_runtime_file("lua", true),
                                { "${3rd}/luv/library" }
                            ),
                            checkThirdParty = false,
                        },

                        telemetry = {
                            enable = false,
                        },
                    },
                },
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(event)
                    local opts_local = { buffer = event.buf }

                    -- K, grn, gra, grr, gri, grt and gO are LSP defaults in
                    -- 0.11+. Only map what they don't already cover; a plain
                    -- `gr` here would shadow the whole `gr*` prefix and stall
                    -- every one of them for 'timeoutlen'.
                    vim.keymap.set(
                        "n",
                        "gd",
                        vim.lsp.buf.definition,
                        opts_local
                    )

                    vim.keymap.set(
                        "n",
                        "<leader>d",
                        vim.diagnostic.open_float,
                        opts_local
                    )
                end,
            })
        end,
    },
}
