return {
  {
    "mbbill/undotree",
  },
  {
    "nvim-focus/focus.nvim",
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
  {
    "ThePrimeagen/git-worktree.nvim",
    init = function()
      print("ThePrimeagen")
      require("git-worktree").setup({})
      require("telescope").load_extension("git_worktree")
    end,
  },
}
