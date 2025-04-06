-- terminal in the floating/popup window.

return {
  "voldikss/vim-floaterm",
  keys = {
    { "§", "<Cmd>FloatermToggle<CR>", desc = "Quick Terminal", mode = { "n" } },
    { "§", "<Cmd>FloatermToggle<CR>", desc = "Quick Terminal", mode = { "t" } },
  },
}
