-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.incsearch = true
vim.opt.title = true
vim.opt.spell = true
vim.opt.scrolloff = 8 -- lines of context
-- vim.g.loaded_ruby_provider = 0

-- crează un bkp la salvarea oricarui fisier undeva in ~ (vezi print(vim.inspect(vim.opt.backupdir:get())) )
-- vim.opt.backup = true
-- vim.opt.backupdir.remove('.')

-- LSP Server to use for PHP.
-- Set to "intelephense" to use intelephense instead of phpactor.
vim.g.lazyvim_php_lsp = "intelephense"

vim.g.terminal_emulator = "dce tapp php"
