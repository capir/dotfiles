if true then
  return {}
end

return {
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local nls = require("null-ls")
      nls.setup({
        sources = {
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.prettier,
          nls.builtins.diagnostics.eslint_d,
          nls.builtins.diagnostics.phpstan.with({
            extra_args = {
              "--memory-limit=2G",
            },
          }),
        },
      })
    end,
  },
  {
    -- add longer timeout, since formatting blade files gets a little slow
    -- "neovim/nvim-lspconfig",
    -- opts = {
    --   format = { timeout_ms = 2000 },
    -- },
  },
}
