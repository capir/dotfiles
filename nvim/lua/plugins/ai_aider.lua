vim.env.OPENAI_API_KEY = vim.fn.system("pass show api/token/openai"):gsub("%s+$", "")
vim.env.ANTHROPIC_API_KEY = vim.fn.system("pass show api/token/anthropic"):gsub("%s+$", "")

return {
  "joshuavial/aider.nvim",
  opts = {
    -- your configuration comes here
    -- if you don't want to use the default settings
    auto_manage_context = true, -- automatically manage buffer context
    default_bindings = true, -- use default <leader>A keybindings
    debug = false, -- enable debug logging
  },
}
