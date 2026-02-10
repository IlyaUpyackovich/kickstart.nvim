# Neovim Configuration Review

## Performance Issues

### 🔴 Critical: Neo-tree Lazy Loading Broken
**Location**: `lua/kickstart/plugins/neo-tree.lua:12`
```lua
lazy = false,  -- ❌ Contradicts the lazy loading below
cmd = 'Neotree',
keys = { ... },
```
**Issue**: Setting `lazy = false` forces the plugin to load at startup, defeating the purpose of `cmd` and `keys`.

**Fix**: Remove `lazy = false` to enable lazy loading:
```lua
-- Remove line 12 entirely, keep only cmd and keys
```
**Impact**: Neo-tree and its 3 dependencies will only load when you press `\` or run `:Neotree`, saving ~50ms startup time.

---

### 🟡 Medium: Blink.cmp Loads Too Early
**Location**: `init.lua:735`
```lua
event = 'VimEnter',  -- ⚠️ Loads before needed
```
**Issue**: Completion loads at startup even if you're just viewing a file.

**Fix**: Change to load on first insert:
```lua
event = 'InsertEnter',
```
**Impact**: Saves ~30-40ms startup time if opening Neovim just to view files.

---

### 🟡 Medium: Aggressive Linting on BufEnter
**Location**: `lua/kickstart/plugins/lint.lua:45`
```lua
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
```
**Issue**: Linting on every buffer switch can cause lag when rapidly switching between files.

**Fix**: Consider removing `BufEnter`, keep only `BufWritePost` and `InsertLeave`:
```lua
vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
```
Or add debouncing for BufEnter events.

**Impact**: Reduces unnecessary lint runs, especially in multi-window workflows.

---

### 🟡 Medium: Treesitter Auto-Install on First Load
**Location**: `init.lua:904`
```lua
auto_install = true,
```
**Issue**: First time opening a new filetype triggers a download during editing, causing a pause.

**Fix**: Either:
1. Explicitly list all parsers you use in `ensure_installed`
2. Keep auto_install but be aware of the behavior

**Impact**: Prevents unexpected delays during editing sessions.

---

## LSP Configuration Issues

### 🟡 Medium: Mason-LSPConfig May Conflict with vim.lsp.config
**Location**: `init.lua:670` and `init.lua:594-668`

**Issue**: You're using the new Neovim 0.11 `vim.lsp.config()` API but also calling `require('mason-lspconfig').setup()` without configuration. Mason-lspconfig is designed for the old lspconfig API.

**Fix**: Either:
1. Let Mason only install, configure manually with vim.lsp.config (current approach - OK)
2. Or fully use mason-lspconfig with handlers (more automatic)

**Current approach is fine**, but document this in code comments to avoid confusion.

---

### 🔴 Critical: No LSP Server Auto-Start
**Location**: `init.lua:594-668`

**Issue**: After configuring servers with `vim.lsp.config()`, they don't auto-start. You need to call `vim.lsp.enable(server_name)` or rely on Mason to start them.

**Fix**: Add after all server configs:
```lua
-- Auto-enable all configured LSP servers
local servers = { 'gopls', 'vtsls', 'solargraph', 'templ', 'jsonls', 'html', 'emmet_ls', 'lua_ls' }
for _, server in ipairs(servers) do
  vim.lsp.enable(server)
end
```

**Verify this is working**: Open a .ts file and run `:LspInfo`. If no servers are attached, this is the issue.

---

### 🟢 Low: Missing Error Handling in safe_telescope
**Location**: `init.lua:507-514`

**Current**: Returns a function that catches errors but doesn't provide context.

**Enhancement**:
```lua
local function safe_telescope(fn, name)
  return function()
    local ok, err = pcall(fn)
    if not ok then
      vim.notify('LSP: ' .. name .. ' - ' .. tostring(err), vim.log.levels.WARN)
    end
  end
end
```

---

## Usability Issues

### 🟡 Medium: Missing Useful Keymaps

**1. No LSP Restart Keymap**
Add to LSP on_attach:
```lua
map('<leader>lr', '<cmd>LspRestart<CR>', 'LSP [R]estart')
```

**2. No Buffer Navigation**
Add to init.lua keymaps section:
```lua
vim.keymap.set('n', '[b', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = '[B]uffer [D]elete' })
```

**3. No Diagnostic Toggle**
Add to init.lua:
```lua
vim.keymap.set('n', '<leader>td', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = '[T]oggle [D]iagnostics' })
```

**4. No Format-on-Save Toggle**
Add global variable and toggle:
```lua
vim.g.disable_autoformat = false

