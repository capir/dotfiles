return {
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "V13Axel/neotest-pest",
    },
    config = function()
      require("neotest").setup({
        icons = {
          passed = "✓",
          failed = "✗",
          running = "▶",
          skipped = "⚠",
        },
        log_level = vim.log.levels.DEBUG, -- more verbose, great for debugging
        adapters = {
          require("neotest-pest")({
            sail_enabled = function()
              return false
            end,
            pest_cmd = "./vendor/bin/pest",
            results_path = function()
              return "./storage/app/" .. os.date("junit-%Y%m%d-%H%M%S")
            end,
          }),
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "php",
      },
    },
  },
}
