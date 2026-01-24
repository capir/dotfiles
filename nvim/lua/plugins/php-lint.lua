-- lua/plugins/php-lint.lua
return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      php = { "phpstan" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      pattern = "*.php",
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
