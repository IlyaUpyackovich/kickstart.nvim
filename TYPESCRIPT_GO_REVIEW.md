# TypeScript/React/Go Workflow Optimization Review

Analysis for primary workflows: TypeScript (Web, React, React Native, Expo) and Go (htmx, templ)

---

## 🔴 Critical Issues for Your Workflow

### 1. **gopls Not Configured - Using Defaults**
**Current**: `vim.lsp.config('gopls', { on_attach = on_attach, capabilities = capabilities })`

**Problem**: Missing essential Go development settings like:
- Inlay hints for types/parameters
- Import organization on save
- Strict analysis settings
- Code lens for tests/benchmarks

**Fix**: Enhanced gopls configuration
```lua
vim.lsp.config('gopls', {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    gopls = {
      gofumpt = true,  -- Stricter formatting
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        fieldalignment = true,
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      semanticTokens = true,
    },
  },
})
```

**Impact**: Better Go development experience, auto-import, better diagnostics

---

### 2. **vtsls Not Configured - Using Defaults**
**Current**: `vim.lsp.config('vtsls', { on_attach = on_attach, capabilities = capabilities })`

**Problem**: Missing TypeScript/React optimizations:
- No import organization
- No unused import removal
- No React-specific settings
- Missing JSX/TSX optimizations
- No monorepo support

**Fix**: Enhanced vtsls configuration
```lua
vim.lsp.config('vtsls', {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
      },
      preferences = {
        importModuleSpecifier = 'relative',
        importModuleSpecifierEnding = 'minimal',
      },
    },
    javascript = {
      inlayHints = {
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
      },
    },
    vtsls = {
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
  },
})
```

**Impact**: Better TypeScript DX, auto-imports, better completions

---

### 3. **Missing Go Formatters**
**Current formatters_by_ft**:
```lua
formatters_by_ft = {
  lua = { 'stylua' },
  templ = {},  -- ⚠️ Empty!
  typescript = { 'prettierd', 'prettier', stop_after_first = true },
  javascript = { 'prettierd', 'prettier', stop_after_first = true },
  -- ❌ No Go formatters!
}
```

**Problem**:
- Go files won't format on save (gopls LSP fallback is used, but not optimal)
- templ files have empty formatter config
- Missing goimports/gofumpt for better Go formatting

**Fix**: Add Go formatters
```lua
formatters_by_ft = {
  lua = { 'stylua' },
  go = { 'goimports', 'gofumpt' },  -- or just 'gofumpt' (includes goimports)
  templ = { 'templ' },  -- templ has its own formatter
  typescript = { 'prettierd', 'prettier', stop_after_first = true },
  javascript = { 'prettierd', 'prettier', stop_after_first = true },
  typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
  javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
  markdown = { 'prettierd', 'prettier', stop_after_first = true },
}
```

Add to Mason ensure_installed:
```lua
ensure_installed = {
  'stylua',
  'gofumpt',      -- ⭐ Add
  'goimports',    -- ⭐ Add
  'templ',        -- ⭐ Add (formatter)
  'jsonls',
  'solargraph',
  'gopls',
  'html',
  'templ',        -- Already here (LSP)
  'emmet_ls',
  'lua_ls',
  'vtsls',
}
```

**Impact**: Consistent Go/templ formatting on save

---

### 4. **Missing React/JSX Linting**
**Current linters**: eslint_d (JS/TS), markdownlint, ruby

**Problem**:
- No React-specific linting (hooks rules, accessibility)
- eslint_d config doesn't specify React plugins

**Fix**: This is actually OK if your projects have proper `.eslintrc` with React plugins. But ensure your projects have:
```json
// .eslintrc.json or eslint.config.js
{
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "plugin:jsx-a11y/recommended"  // Accessibility
  ]
}
```

**Alternative**: Add biome as a faster alternative
```lua
-- In ensure_installed
'biome',  -- Modern linter/formatter for JS/TS (faster than ESLint)
```

---

## 🟡 High-Impact Improvements

### 5. **Add TypeScript Import Sorting**
**Problem**: No automatic import organization

**Fix**: Add organize imports keymap in LSP on_attach:
```lua
-- In on_attach function, after other keymaps
if client.name == 'vtsls' then
  map('<leader>co', function()
    vim.lsp.buf.execute_command {
      command = 'typescript.organizeImports',
      arguments = { vim.api.nvim_buf_get_name(0) },
    }
  end, '[C]ode [O]rganize Imports')

  map('<leader>cR', function()
    vim.lsp.buf.execute_command {
      command = 'typescript.removeUnused',
      arguments = { vim.api.nvim_buf_get_name(0) },
    }
  end, '[C]ode [R]emove Unused')
end
```

**Impact**: One keypress to organize all imports

---

### 6. **Add Go Test Runner**
**Problem**: No easy way to run Go tests from Neovim

