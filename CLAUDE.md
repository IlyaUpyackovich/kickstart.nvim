# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal Neovim configuration based on Kickstart.nvim, designed as a single-file (`init.lua`) configuration with modular plugin extensions.

## Architecture

### Plugin Management
- **Plugin Manager**: lazy.nvim (installed in `init.lua:229-237`)
- **Plugin Locations**:
  - Core plugins: defined directly in `init.lua` line 250+
  - Kickstart plugins: `lua/kickstart/plugins/*.lua` (optional components like debug, neo-tree, gitsigns)
  - Custom plugins: `lua/custom/plugins/*.lua` (auto-imported via line 945)

### LSP Configuration (Neovim 0.11+)
This config uses the **new Neovim 0.11+ LSP API** (`vim.lsp.config`) instead of lspconfig's `setup()`:
- LSP servers configured: `init.lua:594-668` using `vim.lsp.config(server_name, config)`
- Server installation managed by Mason (`mason.nvim`, `mason-lspconfig.nvim`, `mason-tool-installer.nvim`)
- Common on_attach logic: `init.lua:499-558` (sets up keymaps, document highlighting, inlay hints)

**Configured LSP Servers**:
- gopls (Go) - Full config with inlay hints, analysis, gofumpt
- vtsls (TypeScript/JavaScript) - Full config with inlay hints, import management
- solargraph (Ruby)
- templ (Templ templates)
- jsonls (JSON with schema validation)
- html (HTML)
- emmet_ls (Emmet for HTML/CSS/Templ/React)
- lua_ls (Lua)

### Formatting & Linting
- **Formatter**: `conform.nvim`
  - Format on save enabled (500ms timeout, LSP fallback, toggleable with `<leader>tf`)
  - Configured formatters:
    - stylua (Lua)
    - goimports + gofumpt (Go)
    - templ (templ templates)
    - prettier/prettierd (TS/JS/JSX/TSX/Markdown)
  - Keybinding: `<leader>f` to format buffer
- **Linter**: `nvim-lint` (`lua/kickstart/plugins/lint.lua`)
  - eslint_d (JS/TS with dynamic config detection)
  - markdownlint (Markdown)
  - ruby (Ruby)

### Autocompletion
- Uses `blink.cmp` (not nvim-cmp) with LuaSnip for snippets (`init.lua:733-832`)

### Markdown Preview
- Plugin: `markview.nvim` (`init.lua:1376-1399`)
- In-buffer markdown rendering with hybrid mode
- Features:
  - Hybrid mode: Edit and see preview simultaneously
  - Splitview: Side-by-side editing and preview
  - Math rendering: 2000+ LaTeX symbols via KaTeX
  - GitHub emojis, tables, callouts, checkboxes
  - Works with blink.cmp for callout/checkbox completion
- Keybindings:
  - `<leader>mt` - Toggle preview
  - `<leader>ms` - Split preview (side-by-side)
  - `<leader>mh` - Hybrid mode (edit + preview in same buffer)

### Project-Local Configuration
- Plugin: `nvim-config-local` (`init.lua:948-960`)
- Looks for `.nvim.lua`, `.nvimrc`, `.exrc` in project directories
- Use these files for project-specific LSP settings, keymaps, or options

## Common Development Tasks

### Adding a New LSP Server
1. Add server name to `ensure_installed` table in `init.lua:672-682`
2. Configure the server using `vim.lsp.config('server_name', { on_attach = on_attach, capabilities = capabilities, ... })` around line 594-668
3. Restart Neovim or run `:Lazy sync` to install

### Adding a New Custom Plugin
1. Create a new file in `lua/custom/plugins/plugin-name.lua`
2. Return a lazy.nvim plugin spec table (see existing plugins as examples)
3. Restart Neovim or run `:Lazy sync`

### Adding a Formatter
1. Ensure the formatter is installed (add to `mason-tool-installer` if available)
2. Add filetype mapping in `init.lua:721-729` under `formatters_by_ft`

