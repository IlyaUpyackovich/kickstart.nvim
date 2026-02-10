# CLAUDE.md - AI Agent Context

This file provides architectural context and conventions for AI agents working on this Neovim configuration.

## Repository Context

**Type**: Personal Neovim configuration
**Base**: Kickstart.nvim (single-file init.lua + modular extensions)
**User Workflow**: TypeScript/React/React Native/Expo + Go/htmx/templ development
**Neovim Version**: 0.11+ (uses new LSP API)

## Architecture Principles

### Single-File Core + Modular Extensions
- **Core**: `init.lua` contains all essential configuration (~1400 lines)
- **Kickstart plugins**: `lua/kickstart/plugins/*.lua` (optional components)
- **Custom plugins**: `lua/custom/plugins/*.lua` (auto-imported, user-specific)
- **Rationale**: Easy to share core config while allowing personal customization

### Plugin Management (lazy.nvim)
- All plugins lazy-load by default (cmd, keys, ft, event triggers)
- Exception: Colorscheme and markview.nvim (lazy = false but optimized)
- Always check existing lazy-loading strategy before modifying plugins
- Use `ft = { 'filetype' }` for language-specific plugins

### LSP Configuration (Neovim 0.11+ API)
**CRITICAL**: This config uses `vim.lsp.config()` (new 0.11+ API), NOT `lspconfig.setup()`.

```lua
-- Correct (new API):
vim.lsp.config('server_name', {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = { ... }
})
vim.lsp.enable('server_name') -- Explicitly enable

-- Wrong (old API, will conflict):
require('lspconfig').server_name.setup { ... }
```

**Why**: Neovim 0.11 deprecated lspconfig's `setup()` in favor of built-in `vim.lsp.config()`. Using both causes conflicts.

**LSP Servers Configured** (init.lua:594-668):
- gopls (Go) - Full config: inlay hints, staticcheck, gofumpt, codelenses
- vtsls (TypeScript) - Full config: inlay hints, auto-imports, organize imports
- solargraph (Ruby), templ, jsonls, html, emmet_ls, lua_ls

**Common on_attach** (init.lua:499-558):
- Sets up LSP keymaps (grd, gri, grr, grn, gra, etc.)
- Enables document highlighting on CursorHold
- Toggles inlay hints based on user preference
- Special handling for vtsls (TypeScript import commands)

### Formatting (conform.nvim)
- **Format-on-save**: Enabled by default (500ms timeout, LSP fallback)
- **Toggleable**: `<leader>tf` to disable per-session
- **Formatter priority**: External formatter → LSP formatter → no-op
- **Configured formatters** (init.lua:839-847):
  - stylua (Lua)
  - goimports + gofumpt (Go) - applied in sequence
  - templ (templ templates)
  - prettierd/prettier (TS/JS/JSX/TSX/Markdown) - stop_after_first

### Linting (nvim-lint)
- Location: `lua/kickstart/plugins/lint.lua`
- Triggers: BufWritePost, InsertLeave (NOT BufEnter, to reduce noise)
- **eslint_d**: Only runs if config file exists (.eslintrc.js, eslint.config.js, etc.)
- **markdownlint**: Global config at `~/.markdownlintrc` (relaxed rules)

### Completion (blink.cmp)
- **Not nvim-cmp** - uses blink.cmp (faster, async)
- Snippets: LuaSnip
- Sources: LSP, path, snippets, buffer
- Keymaps: `<C-Space>` show, `<C-e>` hide, `<Tab>/<S-Tab>` navigate, `<CR>` accept

## Workflow-Specific Features

### TypeScript/React/React Native
- **LSP**: vtsls (not tsserver) with full inlay hints
- **Import management**: `<leader>co` organize, `<leader>cR` remove unused, `<leader>cI` add missing
- **Package management**: package-info.nvim (npm version inline display, `<leader>n*` commands)
- **React Native**: Custom commands `:ExpoStart`, `:ExpoAndroid`, `:ExpoIos`, `:RNLogcat`
- **Note**: User prefers exact versions without `^` prefix (configure npm: `save-exact=true`)

### Go Development
- **LSP**: gopls with gofumpt, staticcheck, fieldalignment analysis
- **Formatters**: goimports (organize imports) + gofumpt (stricter formatting)
- **Testing**: neotest-go for inline test execution (`<leader>tt`, `<leader>tf`)
- **Templ templates**: Full support (templ LSP + formatter + emmet)

### Git Workflow
- **diffview**: Side-by-side diffs (`<leader>gd`), file history (`<leader>gh`)
- **lazygit**: Terminal integration (`<leader>gg`)
- **gitsigns**: Hunk management (`<leader>h*` commands)

### Markdown Editing
- **markview.nvim**: In-buffer rendering with hybrid mode
- **Modes**: Toggle (`<leader>mt`), split (`<leader>ms`), hybrid (`<leader>mh`)
- **Features**: LaTeX math, GitHub emojis, tables, callouts, treesitter-based
- **Note**: Must load after colorscheme (lazy = false)

## Making Changes Safely

### Adding LSP Servers
1. Add to `ensure_installed` in mason-tool-installer (init.lua:~730)
2. Configure with `vim.lsp.config('name', { on_attach = on_attach, capabilities = capabilities, ... })`
3. Call `vim.lsp.enable('name')` to activate
4. Test with `:LspInfo` and `:checkhealth`

