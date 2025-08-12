-- terminal in the floating/popup window.

return {
  "voldikss/vim-floaterm",
  init = function()
    vim.g.floaterm_width = 0.9
    vim.g.floaterm_height = 0.9
  end,
  keys = {
    { "§", "<Cmd>FloatermToggle<CR>", desc = "Quick Terminal", mode = { "n" } },
    { "§", "<Cmd>FloatermToggle<CR>", desc = "Quick Terminal", mode = { "t" } },
  },
}