vim.keymap.set('n', '<leader>tf', function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify('Format on save: ' .. (vim.g.disable_autoformat and 'OFF' or 'ON'))
end, { desc = '[T]oggle [F]ormat on save' })
```

Then update conform config:
```lua
format_on_save = function(bufnr)
  if vim.g.disable_autoformat then return nil end
  -- ... rest of logic
end,
```

---

### 🔴 Critical: Gitsigns Typo - Wrong Undo Keybind
**Location**: `lua/kickstart/plugins/gitsigns.lua:47`

```lua
map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
```
**Issue**: Says "undo stage" but actually stages. Should be `undo_stage_hunk`.

**Fix**:
```lua
map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
```

---

### 🟢 Low: No Quick Access to Lazy Plugin Manager
Add keymap:
```lua
vim.keymap.set('n', '<leader>l', '<cmd>Lazy<CR>', { desc = 'Open [L]azy plugin manager' })
```

---

## Code Quality Issues

### 🟢 Low: Mixed Language Comments
**Location**: `init.lua:497-558`

Russian comments make collaboration harder:
```lua
-- Эта функция будет вызываться для каждого LSP-сервера при его подключении к буферу.
-- Мы перенесли сюда всю логику из твоего старого LspAttach autocommand.
```

**Fix**: Translate to English for consistency with the rest of the config.

---

### 🟢 Low: vim.env.ESLINT_D_PPID Not Explained
**Location**: `lua/kickstart/plugins/lint.lua:1`

```lua
vim.env.ESLINT_D_PPID = vim.fn.getpid()
```

**Fix**: Add comment explaining why (prevents eslint_d from using wrong Neovim instance):
```lua
-- Set PPID for eslint_d to ensure it uses the correct Neovim instance
vim.env.ESLINT_D_PPID = vim.fn.getpid()
```

---

## Missing Features Worth Adding

### 🟢 EditorConfig Support
Many projects use `.editorconfig`. Add:
```lua
{ 'editorconfig/editorconfig-vim' }
```

### 🟢 Better Navigation with Flash
For blazing fast cursor movement:
```lua
{
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {},
  keys = {
    { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
    { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
  },
}
```

### 🟢 Session Persistence
Auto-save session per directory:
```lua
{
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {},
  keys = {
    { '<leader>qs', function() require('persistence').load() end, desc = 'Restore Session' },
    { '<leader>ql', function() require('persistence').load({ last = true }) end, desc = 'Restore Last Session' },
  },
}
```

### 🟢 Better Quickfix List
```lua
{ 'kevinhwang91/nvim-bqf', ft = 'qf' }
```

### 🟢 Indent Detection (Instead of vim-sleuth)
Consider replacing tpope/vim-sleuth with:
```lua
{
  'nmac427/guess-indent.nvim',
  opts = {},
}
```
It's Lua-native and more actively maintained.

---

## Best Practices Not Followed

### 🟡 Use Protected Calls for Plugin Setup
**Current**: Direct requires can error on first install.

**Fix**: Wrap critical setups:
```lua
local ok, telescope = pcall(require, 'telescope')
if not ok then
  vim.notify('Telescope not installed', vim.log.levels.ERROR)
  return
end
```

### 🟢 Add Which-Key Group Definitions
You have some groups defined, but missing:
```lua
spec = {
  { '<leader>s', group = '[S]earch' },
  { '<leader>t', group = '[T]oggle' },
  { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  -- Add these:
  { '<leader>l', group = '[L]SP' },
  { '<leader>g', group = '[G]it' },
  { '<leader>b', group = '[B]uffer' },
  { '<leader>q', group = '[Q]uit/Session' },
},
```

---

## Configuration Conflicts

### 🟡 Gitsigns Configured Twice
**Locations**: `init.lua:276-287` and `lua/kickstart/plugins/gitsigns.lua`

**Current**: Base config in init.lua, keymaps in kickstart plugin.

**Better**: Move everything to kickstart plugin file for consistency, remove from init.lua.

---

## Summary Priority List

**Must Fix (Critical)**:
1. ✅ Neo-tree lazy loading (`lazy = false` removal)
2. ✅ Gitsigns undo keybind typo
3. ⚠️ Verify LSP servers auto-start (add vim.lsp.enable if needed)

**Should Fix (High Impact)**:
4. ✅ blink.cmp load on InsertEnter instead of VimEnter
5. ✅ Add format-on-save toggle
6. ✅ Add diagnostic toggle
7. ✅ Remove BufEnter from lint events

**Nice to Have**:
8. ✅ Add buffer navigation keymaps
9. ✅ Add LSP restart keymap
10. ✅ Add flash.nvim for better navigation
11. ✅ Translate Russian comments
12. ✅ Add editorconfig support
13. ✅ Consolidate gitsigns config

**Consider**:
- Session persistence plugin
- Better quickfix plugin
- Protected requires for robustness
