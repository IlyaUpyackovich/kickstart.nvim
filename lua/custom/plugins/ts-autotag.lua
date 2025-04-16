return {
  'windwp/nvim-ts-autotag',
  ft = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'html' },
  config = function()
    require('nvim-ts-autotag').setup {
      -- enable_rename = true,
      -- enable_close = true,
      -- enable_close_on_slash = true,
    }
  end,
}
