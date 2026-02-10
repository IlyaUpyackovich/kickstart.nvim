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
        end,
      }

      function _lazygit_toggle()
        lazygit_terminal:toggle()
      end

      -- Claude Code terminal (new - persistent session)
      local claude = Terminal:new {
        cmd = 'claude',
        direction = 'vertical',
        close_on_exit = false, -- Session persists when hidden
        hidden = true,
        on_open = function(term)
          vim.cmd 'startinsert!'
          vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
        end,
      }

      function _claude_toggle()
        claude:toggle()
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

      -- Easy terminal navigation
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts) -- Esc to exit insert mode
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      end

      vim.cmd 'autocmd! TermOpen term://* lua set_terminal_keymaps()'
    end,
  },
}
