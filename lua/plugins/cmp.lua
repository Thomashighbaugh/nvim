--  ╭───────────────────────────────────────────────────────────────╮
--  │                                                               │
--  │                              CMP                              │
--  │                                                               │
--  ╰───────────────────────────────────────────────────────────────╯

local M = {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-document-symbol",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "petertriho/cmp-git",
        "davidsierradz/cmp-conventionalcommits",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "dmitmel/cmp-cmdline-history",
        "garyhurtz/cmp_kitty",
        "tamago324/cmp-zsh",
        "David-Kunz/cmp-npm",
        "ray-x/cmp-treesitter",
        "hrsh7th/cmp-calc",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "doxnit/cmp-luasnip-choice",
    },
    config = function()
        local cmp = require("cmp")
        local lspkind = require("lspkind")

        cmp.setup({
            formatting = {
                format = lspkind.cmp_format({
                    with_text = false,
                    maxwidth = 50,
                    mode = "symbol",
                    menu = {
                        buffer = "BUF",
                        rg = "RG",
                        nvim_lsp = "LSP",
                        path = "PATH",
                        luasnip = "SNIP",
                        calc = "CALC",
                    },
                }),
            },
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            mapping = {
                ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                ["<C-u>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.close(),
                ["<CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function()
                    if cmp.visible() then
                        cmp.select_prev_item()
                    end
                end, { "i", "s" }),
            },
            sources = {
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
                { name = "buffer", keyword_length = 5 },
                { name = "luasnip" },
                { name = "calc" },
                { name = "path" },
                { name = "luasnip-choice" },
                { name = "treesitter" },
                { name = "cmdline" },
                { name = "cmdline-history" },
                { name = "zsh" },
                --	{ name = "nvim_lsp_document_symbol" },
            },
        })

        -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" },
            },
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
        })
    end,
}

return M
