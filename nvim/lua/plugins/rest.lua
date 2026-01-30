return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  keys = {
    { "<leader>Re", "<cmd>lua require('kulala').set_selected_env()<cr>", desc = "Select environment..." },
  },
}
