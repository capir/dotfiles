-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- local function check_intelephense_license()
--   local ok, noice = pcall(require, "noice")
--   if not ok then
--     vim.notify("Noice.nvim not found!", vim.log.levels.ERROR)
--     return
--   end
--
--   local clients = vim.lsp.get_active_clients()
--   local found = false
--
--   for _, client in ipairs(clients) do
--     if client.name == "intelephense" then
--       found = true
--       if client.server_capabilities.workspaceSymbolProvider and client.server_capabilities.signatureHelpProvider then
--         noice.notify(
--           "✅ Intelephense is running.\n🚀 Premium features detected.\n✅ License is active! 🎉",
--           "info"
--         )
--       else
--         noice.notify(
--           "✅ Intelephense is running.\n⚠️ Premium features missing.\n⚠️ License may not be active.",
--           "warn"
--         )
--       end
--       break
--     end
--   end
--
--   if not found then
--     noice.notify("❌ Intelephense is not attached to this buffer.", "error")
--   end
-- end
--
-- vim.keymap.set("n", "<leader>cl", check_intelephense_license, { desc = "Check Intelephense License" })
--
vim.api.nvim_create_user_command("CheckIntelephenseLicense", function()
  local params = { query = "test" }

  -- Send a premium-only request
  vim.lsp.buf_request(0, "workspace/symbol", params, function(err, result, ctx, config)
    if err then
      vim.notify("Intelephense License ❌ (error on premium request)", vim.log.levels.ERROR)
    elseif result == nil then
      vim.notify("Intelephense License ❌ (no result)", vim.log.levels.WARN)
    else
      vim.notify("Intelephense License ✅ (premium features active)", vim.log.levels.INFO)
    end
  end)
end, {})