### Adding Plugins
- **Core plugins**: Add directly to init.lua plugin array (line ~250)
- **Custom plugins**: Create `lua/custom/plugins/name.lua` (auto-imported)
- **Always**: Use lazy-loading (cmd, keys, ft, event)
- **Pattern**: Look at existing plugins for lazy.nvim spec examples

### Adding Formatters
1. Add to mason-tool-installer `ensure_installed` if available via Mason
2. Add filetype mapping to `conform.nvim` formatters_by_ft (init.lua:~839)
3. Test: Open file of that type, run `<leader>f`, check `:ConformInfo`

### Adding Linters
1. Edit `lua/kickstart/plugins/lint.lua`
2. Add to `linters_by_ft` table
3. Configure linter if needed (see eslint_d example for complex config)
4. Test: Open file, trigger lint event, check diagnostics

### Modifying Keybindings
- **LSP keymaps**: Defined in on_attach function (init.lua:~499-558)
- **Plugin keymaps**: Defined in plugin spec's `keys` table (lazy-loaded)
- **Global keymaps**: Defined after plugin specs (init.lua:~110-220)
- **Convention**: Use `<leader>` prefix, descriptive names like `[T]est [F]ile`

## Common Patterns

### Plugin Spec Structure
```lua
{
  'author/plugin-name',
  dependencies = { 'required-plugin' },
  cmd = { 'Command' }, -- Lazy-load on command
  keys = { -- Lazy-load on keymap
    { '<leader>xy', '<cmd>Command<cr>', desc = 'Description' }
  },
  ft = { 'filetype' }, -- Lazy-load on filetype
  event = { 'BufReadPost' }, -- Lazy-load on event
  opts = { ... }, -- Passed to setup() automatically
  config = function()
    require('plugin').setup { ... } -- Manual setup
  end,
}
```

### Adding Language Support
1. Add treesitter parser to `ensure_installed` (init.lua:~1216)
2. Add LSP server (see "Adding LSP Servers" above)
3. Add formatter to conform.nvim
4. Add linter to nvim-lint (optional)
5. Add to Mason ensure_installed for auto-install

## Project Conventions

### File Organization
- Keep init.lua focused on core config
- Extract complex plugins to `lua/kickstart/plugins/` if sharable
- Put personal plugins in `lua/custom/plugins/`
- Document architectural changes in this file

### Commit Messages
- Use conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`
- Include `Co-Authored-By: Claude <model> <noreply@anthropic.com>`
- Keep individual commits focused (one fix per commit preferred)

### Testing Changes
- **Quick**: `:source %` for Lua files (doesn't reload plugins)
- **Plugins**: Restart Neovim or `:Lazy reload <plugin-name>`
- **LSP**: `:LspRestart` after config changes
- **Full**: Close and reopen Neovim

### User Preferences
- No emojis in code/commits (unless explicitly requested)
- Exact package versions (no `^` prefix in package.json)
- Minimal, focused changes (avoid over-engineering)
- Format on save enabled by default
- Inlay hints enabled for TypeScript and Go

## Critical Notes

### Neo-tree Auto-Open
- Opens automatically on `nvim .` via VimEnter autocmd
- netrw is disabled globally (`vim.g.loaded_netrw = 1`)
- Do not re-enable netrw or add `lazy = false` (causes duplicate windows)

### Package-info Highlights
- Uses `highlights` option (NOT `colors` - deprecated)
- Format: `{ up_to_date = { fg = '#hex' } }` (table, not string)

### Markdownlint Configuration
- Global config at `~/.markdownlintrc` (relaxed: no line length, blank line rules)
- Applies to all projects, not just this one

### Treesitter Context
- Shows sticky headers for functions/components at top of window
- Toggle with `<leader>tc` or `<leader>tx`
- Useful for long TypeScript/Go files

## External Dependencies

**Required**:
- Neovim 0.11+ (for vim.lsp.config API)
- Git (for lazy.nvim)
- Node.js + npm (for TypeScript tooling, package-info)
- Go (for gopls, goimports, gofumpt)

**Optional**:
- fd (faster file finding for Telescope)
- ripgrep (faster grep for Telescope)
- lazygit (git TUI)
- prettierd (faster prettier formatting)
- Nerd Font (for icons)

## Reference Locations

**Key Files**:
- `init.lua` - Main configuration (~1400 lines)
- `lua/kickstart/plugins/*.lua` - Modular plugin configs
- `lua/custom/plugins/*.lua` - User-specific plugins
- `~/.markdownlintrc` - Global markdown linting config

**Key Line Ranges in init.lua**:
- Plugin specs: ~250-1400
- Options: ~110-160
- Keymaps: ~160-220
- LSP on_attach: ~499-558
- LSP servers: ~594-668
- Mason tool installer: ~720-770
- Conform formatters: ~839-847
- Blink.cmp: ~733-832
- Treesitter: ~1200-1240

## When in Doubt

1. **Read existing code** before suggesting changes
2. **Preserve lazy-loading** strategies
3. **Test in isolated way** before committing
4. **Ask user** if change affects workflow significantly
5. **Follow Neovim 0.11 API** (vim.lsp.config, not lspconfig.setup)
