return {
  "rest-nvim/rest.nvim",
  enabled = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "http")
    end,
  },
  config = function()
    -- Load the telescope extension for rest.nvim
    require("telescope").load_extension("rest")

    -- Set up rest.nvim configuration using vim.g.rest_nvim
    vim.g.rest_nvim_show_response_curl_command = true
    vim.g.rest_nvim_respond_with = "json" -- or "text"
  end,
  keys = {
    { "<leader>R", group = "REST" },
    { "<leader>Re", "<Cmd>Telescope rest select_env<CR>", desc = "Select environment" },
    { "<leader>Rr", "<Cmd>Rest run<CR>", desc = "Send HTTP Requet" },
    { "<leader>Rl", "<Cmd>Rest last<CR>", desc = "Send Last Requet" },
    { "<leader>Rc", "<Cmd>Rest curl yank<CR>", desc = "Copy to clipboard as curl" },
  },
}
