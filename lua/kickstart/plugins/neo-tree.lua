-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  init = function()
    -- Disable netrw to prevent conflicts with neo-tree
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- Auto-open neo-tree when starting with a directory
    vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = function()
        local arg = vim.fn.argv(0)
        local is_dir = arg ~= '' and vim.fn.isdirectory(arg) == 1
        if is_dir then
          vim.cmd 'Neotree show'
        end
      end,
    })
  end,
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