**Fix**: Add neotest plugin for Go testing
```lua
{
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-go',  -- Go adapter
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require('neotest-go') {
          experimental = {
            test_table = true,
          },
          args = { '-count=1', '-timeout=60s' },
        },
      },
    }
  end,
  keys = {
    { '<leader>tt', function() require('neotest').run.run() end, desc = '[T]est [T]est nearest' },
    { '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = '[T]est [F]ile' },
    { '<leader>ts', function() require('neotest').summary.toggle() end, desc = '[T]est [S]ummary' },
    { '<leader>to', function() require('neotest').output.open({ enter = true }) end, desc = '[T]est [O]utput' },
  },
}
```

**Impact**: Run tests with `<leader>tt`, see results inline

---

### 7. **Add Package.json Scripts Runner**
**Problem**: No easy way to run npm/yarn/pnpm scripts from Neovim

**Fix**: Add package-info.nvim
```lua
{
  'vuki656/package-info.nvim',
  dependencies = 'MunifTanjim/nui.nvim',
  event = 'BufRead package.json',
  config = function()
    require('package-info').setup()
  end,
  keys = {
    { '<leader>ns', function() require('package-info').show() end, desc = '[N]pm [S]how versions' },
    { '<leader>nu', function() require('package-info').update() end, desc = '[N]pm [U]pdate package' },
    { '<leader>nd', function() require('package-info').delete() end, desc = '[N]pm [D]elete package' },
    { '<leader>ni', function() require('package-info').install() end, desc = '[N]pm [I]nstall package' },
  },
}
```

**Impact**: Manage npm packages without leaving Neovim

---

### 8. **Add Better JSX/TSX Support**
**Problem**: Basic JSX support, no React component shortcuts

**Fix**: Enhance nvim-ts-autotag (already installed) and add snippets
```lua
-- Enhance existing ts-autotag config
-- lua/custom/plugins/ts-autotag.lua
return {
  'windwp/nvim-ts-autotag',
  ft = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'html', 'templ' },
  config = function()
    require('nvim-ts-autotag').setup {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
      per_filetype = {
        ["html"] = { enable_close = true },
        ["templ"] = { enable_close = true },  -- ⭐ Add templ support
      },
    }
  end,
}
```

**Add React snippets**: LuaSnip with friendly-snippets already includes React snippets, but you can add custom ones:
```lua
-- Create lua/custom/snippets/typescriptreact.lua
local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s('rfc', {
    t('export function '),
    i(1, 'Component'),
    t('() {'),
    t({ '', '  return (' }),
    t({ '', '    <div>' }),
    i(0),
    t({ '', '    </div>' }),
    t({ '', '  )' }),
    t({ '', '}' }),
  }),
}
```

---

### 9. **Add Treesitter Context for Long Components**
**Problem**: When scrolling in long React components, you lose context of which component/function you're in

**Fix**: Add nvim-treesitter-context
```lua
{
  'nvim-treesitter/nvim-treesitter-context',
  event = 'BufReadPre',
  opts = {
    max_lines = 3,  -- Show up to 3 lines of context
    multiline_threshold = 1,
  },
  keys = {
    { '<leader>tc', function() require('treesitter-context').toggle() end, desc = '[T]oggle [C]ontext' },
  },
}
```

**Impact**: Always see which function/component you're editing

---

### 10. **Add Go Struct Tags Generator**
**Problem**: Manually writing JSON/YAML struct tags is tedious

**Fix**: Install gomodifytags via Mason
```lua
-- Add to ensure_installed
ensure_installed = {
  -- ... existing tools
  'gomodifytags',  -- ⭐ Add
}
```

Then add keymaps in LSP on_attach:
```lua
-- In on_attach function, for Go files
if client.name == 'gopls' then
  map('<leader>gj', ':GoAddTag json<CR>', '[G]o add [J]SON tags')
  map('<leader>gy', ':GoAddTag yaml<CR>', '[G]o add [Y]AML tags')
  map('<leader>gr', ':GoRmTag<CR>', '[G]o [R]emove tags')
end
```

But this requires a Go plugin. Better option: Use gopls code actions which already support this!
Just use `<leader>ca` (code action) on a struct.

---

### 11. **Add Go Error Handling Snippets**
**Problem**: Writing `if err != nil` repeatedly

**Fix**: Already have LuaSnip, add Go snippets:
```lua
-- Create lua/custom/snippets/go.lua
local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s('iferr', {
    t('if err != nil {'),
    t({ '', '\treturn ' }),
    i(1, 'err'),
    t({ '', '}' }),
  }),
}
```

Or use existing snippets from friendly-snippets (already installed).

---

### 12. **Add Better Git Integration for Feature Branch Workflow**
**Problem**: lazygit is good, but integration could be better

**Fix**: Add diffview.nvim for better diff viewing
```lua
{
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = '[G]it [D]iff view' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = '[G]it [H]istory current file' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<CR>', desc = '[G]it [H]istory all' },
  },
  opts = {},
}
```

**Impact**: Better code review workflow

---

### 13. **Add Monorepo Support**
**Problem**: If working with monorepos (common in React Native/Expo), need better project detection

**Fix**: Add project.nvim for better project management
```lua
{
  'ahmedkhalf/project.nvim',
  config = function()
    require('project_nvim').setup {
      detection_methods = { 'lsp', 'pattern' },
      patterns = { '.git', 'package.json', 'go.mod', 'Cargo.toml' },
      ignore_lsp = {},
      show_hidden = true,
    }
  end,
}
```

