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
      local function make_claude_toggle(cmd)
        local term = Terminal:new {
          cmd = cmd,
          direction = 'vertical',
          close_on_exit = false,
          hidden = true,
          on_open = function(t)
            vim.cmd 'startinsert!'
            vim.api.nvim_buf_set_keymap(t.bufnr, 't', '<esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
            vim.api.nvim_buf_set_keymap(t.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
          end,
        }
        local pane_id = nil

        local function tmux_pane_exists(id)
          if not id or id == '' then
            return false
          end
          return vim.system({ 'tmux', 'display-message', '-p', '-t', id, '#{pane_id}' }):wait().code == 0
        end

        return function()
          if vim.env.TMUX then
            if tmux_pane_exists(pane_id) then
              local check = vim.system({ 'tmux', 'display-message', '-p', '-t', pane_id, '#{window_id}' }):wait()
              local pane_win = vim.trim(check.stdout)
              local cur_win = vim.trim(vim.system({ 'tmux', 'display-message', '-p', '#{window_id}' }):wait().stdout)
              if pane_win == cur_win then
                vim.system { 'tmux', 'break-pane', '-d', '-s', pane_id }
              else
                vim.system { 'tmux', 'join-pane', '-h', '-l', '50%', '-s', pane_id }
              end
              return
            end
            pane_id = nil
            local result = vim.system({ 'tmux', 'split-window', '-h', '-l', '50%', '-P', '-F', '#{pane_id}', cmd }):wait()
            if result.code == 0 then
              local id = vim.trim(result.stdout)
              if id ~= '' then
                pane_id = id
              end
            end
          else
            term:toggle()
          end
        end
      end

      local claude_toggle = make_claude_toggle 'claude'
      local claude_yolo_toggle = make_claude_toggle 'claude --dangerously-skip-permissions'

      -- Keybindings
      vim.keymap.set('n', '<leader>gg', '<cmd>lua _lazygit_toggle()<CR>', {
        noremap = true,
        silent = true,
        desc = '[G]it [G]it (lazygit)',
      })

      vim.keymap.set('n', '<leader>cc', claude_toggle, {
        desc = '[C]laude [C]ode',
      })

      vim.keymap.set('n', '<leader>cC', claude_yolo_toggle, {
        desc = '[C]laude [C]ode (skip permissions)',
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
