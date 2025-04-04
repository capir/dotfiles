return {
  {
    "mbbill/undotree",
  },
  {
    "nvim-focus/focus.nvim",
    enabled = false,
    version = "*",
    init = function()
      require("focus").setup({
        autoresize = {
          minwidth = 10,
          minheight = 10,
        },
        ui = {
          number = false,
          -- relativenumber = true,
          hybridnumber = true,
          absolutenumber_unfocussed = true,
        },
      })
    end,
  },
  { "lewis6991/gitsigns.nvim", enabled = true },
  {
    "ThePrimeagen/git-worktree.nvim",
    init = function()
      -- print("ThePrimeagen")
      require("git-worktree").setup({})
      require("telescope").load_extension("git_worktree")
    end,
  },
}
