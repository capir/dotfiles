-- if true the-- vim.diagnostic setup
vim.diagnostic.config({
  virtual_text = false,
  float = { source = true },
})

-- Determine project PHP version
local phpverfile = vim.fn.getcwd() .. "/.php-version"
local phpver = "7.0.33"
if vim.loop.fs_stat(phpverfile) then
  phpver = vim.fn.readfile(phpverfile)[1]
end

-- on_attach for Intelephense (diagnostics, hover, definition, rename)
local function on_attach_intelephense(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
end

-- on_attach for Phpactor (code generation)
local function on_attach_phpactor(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  -- Generate code actions / refactors
  vim.keymap.set("n", "<leader>cg", function()
    vim.cmd("PhpactorContextMenu") -- or PhpactorClassGenerateMethod, PhpactorClassGenerateConstructor
  end, bufopts)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Intelephense: diagnostics only
        intelephense = {
          settings = {
            intelephense = {
              licenceKey = "00FC006EHTDB9O4",
              diagnostics = { undefinedFunctions = true, undefinedMethods = true },
              environment = { phpVersion = phpver },
              files = {
                maxSize = 2000000,
                exclude = { "**/vendor/**", "**/node_modules/**" },
              },
              maxMemory = 2048,
            },
          },
          flags = { debounce_text_changes = 500 },
          on_attach = on_attach_intelephense,
        },

        -- Phpactor: code generation only
        phpactor = {
          cmd = { "~/.local/bin/phpactor", "language-server" },
          root_dir = require("lspconfig.util").root_pattern("composer.json", ".git"),
          on_attach = on_attach_phpactor,
        },
      },
    },
  },

  -- optional: debugging
  {
    "mfussenegger/nvim-dap",
    enabled = false,
    opts = {
      adapters = {
        php = { type = "executable", command = "node" },
      },
      configurations = {
        php = {
          { type = "php", request = "launch", name = "Listen for Xdebug", port = 9003 },
        },
      },
    },
  },
}
