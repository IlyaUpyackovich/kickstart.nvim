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
- gopls (Go)
- vtsls (TypeScript/JavaScript)
- solargraph (Ruby)
- templ (Templ templates)
- jsonls (JSON with schema validation)
- html (HTML)
- emmet_ls (Emmet for HTML/CSS/Templ/React)
- lua_ls (Lua)

### Formatting & Linting
- **Formatter**: `conform.nvim` (`init.lua:692-731`)
  - Format on save enabled (500ms timeout, LSP fallback)
  - Configured formatters: stylua (Lua), prettier/prettierd (TS/JS/JSX/TSX/Markdown)
  - Keybinding: `<leader>f` to format buffer
- **Linter**: `nvim-lint` (`lua/kickstart/plugins/lint.lua`)
  - eslint_d (JS/TS with dynamic config detection)
  - markdownlint (Markdown)
  - ruby (Ruby)

### Autocompletion
- Uses `blink.cmp` (not nvim-cmp) with LuaSnip for snippets (`init.lua:733-832`)

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

### Custom Features
- `<leader>gg` - Toggle lazygit (toggleterm plugin)
- `<leader>f` - Format buffer
- `<leader>th` - Toggle inlay hints

## Important Notes

### Neovim 0.11+ Breaking Changes
This configuration uses `vim.lsp.config()` which is the **new API in Neovim 0.11**. Do not use `lspconfig.server_name.setup()` as it conflicts with this approach.

### ESLint Behavior
The eslint_d linter only runs if it finds a config file (`eslint.config.js`, `eslint.config.mjs`, or `.eslintrc.js`) in the project tree. This prevents false errors in projects without ESLint.

### Filetype Associations
Custom filetype associations are defined at `init.lua:686-687`:
- `.templ` → templ
- `.slim` → slim