Then integrate with Telescope:
```lua
-- Add to Telescope setup
extensions = {
  ['ui-select'] = {
    require('telescope.themes').get_dropdown(),
  },
  projects = {},  -- ⭐ Add
},

-- After pcall extensions, add:
pcall(require('telescope').load_extension, 'projects')

-- Add keymap
vim.keymap.set('n', '<leader>sp', ':Telescope projects<CR>', { desc = '[S]earch [P]rojects' })
```

---

### 14. **Add Go Debugging (DAP)**
**Problem**: No debugging support for Go

**Fix**: Add nvim-dap with Go support
```lua
{
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'leoluz/nvim-dap-go',  -- Go adapter
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    require('dap-go').setup()
    dapui.setup()

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
  end,
  keys = {
    { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
    { '<F10>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
    { '<F11>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
    { '<F12>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = '[D]ebug: Toggle [B]reakpoint' },
    { '<leader>dt', function() require('dap-go').debug_test() end, desc = '[D]ebug: [T]est (Go)' },
  },
}
```

**Impact**: Full debugging support for Go

---

### 15. **Add React Native / Expo Specific Tools**
**Problem**: No React Native specific support

**Fix**: Add React Native snippets and detection
```lua
-- Add to init.lua after filetype associations
vim.filetype.add({
  extension = {
    mdx = 'mdx',  -- For React Native docs
  },
  pattern = {
    ['.*%.config%.js'] = 'javascript',  -- Expo configs
    ['metro%.config%.js'] = 'javascript',
    ['app%.json'] = 'jsonc',  -- Allow comments in app.json
  },
})
```

For running React Native:
```lua
-- Add to toggleterm or create custom commands
vim.api.nvim_create_user_command('ExpoStart', function()
  vim.cmd('TermExec cmd="npx expo start"')
end, {})

vim.api.nvim_create_user_command('ExpoAndroid', function()
  vim.cmd('TermExec cmd="npx expo start --android"')
end, {})

vim.api.nvim_create_user_command('ExpoIos', function()
  vim.cmd('TermExec cmd="npx expo start --ios"')
end, {})
```

---

## 🟢 Nice-to-Have Improvements

### 16. **Add Tailwind CSS IntelliSense**
If using Tailwind in React projects:
```lua
-- Add to LSP configs
vim.lsp.config('tailwindcss', {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { 'html', 'css', 'scss', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'templ' },
})

-- Add to ensure_installed
'tailwindcss',
```

### 17. **Add Better TODO Comments for Your Workflow**
Enhance existing todo-comments:
```lua
{
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    keywords = {
      FIX = { icon = ' ', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
      TODO = { icon = ' ', color = 'info' },
      HACK = { icon = ' ', color = 'warning' },
      WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
      PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
      NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
      TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
    },
  },
  keys = {
    { '<leader>st', '<cmd>TodoTelescope<CR>', desc = '[S]earch [T]odos' },
  },
}
```

### 18. **Add Better Markdown Preview for Documentation**
```lua
{
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  ft = { 'markdown' },
  build = function()
    vim.fn['mkdp#util#install']()
  end,
  keys = {
    { '<leader>mp', '<cmd>MarkdownPreviewToggle<CR>', desc = '[M]arkdown [P]review' },
  },
}
```

---

## 📊 Priority Implementation Order

### Phase 1: Critical (Do These First)
1. ✅ Enhanced gopls configuration
2. ✅ Enhanced vtsls configuration
3. ✅ Add Go formatters (gofumpt, goimports)
4. ✅ Add templ formatter

### Phase 2: High-Impact (Do These Next)
5. ✅ TypeScript import organization keymaps
6. ✅ Go test runner (neotest)
7. ✅ Treesitter context
8. ✅ Package.json manager

### Phase 3: Nice-to-Have
9. ⭕ Go debugging (DAP)
10. ⭕ Diffview for better git workflow
11. ⭕ Project.nvim for monorepos
12. ⭕ React Native commands
13. ⭕ Tailwind LSP (if used)

---

## 🎯 Workflow-Specific Keymaps Summary

After implementing, you'll have:

### TypeScript/React
- `<leader>co` - Organize imports
- `<leader>cR` - Remove unused imports
- `<leader>ns` - Show npm package versions
- `<leader>nu` - Update package
- `<leader>tt` - Run test at cursor

### Go
- `<leader>tt` - Run test at cursor
- `<leader>tf` - Run all tests in file
- `<leader>ca` - Code action (for struct tags, etc.)
- `<leader>db` - Toggle breakpoint
- `<leader>dt` - Debug test

### Git
- `<leader>gd` - Open diff view
- `<leader>gh` - File history
- `<leader>gg` - Lazygit (already have)

---

## 📝 Implementation Steps

Want me to implement these improvements? I can:
1. Create commits for each phase
2. Test configurations
3. Add all new keymaps to CLAUDE.md
4. Update REVIEW.md with workflow-specific notes

Let me know which phase you want to start with, or if you want all at once!
