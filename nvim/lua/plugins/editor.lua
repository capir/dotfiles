return {
  {
    -- visualizes the undo history and makes it easy to browse and switch between different undo branches.
    "mbbill/undotree",
  },
  {
    -- Always have a nice view over your split windows
    -- 👌 Resizes split windows automatically based on golden ratio
    --    Enables cursorline/signcolumn/numbers on focus window only
    -- 🙌 Window creation or switch by direction
    -- 🖥 Equalise splits or maximise focused splits, and toggle between the two
    -- 🔌 Option to open tmux windows instead of creating new splits
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
  -- Deep buffer integration for Git
  --
  -- Signs
  -- Hunk Actions
  -- Blame
  -- Diff
  -- Show hunks Quickfix/Location List
  -- Text Object
  -- Status Line Integration
  -- Show different revisions of buffers
  { "lewis6991/gitsigns.nvim", enabled = true },
  {
    -- A simple wrapper around git worktree operations, create, switch, and delete.
    "ThePrimeagen/git-worktree.nvim",
    init = function()
      -- print("ThePrimeagen")
      require("git-worktree").setup({})
      require("telescope").load_extension("git_worktree")
    end,
  },
}
