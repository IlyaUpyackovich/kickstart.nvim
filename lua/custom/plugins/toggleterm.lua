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

      -- Claude Code: tmux split pane (preferred) or toggleterm fallback
      local claude_toggleterm = Terminal:new {
        cmd = 'claude',
        direction = 'vertical',
        close_on_exit = false,
        hidden = true,
        on_open = function(term)
          vim.cmd 'startinsert!'
          vim.api.nvim_buf_set_keymap(term.bufnr, 't', '<esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
        end,
      }

      local claude_pane_id = nil

      function _claude_toggle()
        if vim.env.TMUX then
          if claude_pane_id then
            -- Check if pane is alive (direct exec, no shell)
            local check = vim.system({ 'tmux', 'display-message', '-p', '-t', claude_pane_id, '#{window_id}' }):wait()
            if check.code == 0 then
              local pane_win = vim.trim(check.stdout)
              local cur_win = vim.trim(vim.system({ 'tmux', 'display-message', '-p', '#{window_id}' }):wait().stdout)
              if pane_win == cur_win then
                vim.system { 'tmux', 'break-pane', '-d', '-s', claude_pane_id }
              else
                vim.system { 'tmux', 'join-pane', '-h', '-l', '50%', '-s', claude_pane_id }
              end
              return
            end
            claude_pane_id = nil
          end
          local result = vim.system({ 'tmux', 'split-window', '-h', '-l', '50%', '-P', '-F', '#{pane_id}', 'claude' }):wait()
          claude_pane_id = vim.trim(result.stdout)
        else
          -- Not in tmux: fall back to toggleterm
          claude_toggleterm:toggle()
        end
      end

      -- Keybindings
      vim.keymap.set('n', '<leader>gg', '<cmd>lua _lazygit_toggle()<CR>', {
        noremap = true,
        silent = true,
        desc = '[G]it [G]it (lazygit)',
      })

      vim.keymap.set('n', '<leader>cc', '<cmd>lua _claude_toggle()<CR>', {
        noremap = true,
        silent = true,
        desc = '[C]laude [C]ode',
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
