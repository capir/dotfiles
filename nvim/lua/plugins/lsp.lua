-- if true then
--   return {}
-- end

vim.diagnostic.config({
  virtual_text = false,
  float = {
    source = true,
  },
})
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          settings = {
            intelephense = {
              licenceKey = "00FC006EHTDB9O4",
              -- environment = {
              --   phpVersion = "7.0.33",
              -- },
            },
          },
        },
      },
    },
  },
  -- {
  --   "nvimtools/none-ls.nvim",
  --   opts = function(_, opts)
  --     local null_ls = require("null-ls")
  --     opts.sources = opts.sources or {}
  --     vim.list_extend(opts.sources, {
  --       null_ls.builtins.diagnostics.phpcs.with({
  --         command = "phpcs",
  --         args = { "--standard=PSR12", "--report=json", "--no-colors", "--encoding=utf-8", "-" },
  --       }),
  --     })
  --   end,
  -- },
  -- {
  --   "nvimtools/none-ls.nvim",
  --   opts = function(_, opts)
  --     local null_ls = require("null-ls")
  --     opts.sources = opts.sources or {}
  --     vim.list_extend(opts.sources, {
  --       null_ls.builtins.formatting.pint.with({
  --         extra_args = { "--config", "pint.json" },
  --       }),
  --     })
  --   end,
  -- },
  {
    "mfussenegger/nvim-dap",
    enabled = false,
    opts = {
      adapters = {
        php = {
          type = "executable",
          command = "node",
          -- args = { "/path/to/vscode-php-debug/out/phpDebug.js" },
        },
      },
      configurations = {
        php = {
          {
            type = "php",
            request = "launch",
            name = "Listen for Xdebug",
            port = 9003,
          },
        },
      },
    },
  },
}
