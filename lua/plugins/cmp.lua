return {
    {
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            local cmp = require("cmp")
            opts.mapping = vim.tbl_deep_extend("force", opts.mapping, {
                ["<Tab>"] = cmp.mapping.confirm({ select = true }),
                ["<CR>"] = cmp.config.disable,
                ['<Down>'] = cmp.mapping(
                    function(fallback)
                    cmp.close()
                    fallback()
                    end, { "i" }
                ),
                ['<Up>'] = cmp.mapping(
                    function(fallback)
                    cmp.close()
                    fallback()
                    end, { "i" }
                ),
            })
        end,
    },
}