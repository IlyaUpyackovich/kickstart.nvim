-- Устанавливаем переменную для управления демоном eslint_d (хорошая практика)
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
        -- Если буфер не имеет имени (например, новый файл), используем CWD Neovim
        if not current_file_path or current_file_path == '' then
          return vim.fn.getcwd()
        end
        local start_path = vim.fs.dirname(current_file_path)
        -- Ищем eslint.config.js вверх по дереву
        local config_files = vim.fs.find('eslint.config.js', {
          upward = true,
          stop = vim.loop.os_homedir(), -- Останавливаемся в домашней директории
          path = start_path,
          type = 'file',
          limit = 1, -- Нам нужен только первый найденный
        })
        if config_files and #config_files > 0 then
          -- Возвращаем директорию, где найден конфиг
          return vim.fs.dirname(config_files[1])
        else
          -- Если не нашли, возвращаем CWD Neovim как запасной вариант
          return vim.fn.getcwd()
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

            -- Проверяем, является ли тип файла одним из тех, для которых используется eslint_d
            if ft == 'javascript' or ft == 'typescript' or ft == 'javascriptreact' or ft == 'typescriptreact' then
              -- Только для этих типов файлов ищем конфиг и обновляем cwd для eslint_d
              -- Проверяем, существует ли линтер eslint_d в конфигурации
              if lint.linters.eslint_d then
                local eslint_cwd = find_eslint_config_dir(current_bufnr)
                lint.linters.eslint_d.cwd = eslint_cwd
                -- Опционально: можно добавить отладочное сообщение
                -- print("Set eslint_d CWD for buffer " .. current_bufnr .. " to: " .. eslint_cwd)
              end
            end

            -- Запускаем линтинг для текущего буфера
            -- lint.try_lint() сам определит, какой линтер использовать (если есть)
            -- на основе filetype и таблицы lint.linters_by_ft
            lint.try_lint()
          end
        end,
        desc = 'Run linters configured via nvim-lint', -- Описание для :autocmd lint
      })
    end,
  },
}
