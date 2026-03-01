return {
  "eliasCVII/timew.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- your configuration lives here
    -- leave empty for defaults.
  },
  keys = {
    { "<leader>t", group = "TimeWarrior" },
    { "<leader>ts", "<Cmd>Timew stop<CR>", desc = "TimeWarrior stop" },
    { "<leader>tc", "<Cmd>Timew continue<CR>", desc = "TimeWarrior continue" },
    { "<leader>tC", "<Cmd>Timew cancel<CR>", desc = "TimeWarrior cancel" },
    { "<leader>tS", "<Cmd>Timew summary<CR>", desc = "TimeWarrior summary" },
  },
}
