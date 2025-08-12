return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, { "yaml" }) -- use yaml grammar for neon
    opts.filetype_to_parsername = vim.tbl_extend("force", opts.filetype_to_parsername or {}, {
      neon = "yaml",
    })
  end,
}
