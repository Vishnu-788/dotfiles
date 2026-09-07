local autocmd = vim.api.nvim_create_autocmd

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
local augroup = vim.api.nvim_create_augroup
local greeting_group = augroup("CustomGreeting", { clear = true })

local function show_greeting()
   local ok, alpha = pcall(require, "alpha")
   if ok then
      alpha.start(false)
   else
      vim.cmd("Alpha")
   end
end

autocmd("VimEnter", {
   group = greeting_group,
   callback = function()
      local is_empty = vim.fn.argc() == 0 and vim.api.nvim_buf_line_count(0) == 1 and
          vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == ""
      local is_dir = vim.fn.isdirectory(vim.fn.expand("%:p")) == 1

      if is_empty or is_dir then
         show_greeting()
      end
   end,
})

autocmd("BufDelete", {
   group = greeting_group,
   callback = function()
      vim.schedule(function()
         local buffers = vim.fn.getbufinfo({ buflisted = 1 })

         if #buffers == 0 then
            show_greeting()
         end
      end)
   end,
})

autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
   group = lint_augroup,
   callback = function()
      require("lint").try_lint()
   end,
})

autocmd("CursorHold", {
   callback = function()
      vim.diagnostic.open_float(nil, { focus = false })
   end,
})


autocmd("ColorScheme", {
   pattern = "*",
   callback = function()
      vim.api.nvim_set_hl(0, "Visual", { bg = "#3d3458", fg = "NONE" })
      vim.api.nvim_set_hl(0, 'WinSeparator', { fg = 'NONE', bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'VertSplit', { fg = 'NONE', bg = 'NONE' })
   end,
})

autocmd('LspAttach', {
   callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == 'jdtls' and client.server_capabilities.semanticTokensProvider then
         vim.lsp.semantic_tokens.enable(false, { bufnr = args.buf })
      end
   end,
})
