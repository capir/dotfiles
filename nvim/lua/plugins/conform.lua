-- Lightweight yet powerful formatter plugin for Neovim

  return {
    "stevearc/conform.nvim",
    init = function()
      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function(args)
          require("conform").format({ bufnr = args.buf, timeout_ms = 500, lsp_format = "fallback" })
        end,
      })
    end,
    opts = {
      formatters_by_ft = {
        bash = { "beautysh" },
        css = { { "prettierd", "prettier" } },
        javascript = { "eslint_d", stop_after_first = true },
        html = { "htmlbeautyfier" },
        lua = { "stylua" },
        markdown = { { "prettierd", "prettier" } },
        php = { "prettier", "pint" },
        typescript = { "eslint_d", stop_after_first = true },
        typescriptreact = { "eslint_d", stop_after_first = true },
      },
    },
  }
