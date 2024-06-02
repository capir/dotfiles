if true then
  return {}
end
return {
  "OscarCreator/rsync.nvim",
  build = "make",
  dependencies = "nvim-lua/plenary.nvim",
  config = function()
    require("rsync").setup({})
  end,
}
--   "KenN7/vim-arsync",
-- }
-- return {
--   "coffebar/transfer.nvim",
--   -- lazy = true,
--   cmd = { "TransferInit", "DiffRemote", "TransferUpload", "TransferDownload", "TransferDirDiff", "TransferRepeat" },
--   opts = {},
--   init = function()
--     require("transfer").setup({
--       close_diffview_mapping = "<leader>tb",
--     })
--   end,
--   config = function()
--     require("which-key").register({
--       ["<leader>"] = {
--         t = {
--           name = "Upload / Download",
--           d = { "<cmd>TransferDownload<cr>", "Download from remote server (scp)" },
--           u = { "<cmd>TransferUpload<cr>", "Upload to remote server (scp)" },
--           f = { "<cmd>DiffRemote<cr>", "Diff file with remote server (scp)" },
--           i = { "<cmd>TransferInit<cr>", "Init/Edit Deployment config" },
--           r = { "<cmd>TransferRepeat<cr>", "Repeat transfer command" },
--         },
--       },
--     })
--   end,
--
-- }
