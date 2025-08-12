-- Lightweight yet powerful formatter plugin for Neovim

return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      bash = { "beautysh" },
      css = { { "prettierd", "prettier" } },
      javascript = { "eslint_d", stop_after_first = true },
      html = { "htmlbeautyfier" },
      lua = { "stylua" },
      markdown = { { "prettierd", "prettier" } },
      php = { "pint" },
      typescript = { "eslint_d", stop_after_first = true },
      typescriptreact = { "eslint_d", stop_after_first = true },
    },
  },
}
