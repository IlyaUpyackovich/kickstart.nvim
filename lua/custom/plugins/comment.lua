return {
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      local pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()

      require('Comment').setup {
        pre_hook = pre_hook,
      }
    end,
  },

  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },
}
