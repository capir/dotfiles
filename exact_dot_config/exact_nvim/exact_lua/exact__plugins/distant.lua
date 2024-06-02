if true then
  return {}
end
return {
  "chipsenkbeil/distant.nvim",
  branch = "v0.3",
  init = function()
    require("distant"):setup()
  end,
}
