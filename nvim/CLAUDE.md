# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration built on [LazyVim](https://lazyvim.github.io/). It uses `lazy.nvim` as the plugin manager and is primarily set up for PHP/Laravel development, with extras for JS/TS, Docker, Git, Markdown, REST, and Tailwind.

## Code Style

Lua files are formatted with `stylua`. Config: 2-space indentation, 120 column width (`stylua.toml`).

Run formatter: `stylua lua/`

## Architecture

### Entry point

`init.lua` → `lua/config/lazy.lua` bootstraps lazy.nvim and imports all plugins from `lua/plugins/`.

### Key directories

- `lua/config/` — Core config: `lazy.lua` (plugin manager setup), `options.lua`, `keymaps.lua`, `autocmds.lua`
- `lua/plugins/` — One file per plugin (or plugin group). Each returns a lazy.nvim plugin spec table.
- `after/ftdetect/`, `after/ftplugin/` — Filetype detection/settings (currently only `neon` filetype)
- `snippets/` — LuaSnip-compatible snippet files (currently `php.snippets`)
- `lazyvim.json` — LazyVim extras enabled for this installation

### Plugin file conventions

- Plugin files return a table (or table-of-tables) following the lazy.nvim spec
- Files ending in `.lua.d` or `.disabled` are ignored by lazy.nvim (used to park inactive configs)
- `lua/plugins/disabled.lua` explicitly disables plugins that LazyVim or extras would otherwise enable
- `lua/plugins/overrides.lua` re-enables or tweaks LazyVim defaults

### Active LazyVim extras (lazyvim.json)

AI, copilot, luasnip, mini-surround, yanky, dial, harpoon2, inc-rename, mini-diff, mini-files, refactoring, telescope, prettier, docker, git, json, markdown, PHP, tailwind, none-ls, rest.

## PHP / LSP Setup

Two LSP servers run side-by-side for PHP (`lua/plugins/lsp.lua`):

- **Intelephense** — diagnostics, hover, definition, rename (premium). PHP version read from `.php-version` file in project root.
- **Phpactor** — code generation and refactoring via `<leader>cg` (PhpactorContextMenu)

LSP is configured via `vim.g.lazyvim_php_lsp = "intelephense"` in `options.lua`.

Diagnostics: virtual text disabled; shown in float with source info.

## Formatting & Linting

**conform.nvim** (`lua/plugins/conform.lua`) — formats on save:
- Lua: `stylua`
- PHP: `prettier`, `pint`
- JS/TS/TSX: `eslint_d`
- CSS/Markdown: `prettierd` / `prettier`
- HTML: `htmlbeautyfier`
- Bash: `beautysh`

**nvim-lint** (`lua/plugins/nvim-lint.lua`) — lints on BufWritePost/BufReadPost/InsertLeave:
- PHP: `phpstan`, `phpmd`
- All filetypes: `typos`

## Testing

vim-test (`lua/plugins/vim-test.lua`) runs tests in a floaterm window:

| Key | Action |
|-----|--------|
| `<leader>tn` | Test nearest |
| `<leader>tf` | Test file |
| `<leader>ts` | Test suite |
| `<leader>tl` | Test last |
| `<leader>tv` | Test visit |

Note: `vim-test` is currently disabled in `lua/plugins/disabled.lua`. To re-enable, remove it from there.

## Claude Code Integration

`lua/plugins/ai_claudecode.lua` integrates claudecode.nvim:

| Key | Action |
|-----|--------|
| `<leader>ac` | Toggle Claude |
| `<leader>af` | Focus Claude |
| `<leader>ar` | Resume session |
| `<leader>aC` | Continue session |
| `<leader>am` | Select model |
| `<leader>ab` | Add current buffer |
| `<leader>as` | Send selection (visual) / Add file (file tree) |
| `<leader>aa` | Accept diff |
| `<leader>ad` | Deny diff |

## Adding a New Plugin

Create `lua/plugins/<name>.lua` returning a lazy.nvim spec. To temporarily disable without deleting, rename to `<name>.lua.d`. To permanently disable a plugin from another spec (e.g., a LazyVim extra), add it to `lua/plugins/disabled.lua`.

## Notable Custom Keymaps (keymaps.lua)

- `;;` / `,,` (insert) — append `;` / `,` at end of line
- `<leader>,` — clear search highlight
- `<leader>fv` — telescope find files in `vendor/`
- `<leader>cg` — Phpactor context menu
- `J` / `K` (visual) — move selected lines up/down
- Arrow keys disabled in normal, insert, and visual modes
