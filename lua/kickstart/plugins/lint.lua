vim.env.ESLINT_D_PPID = vim.fn.getpid()

return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- Function to find the directory containing eslint.config.js
      -- Walks up from the current file
      local function find_eslint_config_dir(bufnr)
        local current_file_path = vim.api.nvim_buf_get_name(bufnr)
        if not current_file_path or current_file_path == '' then
          return nil
        end
        local start_path = vim.fs.dirname(current_file_path)
        local config_files = vim.fs.find({ 'eslint.config.js', 'eslint.config.mjs', '.eslintrc.js' }, {
          upward = true,
          stop = vim.loop.os_homedir(),
          path = start_path,
          type = 'file',
          limit = 1,
        })
        if config_files and #config_files > 0 then
          return vim.fs.dirname(config_files[1])
        else
          return nil
        end
      end

      -- Define linters for specific file types
      -- CWD for eslint_d will be set dynamically below
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        javascript = { 'eslint_d' },
        typescript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
        ruby = { 'ruby' },
      }

      -- Create autocmd for running linting
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function(args)
          -- Run only for modifiable buffers
          if vim.opt_local.modifiable:get() then
            local current_bufnr = args.buf
            local ft = vim.bo[current_bufnr].filetype

            if ft == 'javascript' or ft == 'typescript' or ft == 'javascriptreact' or ft == 'typescriptreact' then
              if lint.linters.eslint_d then
                local eslint_cwd = find_eslint_config_dir(current_bufnr)
                if eslint_cwd then
                  lint.linters.eslint_d.cwd = eslint_cwd
                  lint.try_lint()
                else
                  return
                end
              end
            else
              lint.try_lint()
            end
          end
        end,
        desc = 'Run linters configured via nvim-lint',
      })
    end,
  },
}
