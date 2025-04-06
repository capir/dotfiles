-- 🖱️ Jump to any context by just clicking on it.
-- 🌲 Have a deeply nested file-tree/context? It's gonna get rid of the less useful parts smartly.
-- 📂 Easily tell where your file is located at by looking at your winbar.
-- 📜 Put whatever your heart desires in the custom section.

return {
  "utilyre/barbecue.nvim",
  event = "BufRead",
  dependencies = {
    {
      "SmiteshP/nvim-navic",
      opts = {
        lsp = {
          auto_attach = true,
          preference = { "intelephense" },
        },
      },
    },
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    theme = "tokyonight",
  },
}
