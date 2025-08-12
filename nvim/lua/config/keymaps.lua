-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Move to window using the <ctrl> hjkl keys
-- vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", { desc = "Go to Left Window" })
-- vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", { desc = "Go to Lower Window" })
-- vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", { desc = "Go to Upper Window" })
-- vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", { desc = "Go to Right Window" })

vim.keymap.set("n", "J", "mzJ`z:delmarks z<CR>", { desc = "Concat cu următoarea linie.", silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "PagUp", silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "PagDown", silent = true })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search Result", silent = true })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev Search Result", silent = true })
vim.keymap.set("x", "p", '"_dP', { desc = "Paste yanked", silent = true })
vim.keymap.set("i", ";;", "<Esc>A;<Esc>", { desc = "Append ; EOL", silent = true })
vim.keymap.set("i", ",,", "<Esc>A,<Esc>", { desc = "Append . EOL", silent = true })
vim.keymap.set("n", "<Leader>,", ":nohl<CR>", { desc = "Clear search highlight", silent = true })

vim.keymap.set("n", "<leader>fv", function()
  require("telescope.builtin").find_files({
    no_ignore = true,
    hidden = true,
    search_dirs = { "vendor" },
  })
end, { desc = "Find files in vendor/" })

-- Disable arrow keys in Normal, Insert, and Visual modes
vim.api.nvim_set_keymap("n", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Right>", "<Nop>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Right>", "<Nop>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("v", "<Up>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<Down>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<Left>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<Right>", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>o", function()
  vim.api.nvim_create_autocmd("WinNew", {
    callback = function()
      local wins = vim.api.nvim_list_wins()
      for _, win in ipairs(wins) do
        local conf = vim.api.nvim_win_get_config(win)
        if conf.relative ~= "" then
          print("Window:", win)
          print(vim.inspect(conf))
        end
      end
    end,
  })
  print("test")

  vim.cmd("PhpactorContextMenu")
end)
