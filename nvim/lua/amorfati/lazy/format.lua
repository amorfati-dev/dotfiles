return {
    {
        "stevearc/conform.nvim",

        event = { "BufWritePre" },
        -- Declared here too, so lazy.nvim stubs them before load.
        cmd = { "ConformInfo", "FormatDisable", "FormatEnable" },

        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({
                        async = true,
                        lsp_format = "fallback",
                    })
                end,
                mode = { "n", "v" },
                desc = "Format buffer or selection",
            },
        },

        opts = {
            format_on_save = function(bufnr)
                -- Escape hatch: :FormatDisable while you're in someone
                -- else's repo, :FormatEnable to turn it back on.
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end

                return { timeout_ms = 3000, lsp_format = "fallback" }
            end,

            formatters_by_ft = {
                -- Two passes, both must run: no stop_after_first here.
                python = { "ruff_organize_imports", "ruff_format" },
                lua = { "stylua" },

                javascript = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true },

                json = { "prettierd", "prettier", stop_after_first = true },
                jsonc = { "prettierd", "prettier", stop_after_first = true },
                yaml = { "prettierd", "prettier", stop_after_first = true },
                html = { "prettierd", "prettier", stop_after_first = true },
                css = { "prettierd", "prettier", stop_after_first = true },
                scss = { "prettierd", "prettier", stop_after_first = true },
                markdown = { "prettierd", "prettier", stop_after_first = true },
            },
        },

        config = function(_, opts)
            require("conform").setup(opts)

            vim.api.nvim_create_user_command("FormatDisable", function(args)
                if args.bang then
                    vim.b.disable_autoformat = true
                else
                    vim.g.disable_autoformat = true
                end
            end, {
                desc = "Disable format-on-save (! for this buffer only)",
                bang = true,
            })

            vim.api.nvim_create_user_command("FormatEnable", function()
                vim.b.disable_autoformat = false
                vim.g.disable_autoformat = false
            end, { desc = "Re-enable format-on-save" })
        end,
    },
}
