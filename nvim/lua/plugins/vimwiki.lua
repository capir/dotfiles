return {
  "vimwiki/vimwiki",
  init = function()
    -- vimwiki MUST be configured in init(), not config()
    vim.g.vimwiki_list = {
      {
        path = "~/repos/vimwiki/",
        syntax = "markdown",
        ext = ".md",
      },
      {
        path = "~/work/TOS/vimwiki/",
        syntax = "markdown",
        ext = ".md",
      },
    }

    vim.g.vimwiki_global_ext = 0 -- only treat wiki dirs as wiki
  end,
}
