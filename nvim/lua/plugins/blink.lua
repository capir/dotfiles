return {
  "blink.cmp",
  config = function()
    local ok, blink = pcall(require, "blink.cmp")
    if ok and blink.fuzzy and blink.fuzzy.use_lua then
      blink.fuzzy.use_lua()
    end
  end,
}
