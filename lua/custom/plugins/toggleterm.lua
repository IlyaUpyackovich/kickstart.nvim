return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        close_on_exit = true,
      }

      local Terminal = require('toggleterm.terminal').Terminal
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

      vim.keymap.set('n', '<leader>gg', '<cmd>lua _lazygit_toggle()<CR>', {
        noremap = true,
        silent = true,
        desc = 'Lazygit Toggle (Custom Instance)',
      })
    end,
  },
}
