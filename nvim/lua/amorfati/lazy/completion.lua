return {
    {
        "saghen/blink.cmp",

        -- Ships prebuilt fuzzy-matcher binaries per tag; no cargo needed.
        version = "1.*",

        event = "InsertEnter",

        opts = {
            keymap = {
                preset = "default",
                ["<CR>"] = { "accept", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
            },

            appearance = {
                nerd_font_variant = "mono",
            },

            completion = {
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                },
                ghost_text = {
                    enabled = true,
                },
            },

            signature = {
                enabled = true,
            },

            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },

            fuzzy = {
                implementation = "prefer_rust_with_warning",
            },
        },

        opts_extend = { "sources.default" },
    },
}
