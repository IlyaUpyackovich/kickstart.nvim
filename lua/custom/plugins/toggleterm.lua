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

      local toggleterm_terminal = require 'toggleterm.terminal'
      local Terminal = toggleterm_terminal.Terminal

      local shell_terminals = {}
      local active_shell = 0

      local function create_shell()
        local number = #shell_terminals + 1
        local term = Terminal:new {
          direction = 'horizontal',
          display_name = ('shell %d'):format(number),
        }

        shell_terminals[number] = term
        active_shell = number
        return term
      end

      local function current_shell()
        return shell_terminals[active_shell] or create_shell()
      end

      local function show_shell(number, direction)
        local target = shell_terminals[number]
        if not target then
          return
        end

        for index, term in ipairs(shell_terminals) do
          if index ~= number and term:is_open() then
            term:close()
          end
        end

        active_shell = number
        if target:is_open() then
          target:focus()
        else
          target:open(nil, direction or 'horizontal')
        end
      end

      local function toggle_shell(direction)
        current_shell():toggle(nil, direction)
      end

      local function new_shell()
        create_shell()
        show_shell(active_shell, 'horizontal')
      end

      local function select_shell()
        if #shell_terminals == 0 then
          vim.notify('No terminal instances yet', vim.log.levels.INFO)
          return
        end

        vim.ui.select(shell_terminals, {
          prompt = 'Select terminal instance:',
          format_item = function(term)
            return term.display_name
          end,
        }, function(_, index)
          if index then
            show_shell(index, 'horizontal')
          end
        end)
      end

      local function cycle_shell(offset)
        if #shell_terminals == 0 then
          vim.notify('No terminal instances yet', vim.log.levels.INFO)
          return
        end

        local number = ((active_shell - 1 + offset) % #shell_terminals) + 1
        show_shell(number, 'horizontal')
      end

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
        vim.system { 'tmux', 'new-window', '-n', 'claude', '/Users/ilya/.claude/bin/claude-with-secrets' }
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
        vim.system {
          'tmux',
          'new-window',
          '-n',
          'codex',
          '/Users/ilya/.codex/bin/codex-with-secrets',
        }
      end

      vim.keymap.set('n', '<leader>cc', claude_open, {
        desc = '[C]laude [C]ode',
      })

      vim.keymap.set('n', '<leader>cC', codex_open, {
        desc = '[C]odex',
      })

      vim.keymap.set('n', '<leader>ct', function()
        toggle_shell 'horizontal'
      end, {
        desc = '[C]ode [T]erminal horizontal',
      })

      vim.keymap.set('n', '<leader>cv', function()
        toggle_shell 'vertical'
      end, {
        desc = '[C]ode [V]ertical terminal',
      })

      vim.keymap.set('n', '<leader>cf', function()
        toggle_shell 'float'
      end, {
        desc = '[C]ode [F]loating terminal',
      })

      vim.keymap.set('n', '<leader>cn', new_shell, {
        desc = '[C]ode [N]ew terminal instance',
      })

      vim.keymap.set('n', '<leader>cs', select_shell, {
        desc = '[C]ode [S]elect terminal instance',
      })

      vim.keymap.set('n', '<leader>c]', function()
        cycle_shell(1)
      end, {
        desc = '[C]ode next terminal instance',
      })

      vim.keymap.set('n', '<leader>c[', function()
        cycle_shell(-1)
      end, {
        desc = '[C]ode previous terminal instance',
      })
    end,
  },
}
