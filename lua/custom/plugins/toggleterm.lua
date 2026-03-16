return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        size = function(term)
          if term.direction == 'horizontal' then
            return 15
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]], -- Ctrl-\ to toggle last terminal
        hide_numbers = true,
        shade_terminals = false,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = 'horizontal',
        close_on_exit = false, -- Keep terminals alive when process exits
        shell = vim.o.shell,
        float_opts = {
          border = 'curved',
          width = 120,
          height = 30,
        },
        on_open = function(term)
          -- Esc exits terminal insert mode for generic terminals
          vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], { buffer = term.bufnr })
        end,
      }

      local Terminal = require('toggleterm.terminal').Terminal

      -- Lazygit terminal (existing)
      local lazygit_terminal = Terminal:new {
        cmd = 'lazygit',
        hidden = true,
        direction = 'float',
        dir = vim.fn.getcwd(),
        close_on_exit = true,
        float_opts = {
          border = 'double',
          width = function()
            return math.floor(vim.o.columns * 0.9)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.9)
          end,
        },
        on_open = function(term)
          vim.cmd 'startinsert!'
          -- Don't map Esc here — lazygit needs it for cancel/return
        end,
      }

      function _lazygit_toggle()
        lazygit_terminal:toggle()
      end

      -- Claude Code: always open new session in tmux window
      local function claude_open()
        if not vim.env.TMUX then
          vim.notify('Claude Code requires tmux', vim.log.levels.WARN)
          return
        end
        vim.system { 'tmux', 'new-window', '-n', 'claude', 'claude --dangerously-skip-permissions' }
      end

      -- Keybindings
      vim.keymap.set('n', '<leader>gg', '<cmd>lua _lazygit_toggle()<CR>', {
        noremap = true,
        silent = true,
        desc = '[G]it [G]it (lazygit)',
      })

      -- Codex: open new session in tmux window
      local function codex_open()
        if not vim.env.TMUX then
          vim.notify('Codex requires tmux', vim.log.levels.WARN)
          return
        end
        vim.system { 'tmux', 'new-window', '-n', 'codex', 'codex' }
      end

      vim.keymap.set('n', '<leader>cc', claude_open, {
        desc = '[C]laude [C]ode',
      })

      vim.keymap.set('n', '<leader>cC', codex_open, {
        desc = '[C]odex',
      })

      vim.keymap.set('n', '<leader>ct', '<cmd>ToggleTerm direction=horizontal<CR>', {
        noremap = true,
        silent = true,
        desc = '[C]ode [T]erminal horizontal',
      })

      vim.keymap.set('n', '<leader>cv', '<cmd>ToggleTerm direction=vertical<CR>', {
        noremap = true,
        silent = true,
        desc = '[C]ode [V]ertical terminal',
      })

      vim.keymap.set('n', '<leader>cf', '<cmd>ToggleTerm direction=float<CR>', {
        noremap = true,
        silent = true,
        desc = '[C]ode [F]loating terminal',
      })
    end,
  },
}