### Adding a Linter
1. Edit `lua/kickstart/plugins/lint.lua`
2. Add filetype mapping in the `linters_by_ft` table (line 34-41)
3. Configure the linter if needed (see eslint_d example for complex cases)

### Managing Plugins
- `:Lazy` - Open plugin manager UI
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Install missing plugins and update existing ones

### LSP Commands
- `:Mason` - Open Mason UI to manage LSP servers, linters, formatters
- `:checkhealth` - Diagnose configuration issues
- `:LspInfo` - Show LSP server status for current buffer

### Testing Configuration Changes
- For quick testing: `:source %` after editing Lua files
- For plugin changes: Restart Neovim or `:Lazy reload <plugin-name>`

## Key Keybindings

Leader key: `<Space>`

### LSP Navigation (defined in init.lua:516-524)
- `grd` - Go to definition
- `gri` - Go to implementation
- `grr` - Find references
- `gO` - Document symbols
- `gW` - Workspace symbols
- `grn` - Rename symbol
- `gra` - Code action
- `grD` - Go to declaration

### Search (Telescope, init.lua:431-463)
- `<leader>sf` - Search files
- `<leader>sg` - Live grep
- `<leader>sw` - Search word under cursor
- `<leader>sd` - Search diagnostics
- `<leader>sh` - Search help tags
- `<leader>sn` - Search Neovim config files

### TypeScript/JavaScript (vtsls)
- `<leader>co` - Organize imports
- `<leader>cR` - Remove unused imports
- `<leader>cI` - Add missing imports

### Go Testing (neotest)
- `<leader>tt` - Run test nearest to cursor
- `<leader>tf` - Run all tests in file
- `<leader>tl` - Re-run last test
- `<leader>ts` - Toggle test summary
- `<leader>to` - Open test output
- `<leader>tO` - Toggle test output panel
- `<leader>tS` - Stop running tests

### npm Package Management (package.json only)
- `<leader>ns` - Show package versions
- `<leader>nc` - Clear version display
- `<leader>nt` - Toggle version display
- `<leader>nu` - Update package under cursor
- `<leader>nd` - Delete package under cursor
- `<leader>ni` - Install new package
- `<leader>np` - Change package version

### Markdown Preview (markview.nvim)
- `<leader>mt` - Toggle preview
- `<leader>ms` - Split preview (side-by-side)
- `<leader>mh` - Hybrid mode (edit + preview in same buffer)

### Git (diffview + gitsigns + lazygit)
- `<leader>gg` - Toggle lazygit
- `<leader>gd` - Open diff view
- `<leader>gc` - Close diff view
- `<leader>gh` - File history (current file)
- `<leader>gH` - File history (all files)
- `<leader>gm` - Diff current branch vs main
- See gitsigns.lua for git hunk keymaps (`<leader>h...`)

### Toggles
- `<leader>tf` - Toggle format on save
- `<leader>td` - Toggle diagnostics
- `<leader>th` - Toggle inlay hints
- `<leader>tc` - Toggle treesitter context
- `<leader>tx` - Toggle treesitter context (alias)

### Buffer & Navigation
- `[b` / `]b` - Previous/next buffer
- `<leader>bd` - Delete buffer
- `<leader>f` - Format buffer
- `s` - Flash jump
- `S` - Flash treesitter selection

### React Native / Expo Commands
- `:ExpoStart` - Start Expo dev server
- `:ExpoAndroid` - Start on Android
- `:ExpoIos` - Start on iOS
- `:ExpoWeb` - Start web version
- `:RNLogcat` - View Android logs
- `:RNLog` - View iOS logs

## Important Notes

### Neovim 0.11+ Breaking Changes
This configuration uses `vim.lsp.config()` which is the **new API in Neovim 0.11**. Do not use `lspconfig.server_name.setup()` as it conflicts with this approach.

### ESLint Behavior
The eslint_d linter only runs if it finds a config file (`eslint.config.js`, `eslint.config.mjs`, or `.eslintrc.js`) in the project tree. This prevents false errors in projects without ESLint.

### Filetype Associations
Custom filetype associations are defined at `init.lua:686-687`:
- `.templ` → templ
- `.slim` → slim
