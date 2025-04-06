return {
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    build = (not LazyVim.is_win())
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          -- require("luasnip.loaders.from_vscode").lazy_load()
          -- require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
          require("luasnip/loaders/from_snipmate").lazy_load()
        end,
      },
      -- { "saadparwaiz1/cmp_luasnip" },
      {
        "hrsh7th/nvim-cmp",
        optional = true,
        dependencies = { "saadparwaiz1/cmp_luasnip" },
        opts = function(_, opts)
          opts.snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          }
          table.insert(opts.sources, { name = "luasnip" })
        end,
        keys = {
          {
            "<tab>",
            function()
              require("luasnip").jump(1)
            end,
            mode = "s",
          },
          {
            "<s-tab>",
            function()
              require("luasnip").jump(-1)
            end,
            mode = { "i", "s" },
          },
        },
      },
      {
        "saghen/blink.cmp",
        optional = true,
        opts = {
          snippets = {
            preset = "luasnip",
          },
        },
      },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },
}
