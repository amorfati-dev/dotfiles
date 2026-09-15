return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",

        config = function()
            local parsers = {
                "lua",
                "vim",
                "vimdoc",
                "query",
                "python",
                "javascript",
                "typescript",
                "tsx",
                "html",
                "css",
                "json",
                "bash",
                "markdown",
                "markdown_inline",
            }

            require("nvim-treesitter").install(parsers)

            local group = vim.api.nvim_create_augroup(
                "AmorfatiTreesitter",
                { clear = true }
            )

            vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
                group = group,
                callback = function()
                    if vim.bo.buftype == "" then
                        pcall(vim.treesitter.start)
                    end
                end,
            })
        end,
    },
}
