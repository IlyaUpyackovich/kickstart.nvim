vim.env.ESLINT_D_PPID = vim.fn.getpid()

return {
  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' }, -- События для загрузки плагина
    config = function()
      local lint = require 'lint'

      -- Функция для поиска директории, содержащей eslint.config.js
      -- Поднимается вверх от текущего файла
      local function find_eslint_config_dir(bufnr)
        local current_file_path = vim.api.nvim_buf_get_name(bufnr)
        if not current_file_path or current_file_path == '' then
          return nil
        end
        local start_path = vim.fs.dirname(current_file_path)
        local config_files = vim.fs.find({ 'eslint.config.js', 'eslint.config.mjs' }, {
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

      -- Определяем линтеры для конкретных типов файлов
      -- CWD для eslint_d будет установлен динамически ниже
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        javascript = { 'eslint_d' },
        typescript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
      }

      -- Создаем автокоманду для запуска линтинга
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function(args)
          -- Выполняем только для изменяемых буферов
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
