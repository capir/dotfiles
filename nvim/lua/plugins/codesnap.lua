-- Code snapshots
-- 📸 Snapshot plugin with rich features that can make pretty code snapshots for Neovim

return {
  "mistricky/codesnap.nvim",
  enabled = false,
  build = "make",
  opts = {
    mac_window_bar = false,
    code_font_family = "JetBrainsMono Nerd Font",
    watermark = "",
  },
}
