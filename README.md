# Personal Neovim Configuration

> A production-ready Neovim setup optimized for TypeScript/React/React Native/Expo and Go/htmx/templ development.

**Based on**: [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
**Neovim Version**: 0.11+ required

---

## Quick Start

```bash
# Clone this config
git clone <your-repo-url> ~/.config/nvim

# Start Neovim - plugins will auto-install
nvim

# Open a directory
nvim .
```

That's it! The config will automatically install all plugins and LSP servers.

---

## Table of Contents

- [Beginner Guide](#beginner-guide) - Getting started, basic usage
- [Intermediate Guide](#intermediate-guide) - Customization, workflows
- [Advanced Guide](#advanced-guide) - Deep customization, troubleshooting
- [Keybindings Cheat Sheet](#keybindings-cheat-sheet)
- [FAQ](#faq)

---

# Beginner Guide

## What You Get Out of the Box

### Language Support
- **TypeScript/JavaScript**: Full IntelliSense, auto-imports, inline type hints
- **React/React Native**: JSX support, component navigation, Expo commands
- **Go**: Inline hints, test runner, formatting with goimports + gofumpt
- **Ruby**: Solargraph LSP
- **HTML/CSS**: Emmet snippets, auto-completion
- **Lua**: Neovim config editing with full LSP

### Key Features
- **Smart Completion**: Type-aware auto-completion with snippets
- **Fuzzy Finding**: Find files, text, symbols instantly (Telescope)
- **Git Integration**: Visual diffs, commit history, lazygit terminal
- **Test Runner**: Run Go tests inline with results in split window
- **Markdown Preview**: Live preview with math, diagrams, emoji support
- **Format on Save**: Auto-format files when you save (toggleable)
- **Syntax Highlighting**: Treesitter-powered semantic highlighting

### Navigation Basics

**Leader Key**: `Space` (all commands start with space)

#### Essential Keybindings

| Key | Action |
|-----|--------|
| `Space` + `s` + `f` | **Search Files** - Find any file in project |
| `Space` + `s` + `g` | **Search Text** - Find text across all files |
| `Space` + `s` + `h` | **Search Help** - Find Neovim help docs |
| `g` + `r` + `d` | **Go to Definition** - Jump to where code is defined |
| `g` + `r` + `r` | **Find References** - See all usages of symbol |
| `Space` + `f` | **Format File** - Auto-format current file |
| `\\` (backslash) | **Toggle File Tree** - Show/hide file explorer |

#### Moving Around

| Key | Action |
|-----|--------|
| `Ctrl` + `d` | Scroll down half page |
| `Ctrl` + `u` | Scroll up half page |
| `{` / `}` | Jump to previous/next paragraph |
| `%` | Jump to matching bracket/tag |
| `s` + `<letter>` | **Flash jump** - Jump to any visible word instantly |

#### Editing Basics

| Key | Action |
|-----|--------|
| `i` | Insert mode (start typing) |
| `Esc` | Normal mode (exit insert) |
| `v` | Visual mode (select text) |
| `d` + `d` | Delete line |
| `y` + `y` | Copy line |
| `p` | Paste |
| `u` | Undo |
| `Ctrl` + `r` | Redo |

### First Steps

1. **Open Neovim**: `nvim .` (opens file tree)
2. **Navigate files**: Use arrow keys or `j`/`k`, press `Enter` to open
3. **Search for file**: Press `Space` → `s` → `f`, start typing filename
4. **Find text**: Press `Space` → `s` → `g`, type what you're looking for
5. **Get help**: Press `Space` → `s` → `h`, search for any Neovim command

### Tips for Beginners

- **Don't memorize everything** - Use `Space` + `s` + `h` to search keybindings
- **File tree auto-opens** when you run `nvim .`
- **Auto-completion pops up** as you type - use `Tab`/`Shift-Tab` to navigate, `Enter` to accept
- **Errors/warnings** appear in left margin - hover cursor over them for details
- **Format on save is enabled** - your code auto-formats when you save (`:w`)

---

# Intermediate Guide

## Customizing the Config

### Adding Plugins

**Option 1: Modify init.lua directly** (line ~250)

```lua
-- Add to the plugin array
{
  'author/plugin-name',
  dependencies = { 'required-plugin' },
  opts = {
    -- plugin configuration
  },
}
```

**Option 2: Create custom plugin file** (recommended)

```bash
# Create new plugin file
nvim ~/.config/nvim/lua/custom/plugins/my-plugin.lua
```

```lua
-- Content of my-plugin.lua
return {
  'author/plugin-name',
  config = function()
    require('plugin-name').setup {}
  end,
}
```

Restart Neovim or run `:Lazy sync` to install.

### Language-Specific Workflows

#### TypeScript/React Development

**Key Commands**:
- `Space` + `c` + `o` - Organize imports (remove unused, sort)
- `Space` + `c` + `R` - Remove unused imports
- `Space` + `c` + `I` - Add missing imports

**Package Management** (package.json):
- `Space` + `n` + `s` - Show available versions inline
- `Space` + `n` + `u` - Update package under cursor
- `Space` + `n` + `p` - Change package version (picker)
- `Space` + `n` + `i` - Install new package

**React Native/Expo**:
- `:ExpoStart` - Start dev server
- `:ExpoAndroid` - Launch on Android
- `:ExpoIos` - Launch on iOS
- `:RNLogcat` - View Android logs

**Pro tip**: Enable exact package versions (no `^` prefix):
```bash
npm config set save-exact true
```

#### Go Development

**Testing**:
- `Space` + `t` + `t` - Run test at cursor
- `Space` + `t` + `f` - Run all tests in file
- `Space` + `t` + `s` - Toggle test summary window
- `Space` + `t` + `o` - Show test output

**Format on Save**: Enabled by default
- Runs `goimports` (organize imports) + `gofumpt` (strict formatting)
- Toggle with `Space` + `t` + `f`

**Inline Hints**: Type information shown inline
- Toggle with `Space` + `t` + `h`

#### Markdown Editing

**Preview Modes**:
- `Space` + `m` + `t` - Toggle preview (in-buffer rendering)
- `Space` + `m` + `s` - Split preview (side-by-side)
- `Space` + `m` + `h` - Hybrid mode (edit + preview simultaneously)

**Features**:
- LaTeX math rendering: `$E = mc^2$` or `$$...$$`
- GitHub callouts: `> [!NOTE]`, `> [!WARNING]`
- Emoji shortcodes: `:rocket:` → 🚀
- Tables, checkboxes, code blocks with syntax highlighting

### Git Workflows

**Visual Diffs**:
- `Space` + `g` + `d` - Open diff view
- `Space` + `g` + `c` - Close diff view
- `Space` + `g` + `h` - File history (current file)
- `Space` + `g` + `H` - File history (all files)

**Lazygit Terminal**:
- `Space` + `g` + `g` - Open lazygit (full git TUI)

**Git Hunks** (use `Space` + `h` + ...):
- `s` - Stage hunk
- `u` - Unstage hunk
- `r` - Reset hunk
- `p` - Preview hunk
- `b` - Blame line

### Workspace Management

**Buffers** (open files):
- `[b` / `]b` - Previous/next buffer
- `Space` + `b` + `d` - Delete buffer (close file)

**Windows** (splits):
- `Ctrl` + `w` + `v` - Vertical split
- `Ctrl` + `w` + `s` - Horizontal split
- `Ctrl` + `w` + `h/j/k/l` - Navigate between splits
- `Ctrl` + `w` + `=` - Make splits equal size

**Toggles**:
- `Space` + `t` + `f` - Toggle format on save
- `Space` + `t` + `d` - Toggle diagnostics (errors/warnings)
- `Space` + `t` + `h` - Toggle inlay hints
- `Space` + `t` + `c` - Toggle sticky context header

---

# Advanced Guide

## Architecture Overview

### Plugin System
- **Manager**: lazy.nvim (lazy-loads plugins on-demand)
- **Core plugins**: Defined in `init.lua` (~1400 lines)
- **Kickstart plugins**: `lua/kickstart/plugins/*.lua`
- **Custom plugins**: `lua/custom/plugins/*.lua` (auto-imported)

### LSP System (Neovim 0.11+)
This config uses Neovim's **new built-in LSP API** (`vim.lsp.config()`), not `lspconfig.setup()`.

**Configured Servers**:
- `gopls` (Go)
- `vtsls` (TypeScript/JavaScript)
- `solargraph` (Ruby)
- `templ` (Templ templates)
- `jsonls`, `html`, `emmet_ls`, `lua_ls`

**To add a new LSP server**:
1. Add to `ensure_installed` in mason-tool-installer (init.lua:~730)
2. Configure: `vim.lsp.config('server', { on_attach = on_attach, capabilities = capabilities })`
3. Enable: `vim.lsp.enable('server')`
4. Test: `:LspInfo`

### Formatting System
- **Plugin**: conform.nvim
- **Format on save**: Enabled (500ms timeout, LSP fallback)
- **Configured formatters**:
  - `stylua` (Lua)
  - `goimports` + `gofumpt` (Go, sequential)
  - `prettierd` or `prettier` (TS/JS/Markdown)
  - `templ` (Templ templates)

**To add a formatter**:
1. Install via Mason: `:Mason` → search → install
2. Add to `formatters_by_ft` in init.lua (~line 839):
   ```lua
   filetype = { 'formatter-name' },
   ```
3. Test: Open file, run `Space` + `f`, check `:ConformInfo`

### Linting System
- **Plugin**: nvim-lint
- **Config**: `lua/kickstart/plugins/lint.lua`
- **Triggers**: `BufWritePost`, `InsertLeave` (NOT `BufEnter`)
- **Configured linters**:
  - `eslint_d` (JS/TS, only if config file exists)
  - `markdownlint` (Markdown, global config: `~/.markdownlintrc`)
  - `ruby` (Ruby)

### Completion System
- **Plugin**: blink.cmp (NOT nvim-cmp)
- **Snippet engine**: LuaSnip
- **Sources**: LSP, path, snippets, buffer
- **Keymaps**: `Ctrl-Space` (show), `Tab/Shift-Tab` (navigate), `Enter` (accept)

## Troubleshooting

### LSP Not Working

**Check LSP status**:
```vim
:LspInfo
```

Should show server attached to buffer. If not:

**Check Mason**:
```vim
:Mason
```

Verify LSP server is installed (green checkmark).

**Check logs**:
```vim
:lua vim.cmd('edit ' .. vim.lsp.get_log_path())
```

### Formatter Not Running

**Check formatter**:
```vim
:ConformInfo
```

Shows available formatters for current file type.

**Test manually**:
```vim
:lua vim.lsp.buf.format()
```

If this works but save doesn't, check format-on-save toggle:
```vim
:lua print(vim.g.disable_autoformat)
```

Should be `nil` or `false`. If `true`, toggle with `Space` + `t` + `f`.

### Plugin Not Loading

**Check lazy.nvim**:
```vim
:Lazy
```

Find plugin, check if loaded. Press `?` for help.

**Check for errors**:
```vim
:messages
```

Shows recent errors.

### Performance Issues

**Check startup time**:
```bash
nvim --startuptime startup.log
```

Review `startup.log` for slow plugins.

**Profile**:
```vim
:Lazy profile
```

## Extending the Config

### Project-Specific Settings

Create `.nvim.lua` in project root:

```lua
-- Example: Enable different LSP settings for this project
vim.lsp.config('gopls', {
  settings = {
    gopls = {
      buildFlags = { '-tags=integration' },
    },
  },
})
```

The `nvim-config-local` plugin auto-loads these files.

### Custom Keybindings

Add to `init.lua` (after plugin specs, ~line 110):

```lua
vim.keymap.set('n', '<leader>x', '<cmd>YourCommand<cr>', { desc = 'Your command' })
```

Or in custom plugin file:
```lua
return {
  'plugin-name',
  keys = {
    { '<leader>x', '<cmd>YourCommand<cr>', desc = 'Your command' }
  },
}
```

### Custom Snippets

Create `~/.config/nvim/snippets/<filetype>.lua`:

```lua
local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s('fn', {
    t('function '), i(1, 'name'), t('('), i(2), t(') {'),
    t({ '', '\t' }), i(0),
    t({ '', '}' }),
  }),
}
```

## Maintenance

**Update plugins**:
```vim
:Lazy update
```

**Update LSP servers**:
```vim
:Mason
```

Press `U` to update all.

**Check health**:
```vim
:checkhealth
```

Diagnoses common issues.

**Sync after pulling changes**:
```vim
:Lazy sync
```

Installs new plugins, removes deleted ones.

---

# Keybindings Cheat Sheet

## Leader Key: `Space`

### Search (Telescope)
| Key | Action |
|-----|--------|
| `<leader>sf` | Search Files |
| `<leader>sg` | Search Grep (text) |
| `<leader>sw` | Search Word under cursor |
| `<leader>sd` | Search Diagnostics |
| `<leader>sh` | Search Help |
| `<leader>sn` | Search Neovim config |

### LSP
| Key | Action |
|-----|--------|
| `grd` | Go to Definition |
| `gri` | Go to Implementation |
| `grr` | Find References |
| `grn` | Rename Symbol |
| `gra` | Code Action |
| `gO` | Document Symbols |

### TypeScript/JavaScript
| Key | Action |
|-----|--------|
| `<leader>co` | Organize Imports |
| `<leader>cR` | Remove Unused Imports |
| `<leader>cI` | Add Missing Imports |

### Go Testing
| Key | Action |
|-----|--------|
| `<leader>tt` | Test at cursor |
| `<leader>tf` | Test file |
| `<leader>tl` | Re-run last test |
| `<leader>ts` | Toggle test summary |

### npm Packages (package.json)
| Key | Action |
|-----|--------|
| `<leader>ns` | Show versions |
| `<leader>nu` | Update package |
| `<leader>np` | Change version |
| `<leader>ni` | Install new |

### Markdown
| Key | Action |
|-----|--------|
| `<leader>mt` | Toggle preview |
| `<leader>ms` | Split preview |
| `<leader>mh` | Hybrid mode |

### Git
| Key | Action |
|-----|--------|
| `<leader>gg` | Lazygit |
| `<leader>gd` | Diff view |
| `<leader>gh` | File history |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |

### Toggles
| Key | Action |
|-----|--------|
| `<leader>tf` | Format on save |
| `<leader>td` | Diagnostics |
| `<leader>th` | Inlay hints |
| `<leader>tc` | Sticky context |

### Navigation
| Key | Action |
|-----|--------|
| `\\` | Toggle file tree |
| `[b` / `]b` | Prev/next buffer |
| `<leader>bd` | Delete buffer |
| `s` | Flash jump |

### Editing
| Key | Action |
|-----|--------|
| `<leader>f` | Format file |
| `gcc` | Toggle comment line |
| `gc` + motion | Comment motion |

---

# FAQ

### How do I change the colorscheme?

Edit `init.lua` (~line 1018):
```lua
'folke/tokyonight.nvim', -- Change this line to another theme plugin
```

Popular alternatives:
- `'catppuccin/nvim'`
- `'rebelot/kanagawa.nvim'`
- `'EdenEast/nightfox.nvim'`

Then update the `vim.cmd.colorscheme` line (~1031).

### How do I disable format on save?

**Temporarily** (per session): `Space` + `t` + `f`

**Permanently**: Edit `init.lua` (~line 873):
```lua
format_on_save = false, -- Change to false
```

### How do I add a new language?

1. **Treesitter** (syntax): Add to `ensure_installed` (~line 1216)
2. **LSP** (IntelliSense): See [Advanced Guide → LSP System](#lsp-system-neovim-011)
3. **Formatter**: See [Advanced Guide → Formatting System](#formatting-system)
4. **Linter**: Edit `lua/kickstart/plugins/lint.lua`

### How do I use this with VSCode?

Use the [VSCode Neovim extension](https://github.com/vscode-neovim/vscode-neovim). However, this config is designed for terminal Neovim - many plugins won't work in VSCode.

### Can I use this config on Windows?

Yes, but some tools require additional setup:
- Install via [Scoop](https://scoop.sh/) or [Chocolatey](https://chocolatey.org/)
- Use WSL2 for best compatibility
- See Kickstart's Windows install notes

### Where are plugins stored?

`~/.local/share/nvim/lazy/` - managed by lazy.nvim

### How do I backup my config?

```bash
# Backup
tar -czf nvim-backup.tar.gz ~/.config/nvim ~/.local/share/nvim

# Restore
tar -xzf nvim-backup.tar.gz -C ~/
```

### How do I uninstall?

```bash
# Remove config
rm -rf ~/.config/nvim

# Remove data (plugins, state)
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

---

## Resources

- **Neovim Docs**: `:help` or [neovim.io/doc](https://neovim.io/doc/)
- **Lua Guide**: `:help lua-guide`
- **Plugin Docs**: Check each plugin's GitHub README
- **Kickstart**: [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)

---

## License

MIT
